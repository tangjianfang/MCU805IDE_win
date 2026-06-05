@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: replace_icon.bat - Generate all icon sizes from NewLogo.png
:: Usage: replace_icon.bat          (uses NewLogo.png in same folder)
::        replace_icon.bat <file>   (uses specified PNG file)
:: Requires: ImageMagick (magick command in PATH)
:: ============================================================

:: Source image: default to NewLogo.png in the same folder as this bat
if "%~1"=="" (
    set "SRC_IMG=%~dp0NewLogo.png"
) else (
    set "SRC_IMG=%~1"
)

if not exist "%SRC_IMG%" (
    echo ERROR: Source image not found: %SRC_IMG%
    echo.
    echo Place your logo PNG as "NewLogo.png" in the same folder as this script,
    echo or specify the path: replace_icon.bat path\to\your_logo.png
    exit /b 1
)

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

:: Find magick.exe - check common install locations then PATH
set "MAGICK="
for %%D in (
    "%PROJECT_DIR%"
    "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI"
    "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI-x64-dll"
    "C:\Program Files (x86)\ImageMagick*"
) do (
    if exist "%%~D\magick.exe" set "MAGICK=%%~D\magick.exe"
)
where magick.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "MAGICK=magick.exe"
)

if "%MAGICK%"=="" (
    echo ERROR: ImageMagick not found
    echo Install from: https://imagemagick.org/script/download.php
    echo After install, magick.exe must be in your PATH or in:
    echo   C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\
    exit /b 1
)

echo ============================================================
echo Replacing MCU8051IDE icons
echo Source: %SRC_IMG%
echo ImageMagick: %MAGICK%
echo ============================================================
echo.

:: ---- Square icons: 16, 22, 32 ----
for %%S in (16 22 32) do (
    set "DEST_SRC=%PROJECT_DIR%\src\icons\%%Sx%%S\mcu8051ide.png"
    set "DEST_BUILD=%PROJECT_DIR%\build\icons\%%Sx%%S\mcu8051ide.png"

    echo Generating %%Sx%%S ...
    "%MAGICK%" "%SRC_IMG%" -resize %%Sx%%S -strip "!DEST_SRC!"

    if exist "!DEST_BUILD!" (
        copy /y "!DEST_SRC!" "!DEST_BUILD!" >nul
        echo   Updated: !DEST_BUILD!
    ) else (
        echo   Updated: !DEST_SRC!
    )
)

:: ---- 64x64 desktop icon ----
set "DEST=%PROJECT_DIR%\src\mcu8051ide.png"
echo Generating 64x64 desktop icon ...
"%MAGICK%" "%SRC_IMG%" -resize 64x64 -strip "%DEST%"
echo   Updated: %DEST%

:: ---- Splash screen: 400x199 (white background, centered) ----
set "SPLASH_SRC=%PROJECT_DIR%\src\icons\other\splash.png"
set "SPLASH_BUILD=%PROJECT_DIR%\build\icons\other\splash.png"

echo Generating 400x199 splash screen ...
"%MAGICK%" "%SRC_IMG%" -resize 400x199^> -background white -gravity center -extent 400x199 -strip "%SPLASH_SRC%"

if exist "%SPLASH_BUILD%" (
    copy /y "%SPLASH_SRC%" "%SPLASH_BUILD%" >nul
    echo   Updated: %SPLASH_BUILD%
) else (
    echo   Updated: %SPLASH_SRC%
)

echo.
echo ============================================================
echo Done! All icons replaced.
echo Next: run build_exe.bat to rebuild the exe.
echo ============================================================
endlocal