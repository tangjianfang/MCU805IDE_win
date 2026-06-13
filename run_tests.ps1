# run_tests.ps1 - Automated regression tests for MCU 8051 IDE
# Called by run_tests.bat
# Tests assembler CLI against expected output files in src/regression_tests/

param(
    [string]$ProjectDir = $PSScriptRoot,
    [switch]$KeepOutput
)

$IdeExe     = Join-Path $ProjectDir "build\mcu8051ide.exe"
$TestDir    = Join-Path $ProjectDir "src\regression_tests"
$TempBase   = Join-Path $env:TEMP "mcu8051ide_tests"
$Pass = 0; $Fail = 0; $Skip = 0

Write-Host "============================================================"
Write-Host "MCU 8051 IDE - Automated Regression Tests"
Write-Host "============================================================"
Write-Host ""

# ---- Check IDE exe ----
if (-not (Test-Path $IdeExe)) {
    Write-Host "ERROR: mcu8051ide.exe not found." -ForegroundColor Red
    Write-Host "Please run build_exe.bat first."
    exit 1
}

# ---- Get version ----
$VerLine = & $IdeExe --version 2>&1 | Select-String "IDE v"
Write-Host "IDE Version:  $VerLine"
Write-Host "Test dir:     $TestDir"
Write-Host "Temp output:  $TempBase"
Write-Host ""

# ---- Create temp dir ----
if (Test-Path $TempBase) { Remove-Item $TempBase -Recurse -Force }
New-Item $TempBase -ItemType Directory | Out-Null

# ===========================================================
# Helper: compare file contents ignoring CRLF vs LF
# ===========================================================
function Compare-Contents($file1, $file2) {
    $a = (Get-Content $file1) -join "`n"
    $b = (Get-Content $file2) -join "`n"
    return $a -eq $b
}

# Helper: compare only address+opcode lines in .lst files
# (skips page header, symbol table - only lines like "0000 7455  3  mov ...")
function Compare-LstCode($file1, $file2) {
    $pattern = '^\s+[0-9A-Fa-f]{4}'
    $a = (Get-Content $file1 | Where-Object { $_ -match $pattern }) -join "`n"
    $b = (Get-Content $file2 | Where-Object { $_ -match $pattern }) -join "`n"
    return $a -eq $b
}

# Helper: parse .in file for extra CLI options
# Skips blank lines and lines whose non-whitespace content starts with #
function Get-TestOptions($inFile) {
    if (-not (Test-Path $inFile)) { return @() }
    $lines = Get-Content $inFile
    return $lines | Where-Object {
        $t = $_.Trim()
        $t -ne "" -and -not $t.StartsWith("#")
    }
}

# ===========================================================
# ASSEMBLER TESTS
# ===========================================================

Write-Host "---- Assembler Tests ----------------------------------------"
$AsmCases = Join-Path $TestDir "assembler\testcases"

Get-ChildItem "$AsmCases\*.asm" | ForEach-Object {
    $tname = $_.BaseName
    $tout  = Join-Path $TempBase $tname
    New-Item $tout -ItemType Directory -Force | Out-Null

    # Copy source to temp dir (IDE writes output alongside input)
    Copy-Item $_.FullName "$tout\$($_.Name)"

    # Read extra CLI options from .in file
    $inFile     = Join-Path $AsmCases "$tname.in"
    $extraOpts  = Get-TestOptions $inFile
    $asmArgs    = @("--assemble", "$tout\$($_.Name)", "--nocolor", "--no-sim") + $extraOpts

    # Run assembler
    & $IdeExe @asmArgs 2>&1 | Out-Null
    $casePassed = $true

    # Compare HEX
    $hexExp = Join-Path $AsmCases "$tname.hex.exp"
    $hexOut = Join-Path $tout "$tname.hex"
    if (Test-Path $hexExp) {
        if (-not (Test-Path $hexOut)) {
            Write-Host "  [FAIL] $tname" -ForegroundColor Red
            Write-Host "         Reason: hex file not generated"
            $casePassed = $false
        } elseif (-not (Compare-Contents $hexOut $hexExp)) {
            Write-Host "  [FAIL] $tname" -ForegroundColor Red
            Write-Host "         Reason: hex content mismatch"
            Write-Host "         Got:      $(Get-Content $hexOut | Select-Object -First 1)"
            Write-Host "         Expected: $(Get-Content $hexExp | Select-Object -First 1)"
            $casePassed = $false
        }
    }

    # Compare LST (code section only)
    $lstExp = Join-Path $AsmCases "$tname.lst.exp"
    $lstOut = Join-Path $tout "$tname.lst"
    if ((Test-Path $lstExp) -and (Test-Path $lstOut)) {
        if (-not (Compare-LstCode $lstOut $lstExp)) {
            Write-Host "  [FAIL] $tname" -ForegroundColor Red
            Write-Host "         Reason: lst code section mismatch"
            $casePassed = $false
        }
    }

    if ($casePassed) {
        Write-Host "  [PASS] $tname" -ForegroundColor Green
        $script:Pass++
    } else {
        $script:Fail++
    }
}

Write-Host ""
Write-Host "---- Simulator Tests ----------------------------------------"
$SimCases = Join-Path $TestDir "simulator\testcases"

Get-ChildItem "$SimCases\*.in" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  [SKIP] $($_.BaseName) (requires m4 preprocessor - Linux only)" -ForegroundColor Yellow
    $script:Skip++
}

