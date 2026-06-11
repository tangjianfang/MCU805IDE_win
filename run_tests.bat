@echo off
:: ============================================================
:: run_tests.bat - Automated regression tests for MCU 8051 IDE
:: Delegates all test logic to run_tests.ps1
:: Usage: run_tests.bat
::        run_tests.bat --keep-output
:: ============================================================

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "PS1=%PROJECT_DIR%\run_tests.ps1"

:: Pass --keep-output flag through if specified
set "EXTRA="
if "%1"=="--keep-output" set "EXTRA=-KeepOutput"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -ProjectDir "%PROJECT_DIR%" %EXTRA%
exit /b %errorlevel%
