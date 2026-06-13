# test_real_compile.ps1
# Drives the real mcu8051ide.exe GUI: launches with the test project,
# forces the window to foreground, then sends F11 (compile hotkey) and
# watches the .mcu8051ide_compile.log + .mcu8051ide_sdcc_output.log
# to see what the real polling path actually does.

$ErrorActionPreference = "Stop"

$exe        = "C:\tjf\github\MCU805IDE_win\build\mcu8051ide.exe"
$project    = "C:\tjf\123.mcu8051ide"
$work_dir   = "C:\tjf\testcases"
$log_path   = Join-Path $work_dir ".mcu8051ide_sdcc_output.log"
$diag_log   = Join-Path $env:USERPROFILE ".mcu8051ide_compile.log"

# Clean logs
Remove-Item -Force $log_path -ErrorAction SilentlyContinue
Remove-Item -Force $diag_log -ErrorAction SilentlyContinue

# Add Win32 helpers
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int n);
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int w, int h, bool repaint);
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    [DllImport("kernel32.dll")]
    public static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")]
    public static extern IntPtr GetTopWindow(IntPtr hWnd);
}
"@ -ReferencedAssemblies System.Windows.Forms

Add-Type -AssemblyName System.Windows.Forms

# Kill any prior instance
Get-Process mcu8051ide -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# Launch
Write-Host "Launching IDE..."
$proc = Start-Process -FilePath $exe -ArgumentList "--open-project",$project,"--no-plugins","--nosplash" -PassThru
Write-Host "  PID: $($proc.Id)"

# Wait for the window to appear
$hwnd = [IntPtr]::Zero
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Milliseconds 500
    $p = Get-Process -Id $proc.Id -ErrorAction SilentlyContinue
    if ($p -and $p.MainWindowHandle -ne 0) {
        $hwnd = $p.MainWindowHandle
        Write-Host "  Window appeared after $($i * 500)ms (hwnd=$hwnd)"
        break
    }
}
if ($hwnd -eq [IntPtr]::Zero) {
    Write-Host "  ERROR: window never appeared"
    exit 1
}

# Force foreground using AttachThreadInput trick
[W]::ShowWindow($hwnd, 3) | Out-Null
[W]::MoveWindow($hwnd, 0, 0, 1200, 800, $true) | Out-Null
$ourThread = [W]::GetCurrentThreadId()
$ideThread = [W]::GetWindowThreadProcessId($hwnd, [ref]0)
[W]::AttachThreadInput($ourThread, $ideThread, $true) | Out-Null
[W]::BringWindowToTop($hwnd) | Out-Null
[W]::SetForegroundWindow($hwnd) | Out-Null
[W]::AttachThreadInput($ourThread, $ideThread, $false) | Out-Null
Start-Sleep -Milliseconds 800
$fg = [W]::GetForegroundWindow()
Write-Host "  Foreground: $fg (ide: $hwnd)  match=$($fg -eq $hwnd)"

# Send F11
Write-Host "Sending F11 (compile)..."
[System.Windows.Forms.SendKeys]::SendWait('{F11}')

# Watch the logs for 10 seconds
Write-Host "Watching logs for 10 seconds..."
$deadline = (Get-Date).AddSeconds(10)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500
    $diagExists = Test-Path $diag_log
    $sdccExists = Test-Path $log_path
    Write-Host "  [$([int]((Get-Date) - $deadline).TotalSeconds*-1)s] diag=$diagExists sdcc=$sdccExists"
    if ($sdccExists) {
        $sz = (Get-Item $log_path).Length
        if ($sz -gt 0 -and (Select-String -Path $log_path -Pattern "^SDCC_DONE" -Quiet)) {
            Write-Host "  SDCC_DONE marker found in log!"
            break
        }
    }
}

# Final report
Write-Host ""
Write-Host "============================================================"
Write-Host "REAL IDE COMPILE TEST RESULT"
Write-Host "============================================================"
Write-Host "Diag log: $diag_log"
if (Test-Path $diag_log) {
    Write-Host "--- diag log content ---"
    Get-Content $diag_log | ForEach-Object { Write-Host "  $_" }
}
Write-Host ""
Write-Host "SDCC output log: $log_path"
if (Test-Path $log_path) {
    Write-Host "--- last 5 lines ---"
    Get-Content $log_path -Tail 5 | ForEach-Object { Write-Host "  $_" }
    $has = Select-String -Path $log_path -Pattern "^SDCC_DONE" -Quiet
    Write-Host "  has SDCC_DONE: $has"
} else {
    Write-Host "  (file does not exist)"
}
Write-Host "============================================================"

# Cleanup
Get-Process mcu8051ide -ErrorAction SilentlyContinue | Stop-Process -Force
