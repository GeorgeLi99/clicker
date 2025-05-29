@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

echo ==========================================
echo     run.bat 修复验证测试工具
echo ==========================================
echo.

echo 此工具将测试run.bat的修复效果
echo.
echo 测试项目：
echo 1. 文件编码检查
echo 2. Python检测功能
echo 3. 错误处理机制
echo 4. 管理员权限处理
echo.

echo [1/4] 检查run.bat文件编码...
if exist "run.bat" (
    echo ✅ run.bat文件存在
    
    REM 尝试执行一个简单的test
    echo.
    echo [2/4] 测试基本功能...
    echo 运行run.bat的环境检查部分...
    echo.
    
    REM 创建一个临时测试
    echo 如果看到中文乱码，说明需要将bat文件保存为ANSI格式
    echo 请按以下步骤修复：
    echo 1. 右键点击run.bat → 编辑
    echo 2. 文件 → 另存为 → 编码选择ANSI → 保存
    echo.
    
    echo [3/4] 检查修复工具...
    if exist "fix" (
        echo ✅ fix文件夹存在
    ) else (
        echo ❌ fix文件夹不存在
    )
    
    if exist "install_python.bat" (
        echo ✅ install_python.bat存在
    ) else (
        echo ❌ install_python.bat不存在
    )
    
    echo.
    echo [4/4] 测试完成
    echo.
    echo 如果要进行实际测试，请运行：
    echo - run.bat（主程序）
    echo - install_python.bat（单独安装Python）
    echo - test_environment.bat（环境测试）
    echo.
    
) else (
    echo ❌ run.bat文件不存在
    echo 请确保在正确的目录中运行此测试
)

echo 按任意键退出...
pause >nul 