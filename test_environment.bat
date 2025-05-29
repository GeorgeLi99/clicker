@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        快速环境测试
echo ==========================================
echo.

REM 检查Python环境
set "PYTHON_CMD="

REM 方法1: 直接检查python命令
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    goto :test_python
)

REM 方法2: 尝试python3命令
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python3"
    goto :test_python
)

REM 方法3: 检查常见安装路径
for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        goto :test_python
    )
)

for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        goto :test_python
    )
)

for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        goto :test_python
    )
)

echo ❌ 未找到Python安装
echo 请安装Python 3.8+并确保添加到PATH
echo 下载地址: https://www.python.org/downloads/
goto :exit_error

:test_python
echo ✅ 找到Python: %PYTHON_CMD%
"%PYTHON_CMD%" --version
echo.

echo 测试Python依赖包...
"%PYTHON_CMD%" -c "
print('正在测试依赖包...')
try:
    import selenium
    print('✅ selenium: ', selenium.__version__)
except ImportError:
    print('❌ selenium 未安装')

try:
    import webdriver_manager
    print('✅ webdriver_manager: 已安装')
except ImportError:
    print('❌ webdriver_manager 未安装')

try:
    from selenium import webdriver
    print('✅ webdriver 模块正常')
except ImportError:
    print('❌ webdriver 模块导入失败')

print()
print('测试Chrome浏览器启动...')
try:
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    driver = webdriver.Chrome(options=options)
    driver.get('https://www.baidu.com')
    if 'baidu' in driver.current_url:
        print('✅ Chrome浏览器和驱动正常工作')
    driver.quit()
except Exception as e:
    print(f'❌ Chrome浏览器测试失败: {e}')
    print('请确保已安装Chrome浏览器')

print()
print('=== 环境测试完成 ===')
"

echo.
echo 如果上述测试有任何失败项，请：
echo 1. 运行 fix/quick_fix.bat 进行修复
echo 2. 或者运行 fix/diagnose.bat 进行详细诊断
echo.
goto :exit_normal

:exit_error
echo.
echo 环境测试失败，请先解决Python安装问题
echo.
echo 按任意键退出...
PAUSE
exit /b 1

:exit_normal
echo 按任意键退出...
PAUSE
exit /b 0 