@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        浏览器连接测试工具
echo ==========================================
echo.

echo 正在测试浏览器连接...
echo.

REM 首先检查Python环境
set "PYTHON_CMD="

REM 方法1: 直接检查python命令
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    goto :python_found
)

REM 方法2: 尝试python3命令
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python3"
    goto :python_found
)

REM 方法3: 检查常见的Python安装路径
echo 🔍 在PATH中未找到Python，正在检查常见安装路径...

for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

REM 如果都没找到，显示错误信息
echo ❌ 未找到Python安装
echo.
echo 请先安装Python后再运行此工具
echo 访问 https://www.python.org/downloads/ 下载Python
echo.
goto :exit_with_error

:python_found
echo ✅ 找到Python: %PYTHON_CMD%
echo.

"%PYTHON_CMD%" -c "
import sys
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service
    from webdriver_manager.chrome import ChromeDriverManager
    import time

    print('=== 浏览器连接测试开始 ===')
    print()

    # 测试1: 基本浏览器启动
    print('1. 测试Chrome浏览器启动...')
    try:
        options = webdriver.ChromeOptions()
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        driver = webdriver.Chrome(options=options)
        print('✅ Chrome浏览器启动成功')
        
        # 测试百度
        print('2. 测试网络连接(百度)...')
        driver.get('https://www.baidu.com')
        time.sleep(3)
        if 'baidu' in driver.current_url and len(driver.page_source) > 1000:
            print('✅ 网络连接正常，页面内容加载成功')
        else:
            print('❌ 页面加载异常')
            print(f'当前URL: {driver.current_url}')
            print(f'页面源码长度: {len(driver.page_source)}')
        
        # 测试南大登录页面
        print('3. 测试南大登录页面...')
        login_url = 'https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do'
        driver.get(login_url)
        time.sleep(5)
        
        current_url = driver.current_url
        page_title = driver.title
        page_length = len(driver.page_source)
        
        print(f'   当前URL: {current_url}')
        print(f'   页面标题: {page_title}')
        print(f'   页面内容长度: {page_length}')
        
        if 'authserver.nju.edu.cn' in current_url and page_length > 1000:
            print('✅ 南大登录页面访问正常')
            
            # 检查关键元素
            try:
                from selenium.webdriver.common.by import By
                username_element = driver.find_element(By.ID, 'username')
                print('✅ 检测到用户名输入框')
            except:
                print('⚠️ 未检测到用户名输入框')
                
        elif page_length < 100:
            print('❌ 页面内容为空或加载失败')
            print('可能的原因：')
            print('  - 网络连接问题')
            print('  - Chrome驱动版本不匹配')
            print('  - 防火墙阻止访问')
        else:
            print(f'⚠️ 页面跳转异常: {current_url}')
        
        driver.quit()
        print('✅ 浏览器已关闭')
        
    except Exception as e:
        print(f'❌ 浏览器测试失败: {e}')
        try:
            driver.quit()
        except:
            pass
    
    print()
    print('=== 测试完成 ===')
    
except ImportError as ie:
    print(f'❌ 导入模块失败: {ie}')
    print('请确保selenium和webdriver-manager已安装')
    print('可以运行: pip install selenium webdriver-manager')
except Exception as e:
    print(f'❌ 测试过程中出错: {e}')
"

:exit_with_pause
echo.
echo 测试完成！
echo 如果显示"页面内容为空或加载失败"，请尝试：
echo 1. 运行fix.bat并选择选项2清理ChromeDriver缓存
echo 2. 确保网络连接正常
echo 3. 尝试以管理员身份运行
echo.
echo 按任意键退出...
PAUSE
exit /b 0

:exit_with_error
echo 按任意键退出...
PAUSE
exit /b 1