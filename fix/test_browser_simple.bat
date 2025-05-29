@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        Browser Connection Test Tool
echo ==========================================
echo.

echo Testing browser connection...
echo.

python -c "
import sys
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service
    from webdriver_manager.chrome import ChromeDriverManager
    import time

    print('=== Browser Connection Test Start ===')
    print()

    # Test 1: Basic browser launch
    print('1. Testing basic Chrome launch...')
    try:
        options = webdriver.ChromeOptions()
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        driver = webdriver.Chrome(options=options)
        print('✅ Chrome browser launched successfully')
        
        # Test Baidu
        print('2. Testing network connection (Baidu)...')
        driver.get('https://www.baidu.com')
        time.sleep(3)
        if 'baidu' in driver.current_url and len(driver.page_source) > 1000:
            print('✅ Network connection normal, page content loaded successfully')
        else:
            print('❌ Page load abnormal')
            print(f'Current URL: {driver.current_url}')
            print(f'Page source length: {len(driver.page_source)}')
        
        # Test NJU login page
        print('3. Testing NJU login page...')
        login_url = 'https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do'
        driver.get(login_url)
        time.sleep(5)
        
        current_url = driver.current_url
        page_title = driver.title
        page_length = len(driver.page_source)
        
        print(f'   Current URL: {current_url}')
        print(f'   Page Title: {page_title}')
        print(f'   Page Content Length: {page_length}')
        
        if 'authserver.nju.edu.cn' in current_url and page_length > 1000:
            print('✅ NJU login page accessed normally')
            
            # Check key elements
            try:
                username_element = driver.find_element_by_id('username') # Note: find_element_by_id is deprecated
                print('✅ Username input field detected')
            except:
                print('⚠️ Username input field not detected')
                
        elif page_length < 100:
            print('❌ Page content empty or load failed')
            print('Possible reasons:')
            print('  - Network connection issue')
            print('  - Chrome driver version mismatch')
            print('  - Firewall blocking access')
        else:
            print(f'⚠️ Page redirection abnormal: {current_url}')
        
        driver.quit()
        print('✅ Browser closed')
        
    except Exception as e:
        print(f'❌ Browser test failed: {e}')
        try:
            driver.quit()
        except:
            pass
    
    print()
    print('=== Test Complete ===')
    
except ImportError as ie:
    print(f'❌ Failed to import module: {ie}')
    print('Please ensure selenium and webdriver-manager are installed.')
except Exception as e:
    print(f'❌ Error during test process: {e}')
"

echo.
echo Test complete!
echo If it shows "Page content empty or load failed", please try:
echo 1. Run fix.bat and select option 2 to clean ChromeDriver cache.
echo 2. Ensure your network connection is normal.
echo 3. Try running as an administrator.
echo.
echo Press any key to exit...
PAUSE