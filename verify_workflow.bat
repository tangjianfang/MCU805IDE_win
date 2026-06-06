@echo off
echo ============================================================
echo MCU 8051 IDE - Workflow Verification Script
echo ============================================================
echo.

set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

echo [Step 1/5] Checking project structure...
if not exist "src\" (
    echo ERROR: src\ directory not found
    goto :fail
)
if not exist "resources\" (
    echo ERROR: resources\ directory not found
    echo Please run: download_deps.bat
    goto :fail
)
if not exist "build_exe.bat" (
    echo ERROR: build_exe.bat not found
    goto :fail
)
echo   OK: Project structure verified
echo.

echo [Step 2/5] Checking dependencies...
if not exist "resources\freewrap\freewrapTCLSH32.exe" (
    echo ERROR: resources\freewrap\freewrapTCLSH32.exe not found
    echo Please run: download_deps.bat
    goto :fail
)
if not exist "resources\freewrap\freewrap32.exe" (
    echo ERROR: resources\freewrap\freewrap32.exe not found
    goto :fail
)
if not exist "resources\lib_pkg_dir\" (
    echo ERROR: resources\lib_pkg_dir\ not found
    goto :fail
)
if not exist "resources\lib_pkg_dir\itcl\itcl34.dll" (
    echo ERROR: Itcl 3.4 not found in resources\lib_pkg_dir\itcl\
    goto :fail
)
echo   OK: All dependencies present
echo.

echo [Step 3/5] Cleaning build directory...
if exist "build\" (
    rmdir /s /q build
    echo   Removed old build\ directory
)
mkdir build
echo   OK: Build directory ready
echo.

echo [Step 4/5] Building executable...
chcp 65001 >nul 2>&1
cmd /c "%PROJECT_DIR%build_exe.bat" > build_exe.log 2>&1
if %errorlevel% neq 0 (
    echo ERROR: build_exe.bat failed
    echo Check build_exe.log for details
    echo.
    echo Last 20 lines of log:
    type build_exe.log | findstr /C:"ERROR" /C:"Error" /C:"failed" /C:"Build"
    goto :fail
)
if not exist "build\mcu8051ide.exe" (
    echo ERROR: build\mcu8051ide.exe not generated
    goto :fail
)
echo   OK: Executable built successfully
echo   Size:
for %%A in (build\mcu8051ide.exe) do echo     %%~zA bytes
echo.

echo [Step 5/5] Building installer...
cmd /c "%PROJECT_DIR%build_installer.bat" > build_installer.log 2>&1
if %errorlevel% neq 0 (
    echo ERROR: build_installer.bat failed
    echo Check build_installer.log for details
    echo.
    echo Last 20 lines of log:
    type build_installer.log | findstr /C:"ERROR" /C:"Error" /C:"failed" /C:"compile"
    goto :fail
)
if not exist "build\mcu8051ide-1.4.9-setup.exe" (
    echo ERROR: Installer not generated
    goto :fail
)
echo   OK: Installer built successfully
echo   Size:
for %%A in (build\mcu8051ide-1.4.9-setup.exe) do echo     %%~zA bytes
echo.

echo ============================================================
echo SUCCESS: All verification steps passed!
echo ============================================================
echo.
echo Generated files:
echo   - build\mcu8051ide.exe (portable executable)
echo   - build\mcu8051ide-1.4.9-setup.exe (installer)
echo.
echo You can now:
echo   1. Test the executable: build\mcu8051ide.exe
echo   2. Test the installer: build\mcu8051ide-1.4.9-setup.exe
echo.
echo To clean git history (reduce repo size):
echo   1. git checkout clean-history
echo   2. Run cleanup_history.bat
echo   3. git push origin clean-history --force
echo   4. Create PR to merge clean-history into main
echo.
goto :end

:fail
echo.
echo ============================================================
echo VERIFICATION FAILED
echo ============================================================
exit /b 1

:end
echo.
pause
