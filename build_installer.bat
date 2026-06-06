@echo off

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
copy /y "%WIN_PKG_DIR%\mcu8051ide_win_setup.iss" "%BUILD_DIR%\mcu8051ide_win_setup.iss" >nul

:: ---- Copy setup image to build/ (required by Inno Setup) ----
copy /y "%WIN_PKG_DIR%\setup_image.bmp" "%BUILD_DIR%\setup_image.bmp" >nul

set "ISS_FILE=%BUILD_DIR%\mcu8051ide_win_setup.iss"

:: ---- Find Inno Setup 6 compiler (ISCC.exe) ----
set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" set "ISCC="

:: Check PATH as fallback
if "%ISCC%"=="" (
    where ISCC.exe >nul 2>&1
    if not errorlevel 1 set "ISCC=ISCC.exe"
)

if "%ISCC%"=="" (
    echo ERROR: Inno Setup 6 compiler not found
    echo Install from: https://jrsoftware.org/isdl.php
    exit /b 1
)

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
