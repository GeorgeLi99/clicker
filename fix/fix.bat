@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        快速修复工具
echo ==========================================
echo.

echo 此工具将尝试解决常见问题，请选择修复选项：
echo.
echo [1] 重新安装Python依赖包
echo [2] 清理并重新下载ChromeDriver
echo [3] 重新创建配置文件
echo [4] 清理日志和临时文件
echo [5] 修复Python环境变量
echo [6] 全面重置（谨慎使用）
echo [7] 一键快速修复（推荐）
echo [0] 退出
echo.

set /p choice="请输入选项编号: "

if "%choice%"=="1" goto :fix_packages
if "%choice%"=="2" goto :fix_chromedriver
if "%choice%"=="3" goto :fix_config
if "%choice%"=="4" goto :cleanup
if "%choice%"=="5" goto :fix_python_path
if "%choice%"=="6" goto :full_reset
if "%choice%"=="7" goto :quick_fix
if "%choice%"=="0" goto :exit
goto :invalid_choice

:fix_packages
echo ════ 重新安装Python依赖包 ════
echo 正在清理pip缓存...
pip cache purge 2>nul
echo 正在卸载旧版本...
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul
echo 正在重新安装...
pip install selenium webdriver-manager python-dotenv
if %errorlevel% equ 0 (
    echo ✅ 依赖包修复完成
) else (
    echo ❌ 依赖包修复失败
)
goto :done

:fix_chromedriver
echo ════ 重新下载ChromeDriver ════
echo 正在删除旧驱动...
rmdir /s /q drivers 2>nul
mkdir drivers 2>nul
echo 正在清理webdriver-manager缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ ChromeDriver清理完成，下次运行时会自动下载
goto :done

:fix_config
echo ════ 重新创建配置文件 ════
if exist config.py (
    echo 备份旧配置文件...
    copy config.py config.py.backup >nul 2>&1
)
echo 正在创建新配置文件...
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
echo ✅ 配置文件重新创建完成
goto :done

:cleanup
echo ════ 清理日志和临时文件 ════
echo 正在清理日志文件...
rmdir /s /q logs 2>nul
mkdir logs 2>nul
echo 正在清理临时文件...
del *.log 2>nul
del test_*.py 2>nul
del driver_path.txt 2>nul
del *.tmp 2>nul
echo 正在清理Python缓存...
rmdir /s /q __pycache__ 2>nul
echo ✅ 清理完成
goto :done

:fix_python_path
echo ════ 修复Python环境变量 ════
echo 当前PATH环境变量中的Python路径:
where python 2>nul
echo.
echo 如果上面没有显示Python路径，请：
echo 1. 重新安装Python，安装时勾选"Add Python to PATH"
echo 2. 或手动添加Python到环境变量
echo 3. 重启命令提示符窗口
echo.
echo Python安装目录通常在：
echo - C:\Users\%USERNAME%\AppData\Local\Programs\Python\
echo - C:\Python3x\
echo.
pause
goto :done

:full_reset
echo ════ 全面重置（警告）════
echo ⚠️  这将删除所有本地配置和缓存，确定要继续吗？
echo 输入 YES 确认，或按任意键取消:
set /p confirm="确认: "
if /I not "%confirm%"=="YES" (
    echo 操作已取消
    goto :done
)

echo 正在进行全面重置...
rmdir /s /q logs 2>nul
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q venv 2>nul
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
del config.py 2>nul
del *.log 2>nul
del *.tmp 2>nul
pip cache purge 2>nul
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul

echo ✅ 全面重置完成，请重新运行 run.bat
goto :done

:quick_fix
echo ════ 一键快速修复 ════
echo 正在执行一键快速修复...
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
echo ✅ 缓存清理完成

echo [2/4] 重新安装依赖...
pip cache purge 2>nul
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul
pip install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ 依赖安装成功
) else (
    echo ❌ 依赖安装失败
)

echo [3/4] 更新配置文件...
(
    echo # 南京大学教室评价系统配置文件
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
echo ✅ 配置文件已更新

echo [4/4] 验证环境...
python -c "import selenium; print('✅ selenium正常')" 2>nul || echo ❌ selenium异常
echo ✅ 一键修复完成

echo.
echo 修复完成，建议现在运行 run.bat 测试程序
goto :done

:invalid_choice
echo ❌ 无效选项，请重新选择
PAUSE
cls
goto :start

:done
echo.
echo 修复完成！建议重新运行 run.bat 测试是否正常。
goto :exit

:exit
echo.
echo 按任意键退出...
PAUSE
exit /b 0 