@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:start_menu
echo ==========================================
echo        403 Permission Error Fix Tool
echo ==========================================
echo.
echo 403 errors are usually caused by:
echo 1. Evaluation system is not open or has closed
echo 2. Account does not have evaluation permission
echo 3. URL parameters have expired
echo 4. Session status issues
echo.
echo Please select a fix option:
echo.
echo [1] Get the latest evaluation system URL (Info & Auto-update attempt)
echo [2] Check evaluation time window (Info)
echo [3] Manually obtain the correct login link (Info & Edit config)
echo [4] Clear browser cache and retry (Actions & Info)
echo [5] View detailed error information (Logs & Test)
echo [0] Exit
echo.

set /p choice="Enter option number: "

if "%choice%"=="1" goto :get_new_url
if "%choice%"=="2" goto :check_time_window
if "%choice%"=="3" goto :manual_link
if "%choice%"=="4" goto :clear_cache_option
if "%choice%"=="5" goto :check_error_details
if "%choice%"=="0" goto :exit_script
goto :invalid_choice

:get_new_url
echo ==== Acquiring Latest Evaluation System URL ====
echo.
echo Creating URL acquisition script guide...

python -c "
print('=== Nanjing University Evaluation System URL Acquisition Guide ===')
print()
print('As the evaluation system URL may contain time-sensitive parameters, you might need to manually obtain the latest link:')
print()
print('Step 1:')
print('  1. Open your browser and go to: https://ehallapp.nju.edu.cn')
print('  2. Log in with your student ID and password')
print('  3. In the search bar, type \"Teaching Evaluation\" (or the Chinese equivalent if the interface is in Chinese)')
print('  4. Click on the \"Undergraduate Teaching Evaluation\" application (or similar)')
print()
print('Step 2 (Alternative, more technical):')
print('  5. Right-click on the page -> Inspect -> Network tab')
print('  6. Refresh the page')
print('  7. Look for requests ending with \"index.do\"')
print('  8. Copy the full URL of such a request')
print()
print('Step 3:')
print('  9. Open the config.py file in your script directory')
print('  10. Replace the value of LOGIN_URL with the new URL you copied')
print('  11. Save the file and try running the program again')
print()
print('Example of a commonly correct URL format:')
print('https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do%3Ft_s%3D[TIMESTAMP]%26...')
"

echo.
echo Do you want to automatically try updating the URL configuration to a simplified one? (y/N)
set /p update_choice="Select: "

if /I "%update_choice%"=="y" (
    echo Attempting to auto-update configuration...
    goto :auto_update_config
) else (
    echo Please follow the steps above to manually update the URL.
)

goto :done

