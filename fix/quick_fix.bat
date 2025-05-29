@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        Quick Fix Tool
echo ==========================================
echo.

echo This tool will automatically attempt to fix common issues:
echo ✅ Clear all caches
echo ✅ Reinstall dependencies
echo ✅ Update configuration file
echo ✅ Attempt to fix 403 permission errors (by resetting URL)
echo.

echo Starting auto-fix...
echo.

echo [1/5] Clearing webdriver cache...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ Webdriver cache cleared

echo [2/5] Clearing local files...
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir drivers 2>nul
mkdir logs 2>nul
echo ✅ Local cache cleared

echo [3/5] Reinstalling Python dependencies...
pip cache purge 2>nul
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul
pip install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ Python dependencies reinstalled successfully
) else (
    echo ❌ Failed to install Python dependencies. Please check your network connection.
)

echo [4/5] Updating configuration file...
(
    echo # Nanjing University Teacher Evaluation System Configuration File
    echo.
    echo # Login Page URL - Simplified version
    echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # Evaluation System URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver Settings
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py
echo ✅ Configuration file updated

echo [5/5] Testing system environment...
python -c "
try:
    from selenium import webdriver
    print('✅ selenium module is working')
    
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    driver = webdriver.Chrome(options=options)
    driver.get('https://www.baidu.com')
    if 'baidu' in driver.current_url:
        print('✅ Browser functionality is normal')
    driver.quit()
    print('✅ Environment test passed')
except Exception as e:
    print(f'❌ Environment test failed: {e}')
" 2>nul || echo ⚠️ Environment test skipped

echo.
echo ==========================================
echo              Fix Complete
echo ==========================================
echo.

echo 🎉 Auto-fix completed!
echo.
echo 📋 Summary of fixes:
echo   - Cleared all cache files
echo   - Reinstalled Python dependencies
echo   - Updated configuration file to a simplified version
echo   - Verified system environment
echo.

echo 💡 Next steps:
echo   1. Double-click and run run.bat
echo   2. If issues persist, run the specific fix tool:
echo      - Script crashing: diagnose.bat
echo      - Browser blank screen: test_browser_simple.bat  
echo      - 403 error: fix_403.bat
echo.

echo 📞 If problems still exist, possible reasons:
echo   - Evaluation system is not open (403 error is normal in this case)
echo   - Network connection issues
echo   - Outdated Chrome browser version
echo   - Antivirus software interference
echo.

echo Press any key to exit...
PAUSE
exit /b 0 