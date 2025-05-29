@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

echo ==========================================
echo    南京大学教师评价自动填写程序 - 一键启动
echo ==========================================
echo.

REM 全面的环境检查函数
goto :check_environment

:check_environment
echo [1/4] 检查运行环境...

REM 首先尝试检查Python是否在PATH中
set "PYTHON_CMD="
set "PIP_CMD="

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

REM 检查用户目录下的Python
for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

REM 检查C盘根目录的Python
for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

REM 检查Program Files中的Python
for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        echo ✅ 在 %%i 找到Python
        goto :python_found
    )
)

REM 如果都没找到，提供自动安装选项
:python_not_found
echo ❌ 未找到Python安装
echo.
echo 检测到您的计算机未安装Python。
echo 程序可以为您自动下载并安装Python 3.11（推荐版本）。
echo.
echo 选项：
echo [1] 自动安装Python（推荐）
echo [2] 手动安装Python
echo [3] 退出程序
echo.
set /p install_choice="请选择 (1/2/3): "

if "%install_choice%"=="1" goto :auto_install_python
if "%install_choice%"=="2" goto :manual_install_guide
if "%install_choice%"=="3" goto :error_exit

echo 无效选择，默认选择手动安装指南...
goto :manual_install_guide

:auto_install_python
echo.
echo ==========================================
echo        自动安装Python
echo ==========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  检测到当前不是管理员权限
    echo 自动安装Python需要管理员权限，程序将尝试请求管理员权限...
    echo.
    echo 如果弹出UAC提示，请点击"是"来允许程序以管理员身份运行
    echo.
    pause
    
    REM 请求管理员权限重新运行脚本
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d \"%cd%\" && \"%~f0\"' -Verb RunAs"
    exit /b 0
)

echo ✅ 检测到管理员权限
echo.

REM 检测系统架构
echo 检测系统架构...
set "ARCH=x86"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x64"
if "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "ARCH=x64"
echo ✅ 系统架构: %ARCH%

REM 设置Python下载信息
set "PYTHON_VERSION=3.11.7"
if "%ARCH%"=="x64" (
    set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
    set "PYTHON_FILENAME=python-%PYTHON_VERSION%-amd64.exe"
) else (
    set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%.exe"
    set "PYTHON_FILENAME=python-%PYTHON_VERSION%.exe"
)

echo.
echo 准备下载Python %PYTHON_VERSION% (%ARCH%)...
echo 下载地址: %PYTHON_URL%
echo.

REM 创建临时目录
if not exist "temp" mkdir temp

REM 下载Python安装包
echo 正在下载Python安装包，请稍候...
echo 这可能需要几分钟时间，取决于您的网络速度...
echo.

powershell -Command "& {
    try {
        $ProgressPreference = 'SilentlyContinue'
        Write-Host '开始下载...'
        Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile 'temp\%PYTHON_FILENAME%' -UseBasicParsing
        Write-Host '✅ 下载完成'
        exit 0
    } catch {
        Write-Host '❌ 下载失败: ' + $_.Exception.Message
        exit 1
    }
}"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Python下载失败
    echo.
    echo 可能的原因：
    echo 1. 网络连接问题
    echo 2. 防火墙或杀毒软件拦截
    echo 3. 官方服务器暂时不可用
    echo.
    echo 建议：
    echo 1. 检查网络连接
    echo 2. 临时关闭杀毒软件后重试
    echo 3. 手动下载Python: https://www.python.org/downloads/
    echo.
    goto :cleanup_and_exit
)

REM 验证下载的文件
if not exist "temp\%PYTHON_FILENAME%" (
    echo ❌ 下载的文件不存在
    goto :cleanup_and_exit
)

echo.
echo ✅ Python安装包下载完成
echo 正在安装Python，请稍候...
echo.

REM 静默安装Python
echo 开始安装Python %PYTHON_VERSION%...
echo 安装选项：
echo - 添加Python到PATH
echo - 安装pip
echo - 安装所有用户
echo.

"temp\%PYTHON_FILENAME%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_doc=0 Include_dev=0 Include_debug=0 Include_launcher=1 Include_tcltk=1 Include_pip=1

if %errorlevel% neq 0 (
    echo ❌ Python安装失败
    echo 错误代码: %errorlevel%
    echo.
    echo 请尝试：
    echo 1. 手动运行 temp\%PYTHON_FILENAME%
    echo 2. 或者访问 https://www.python.org/downloads/ 手动下载安装
    echo.
    goto :cleanup_and_exit
)

echo ✅ Python安装完成！
echo.

REM 清理安装文件
echo 清理临时文件...
del "temp\%PYTHON_FILENAME%" >nul 2>&1
rmdir "temp" >nul 2>&1

echo.
echo ==========================================
echo        Python安装成功
echo ==========================================
echo.
echo Python %PYTHON_VERSION% 已成功安装到您的系统中
echo.
echo 程序将重新启动以使用新安装的Python...
echo.
pause

REM 重新启动脚本以使用新安装的Python
echo 重新启动程序...
cmd /c "%~f0"
exit /b 0

:cleanup_and_exit
if exist "temp\%PYTHON_FILENAME%" del "temp\%PYTHON_FILENAME%" >nul 2>&1
if exist "temp" rmdir "temp" >nul 2>&1
goto :error_exit

