@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:start
echo ==========================================
echo        Advanced Fix Tool
echo ==========================================
echo.
echo This tool will attempt to resolve common issues. Please select an option:
echo.
echo [1] Reinstall Python dependencies
echo [2] Clean and re-download ChromeDriver
echo [3] Recreate configuration file
echo [4] Clean logs and temporary files
echo [5] Check/Fix Python environment variables (Info)
echo [6] Full reset (Use with caution)
echo [7] Quick Fix (Recommended - same as quick_fix.bat)
echo [0] Exit
echo.

set /p choice="Enter option number: "

if "%choice%"=="1" goto :fix_packages
if "%choice%"=="2" goto :fix_chromedriver
if "%choice%"=="3" goto :fix_config
if "%choice%"=="4" goto :cleanup
if "%choice%"=="5" goto :fix_python_path
if "%choice%"=="6" goto :full_reset
if "%choice%"=="7" goto :quick_fix_action
if "%choice%"=="0" goto :exit_script
goto :invalid_choice

:fix_packages
echo ==== Reinstalling Python Dependencies ====
echo Cleaning pip cache...
pip cache purge 2>nul
echo Uninstalling old versions...
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul
echo Reinstalling...
pip install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ Dependencies reinstalled successfully
) else (
    echo ❌ Failed to reinstall dependencies
)
goto :done

:fix_chromedriver
echo ==== Cleaning and Re-downloading ChromeDriver ====
echo Deleting old drivers...
rmdir /s /q drivers 2>nul
mkdir drivers 2>nul
echo Cleaning webdriver-manager cache...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ ChromeDriver cleaned. It will be re-downloaded on next run.
goto :done

:fix_config
echo ==== Recreating Configuration File ====
if exist config.py (
    echo Backing up old configuration file...
    copy config.py config.py.backup >nul 2>&1
)
echo Creating new configuration file...
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
echo ✅ Configuration file recreated successfully.
goto :done

:cleanup
echo ==== Cleaning Logs and Temporary Files ====
echo Cleaning log files...
rmdir /s /q logs 2>nul
mkdir logs 2>nul
echo Cleaning temporary files...
del *.log 2>nul
del test_*.py 2>nul
del driver_path.txt 2>nul
del *.tmp 2>nul
echo Cleaning Python cache...
rmdir /s /q __pycache__ 2>nul
echo ✅ Cleanup complete.
goto :done

:fix_python_path
echo ==== Checking Python Environment Variables ====
echo Python paths found in your PATH environment variable:
where python 2>nul
echo.
echo If no Python path is displayed above, please:
echo 1. Reinstall Python, ensuring "Add Python to PATH" is checked during installation.
echo 2. Or, manually add Python to your environment variables.
echo 3. Restart the command prompt window after making changes.
echo.
echo Python installation directories are typically found at:
echo - C:\Users\%USERNAME%\AppData\Local\Programs\Python\
echo - C:\Python3x\
echo.
pause
goto :done

:full_reset
echo ==== Full Reset (Warning) ====
echo ⚠️  This will delete all local configurations and caches. Are you sure you want to continue?
echo Type YES to confirm, or any other key to cancel:
set /p confirm="Confirm: "
if /I not "%confirm%"=="YES" (
    echo Operation cancelled.
    goto :done
)

echo Performing full reset...
rmdir /s /q logs 2>nul
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q venv 2>nul
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
del config.py 2>nul
del *.log 2>nul
del *.tmp 2>nul
pip cache purge 2>nul
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul

echo ✅ Full reset complete. Please re-run run.bat.
goto :done

:quick_fix_action
echo ==== Quick Fix ====
echo Performing quick fix...
echo.
echo This will automatically perform the following actions:
echo - Clean all caches
echo - Reinstall dependencies
echo - Update configuration file
echo - Verify environment
echo.

echo Starting fix...
echo.

echo [1/4] Cleaning caches...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir drivers 2>nul
mkdir logs 2>nul
echo ✅ Caches cleaned.

echo [2/4] Reinstalling dependencies...
pip cache purge 2>nul
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul
pip install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ Dependencies reinstalled successfully.
) else (
    echo ❌ Failed to reinstall dependencies.
)

echo [3/4] Updating configuration file...
(
    echo # Nanjing University Teacher Evaluation System Configuration File
    echo.
    echo # Login Page URL
    echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # Evaluation System URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver Settings
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py
echo ✅ Configuration file updated.

echo [4/4] Verifying environment...
python -c "import selenium; print('✅ selenium is working')" 2>nul || echo ❌ selenium error
echo ✅ Quick fix complete.

echo.
echo Fix complete. It is recommended to run run.bat now to test the application.
goto :done

:invalid_choice
echo ❌ Invalid option. Please choose again.
PAUSE
cls
goto :start

:done
echo.
echo Operation complete! It is recommended to re-run run.bat to check if everything is normal.
goto :exit_script

:exit_script
echo.
echo Press any key to exit...
PAUSE
exit /b 0 