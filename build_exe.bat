@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: build_exe.bat - One-click build of mcu8051ide.exe
:: Handles both fresh (empty build/) and incremental builds.
:: Usage: build_exe.bat   (no arguments needed)
:: ============================================================

set "PROJECT_DIR=%~dp0"
set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "BUILD_DIR=%PROJECT_DIR%\build"
set "SRC_DIR=%PROJECT_DIR%\src"
set "DEPS_DIR=%PROJECT_DIR%\deps"
set "WIN_PKG_DIR=%SRC_DIR%\pkgs\Windows"
set "FREEWRAP_TCLSH=%DEPS_DIR%\freewrap\freewrapTCLSH32.exe"
set "FREEWRAP_WRAPPER=%DEPS_DIR%\freewrap\freewrap32.exe"
set "ACTIVETCL_DIR=%DEPS_DIR%\ActiveTcl-master\lib"

echo ============================================================
echo Building MCU8051IDE Windows exe
echo ============================================================
echo.

:: ============================================================
:: PHASE 1: Check prerequisites
:: ============================================================

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

if not exist "%SRC_DIR%\lib\main.tcl" (
    echo ERROR: Source files not found in %SRC_DIR%\lib\
    exit /b 1
)

:: ============================================================
:: PHASE 2: Prepare build directory (copy source + deps)
:: ============================================================

echo Preparing build directory ...

:: ---- Create build directory ----
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

:: ---- Copy application source: lib/ ----
echo   Copying lib/ ...
if not exist "%BUILD_DIR%\lib" mkdir "%BUILD_DIR%\lib"
xcopy /y /s /q "%SRC_DIR%\lib\*.tcl" "%BUILD_DIR%\lib\" >nul 2>&1

:: ---- Copy application data ----
echo   Copying data/ ...
if not exist "%BUILD_DIR%\data" mkdir "%BUILD_DIR%\data"
xcopy /y /q "%SRC_DIR%\data\*.*" "%BUILD_DIR%\data\" >nul 2>&1

:: ---- Copy demo projects ----
echo   Copying demo/ ...
if not exist "%BUILD_DIR%\demo" mkdir "%BUILD_DIR%\demo"
xcopy /y /q "%SRC_DIR%\demo\*.*" "%BUILD_DIR%\demo\" >nul 2>&1

:: ---- Copy UI icons (recursive) ----
echo   Copying icons/ ...
if not exist "%BUILD_DIR%\icons" mkdir "%BUILD_DIR%\icons"
xcopy /y /s /q "%SRC_DIR%\icons\*.*" "%BUILD_DIR%\icons\" >nul 2>&1

:: ---- Copy translations ----
echo   Copying translations/ ...
if not exist "%BUILD_DIR%\translations" mkdir "%BUILD_DIR%\translations"
xcopy /y /q "%SRC_DIR%\translations\*.*" "%BUILD_DIR%\translations\" >nul 2>&1

:: ---- Copy hardware plugins ----
echo   Copying hwplugins/ ...
if not exist "%BUILD_DIR%\hwplugins" mkdir "%BUILD_DIR%\hwplugins"
xcopy /y /q "%SRC_DIR%\hwplugins\*.*" "%BUILD_DIR%\hwplugins\" >nul 2>&1

:: ---- Copy library dependencies ----
echo   Copying libraries/bwidget/ ...
if not exist "%BUILD_DIR%\libraries\bwidget" mkdir "%BUILD_DIR%\libraries\bwidget"
xcopy /y /s /q "%DEPS_DIR%\lib_pkg_dir\bwidget\*.*" "%BUILD_DIR%\libraries\bwidget\" >nul 2>&1

echo   Copying libraries/img_png/ ...
if not exist "%BUILD_DIR%\libraries\img_png" mkdir "%BUILD_DIR%\libraries\img_png"
xcopy /y /q "%DEPS_DIR%\lib_pkg_dir\img_png\*.*" "%BUILD_DIR%\libraries\img_png\" >nul 2>&1

echo   Copying libraries/itcl/ (Itcl 3.4) ...
if not exist "%BUILD_DIR%\libraries\itcl" mkdir "%BUILD_DIR%\libraries\itcl"
xcopy /y /q "%DEPS_DIR%\lib_pkg_dir\itcl\*.*" "%BUILD_DIR%\libraries\itcl\" >nul 2>&1

echo   Copying libraries/tclx8.4/ ...
if not exist "%BUILD_DIR%\libraries\tclx8.4" mkdir "%BUILD_DIR%\libraries\tclx8.4"
xcopy /y /q "%DEPS_DIR%\lib_pkg_dir\tclx8.4\*.*" "%BUILD_DIR%\libraries\tclx8.4\" >nul 2>&1

echo   Copying libraries/tdom/ ...
if not exist "%BUILD_DIR%\libraries\tdom" mkdir "%BUILD_DIR%\libraries\tdom"
xcopy /y /q "%DEPS_DIR%\lib_pkg_dir\tdom\*.*" "%BUILD_DIR%\libraries\tdom\" >nul 2>&1

:: ---- Copy md5 library from ActiveTcl ----
echo   Copying libraries/md5/ ...
if not exist "%BUILD_DIR%\libraries\md5" mkdir "%BUILD_DIR%\libraries\md5"
xcopy /y /q "%ACTIVETCL_DIR%\tcllib1.18\md5\*.*" "%BUILD_DIR%\libraries\md5\" >nul 2>&1