:manual_install_guide
echo.
echo ==========================================
echo        手动安装Python指南
echo ==========================================
echo.
echo 请按照以下步骤手动安装Python：
echo.
echo 1. 访问 https://www.python.org/downloads/
echo 2. 下载Python 3.8或更高版本（推荐3.11）
echo 3. 运行下载的安装程序
echo 4. ⚠️  重要：安装时务必勾选 "Add Python to PATH"
echo 5. 点击"Install Now"完成安装
echo 6. 安装完成后重新运行此脚本
echo.
echo 如果已经安装Python，请确认：
echo - Python版本为3.8或更高
echo - 安装时已勾选"Add Python to PATH"
echo - 或者手动将Python路径添加到系统环境变量
echo.
echo 技术提示：
echo 您也可以运行 fix/diagnose.bat 来诊断Python安装问题
echo.
goto :error_exit

:python_found
REM 获取Python版本
for /f "tokens=2" %%i in ('"%PYTHON_CMD%" --version 2^>^&1') do set pyver=%%i
echo ✅ 检测到Python版本: %pyver%

REM 检查pip是否可用
"%PIP_CMD%" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ pip未找到，请重新安装Python并确保包含pip
    echo.
    echo 尝试的pip路径: %PIP_CMD%
    echo.
    
    REM 尝试修复pip
    echo 尝试修复pip...
    "%PYTHON_CMD%" -m ensurepip --upgrade >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ pip修复成功
        set "PIP_CMD=%PYTHON_CMD% -m pip"
    ) else (
        echo ❌ pip修复失败，请重新安装Python
        goto :error_exit
    )
) else (
    echo ✅ pip检查通过
)

goto :check_files

:check_files
echo [2/4] 检查必需文件...

REM 检查main.py是否存在
if not exist "main.py" (
    echo ❌ 未找到main.py文件
    echo 请确保在正确的目录中运行此脚本
    goto :error_exit
)
echo ✅ main.py文件存在

REM 检查config.py，如果不存在则创建
if not exist "config.py" (
    echo ⚠️  config.py不存在，正在创建...
    goto :create_config
)
echo ✅ config.py文件存在
goto :install_dependencies

:create_config
echo [3/4] 创建配置文件...
(
    echo # 南京大学教师评价系统配置文件
    echo.
    echo # 登录页面URL
    echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # 评价系统URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver设置（推荐使用自动管理）
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py
echo ✅ 配置文件创建成功
goto :install_dependencies

:install_dependencies
echo [3/4] 安装/检查依赖包...

REM 如果存在requirements.txt，使用它安装依赖
if exist "requirements.txt" (
    echo 从requirements.txt安装依赖...
    "%PIP_CMD%" install -r requirements.txt --quiet
    if %errorlevel% neq 0 (
        echo ⚠️  从requirements.txt安装依赖时出现问题，尝试单独安装
        goto :install_basic_deps
    )
    echo ✅ 依赖安装成功
    goto :prepare_directories
)

:install_basic_deps
echo 安装基本依赖包...
echo 安装selenium...
"%PIP_CMD%" install selenium --quiet
if %errorlevel% neq 0 (
    echo ❌ 安装selenium失败
    echo 请检查网络连接或尝试手动运行: %PIP_CMD% install selenium
    goto :error_exit
)

echo 安装webdriver-manager...
"%PIP_CMD%" install webdriver-manager --quiet
if %errorlevel% neq 0 (
    echo ❌ 安装webdriver-manager失败
    echo 请检查网络连接或尝试手动运行: %PIP_CMD% install webdriver-manager
    goto :error_exit
)

echo 安装python-dotenv...
"%PIP_CMD%" install python-dotenv --quiet
if %errorlevel% neq 0 (
    echo ❌ 安装python-dotenv失败
    echo 请检查网络连接或尝试手动运行: %PIP_CMD% install python-dotenv
    goto :error_exit
)

echo ✅ 基本依赖安装成功

:prepare_directories
echo [4/4] 准备运行环境...

REM 创建logs目录
if not exist "logs" mkdir logs

REM 创建drivers目录
if not exist "drivers" mkdir drivers

echo.
echo ==========================================
echo            环境检查完成
echo        启动教师评价自动填写程序
echo ==========================================
echo.

goto :run_program

:run_program
REM 运行主程序并捕获错误
echo 正在启动程序...
echo.

REM 设置带日期时间戳的日志文件名
set "CURRENT_DATETIME=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "CURRENT_DATETIME=!CURRENT_DATETIME: =0!"
set "LOG_FILE=logs\run_log_!CURRENT_DATETIME!.log"
echo 日志将记录到: !LOG_FILE!
echo.

"%PYTHON_CMD%" main.py > "!LOG_FILE!" 2>&1
set EXIT_CODE=%errorlevel%

echo.
if %EXIT_CODE% equ 0 (
    echo ✅ 程序运行完毕
) else (
    echo ❌ 程序运行时出错 (退出代码: %EXIT_CODE%^)
    echo    请查看日志文件 !LOG_FILE! 获取详细错误信息
    echo.
    echo 可能的解决方案：
    echo 1. 检查网络连接是否正常
    echo 2. 确认Chrome浏览器已安装并更新到最新版本
    echo 3. 检查是否有杀毒软件拦截程序运行
    echo 4. 尝试以管理员身份运行此脚本
    echo 5. 运行fix文件夹中的修复工具
)

goto :normal_exit

:error_exit
echo.
echo ❌ 环境检查失败，程序无法运行
echo.
echo 故障排除建议：
echo 1. 确保Python 3.8+正确安装并添加到PATH
echo 2. 确保网络连接正常，能够下载Python包
echo 3. 尝试以管理员身份运行此脚本
echo 4. 如果问题持续存在，请运行fix文件夹中的修复工具
echo.
echo 按任意键退出...
pause >nul
exit /b 1

:normal_exit
echo.
echo 程序输出已记录到 !LOG_FILE!
echo 按任意键退出...
PAUSE
exit /b %EXIT_CODE% 