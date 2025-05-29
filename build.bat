@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

echo ==========================================
echo    南京大学教师评价程序 - 快速打包工具
echo ==========================================
echo.

echo 正在运行打包脚本...
python build_simple.py

echo.
echo 打包完成！
pause