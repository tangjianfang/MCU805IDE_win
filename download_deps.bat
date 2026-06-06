@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo MCU 8051 IDE - Extract Dependencies
echo ============================================================
echo.
echo This script will extract required dependencies from local zip files.
echo.

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "RESOURCES_DIR=%PROJECT_DIR%\resources"

if not exist "%RESOURCES_DIR%" mkdir "%RESOURCES_DIR%"

:: Check if PowerShell is available
where powershell >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: PowerShell not found. Cannot extract zip files.
    echo Please install PowerShell or extract manually:
    echo.
    echo 1. freewrap.zip -^> resources\freewrap\
    echo 2. lib_pkg_dir.zip -^> resources\lib_pkg_dir\
    echo.
    pause
    exit /b 1
)

echo [1/2] Extracting FreeWrap 6.61...
set "FREEWRAP_ZIP=%PROJECT_DIR%\freewrap.zip"
set "FREEWRAP_DIR=%RESOURCES_DIR%\freewrap"

if not exist "%FREEWRAP_DIR%" (
    if not exist "%FREEWRAP_ZIP%" (
        echo     ERROR: freewrap.zip not found in project root.
        echo     Please ensure freewrap.zip is present in: %PROJECT_DIR%
        pause
        exit /b 1
    )
    echo     Extracting from local zip...
    powershell -Command "Expand-Archive -Path '%FREEWRAP_ZIP%' -DestinationPath '%RESOURCES_DIR%' -Force" 2>nul
    if exist "%FREEWRAP_DIR%" (
        echo     Done.
    ) else (
        echo     ERROR: Extraction failed.
        echo     Please extract freewrap.zip to resources\freewrap\ manually.
        pause
        exit /b 1
    )
) else (
    echo     Already exists, skipping.
)

echo.
echo [2/2] Extracting Tcl libraries (lib_pkg_dir)...
set "LIBS_ZIP=%PROJECT_DIR%\lib_pkg_dir.zip"
set "LIBS_DIR=%RESOURCES_DIR%\lib_pkg_dir"

if not exist "%LIBS_DIR%" (
    if not exist "%LIBS_ZIP%" (
        echo     ERROR: lib_pkg_dir.zip not found in project root.
        echo     Please ensure lib_pkg_dir.zip is present in: %PROJECT_DIR%
        pause
        exit /b 1
    )
    echo     Extracting from local zip...
    powershell -Command "Expand-Archive -Path '%LIBS_ZIP%' -DestinationPath '%RESOURCES_DIR%' -Force" 2>nul
    if exist "%LIBS_DIR%" (
        echo     Done.
    ) else (
        echo     ERROR: Extraction failed.
        echo     Please extract lib_pkg_dir.zip to resources\lib_pkg_dir\ manually.
        pause
        exit /b 1
    )
) else (
    echo     Already exists, skipping.
)

echo.
echo ============================================================
echo Dependency extraction complete!
echo.
echo Next steps:
echo   1. Run build_exe.bat to build the IDE
echo   2. Run build_installer.bat to create the installer
echo ============================================================
echo.

endlocal
