@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: build_installer.bat - Build the Inno Setup 6 installer
:: Copies the ISS script from src/pkgs/Windows/ to build/ first.
:: Usage: build_installer.bat
:: ============================================================

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "BUILD_DIR=%PROJECT_DIR%\build"
set "WIN_PKG_DIR=%PROJECT_DIR%\src\pkgs\Windows"

echo ============================================================
echo Building MCU 8051 IDE installer
echo ============================================================
echo.

:: ---- Check that mcu8051ide.exe exists ----
if not exist "%BUILD_DIR%\mcu8051ide.exe" (
    echo ERROR: mcu8051ide.exe not found in build directory
    echo Please run build_exe.bat first.
    exit /b 1
)

:: ---- Copy ISS script to build/ ----
copy /y "%WIN_PKG_DIR%\mcu8051ide_win_setup.iss" "%BUILD_DIR%\mcu8051ide_win_setup.iss" >/dev/null

:: ---- Copy setup image to build/ (required by Inno Setup) ----
copy /y "%WIN_PKG_DIR%\setup_image.bmp" "%BUILD_DIR%\setup_image.bmp" >/dev/null

set "ISS_FILE=%BUILD_DIR%\mcu8051ide_win_setup.iss"

:: ---- Find Inno Setup 6 compiler (ISCC.exe) ----
set "ISCC="

:: Check common install locations
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" (
    set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
)
if not defined ISCC (
    if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" (
        set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
    )
)
if not defined ISCC (
    if exist "D:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
        set "ISCC=D:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    )
)
if not defined ISCC (
    if exist "D:\Program Files\Inno Setup 6\ISCC.exe" (
        set "ISCC=D:\Program Files\Inno Setup 6\ISCC.exe"
    )
)

:: Check PATH as fallback
if not defined ISCC (
    where ISCC.exe >/dev/null 2>&1
    if not errorlevel 1 set "ISCC=ISCC.exe"
)

:: If still not found, prompt user for manual input
if not defined ISCC goto prompt_iscc

echo Using Inno Setup: %ISCC%
echo ISS script:       %ISS_FILE%
echo.

:: ---- Build the installer ----
cd /d "%BUILD_DIR%"
"%ISCC%" "%ISS_FILE%"

set "BUILD_ERR=%errorlevel%"
cd /d "%PROJECT_DIR%"

if not %BUILD_ERR%==0 (
    echo.
    echo ERROR: Installer build failed (error code: %BUILD_ERR%)
    exit /b %BUILD_ERR%
)

echo.
echo ============================================================
echo Installer build successful!
echo Output directory: %BUILD_DIR%
echo ============================================================
goto end

:prompt_iscc
echo ============================================================
echo Inno Setup 6 compiler ISCC.exe not found.
echo.
echo Searched locations:
echo   - C:\Program Files (x86)\Inno Setup 6\ISCC.exe
echo   - C:\Program Files\Inno Setup 6\ISCC.exe
echo   - D:\Program Files (x86)\Inno Setup 6\ISCC.exe
echo   - D:\Program Files\Inno Setup 6\ISCC.exe
echo   - System PATH
echo.
echo Please install Inno Setup 6 from:
echo   https://jrsoftware.org/isdl.php
echo ============================================================
echo.

:ask_iscc
set "ISCC="
set /p "ISCC=Enter full path to ISCC.exe (or press Enter to abort): "

if not defined ISCC (
    echo.
    echo Aborted.
    exit /b 1
)

if not exist "%ISCC%" (
    echo ERROR: File not found: %ISCC%
    goto ask_iscc
)

echo.
echo Using manually specified path: %ISCC%
echo.

echo Using Inno Setup: %ISCC%
echo ISS script:       %ISS_FILE%
echo.

:: ---- Build the installer ----
cd /d "%BUILD_DIR%"
"%ISCC%" "%ISS_FILE%"

set "BUILD_ERR=%errorlevel%"
cd /d "%PROJECT_DIR%"

if not %BUILD_ERR%==0 (
    echo.
    echo ERROR: Installer build failed (error code: %BUILD_ERR%)
    exit /b %BUILD_ERR%
)

echo.
echo ============================================================
echo Installer build successful!
echo Output directory: %BUILD_DIR%
echo ============================================================

:end
endlocal
