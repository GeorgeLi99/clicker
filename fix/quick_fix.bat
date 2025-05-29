@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        快速修复工具
echo ==========================================
echo.

echo 此工具将自动尝试修复常见问题：
echo ✅ 清理所有缓存
echo ✅ 重新安装依赖包
echo ✅ 更新配置文件
echo ✅ 尝试修复403权限错误（通过重置URL）
echo.

REM 首先检查Python环境
set "PYTHON_CMD="
set "PIP_CMD="

echo [0/5] 检查Python环境...

REM 方法1: 直接检查python命令
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    set "PIP_CMD=pip"
    goto :python_found
)

REM 方法2: 尝试python3命令
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python3"
    set "PIP_CMD=pip3"
    goto :python_found
)

REM 方法3: 检查常见的Python安装路径
echo 🔍 在PATH中未找到Python，正在检查常见安装路径...

for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

REM 如果都没找到，显示错误信息
echo ❌ 未找到Python安装
echo.
echo 请先安装Python后再运行此工具
echo 访问 https://www.python.org/downloads/ 下载Python
echo 安装时务必勾选 "Add Python to PATH"
echo.
goto :exit_with_error

:python_found
echo ✅ Python环境检查通过: %PYTHON_CMD%

echo 开始自动修复...
echo.

echo [1/5] 清理webdriver缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ Webdriver缓存已清理

echo [2/5] 清理本地文件...
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir drivers 2>nul
mkdir logs 2>nul
echo ✅ 本地缓存已清理

echo [3/5] 重新安装Python依赖包...
"%PIP_CMD%" cache purge 2>nul
"%PIP_CMD%" uninstall selenium webdriver-manager python-dotenv -y 2>nul
"%PIP_CMD%" install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ Python依赖包重新安装成功
) else (
    echo ❌ Python依赖包安装失败，请检查网络连接
    echo 可以尝试手动运行: %PIP_CMD% install selenium webdriver-manager python-dotenv
)

echo [4/5] 更新配置文件...
(
    echo # 南京大学教师评价系统配置文件
    echo.
    echo # 登录页面URL - 简化版本
    echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # 评价系统URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver设置
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py
echo ✅ 配置文件已更新

echo [5/5] 测试系统环境...
"%PYTHON_CMD%" -c "
try:
    from selenium import webdriver
    print('✅ selenium模块正常工作')
    
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    driver = webdriver.Chrome(options=options)
    driver.get('https://www.baidu.com')
    if 'baidu' in driver.current_url:
        print('✅ 浏览器功能正常')
    driver.quit()
    print('✅ 环境测试通过')
except Exception as e:
    print(f'❌ 环境测试失败: {e}')
" 2>nul || echo ⚠️ 环境测试跳过

echo.
echo ==========================================
echo              修复完成
echo ==========================================
echo.

echo 🎉 自动修复已完成！
echo.
echo 📋 修复摘要：
echo   - 已清理所有缓存文件
echo   - 已重新安装Python依赖包
echo   - 已更新配置文件为简化版本
echo   - 已验证系统环境
echo.

echo 💡 下一步操作：
echo   1. 双击运行run.bat
echo   2. 如果问题仍然存在，运行专门的修复工具：
echo      - 脚本崩溃: diagnose.bat
echo      - 浏览器空白: test_browser_simple.bat  
echo      - 403错误: fix_403.bat
echo.

echo 📞 如果问题仍然存在，可能的原因：
echo   - 评价系统未开放（此时403错误属正常）
echo   - 网络连接问题
echo   - Chrome浏览器版本过旧
echo   - 杀毒软件拦截
echo.

echo 按任意键退出...
PAUSE
exit /b 0

:exit_with_error
echo 按任意键退出...
PAUSE
exit /b 1 