:: ---- Copy app icon PNG ----
echo   Copying mcu8051ide.png ...
copy /y "%SRC_DIR%\mcu8051ide.png" "%BUILD_DIR%\mcu8051ide.png" >nul 2>&1

:: ---- Copy entry script ----
echo   Copying mcu8051ide_entry.tcl ...
copy /y "%WIN_PKG_DIR%\mcu8051ide_entry.tcl" "%BUILD_DIR%\mcu8051ide_entry.tcl" >nul 2>&1

:: ---- Generate .ico from .png (if possible) ----
echo   Generating mcu8051ide.ico ...

:: Try ImageMagick first
set "MAGICK="
for %%p in (
    "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"
    "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI-x64-dll\magick.exe"
) do (
    if exist %%p set "MAGICK=%%~p"
)
where magick.exe >nul 2>&1
if !errorlevel! equ 0 set "MAGICK=magick.exe"

if defined MAGICK (
    "%MAGICK%" "%BUILD_DIR%\mcu8051ide.png" -resize 256x256 -define icon:auto-resize=16,32,48,64,128,256 "%BUILD_DIR%\mcu8051ide.ico" 2>nul
    if exist "%BUILD_DIR%\mcu8051ide.ico" (
        echo     Generated from PNG using ImageMagick
    ) else (
        echo     ImageMagick conversion failed, using fallback ICO
        copy /y "%WIN_PKG_DIR%\mcu8051ide.ico" "%BUILD_DIR%\mcu8051ide.ico" >nul 2>&1
    )
) else (
    :: No ImageMagick - use the existing ICO from the package
    copy /y "%WIN_PKG_DIR%\mcu8051ide.ico" "%BUILD_DIR%\mcu8051ide.ico" >nul 2>&1
    echo     Using existing ICO (no ImageMagick found)
)

echo   Preparation complete.
echo.

:: ============================================================
:: PHASE 3: Generate wrap file list dynamically
:: ============================================================

echo Generating wrap file list ...

"%FREEWRAP_TCLSH%" "%WIN_PKG_DIR%\gen_wrap_list.tcl" "%BUILD_DIR%"

if not exist "%BUILD_DIR%\list_of_files_to_wrap.txt" (
    echo ERROR: Failed to generate list_of_files_to_wrap.txt
    exit /b 1
)

:: Count files in the list
set "WRAP_COUNT=0"
for /f %%l in ("%BUILD_DIR%\list_of_files_to_wrap.txt") do set /a WRAP_COUNT+=1
echo   Wrap list contains !WRAP_COUNT! files
echo.

:: ============================================================
:: PHASE 4: Verify all files in the wrap list exist
:: ============================================================

echo Verifying wrap file list ...
set "MISSING=0"
for /f "usebackq delims=" %%f in ("%BUILD_DIR%\list_of_files_to_wrap.txt") do (
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
echo.

:: ============================================================
:: PHASE 5: Build external_command.exe (helper for IDE)
:: ============================================================

echo Building external_command.exe ...

:: Kill any running instances first
taskkill /f /im mcu8051ide.exe >nul 2>&1
taskkill /f /im external_command.exe >nul 2>&1

:: Copy the external command entry script from source
copy /y "%WIN_PKG_DIR%\ext_cmd_entry.tcl" "%BUILD_DIR%\ext_cmd_entry.tcl" >nul 2>&1

cd /d "%BUILD_DIR%"
"%FREEWRAP_TCLSH%" ext_cmd_entry.tcl -forcewrap -w "%FREEWRAP_WRAPPER%" -o external_command.exe 2>nul
del "%BUILD_DIR%\ext_cmd_entry.tcl" >nul 2>&1

cd /d "%PROJECT_DIR%"

if not exist "%BUILD_DIR%\external_command.exe" (
    echo WARNING: external_command.exe not built (non-critical, continuing)
) else (
    echo   external_command.exe built successfully
)
echo.

:: ============================================================
:: PHASE 6: Build main mcu8051ide.exe
:: ============================================================

echo Building mcu8051ide.exe ...
echo.

:: Record current exe size for change detection
set "OLD_SIZE=0"
if exist "%BUILD_DIR%\mcu8051ide.exe" (
    for %%e in ("%BUILD_DIR%\mcu8051ide.exe") do set "OLD_SIZE=%%~ze"
)

cd /d "%BUILD_DIR%"
"%FREEWRAP_TCLSH%" mcu8051ide_entry.tcl -forcewrap -f list_of_files_to_wrap.txt -w "%FREEWRAP_WRAPPER%" -o mcu8051ide.exe

cd /d "%PROJECT_DIR%"

:: ---- Verify output ----
if not exist "%BUILD_DIR%\mcu8051ide.exe" (
    echo.
    echo ERROR: Output exe not found after build
    exit /b 1
)

for %%e in ("%BUILD_DIR%\mcu8051ide.exe") do set "NEW_SIZE=%%~ze"

:: Detect if exe was actually rebuilt
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

echo   Output: %BUILD_DIR%\mcu8051ide.exe
echo   Size:   !NEW_SIZE! bytes
echo.
echo To run: double-click the exe or execute:
echo   "%BUILD_DIR%\mcu8051ide.exe"
echo ============================================================

endlocal