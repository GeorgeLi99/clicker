@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

REM 首先检查Python环境
set "PYTHON_CMD="
set "PIP_CMD="

:check_python
REM 方法1: 直接检查python命令
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    set "PIP_CMD=pip"
    goto :start
)

REM 方法2: 尝试python3命令
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python3"
    set "PIP_CMD=pip3"
    goto :start
)

REM 方法3: 检查常见的Python安装路径
for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        goto :start
    )
)

for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        goto :start
    )
)

for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        goto :start
    )
)

REM 如果都没找到，显示错误信息
echo ❌ 未找到Python安装
echo.
echo 请先安装Python后再运行此工具
echo 访问 https://www.python.org/downloads/ 下载Python
echo 安装时务必勾选 "Add Python to PATH"
echo.
echo 按任意键退出...
PAUSE
exit /b 1

:start
echo ==========================================
echo        高级修复工具
echo ==========================================
echo.
echo ✅ 已检测到Python: %PYTHON_CMD%
echo.
echo 此工具将尝试解决常见问题。请选择一个选项：
echo.
echo [1] 重新安装Python依赖包
echo [2] 清理并重新下载ChromeDriver
echo [3] 重新创建配置文件
echo [4] 清理日志和临时文件
echo [5] 检查/修复Python环境变量（信息）
echo [6] 完全重置（谨慎使用）
echo [7] 快速修复（推荐 - 相当于quick_fix.bat）
echo [0] 退出
echo.

set /p choice="请输入选项编号: "

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
echo ==== 重新安装Python依赖包 ====
echo 清理pip缓存...
"%PIP_CMD%" cache purge 2>nul
echo 卸载旧版本...
"%PIP_CMD%" uninstall selenium webdriver-manager python-dotenv -y 2>nul
echo 重新安装...
"%PIP_CMD%" install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ 依赖包重新安装成功
) else (
    echo ❌ 重新安装依赖包失败
    echo 请检查网络连接并尝试手动运行: %PIP_CMD% install selenium webdriver-manager python-dotenv
)
goto :done

:fix_chromedriver
echo ==== 清理并重新下载ChromeDriver ====
echo 删除旧驱动...
rmdir /s /q drivers 2>nul
mkdir drivers 2>nul
echo 清理webdriver-manager缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ ChromeDriver已清理。下次运行时将重新下载。
goto :done

:fix_config
echo ==== 重新创建配置文件 ====
if exist config.py (
    echo 备份旧配置文件...
    copy config.py config.py.backup >nul 2>&1
)
echo 创建新配置文件...
(
    echo # 南京大学教师评价系统配置文件
    echo.
    echo # 登录页面URL
    echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # 评价系统URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver设置（推荐自动管理）
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py
echo ✅ 配置文件重新创建成功。
goto :done

:cleanup
echo ==== 清理日志和临时文件 ====
echo 清理日志文件...
rmdir /s /q logs 2>nul
mkdir logs 2>nul
echo 清理临时文件...
del *.log 2>nul
del test_*.py 2>nul
del driver_path.txt 2>nul
del *.tmp 2>nul
echo 清理Python缓存...
rmdir /s /q __pycache__ 2>nul
echo ✅ 清理完成。
goto :done

:fix_python_path
echo ==== 检查Python环境变量 ====
echo 在您的PATH环境变量中找到的Python路径：
where python 2>nul
echo.
echo 如果上面没有显示Python路径，请：
echo 1. 重新安装Python，安装时确保勾选"Add Python to PATH"
echo 2. 或者手动将Python添加到环境变量中
echo 3. 修改后重启命令提示符窗口
echo.
echo Python安装目录通常位于：
echo - C:\Users\%USERNAME%\AppData\Local\Programs\Python\
echo - C:\Python3x\
echo.
pause
goto :done

:full_reset
echo ==== 完全重置（警告） ====
echo ⚠️  这将删除所有本地配置和缓存。确定要继续吗？
echo 输入YES确认，或输入其他任意键取消：
set /p confirm="确认: "
if /I not "%confirm%"=="YES" (
    echo 操作已取消。
    goto :done
)

echo 执行完全重置...
rmdir /s /q logs 2>nul
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q venv 2>nul
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
del config.py 2>nul
del *.log 2>nul
del *.tmp 2>nul
"%PIP_CMD%" cache purge 2>nul
"%PIP_CMD%" uninstall selenium webdriver-manager python-dotenv -y 2>nul

echo ✅ 完全重置完成。请重新运行run.bat。
goto :done

:quick_fix_action
echo ==== 快速修复 ====
echo 执行快速修复...
echo.
echo 这将自动执行以下操作：
echo - 清理所有缓存
echo - 重新安装依赖包
echo - 更新配置文件
echo - 验证环境
echo.

echo 开始修复...
echo.

echo [1/4] 清理缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir drivers 2>nul
mkdir logs 2>nul
echo ✅ 缓存已清理。

echo [2/4] 重新安装依赖包...
"%PIP_CMD%" cache purge 2>nul
"%PIP_CMD%" uninstall selenium webdriver-manager python-dotenv -y 2>nul
"%PIP_CMD%" install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ 依赖包重新安装成功。
) else (
    echo ❌ 依赖包重新安装失败。
)

echo [3/4] 更新配置文件...
(
    echo # 南京大学教师评价系统配置文件
    echo.
    echo # 登录页面URL
    echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # 评价系统URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver设置
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py
echo ✅ 配置文件已更新。

echo [4/4] 验证环境...
"%PYTHON_CMD%" -c "import selenium; print('✅ selenium正常工作')" 2>nul || echo ❌ selenium错误
echo ✅ 快速修复完成。

echo.
echo 修复完成。建议现在运行run.bat测试应用。
goto :done

:invalid_choice
echo ❌ 无效选项。请重新选择。
PAUSE
cls
goto :start

:done
echo.
echo 操作完成！建议重新运行run.bat检查是否一切正常。
goto :exit_script

:exit_script
echo.
echo 按任意键退出...
PAUSE
exit /b 0 