# ===========================================================
# SDCC PIPELINE TESTS (polling + marker matching)
# ===========================================================

Write-Host ""
Write-Host "---- SDCC Pipeline Tests ------------------------------------"

$TestsDir   = Join-Path $ProjectDir "tests"
$Tclsh      = Join-Path $ProjectDir "resources\freewrap\freewrapTCLSH32.exe"
$Lf2Crlf    = Join-Path $ProjectDir "src\pkgs\Windows\lf2crlf.vbs"

if (-not (Test-Path $Tclsh)) {
    Write-Host "  [SKIP] freewrapTCLSH32.exe not found" -ForegroundColor Yellow
    $script:Skip += 2
} else {
    foreach ($tclTest in @("test_regex_red_green.tcl", "test_sdcc_polling.tcl")) {
        $srcTcl  = Join-Path $TestsDir $tclTest
        $crlfTcl = "$srcTcl.crlf"
        if (-not (Test-Path $srcTcl)) {
            Write-Host "  [SKIP] $tclTest (file missing)" -ForegroundColor Yellow
            $script:Skip++
            continue
        }
        # freewrapTCLSH32 is a Windows exe; source must be CRLF
        & cscript //nologo $Lf2Crlf $srcTcl $crlfTcl 2>&1 | Out-Null
        Move-Item -Force $crlfTcl $srcTcl

        $out = & $Tclsh $srcTcl 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [PASS] $tclTest" -ForegroundColor Green
            $script:Pass++
        } else {
            Write-Host "  [FAIL] $tclTest" -ForegroundColor Red
            $out | ForEach-Object { Write-Host "         $_" }
            $script:Fail++
        }
    }
}

# ===========================================================
# C COMPILER TESTS (SDCC, external toolchain)
# ===========================================================

Write-Host ""
Write-Host "---- C Compiler Tests (SDCC) --------------------------------"

# Find SDCC: PATH, then common install locations
$SdccExe = $null
foreach ($p in @(
    (Get-Command sdcc.exe -ErrorAction SilentlyContinue).Source
    "C:\Program Files\SDCC\bin\sdcc.exe"
    "C:\Program Files (x86)\SDCC\bin\sdcc.exe"
    "D:\Program Files\SDCC\bin\sdcc.exe"
)) {
    if ($p -and (Test-Path $p)) { $SdccExe = $p; break }
}

if (-not $SdccExe) {
    Write-Host "  [SKIP] SDCC not found. Install from https://sdcc.sourceforge.net/" -ForegroundColor Yellow
    Get-ChildItem "$TestDir\c_compiler\testcases\*.c" | ForEach-Object { $script:Skip++ }
} else {
    $SdccDir = Split-Path -Parent $SdccExe
    Write-Host "  SDCC found: $SdccExe"

    Get-ChildItem "$TestDir\c_compiler\testcases\*.c" | ForEach-Object {
        $tname = $_.BaseName
        $tout  = Join-Path $TempBase "c_$tname"
        New-Item $tout -ItemType Directory -Force | Out-Null
        Copy-Item $_.FullName "$tout\$($_.Name)"

        # Prepend SDCC bin to PATH so sdcc finds cc1
        $env:PATH = "$SdccDir;$env:PATH"

        # SDCC writes outputs to the current working directory
        Push-Location $tout
        try {
            & $SdccExe -mmcs51 $_.Name 2>&1 | Out-Null
        } finally {
            Pop-Location
        }

        $casePassed = $true
        $ihx = Join-Path $tout "$tname.ihx"
        if (-not (Test-Path $ihx)) {
            Write-Host "  [FAIL] $tname" -ForegroundColor Red
            Write-Host "         Reason: .ihx not generated"
            $casePassed = $false
        } else {
            $recs = Get-Content $ihx | Where-Object { $_ -match '^:[0-9A-Fa-f]{8,}$' }
            if (-not $recs -or $recs.Count -lt 2) {
                Write-Host "  [FAIL] $tname" -ForegroundColor Red
                Write-Host "         Reason: invalid Intel HEX records"
                $casePassed = $false
            } elseif ($recs[-1] -notmatch '^:00000001FF$') {
                Write-Host "  [FAIL] $tname" -ForegroundColor Red
                Write-Host "         Reason: missing EOF record"
                $casePassed = $false
            }
        }

        if ($casePassed) {
            Write-Host "  [PASS] $tname" -ForegroundColor Green
            $script:Pass++
        } else {
            $script:Fail++
        }
    }
}

# ===========================================================
# SUMMARY
# ===========================================================

$Total = $Pass + $Fail
Write-Host ""
Write-Host "============================================================"
if ($Fail -gt 0) {
    Write-Host "Results:  $Pass passed,  $Fail FAILED,  $Skip skipped  (total: $Total)" -ForegroundColor Red
} else {
    Write-Host "Results:  $Pass passed,  0 failed,  $Skip skipped  (total: $Total)" -ForegroundColor Green
}
Write-Host "============================================================"
Write-Host ""

if (-not $KeepOutput) {
    Remove-Item $TempBase -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "Output preserved: $TempBase"
    Write-Host ""
}

if ($Fail -gt 0) {
    Write-Host "*** SOME TESTS FAILED ***" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All tests passed." -ForegroundColor Green
    exit 0
}
