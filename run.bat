@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo    教室评价表自动填写程序 - 一键启动脚本
echo ==========================================
echo.

REM 基本环境检查函数
goto :check_environment

:check_environment
echo [1/4] 正在检查运行环境...

REM 检查Python是否已安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python未安装或未添加到PATH
    echo.
    echo 请按照以下步骤安装Python：
    echo 1. 访问 https://www.python.org/downloads/
    echo 2. 下载Python 3.8或更高版本
    echo 3. 安装时务必勾选 "Add Python to PATH" 选项
    echo 4. 安装完成后重新运行此脚本
    echo.
    goto :error_exit
)

REM 获取Python版本
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo ✅ 检测到Python版本: %pyver%

REM 检查pip是否可用
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ pip未找到，请重新安装Python并确保包含pip
    goto :error_exit
)

echo ✅ pip检查通过
goto :check_files

:check_files
echo [2/4] 正在检查必要文件...

REM 检查main.py是否存在
if not exist "main.py" (
    echo ❌ main.py文件未找到
    echo 请确保在正确的目录下运行此脚本
    goto :error_exit
)
echo ✅ main.py文件存在

REM 检查requirements.txt是否存在
if not exist "requirements.txt" (
    echo ⚠️  requirements.txt文件未找到，将手动安装基本依赖
    goto :install_basic_deps
)
echo ✅ requirements.txt文件存在
goto :create_config

:install_basic_deps
echo [3/4] 正在安装基本依赖...
echo 安装selenium...
pip install selenium --quiet
if %errorlevel% neq 0 (
    echo ❌ 安装selenium失败
    goto :error_exit
)

echo 安装webdriver-manager...
pip install webdriver-manager --quiet
if %errorlevel% neq 0 (
    echo ❌ 安装webdriver-manager失败
    goto :error_exit
)

echo 安装python-dotenv...
pip install python-dotenv --quiet
if %errorlevel% neq 0 (
    echo ❌ 安装python-dotenv失败
    goto :error_exit
)

echo ✅ 基本依赖安装完成
goto :create_config

:create_config
echo [3/4] 正在检查配置文件...

REM 检查config.py是否存在，如果不存在则创建
if not exist "config.py" (
    echo 正在创建配置文件...
    (
        echo # 南京大学教室评价系统配置文件
        echo.
        echo # 登录页面URL
        echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
        echo.
        echo # 评价系统URL
        echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
        echo.
        echo # ChromeDriver设置（优先使用自动管理）
        echo USE_AUTO_DRIVER = True
        echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
    ) > config.py
    echo ✅ 配置文件已创建
) else (
    echo ✅ 配置文件已存在
)

goto :install_dependencies

:install_dependencies
echo [4/4] 正在安装/检查依赖包...

REM 如果存在requirements.txt，使用它安装依赖
if exist "requirements.txt" (
    echo 从requirements.txt安装依赖...
    pip install -r requirements.txt --quiet
    if %errorlevel% neq 0 (
        echo ⚠️  从requirements.txt安装依赖时出现问题，尝试单独安装
        goto :install_basic_deps
    )
    echo ✅ 依赖包安装完成
)

REM 创建日志目录
if not exist "logs" mkdir logs

echo.
echo ==========================================
echo            环境检查完成
echo        正在启动教室评价自动填写程序
echo ==========================================
echo.

goto :run_program

:run_program
REM 运行主程序，并捕获错误
echo 正在启动程序...
echo.

python main.py
set EXIT_CODE=%errorlevel%

echo.
if %EXIT_CODE% equ 0 (
    echo ✅ 程序正常结束
) else (
    echo ❌ 程序执行时出现错误 (退出码: %EXIT_CODE%^)
    echo.
    echo 可能的解决方案：
    echo 1. 检查网络连接是否正常
    echo 2. 确认Chrome浏览器已安装并更新到最新版本
    echo 3. 检查是否有杀毒软件阻止程序运行
    echo 4. 尝试以管理员身份运行此脚本
)

goto :normal_exit

:error_exit
echo.
echo ❌ 环境检查失败，程序无法运行
echo.
echo 故障排除建议：
echo 1. 确保Python 3.8+已正确安装并添加到PATH
echo 2. 确保网络连接正常，能够下载Python包
echo 3. 尝试以管理员身份运行此脚本
echo 4. 如果问题持续，请联系技术支持
echo.
echo 按任意键退出...
pause >nul
exit /b 1

:normal_exit
echo.
echo 按任意键退出...
pause >nul
exit /b %EXIT_CODE% 