@echo off
rem ============================================================
rem startsdcc.bat - Run SDCC compiler from MCU 8051 IDE on Windows
rem Called by ::ExternalCompiler::compile_C in external_compiler.tcl.
rem
rem Usage: startsdcc.bat <work_dir> <sdcc_opts...> <input_file>
rem   work_dir   - directory to cd into before invoking sdcc
rem   sdcc_opts  - arguments to pass through to sdcc
rem   input_file - C source file
rem
rem SDCC must be on PATH, OR located in one of these common install
rem locations. We auto-detect and add it to PATH so the child sdcc
rem process can find its helpers (sdcpp.exe, sdas8051.exe, etc.).
rem ============================================================

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

rem ---- Find SDCC bin directory ----
SET "SDCC_BIN="

rem First, check if sdcc is already on PATH
WHERE sdcc.exe >nul 2>&1
IF !ERRORLEVEL! EQU 0 (
    GOTO :HaveSDCC
)

rem Not on PATH - try common install locations
FOR %%D IN (
    "%ProgramFiles%\SDCC\bin"
    "%ProgramFiles(x86)%\SDCC\bin"
    "%ProgramW6432%\SDCC\bin"
    "D:\Program Files\SDCC\bin"
    "D:\Program Files (x86)\SDCC\bin"
    "C:\SDCC\bin"
    "D:\SDCC\bin"
) DO (
    IF EXIST "%%~D\sdcc.exe" (
        SET "SDCC_BIN=%%~D"
        GOTO :HaveSDCC
    )
)

rem Not found anywhere - emit a clear error so the IDE message panel
rem shows what went wrong instead of appearing to hang silently.
ECHO.
ECHO ============================================================
ECHO SDCC compiler not found.
ECHO.
ECHO Searched:
ECHO   - System PATH
FOR %%D IN (
    "%ProgramFiles%\SDCC\bin"
    "%ProgramFiles(x86)%\SDCC\bin"
    "D:\Program Files\SDCC\bin"
    "D:\Program Files (x86)\SDCC\bin"
    "C:\SDCC\bin"
    "D:\SDCC\bin"
) DO (
    ECHO   - %%~D
)
ECHO.
ECHO Please install SDCC 4.x from:
ECHO   https://sdcc.sourceforge.net/
ECHO Or add your SDCC bin directory to the system PATH and restart
ECHO MCU 8051 IDE.
ECHO ============================================================
ECHO.
EXIT /B 127

:HaveSDCC
IF DEFINED SDCC_BIN (
    SET "PATH=!SDCC_BIN!;%PATH%"
)

rem ---- Change to work directory and run sdcc ----
IF "%~1"=="" (
    ECHO startsdcc.bat: missing work_dir argument 1>&2
    EXIT /B 1
)
cd /d "%~1"
SHIFT

rem Reassemble remaining args into args variable.
rem Use delayed expansion (!args!) so the loop correctly accumulates
rem across iterations - the original used %args% which is parsed
rem before each SET and never grows beyond the first iteration.
SET "args="
:Loop
IF "%~1"=="" GOTO :Continue
SET "args=!args! %~1"
SHIFT
GOTO :Loop

:Continue
sdcc -mmcs51 %args%
EXIT /B %ERRORLEVEL%
