@echo off
rem ============================================================
rem startsdcc.bat - Run SDCC compiler from MCU 8051 IDE on Windows
rem
rem Usage: startsdcc.bat <work_dir> <sdcc_opts...> <input_file>
rem
rem Auto-detects SDCC in PATH or in common install locations.
rem Writes SDCC output to <work_dir>\.mcu8051ide_sdcc_output.log
rem ending with a 'SDCC_DONE:<rc>' line that the IDE polls for.
rem ============================================================

if defined USERPROFILE (
    set "DIAG_LOG=%USERPROFILE%\.mcu8051ide_compile.log"
) else (
    set "DIAG_LOG=startsdcc_diag.log"
)
set "RAW_DATE=%DATE%"
call set "DATE_PRE=%%RAW_DATE:~0,10%%"
set "STAMP=%DATE_PRE% %TIME:~0,8%"

rem Single-line start marker, no per-step noise
echo [%STAMP%] startsdcc.bat v5 work_dir=%~1 args=%2 %3 %4 %5 %6 %7 %8 %9 > "%DIAG_LOG%"

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET "SDCC_BIN="
WHERE sdcc.exe >nul 2>&1
IF !ERRORLEVEL! EQU 0 GOTO :HaveSDCC

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

echo [%STAMP%] SDCC NOT FOUND - aborting >> "%DIAG_LOG%"
echo SDCC compiler not found. Searched PATH and common install locations.
echo Install SDCC 4.x from https://sdcc.sourceforge.net/ or add SDCC bin to PATH.
echo SDCC_NOT_FOUND >> "%USERPROFILE%\.mcu8051ide_sdcc_output.log" 2>nul
EXIT /B 127

:HaveSDCC
IF DEFINED SDCC_BIN SET "PATH=!SDCC_BIN!;%PATH%"

IF "%~1"=="" (
    echo [%STAMP%] ERROR: missing work_dir >> "%DIAG_LOG%"
    EXIT /B 1
)
cd /d "%~1"
SHIFT

SET "args="
:Loop
IF "%~1"=="" GOTO :Continue
SET "args=!args! %~1"
SHIFT
GOTO :Loop

:Continue
set "OUTPUT_FILE=%CD%\.mcu8051ide_sdcc_output.log"
type nul > "!OUTPUT_FILE!"
sdcc -mmcs51 %args% >> "!OUTPUT_FILE!" 2>&1
SET "RC=!ERRORLEVEL!"
rem Write the SDCC_DONE marker line. Plain `echo` (not `echo.`) writes
rem "SDCC_DONE:N<CR><LF>" with no trailing space, which the IDE's regex
rem matches cleanly. Append so the SDCC output above is preserved.
>> "!OUTPUT_FILE!" echo SDCC_DONE:!RC!
echo [%STAMP%] rc=!RC! >> "%DIAG_LOG%"
EXIT /B %RC%
