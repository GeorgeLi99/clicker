@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo Checking Python environment...

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not installed or not added to PATH.
    echo Please install Python 3.8 or higher from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Checking dependencies...
pip install -r requirements.txt --quiet

REM Create logs directory if it doesn't exist
if not exist "logs" mkdir logs

echo Starting to package the application...

REM Set log filename with date and timestamp
set "CURRENT_DATETIME=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "LOG_FILE=logs\build_log_%CURRENT_DATETIME%.log"
echo Build log will be recorded in: %LOG_FILE%
echo.

python build.py > "%LOG_FILE%" 2>&1
set EXIT_CODE=%errorlevel%

echo.
if %EXIT_CODE% equ 0 (
    echo ✅ Packaging successful!
    echo    The executable file is located in the 'dist' directory.
) else (
    echo ❌ Error during packaging (Exit code: %EXIT_CODE%^)
    echo    Please check the log file %LOG_FILE% for detailed error information.
)

echo.
echo Packaging process output has been recorded to %LOG_FILE%
echo Press any key to exit...
pause >nul
exit /b %EXIT_CODE%