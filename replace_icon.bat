@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: replace_icon.bat - Generate all icon sizes from one source PNG
:: Usage: replace_icon.bat <source_png_path>
:: Example: replace_icon.bat my_new_logo.png
:: Requires: ImageMagick (magick command in PATH)
:: ============================================================

if "%~1"=="" (
    echo Usage: replace_icon.bat ^<source_png_path^>
    echo Example: replace_icon.bat my_new_logo.png
    echo.
    echo Generates all icon sizes from one source image and copies
    echo to both src/ and build/ directories:
    echo   16x16   - Taskbar / window icon
    echo   22x22   - Medium icon
    echo   32x32   - Large icon
    echo   64x64   - Desktop icon
    echo   400x199 - Splash screen
    exit /b 1
)

set "SRC_IMG=%~1"
if not exist "%SRC_IMG%" (
    echo ERROR: File not found: %SRC_IMG%
    exit /b 1
)

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

where magick >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: ImageMagick not found (magick command)
    echo Install from: https://imagemagick.org/script/download.php
    echo Make sure magick is in your PATH after install.
    exit /b 1
)

echo ============================================================
echo Replacing MCU8051IDE icons
echo Source: %SRC_IMG%
echo ============================================================
echo.

:: ---- Square icons: 16, 22, 32, 64 ----
for %%S in (16 22 32 64) do (
    set "DEST_SRC=%PROJECT_DIR%\src\icons\%%Sx%%S\mcu8051ide.png"
    set "DEST_BUILD=%PROJECT_DIR%\build\icons\%%Sx%%S\mcu8051ide.png"

    echo Generating %%Sx%%S ...
    magick "%SRC_IMG%" -resize %%Sx%%S -strip "!DEST_SRC!"

    if exist "!DEST_BUILD!" (
        copy /y "!DEST_SRC!" "!DEST_BUILD!" >nul
        echo   Updated: !DEST_BUILD!
    ) else (
        echo   Updated: !DEST_SRC!
    )
)

:: ---- 64x64 desktop icon (src/mcu8051ide.png) ----
set "DEST=%PROJECT_DIR%\src\mcu8051ide.png"
echo Generating 64x64 desktop icon ...
magick "%SRC_IMG%" -resize 64x64 -strip "%DEST%"
echo   Updated: %DEST%

:: ---- Splash screen: 400x199 ----
set "SPLASH_SRC=%PROJECT_DIR%\src\icons\other\splash.png"
set "SPLASH_BUILD=%PROJECT_DIR%\build\icons\other\splash.png"

echo Generating 400x199 splash screen ...
magick "%SRC_IMG%" -resize 400x199 -background white -gravity center -extent 400x199 -strip "%SPLASH_SRC%"

if exist "%SPLASH_BUILD%" (
    copy /y "%SPLASH_SRC%" "%SPLASH_BUILD%" >nul
    echo   Updated: %SPLASH_BUILD%
) else (
    echo   Updated: %SPLASH_SRC%
)

echo.
echo ============================================================
echo Done! All icons replaced in src/ and build/ directories.
echo Next step: run build_exe.bat to rebuild the exe.
echo ============================================================
endlocal