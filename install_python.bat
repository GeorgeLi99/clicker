@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        Python自动安装工具
echo ==========================================
echo.

echo 此工具将为您自动下载并安装Python 3.11
echo 适用于Windows 10/11 (32位/64位)
echo.

REM 检查是否已安装Python
echo 检查现有Python安装...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    python --version
    echo.
    echo ✅ 检测到已安装Python
    echo 是否要重新安装或更新？ (y/N)
    set /p reinstall="请选择: "
    if /I not "%reinstall%"=="y" (
        echo 取消安装，退出程序
        goto :exit_normal
    )
)

echo.
echo ⚠️  注意事项：
echo 1. 此安装需要管理员权限
echo 2. 需要稳定的网络连接下载安装包（约30MB）
echo 3. 安装过程可能需要几分钟
echo 4. 安装完成后会自动添加Python到PATH
echo.
echo 是否继续安装？ (y/N)
set /p continue_install="请选择: "
if /I not "%continue_install%"=="y" (
    echo 取消安装，退出程序
    goto :exit_normal
)

echo.
echo ==========================================
echo        开始安装Python
echo ==========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  需要管理员权限来安装Python
    echo 程序将请求管理员权限...
    echo.
    echo 如果弹出UAC提示，请点击"是"来允许程序以管理员身份运行
    echo.
    pause
    
    REM 请求管理员权限重新运行脚本
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d \"%cd%\" && \"%~f0\"' -Verb RunAs"
    exit /b 0
)

echo ✅ 管理员权限确认
echo.

REM 检测系统架构
echo [1/4] 检测系统架构...
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
echo [2/4] 下载Python安装包...
echo 版本: Python %PYTHON_VERSION%
echo 架构: %ARCH%
echo 下载地址: %PYTHON_URL%
echo.

REM 创建临时目录
if not exist "temp" mkdir temp

REM 下载Python安装包
echo 正在下载，请稍候...
echo 文件大小约30MB，下载时间取决于网络速度...
echo.

powershell -Command "& {
    try {
        Write-Host '开始下载Python安装包...'
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile('%PYTHON_URL%', 'temp\%PYTHON_FILENAME%')
        Write-Host '✅ 下载完成'
        exit 0
    } catch {
        Write-Host '❌ 下载失败: ' + $_.Exception.Message
        Write-Host '可能的原因：网络连接问题或服务器暂时不可用'
        exit 1
    }
}"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Python下载失败
    echo.
    echo 可能的解决方案：
    echo 1. 检查网络连接
    echo 2. 临时关闭防火墙/杀毒软件后重试
    echo 3. 手动下载：https://www.python.org/downloads/
    echo 4. 使用其他网络环境重试
    echo.
    goto :cleanup_and_exit
)

REM 验证下载的文件
if not exist "temp\%PYTHON_FILENAME%" (
    echo ❌ 下载的文件不存在，安装失败
    goto :cleanup_and_exit
)

echo ✅ Python安装包下载完成
echo.

echo [3/4] 安装Python...
echo 正在执行静默安装，请稍候...
echo.
echo 安装配置：
echo - 安装位置：系统默认位置
echo - 添加到PATH：是
echo - 安装pip：是
echo - 安装给所有用户：是
echo - 包含Tkinter：是
echo.

REM 执行静默安装
"temp\%PYTHON_FILENAME%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Include_doc=0 Include_dev=0 Include_debug=0 Include_launcher=1 Include_tcltk=1 Include_pip=1

if %errorlevel% neq 0 (
    echo ❌ Python安装失败
    echo 错误代码: %errorlevel%
    echo.
    echo 可能的解决方案：
    echo 1. 手动运行安装程序：temp\%PYTHON_FILENAME%
    echo 2. 检查磁盘空间是否充足
    echo 3. 临时关闭杀毒软件后重试
    echo 4. 确保没有其他Python安装程序在运行
    echo.
    goto :cleanup_and_exit
)

echo ✅ Python安装完成
echo.

echo [4/4] 验证安装...
echo 清理临时文件...
del "temp\%PYTHON_FILENAME%" >nul 2>&1
rmdir "temp" >nul 2>&1

echo 验证Python安装...
REM 刷新环境变量
call refreshenv.cmd >nul 2>&1

REM 验证Python安装
timeout /t 2 >nul
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Python验证成功
    python --version
    echo.
    
    REM 验证pip
    pip --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ pip验证成功
        pip --version
    ) else (
        echo ⚠️  pip验证失败，但Python安装成功
    )
) else (
    echo ⚠️  Python命令验证失败
    echo 这可能是正常的，环境变量可能需要重启后生效
    echo 请重启命令提示符或计算机后再次测试
)

echo.
echo ==========================================
echo        安装完成
echo ==========================================
echo.
echo 🎉 Python %PYTHON_VERSION% 安装成功！
echo.
echo 📋 安装总结：
echo - Python版本：%PYTHON_VERSION%
echo - 系统架构：%ARCH%
echo - 添加到PATH：是
echo - 包含pip：是
echo.
echo 💡 下一步：
echo 1. 重启命令提示符或PowerShell
echo 2. 运行 "python --version" 验证安装
echo 3. 现在可以运行需要Python的程序了
echo.
echo 如果遇到问题，请：
echo 1. 重启计算机后再次测试
echo 2. 运行 fix/diagnose.bat 进行诊断
echo.
goto :exit_normal

:cleanup_and_exit
echo 清理临时文件...
if exist "temp\%PYTHON_FILENAME%" del "temp\%PYTHON_FILENAME%" >nul 2>&1
if exist "temp" rmdir "temp" >nul 2>&1
echo.
echo 安装未成功完成。如需帮助，请查看上述错误信息。
goto :exit_error

:exit_normal
echo 按任意键退出...
pause >nul
exit /b 0

:exit_error
echo 按任意键退出...
pause >nul
exit /b 1 