@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        系统环境诊断工具
echo ==========================================
echo.

echo [诊断开始] %date% %time%
echo.

REM 检查操作系统版本
echo ════ 系统信息 ════
echo OS版本: 
ver
echo.

echo 当前目录: %cd%
echo.

REM 全面检查Python安装
echo ════ Python环境检查 ════
set "PYTHON_CMD="
set "PIP_CMD="
set "PYTHON_FOUND=0"

REM 方法1: 直接检查python命令
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    set "PIP_CMD=pip"
    set "PYTHON_FOUND=1"
    echo ✅ Python已安装（通过PATH）
    python --version
    echo Python路径:
    where python 2>nul
    echo.
    goto :check_pip
)

REM 方法2: 尝试python3命令
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python3"
    set "PIP_CMD=pip3"
    set "PYTHON_FOUND=1"
    echo ✅ Python已安装（通过python3命令）
    python3 --version
    echo Python路径:
    where python3 2>nul
    echo.
    goto :check_pip
)

REM 方法3: 检查常见的Python安装路径
echo 🔍 在PATH中未找到Python，正在检查常见安装路径...

for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        set "PYTHON_FOUND=1"
        echo ✅ 在 %%i 找到Python
        "%%i\python.exe" --version
        echo.
        goto :check_pip
    )
)

for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        set "PYTHON_FOUND=1"
        echo ✅ 在 %%i 找到Python
        "%%i\python.exe" --version
        echo.
        goto :check_pip
    )
)

for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        set "PYTHON_FOUND=1"
        echo ✅ 在 %%i 找到Python
        "%%i\python.exe" --version
        echo.
        goto :check_pip
    )
)

REM 如果都没找到
if %PYTHON_FOUND% equ 0 (
    echo ❌ Python未安装或未添加到PATH
    echo 请安装Python 3.8+并确保添加到PATH
    echo 下载地址: https://www.python.org/downloads/
    echo 安装时务必勾选 "Add Python to PATH"
    echo.
    goto :check_chrome
)

:check_pip
REM 检查pip
"%PIP_CMD%" --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ pip可用
    "%PIP_CMD%" --version
) else (
    echo ❌ pip不可用
    echo 请重新安装Python确保包含pip
)
echo.

REM 检查Chrome浏览器
:check_chrome
echo ════ Chrome浏览器检查 ════
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    echo ✅ Chrome已安装 (64位)
    powershell -Command "try { (Get-Item 'C:\Program Files\Google\Chrome\Application\chrome.exe').VersionInfo.FileVersion } catch { 'Unable to get version' }" 2>nul
) else if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    echo ✅ Chrome已安装 (32位)
    powershell -Command "try { (Get-Item 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe').VersionInfo.FileVersion } catch { 'Unable to get version' }"
) else (
    echo ❌ Chrome未找到
    echo 请安装Chrome浏览器: https://www.google.com/chrome/
)
echo.

REM 检查网络连接
echo ════ 网络连接检查 ════
echo 测试网络连接...
ping -n 1 www.baidu.com >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 网络连接正常
) else (
    echo ❌ 网络连接异常
)

ping -n 1 authserver.nju.edu.cn >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 可以访问南大认证服务器
) else (
    echo ❌ 无法访问南大认证服务器
)
echo.

REM 检查必要文件
echo ════ 项目文件检查 ════
if exist "main.py" (
    echo ✅ main.py存在
) else (
    echo ❌ main.py不存在
)

if exist "config.py" (
    echo ✅ config.py存在
) else (
    echo ❌ config.py不存在
)

if exist "requirements.txt" (
    echo ✅ requirements.txt存在
    echo 内容:
    type requirements.txt
) else (
    echo ⚠️  requirements.txt不存在
)

if exist "logs" (
    echo ✅ logs目录存在
) else (
    echo ⚠️  logs目录不存在
)
echo.

REM 检查Python依赖包
echo ════ Python包检查 ════
if %errorlevel% equ 0 (
    echo 检查selenium...
    python -c "import selenium; print('✅ selenium版本:', selenium.__version__)" 2>nul || echo ❌ selenium未安装
    
    echo 检查webdriver_manager...
    python -c "import webdriver_manager; print('✅ webdriver_manager已安装')" 2>nul || echo ❌ webdriver_manager未安装
    
    echo 检查其他依赖...
    python -c "import time, os, sys; print('✅ 标准库正常')" 2>nul || echo ❌ 标准库异常
)
echo.

REM 浏览器连接测试
echo ════ 浏览器连接测试 ════
echo 测试浏览器基本功能...
python -c "
try:
    from selenium import webdriver
    print('正在启动Chrome浏览器...')
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    driver = webdriver.Chrome(options=options)
    print('✅ Chrome浏览器启动成功')
    
    print('测试百度连接...')
    driver.get('https://www.baidu.com')
    if 'baidu' in driver.current_url:
        print('✅ 网络连接正常')
    else:
        print('❌ 网络连接异常')
    
    print('测试南大服务器连接...')
    driver.get('https://authserver.nju.edu.cn')
    if 'authserver.nju.edu.cn' in driver.current_url:
        print('✅ 南大服务器可访问')
    else:
        print('❌ 无法访问南大服务器')
    
    driver.quit()
    print('✅ 浏览器测试完成')
except Exception as e:
    print(f'❌ 浏览器测试失败: {e}')
    print('可能原因：Chrome未安装或驱动版本不匹配')
" 2>nul || echo ❌ 浏览器测试失败：请确保已安装Chrome浏览器
echo.

REM 检查权限
echo ════ 权限检查 ════
echo 当前用户:
whoami
echo.

REM 尝试写入测试
echo test > test_write.tmp 2>nul
if exist test_write.tmp (
    echo ✅ 具有写入权限
    del test_write.tmp >nul 2>&1
) else (
    echo ❌ 缺少写入权限
)
echo.

REM 检查杀毒软件
echo ════ 安全软件检查 ════
echo 检查Windows Defender状态...
powershell -Command "Get-MpPreference | Select-Object -Property DisableRealtimeMonitoring" 2>nul
echo.

echo ════ 诊断完成 ════
echo.
echo 如果发现问题，请根据以上检查结果：
echo 1. 安装缺失的软件或依赖
echo 2. 检查网络连接和防火墙设置
echo 3. 确保具有足够的系统权限
echo 4. 考虑临时关闭杀毒软件再试
echo.
echo 按任意键退出...
PAUSE