@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: build_exe.bat - One-click build of mcu8051ide.exe
:: Usage: build_exe.bat   (no arguments needed)
:: ============================================================

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "BUILD_DIR=%PROJECT_DIR%\build"
set "FREEWRAP_TCLSH=%PROJECT_DIR%\deps\freewrap\freewrapTCLSH32.exe"
set "FREEWRAP_WRAPPER=%PROJECT_DIR%\deps\freewrap\freewrap32.exe"
set "ENTRY_SCRIPT=%BUILD_DIR%\mcu8051ide_entry.tcl"
set "FILE_LIST=%BUILD_DIR%\list_of_files_to_wrap.txt"
set "OUTPUT_EXE=%BUILD_DIR%\mcu8051ide.exe"

echo ============================================================
echo Building MCU8051IDE Windows exe
echo ============================================================
echo.

:: ---- Check dependencies ----
if not exist "%FREEWRAP_TCLSH%" (
    echo ERROR: freewrapTCLSH32.exe not found
    echo Path: %FREEWRAP_TCLSH%
    exit /b 1
)

if not exist "%FREEWRAP_WRAPPER%" (
    echo ERROR: freewrap32.exe not found
    echo Path: %FREEWRAP_WRAPPER%
    exit /b 1
)

if not exist "%ENTRY_SCRIPT%" (
    echo ERROR: Entry script not found
    echo Path: %ENTRY_SCRIPT%
    exit /b 1
)

if not exist "%FILE_LIST%" (
    echo ERROR: File list not found
    echo Path: %FILE_LIST%
    exit /b 1
)

:: ---- Verify all files in the wrap list exist ----
echo Checking wrap file list ...
set "MISSING=0"
for /f "usebackq delims=" %%f in ("%FILE_LIST%") do (
    if not exist "%BUILD_DIR%\%%f" (
        echo   MISSING: %%f
        set "MISSING=1"
    )
)
if "!MISSING!"=="1" (
    echo ERROR: Some files are missing. Check the build directory.
    exit /b 1
)
echo   All files verified

:: ---- Kill any running mcu8051ide.exe ----
taskkill /f /im mcu8051ide.exe >nul 2>&1
:: (Silently kill if running; ignore error if not running)

:: ---- Record current exe timestamp so we can detect a new build ----
set "OLD_SIZE=0"
if exist "%OUTPUT_EXE%" (
    for %%e in ("%OUTPUT_EXE%") do set "OLD_SIZE=%%~ze"
)

:: ---- Build ----
echo.
echo Building ...
echo.

cd /d "%BUILD_DIR%"

"%FREEWRAP_TCLSH%" mcu8051ide_entry.tcl -forcewrap -f list_of_files_to_wrap.txt -w "%FREEWRAP_WRAPPER%" -o mcu8051ide.exe

:: ---- Verify output ----
cd /d "%PROJECT_DIR%"

if not exist "%OUTPUT_EXE%" (
    echo.
    echo ERROR: Output exe not found after build
    echo Path: %OUTPUT_EXE%
    exit /b 1
)

for %%e in ("%OUTPUT_EXE%") do set "NEW_SIZE=%%~ze"

:: Detect if exe was actually rebuilt (size changed or was 0 before)
if "!OLD_SIZE!"=="0" (
    echo.
    echo ============================================================
    echo Build successful!
) else if "!NEW_SIZE!"=="!OLD_SIZE!" (
    echo.
    echo ============================================================
    echo Build completed (exe unchanged - same content)
) else (
    echo.
    echo ============================================================
    echo Build successful!
)

echo   Output: %OUTPUT_EXE%
echo   Size:   !NEW_SIZE! bytes
echo.
echo To run: double-click the exe or execute:
echo   "%OUTPUT_EXE%"
echo ============================================================

endlocal