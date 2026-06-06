@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo MCU 8051 IDE - Download Dependencies
echo ============================================================
echo.
echo This script will download required dependencies to resources/
echo.

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "RESOURCES_DIR=%PROJECT_DIR%\resources"

if not exist "%RESOURCES_DIR%" mkdir "%RESOURCES_DIR%"

:: Check if PowerShell is available
where powershell >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: PowerShell not found. Please download manually.
    echo.
    echo 1. FreeWrap 6.61
    echo    Download URL
    echo    https^://sourceforge.net/projects/freewrap/files/freewrap/6.61/freewrap-6.61-win32.exe/download
    echo    Extract to: resources\freewrap\
    echo.
    echo 2. lib_pkg_dir ^(Tcl libraries^)
    echo    Download URL
    echo    https^://github.com/tjwei/MCU8051IDE_win/releases/download/deps/lib_pkg_dir.zip
    echo    Extract to: resources\lib_pkg_dir\
    echo.
    pause
    exit /b 1
)

echo [1/2] Downloading FreeWrap 6.61...
set "FREEWRAP_URL=https://sourceforge.net/projects/freewrap/files/freewrap/6.61/freewrap-6.61-win32.exe/download"
set "FREEWRAP_FILE=%RESOURCES_DIR%\freewrap-6.61-win32.exe"
set "FREEWRAP_DIR=%RESOURCES_DIR%\freewrap"

if not exist "%FREEWRAP_DIR%" (
    echo     Downloading from SourceForge...
    powershell -Command "Invoke-WebRequest -Uri '%FREEWRAP_URL%' -OutFile '%FREEWRAP_FILE%' -UseBasicParsing" 2>nul
    if exist "%FREEWRAP_FILE%" (
        echo     Extracting...
        mkdir "%FREEWRAP_DIR%" >nul 2>&1
        "%FREEWRAP_FILE%" /S /D=%FREEWRAP_DIR%
        del "%FREEWRAP_FILE%" >nul 2>&1
        echo     Done.
    ) else (
        echo     ERROR: Download failed. Please download manually:
        echo     %FREEWRAP_URL%
        echo     Extract to: %FREEWRAP_DIR%
    )
) else (
    echo     Already exists, skipping.
)

echo.
echo [2/2] Downloading Tcl libraries (lib_pkg_dir)...
set "LIBS_URL=https://github.com/tjwei/MCU8051IDE_win/releases/download/deps/lib_pkg_dir.zip"
set "LIBS_FILE=%RESOURCES_DIR%\lib_pkg_dir.zip"
set "LIBS_DIR=%RESOURCES_DIR%\lib_pkg_dir"

if not exist "%LIBS_DIR%" (
    echo     Downloading from GitHub...
    powershell -Command "Invoke-WebRequest -Uri '%LIBS_URL%' -OutFile '%LIBS_FILE%' -UseBasicParsing" 2>nul
    if exist "%LIBS_FILE%" (
        echo     Extracting...
        powershell -Command "Expand-Archive -Path '%LIBS_FILE%' -DestinationPath '%RESOURCES_DIR%' -Force"
        del "%LIBS_FILE%" >nul 2>&1
        echo     Done.
    ) else (
        echo     ERROR: Download failed. Please download manually:
        echo     %LIBS_URL%
        echo     Extract to: %LIBS_DIR%
    )
) else (
    echo     Already exists, skipping.
)

echo.
echo ============================================================
echo Dependency download complete!
echo.
echo Next steps:
echo   1. Run build_exe.bat to build the IDE
echo   2. Run build_installer.bat to create the installer
echo ============================================================
echo.

endlocal
