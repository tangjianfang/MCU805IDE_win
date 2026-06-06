@echo off
echo ============================================================
echo MCU 8051 IDE - Git History Cleanup Script
echo ============================================================
echo.
echo WARNING: This will rewrite git history and reduce repository
echo          size from ~375 MB to ~14 MB.
echo.
echo This script will:
echo   1. Remove build/, deps/, resources/ from git history
echo   2. Keep only src/, scripts, and configuration files
echo   3. Require force push to remote repository
echo.
echo IMPORTANT: Make sure you have a backup before proceeding!
echo.

set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

REM Check if we're on the clean-workflow branch
for /f "tokens=*" %%i in ('git branch --show-current') do set BRANCH=%%i
if not "%BRANCH%"=="clean-workflow" (
    echo ERROR: You must be on the 'clean-workflow' branch
    echo Current branch: %BRANCH%
    echo.
    echo Run: git checkout clean-workflow
    goto :fail
)

REM Check for git-filter-repo
where git-filter-repo >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: git-filter-repo is not installed
    echo.
    echo Please install it first:
    echo   Option 1: pip install git-filter-repo
    echo   Option 2: Download from https://github.com/newren/git-filter-repo
    echo.
    echo After installation, run this script again.
    goto :fail
)

echo [Step 1/6] Creating backup branch...
git branch backup-before-cleanup 2>nul
if %errorlevel% neq 0 (
    echo   Warning: backup-before-cleanup branch already exists, skipping
) else (
    echo   OK: Created backup-before-cleanup branch
)
echo.

echo [Step 2/6] Analyzing repository size...
echo   Current .git size:
for /f "tokens=3" %%a in ('dir /s .git ^| findstr "File(s)"') do echo     %%a
echo.

echo [Step 3/6] Removing build/ from history...
git filter-repo --invert-paths --path build/ --force
if %errorlevel% neq 0 (
    echo ERROR: Failed to remove build/ from history
    goto :fail
)
echo   OK: build/ removed from history
echo.

echo [Step 4/6] Removing deps/ from history...
git filter-repo --invert-paths --path deps/ --force
if %errorlevel% neq 0 (
    echo ERROR: Failed to remove deps/ from history
    goto :fail
)
echo   OK: deps/ removed from history
echo.

echo [Step 5/6] Removing resources/ from history...
git filter-repo --invert-paths --path resources/ --force
if %errorlevel% neq 0 (
    echo ERROR: Failed to remove resources/ from history
    goto :fail
)
echo   OK: resources/ removed from history
echo.

echo [Step 6/6] Checking final repository size...
echo   New .git size:
for /f "tokens=3" %%a in ('dir /s .git ^| findstr "File(s)"') do echo     %%a
echo.

echo ============================================================
echo SUCCESS: Git history cleaned!
echo ============================================================
echo.
echo Next steps:
echo   1. Review the changes: git log --oneline
echo   2. Force push to remote:
echo      git push origin clean-workflow --force
echo   3. Create a PR to merge clean-workflow into main
echo   4. After merge, force push main:
echo      git checkout main
echo      git merge clean-workflow
echo      git push origin main --force
echo.
echo IMPORTANT: Other collaborators must re-clone the repository
echo            after the force push to get the cleaned history.
echo.
goto :end

:fail
echo.
echo ============================================================
echo CLEANUP FAILED
echo ============================================================
echo.
echo If something went wrong, you can restore from backup:
echo   git checkout backup-before-cleanup
echo   git reset --hard backup-before-cleanup
echo.
exit /b 1

:end
echo.
pause