:auto_update_config
echo Creating a simplified configuration, removing time-sensitive parameters...
(
    echo # Nanjing University Teacher Evaluation System Configuration File
    echo.
    echo # Simplified Login Page URL (without time-sensitive parameters)
    echo LOGIN_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # Backup Login URL (standard with authserver)
    echo BACKUP_LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # Evaluation System URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver Settings
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py

echo ✅ Configuration updated to a simplified version.
goto :done

:check_time_window
echo ==== Checking Evaluation Time Window ====
echo.
echo Teaching evaluations usually have fixed opening times:
echo.
echo 📅 Common evaluation periods:
echo   - Mid-term evaluation: Weeks 8-10 of the semester
echo   - Final evaluation: Weeks 16-18 of the semester
echo   - Please check notifications from the Academic Affairs Office for specific dates.
echo.
echo 🔍 How to check:
echo   1. Visit the official website of the Nanjing University Academic Affairs Office.
echo   2. Look for the latest teaching evaluation notices.
echo   3. Confirm if the current date is within the evaluation window.
echo.
echo 💡 If not within the evaluation period:
echo   - A 403 error is normal.
echo   - Please wait for the evaluation period to open.
echo   - Pay attention to notifications from the Academic Affairs Office for the latest schedule.
echo.

python -c "
import datetime
now = datetime.datetime.now()
print(f'Current time: {now.strftime(\"%Y-%m-%d %H:%M:%S\")}')
print(f'Current week number: Week {now.isocalendar()[1]}')
print()
print('If not currently within the evaluation window, please wait for official announcements.')
"

goto :done

:manual_link
echo ==== Manually Obtaining the Correct Login Link ====
echo.
echo This is often the most reliable solution:
echo.
echo 📋 Detailed Steps:
echo.
echo 1. Open Chrome browser.
echo 2. Visit: https://ehallapp.nju.edu.cn
echo 3. Log in with your student ID and password.
echo 4. Search for and click on "Undergraduate Teaching Evaluation" (or similar).
echo 5. Observe the full URL in the address bar.
echo.
echo 6. Copy this complete URL into the LOGIN_URL field in the config.py file.
echo.
echo Example:
echo   If you see a URL like:
echo   https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do?t_s=1234567890...
echo.
echo   You might need to construct the LOGIN_URL in config.py like this (or use the direct eHall URL if that works):
echo   LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=[URL-encoded version of the complete eHall app URL]"
echo   (URL encoding means replacing characters like ':' with '%3A', '/' with '%2F', etc.)
echo   Alternatively, try using the direct eHall app URL itself for LOGIN_URL if you are already logged into eHall.

echo.
echo Do you want to open config.py for editing? (y/N)
set /p edit_choice="Select: "

if /I "%edit_choice%"=="y" (
    if exist config.py (
        echo Opening config.py...
        notepad config.py
    ) else (
        echo config.py not found. Attempting to create a default one...
        goto :auto_update_config
    )
)

goto :done

:clear_cache_option
echo ==== Clearing Caches and Retrying ====
echo.
echo Attempting to resolve issues by clearing caches...

echo 1. Clearing webdriver cache...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ Webdriver cache cleared.

echo 2. Clearing local driver files...
rmdir /s /q drivers 2>nul
mkdir drivers 2>nul
echo ✅ Local driver files cleared.

echo 3. Clearing program cache...
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir logs 2>nul
echo ✅ Program cache cleared.

echo.
echo 💡 It is also recommended to manually clear your Chrome browser cache:
echo   1. Open Chrome browser.
echo   2. Press Ctrl+Shift+Delete.
echo   3. Select "All time" for the time range.
echo   4. Check "Cookies and other site data" and "Cached images and files".
echo   5. Click "Clear data".
echo.
echo Cache clearing complete. It is recommended to re-run run.bat.
goto :done

:check_error_details
echo ==== Viewing Detailed Error Information ====
echo.
echo Checking log files...
if exist logs (
    echo Found log files:
    dir logs\*.log /b 2>nul
    echo.
    echo Latest log contents (filtered for errors):
    for /f %%f in ('dir logs\*.log /b /o:d 2^>nul') do (
        echo --- logs\%%f ---
        type logs\%%f | findstr /i "403 error failed exception abnormal" 2>nul
    )
) else (
    echo No log files found in the 'logs' directory.
)

echo.
echo Testing current URL accessibility...

python -c "
try:
    import requests
    # Attempt to read LOGIN_URL from config.py
    config = {}
    try:
        with open('config.py', 'r', encoding='utf-8') as f:
            exec(f.read(), config)
        LOGIN_URL = config.get('LOGIN_URL')
        if not LOGIN_URL:
            print('LOGIN_URL not found in config.py or is empty.')
            LOGIN_URL = 'https://authserver.nju.edu.cn/authserver/login' # Fallback
    except FileNotFoundError:
        print('config.py not found. Using a default URL for testing.')
        LOGIN_URL = 'https://authserver.nju.edu.cn/authserver/login'
    except Exception as e_conf:
        print(f'Error reading config.py: {e_conf}. Using a default URL for testing.')
        LOGIN_URL = 'https://authserver.nju.edu.cn/authserver/login'

    print(f'Testing URL: {LOGIN_URL}')
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36'
    }
    response = requests.get(LOGIN_URL, headers=headers, timeout=15, allow_redirects=True) # Allow redirects for login pages
    print(f'Status Code: {response.status_code}')
    print(f'Final URL after redirects (if any): {response.url}')
    
    if response.status_code == 403:
        print('❌ Confirmed 403 Error.')
        print('Possible reasons:')
        print('1. Evaluation system not open.')
        print('2. URL contains expired parameters.')
        print('3. Access permission restricted (IP, account, etc.).')
    elif response.status_code == 200:
        print('✅ Status 200 OK. Page seems accessible.')
        if 'authserver' in response.url:
            print('   Likely on the login page.')
        elif 'ehallapp' in response.url:
            print('   Likely on the eHall system page.')
    else:
        print(f'Status: {response.status_code}. Please check the URL and network.')
        
except ImportError:
    print('Python 'requests' module not installed. Skipping direct network test.')
    print('You can install it by running: pip install requests')
except Exception as e:
    print(f'URL test failed: {e}')
"

goto :done

:invalid_choice
echo ❌ Invalid option. Please choose again.
PAUSE
cls
goto :start_menu

:done
echo.
echo Operation complete! It is recommended to re-run run.bat to check if the issue is resolved.
goto :exit_script

:exit_script
echo.
echo Press any key to exit...
PAUSE
exit /b 0 