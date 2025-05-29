@echo off
echo ==========================================
echo    教室评价表自动填写程序 - 一键启动脚本
echo ==========================================
echo.

REM 检查Python是否已安装
echo 正在检查Python环境...
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo Python未安装，正在打开Python官方下载页面...
    start https://www.python.org/downloads/
    echo 请安装Python 3.8或以上版本，安装时勾选"Add Python to PATH"选项
    echo 安装完成后请重新运行此脚本
    pause
    exit /b 1
)

REM 验证Python版本
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo 检测到Python版本: %pyver%

REM 检查是否需要创建虚拟环境
if not exist venv (
    echo 正在创建Python虚拟环境...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo 创建虚拟环境失败，请确保安装了venv模块
        pause
        exit /b 1
    )
    echo 虚拟环境创建成功
) else (
    echo 检测到已存在的虚拟环境
)

REM 激活虚拟环境
echo 正在激活虚拟环境...
call venv\Scripts\activate

REM 检查依赖是否已安装
echo 正在检查并安装依赖...
if not exist venv\Lib\site-packages\selenium (
    echo 安装selenium包...
    pip install selenium
)

if not exist venv\Lib\site-packages\webdriver_manager (
    echo 安装webdriver_manager包...
    pip install webdriver-manager
)

REM 检查requirements.txt是否存在，如果存在则安装其中的依赖
if exist requirements.txt (
    echo 从requirements.txt安装依赖...
    pip install -r requirements.txt
)

REM 检查配置文件是否存在
if not exist config.py (
    echo 配置文件不存在，正在创建默认配置...
    (
        echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do?t_s=1748431299034&amp_sec_version_=1&gid_=U3Z3VnNabUl0R2M1TTJGcVlibDNTYWRIMVd6SGpFY0NJMG5teld5eDBDcUpFaHNSU0k3ZlBRTldCR29BODIzY0xXT0VzRWhEendYMmZPRmEzSDhFQnc9PQ&EMAP_LANG=zh&THEME=magenta"
        echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do%%3Ft_s%%3D1748431299034%%26amp_sec_version_%%3D1%%26gid_%%3DU3Z3VnNabUl0R2M1TTJGcVlibDNTYWRIMVd6SGpFY0NJMG5teld5eDBDcUpFaHNSU0k3ZlBRTldCR29BODIzY0xXT0VzRWhEendYMmZPRmEzSDhFQnc9PQ%%26EMAP_LANG%%3Dzh%%26THEME%%3Dmagenta"
    ) > config.py
    echo 已创建默认配置文件
)

REM 检查Chrome浏览器驱动
echo 正在检查Chrome浏览器驱动...
python -c "from selenium import webdriver; from selenium.webdriver.chrome.service import Service; from webdriver_manager.chrome import ChromeDriverManager; print('设置Chrome驱动...'); driver = webdriver.Chrome(service=Service(ChromeDriverManager().install())); driver.quit(); print('Chrome驱动设置成功')" || (
    echo Chrome驱动设置失败，请检查Chrome浏览器是否正确安装
    pause
    exit /b 1
)

echo.
echo ==========================================
echo            准备工作已完成
echo        开始运行教室评价自动填写程序
echo ==========================================
echo.

REM 启动主程序
python main.py

REM 完成后暂停
echo.
echo 程序已执行完毕，请按任意键退出...
pause > nul 