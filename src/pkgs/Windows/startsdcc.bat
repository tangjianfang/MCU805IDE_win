@echo off
rem ============================================================
rem startsdcc.bat - Run SDCC compiler from MCU 8051 IDE on Windows
rem Called by ::ExternalCompiler::compile_C in external_compiler.tcl.
rem
rem Usage: startsdcc.bat <work_dir> <sdcc_opts...> <input_file>
rem   work_dir   - directory to cd into before invoking sdcc
rem   sdcc_opts  - arguments to pass through to sdcc
rem   input_file - C source file
rem
rem SDCC must be on PATH, OR located in one of these common install
rem locations. We auto-detect and add it to PATH so the child sdcc
rem process can find its helpers (sdcpp.exe, sdas8051.exe, etc.).
rem
rem Diagnostic log is written to %USERPROFILE%\.mcu8051ide_compile.log
rem to help debug issues when the IDE's DDE pipe doesn't connect.
rem ============================================================

rem Initialize diagnostic log early so we can capture every step
if defined USERPROFILE (
    set "DIAG_LOG=%USERPROFILE%\.mcu8051ide_compile.log"
) else (
    set "DIAG_LOG=startsdcc_diag.log"
)
echo [%date% %time%] === startsdcc.bat v3 (iram/xram/code-size-fix + DDE error log) invoked === > "%DIAG_LOG%"
echo [%date% %time%] argv: %* >> "%DIAG_LOG%"

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

rem ---- Find SDCC bin directory ----
SET "SDCC_BIN="

rem First, check if sdcc is already on PATH
WHERE sdcc.exe >nul 2>&1
IF !ERRORLEVEL! EQU 0 (
    echo [%date% %time%] SDCC found on PATH >> "%DIAG_LOG%"
    GOTO :HaveSDCC
)

rem Not on PATH - try common install locations
FOR %%D IN (
    "%ProgramFiles%\SDCC\bin"
    "%ProgramFiles(x86)%\SDCC\bin"
    "%ProgramW6432%\SDCC\bin"
    "D:\Program Files\SDCC\bin"
    "D:\Program Files (x86)\SDCC\bin"
    "C:\SDCC\bin"
    "D:\SDCC\bin"
) DO (
    IF EXIST "%%~D\sdcc.exe" (
        SET "SDCC_BIN=%%~D"
        echo [%date% %time%] SDCC found at %%~D >> "%DIAG_LOG%"
        GOTO :HaveSDCC
    )
)

rem Not found anywhere - emit a clear error so the IDE message panel
rem shows what went wrong instead of appearing to hang silently.
echo.
echo ============================================================
echo SDCC compiler not found.
echo.
echo Searched:
echo   - System PATH
echo   - %ProgramFiles%\SDCC\bin
echo   - %ProgramFiles(x86)%\SDCC\bin
echo   - %ProgramW6432%\SDCC\bin
echo   - D:\Program Files\SDCC\bin
echo   - D:\Program Files (x86)\SDCC\bin
echo   - C:\SDCC\bin
echo   - D:\SDCC\bin
echo.
echo Please install SDCC 4.x from:
echo   https://sdcc.sourceforge.net/
echo Or add your SDCC bin directory to the system PATH and restart
echo MCU 8051 IDE.
echo ============================================================
echo.
echo [%date% %time%] SDCC NOT FOUND - aborting with exit 127 >> "%DIAG_LOG%"
EXIT /B 127

:HaveSDCC
IF DEFINED SDCC_BIN (
    SET "PATH=!SDCC_BIN!;%PATH%"
    echo [%date% %time%] Updated PATH with !SDCC_BIN! >> "%DIAG_LOG%"
)

rem ---- Change to work directory and run sdcc ----
IF "%~1"=="" (
    echo [%date% %time%] ERROR: missing work_dir argument >> "%DIAG_LOG%"
    ECHO startsdcc.bat: missing work_dir argument 1>&2
    EXIT /B 1
)
echo [%date% %time%] cd /d %~1 >> "%DIAG_LOG%"
cd /d "%~1"
echo [%date% %time%] now in %CD% >> "%DIAG_LOG%"
SHIFT

rem Reassemble remaining args into args variable.
rem Use delayed expansion (!args!) so the loop correctly accumulates
rem across iterations - the original used %args% which is parsed
rem before each SET and never grows beyond the first iteration.
SET "args="
:Loop
IF "%~1"=="" GOTO :Continue
SET "args=!args! %~1"
SHIFT
GOTO :Loop

:Continue
echo [%date% %time%] invoking: sdcc -mmcs51 !args! >> "%DIAG_LOG%"
sdcc -mmcs51 %args%
SET "RC=!ERRORLEVEL!"
echo [%date% %time%] sdcc returned !RC! >> "%DIAG_LOG%"
EXIT /B %RC%
