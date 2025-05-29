@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo 正在检查Python环境...

python --version >nul 2>&1
if errorlevel 1 (
    echo Python未安装，请先安装Python 3.8或更高版本
    echo 下载地址：https://www.python.org/downloads/
    pause
    exit /b 1
)

echo 正在检查依赖包...
pip install -r requirements.txt

echo 开始打包程序...
python build.py

echo.
echo 如果打包成功，可执行文件将位于 dist 目录下
echo 按任意键退出...
PAUSE