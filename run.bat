@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ==========================================
echo    Teacher Evaluation Auto-filler - One-click Start
echo ==========================================
echo.

REM Basic environment check function
goto :check_environment

:check_environment
echo [1/4] Checking environment...

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not installed or not added to PATH
    echo.
    echo Please install Python by following these steps:
    echo 1. Visit https://www.python.org/downloads/
    echo 2. Download Python 3.8 or higher
    echo 3. During installation, make sure to check "Add Python to PATH"
    echo 4. Rerun this script after installation
    echo.
    goto :error_exit
)

REM Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo ✅ Python version detected: %pyver%

REM Check if pip is available
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ pip not found. Please reinstall Python and ensure pip is included.
    goto :error_exit
)

echo ✅ pip check passed
goto :check_files

:check_files
echo [2/4] Checking necessary files...

REM Check if main.py exists
if not exist "main.py" (
    echo ❌ main.py file not found
    echo Please ensure you are running this script in the correct directory
    goto :error_exit
)
echo ✅ main.py file exists

REM Check if requirements.txt exists
if not exist "requirements.txt" (
    echo ⚠️  requirements.txt file not found. Will install basic dependencies manually.
    goto :install_basic_deps
)
echo ✅ requirements.txt file exists
goto :create_config

:install_basic_deps
echo [3/4] Installing basic dependencies...
echo Installing selenium...
pip install selenium --quiet
if %errorlevel% neq 0 (
    echo ❌ Failed to install selenium
    goto :error_exit
)

echo Installing webdriver-manager...
pip install webdriver-manager --quiet
if %errorlevel% neq 0 (
    echo ❌ Failed to install webdriver-manager
    goto :error_exit
)

echo Installing python-dotenv...
pip install python-dotenv --quiet
if %errorlevel% neq 0 (
    echo ❌ Failed to install python-dotenv
    goto :error_exit
)

echo ✅ Basic dependencies installed successfully
goto :create_config

:create_config
echo [3/4] Checking configuration file...

REM Check if config.py exists, create if not
if not exist "config.py" (
    echo Creating configuration file...
    (
        echo # Nanjing University Teacher Evaluation System Configuration File
        echo.
        echo # Login Page URL
        echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
        echo.
        echo # Evaluation System URL
        echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
        echo.
        echo # ChromeDriver Settings (Auto-management preferred)
        echo USE_AUTO_DRIVER = True
        echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
    ) > config.py
    echo ✅ Configuration file created successfully
) else (
    echo ✅ Configuration file already exists
)

goto :install_dependencies

:install_dependencies
echo [4/4] Installing/Checking dependencies...

REM If requirements.txt exists, use it to install dependencies
if exist "requirements.txt" (
    echo Installing dependencies from requirements.txt...
    pip install -r requirements.txt --quiet
    if %errorlevel% neq 0 (
        echo ⚠️  Problem installing dependencies from requirements.txt. Attempting individual installation.
        goto :install_basic_deps
    )
    echo ✅ Dependencies installed successfully
)

REM Create logs directory
if not exist "logs" mkdir logs

echo.
echo ==========================================
echo            Environment check complete
echo        Starting Teacher Evaluation Auto-filler
echo ==========================================
echo.

goto :run_program

:run_program
REM Run main program and capture errors
echo Starting program...
echo.

REM Set log filename with date and timestamp
set "CURRENT_DATETIME=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "LOG_FILE=logs\run_log_%CURRENT_DATETIME%.log"
echo Log will be recorded in: %LOG_FILE%
echo.

python main.py > "%LOG_FILE%" 2>&1
set EXIT_CODE=%errorlevel%

echo.
if %EXIT_CODE% equ 0 (
    echo ✅ Program finished successfully
) else (
    echo ❌ Error during program execution (Exit code: %EXIT_CODE%^)
    echo    Please check the log file %LOG_FILE% for detailed error information.
    echo.
    echo Possible solutions:
    echo 1. Check if the network connection is normal
    echo 2. Confirm Chrome browser is installed and updated to the latest version
    echo 3. Check if any antivirus software is blocking the program
    echo 4. Try running this script as an administrator
)

goto :normal_exit

:error_exit
echo.
echo ❌ Environment check failed. Program cannot run.
echo.
echo Troubleshooting suggestions:
echo 1. Ensure Python 3.8+ is correctly installed and added to PATH
echo 2. Ensure the network connection is normal and can download Python packages
echo 3. Try running this script as an administrator
echo 4. If the problem persists, please contact technical support
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:normal_exit
echo.
echo Program output has been recorded to %LOG_FILE%
echo Press any key to exit...
PAUSE
exit /b %EXIT_CODE% 