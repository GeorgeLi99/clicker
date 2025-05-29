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
    goto :start_menu
)

REM 方法2: 尝试python3命令
python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python3"
    set "PIP_CMD=pip3"
    goto :start_menu
)

REM 方法3: 检查常见的Python安装路径
for /d %%i in ("%USERPROFILE%\AppData\Local\Programs\Python\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        goto :start_menu
    )
)

for /d %%i in ("C:\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        goto :start_menu
    )
)

for /d %%i in ("C:\Program Files\Python*") do (
    if exist "%%i\python.exe" (
        set "PYTHON_CMD=%%i\python.exe"
        set "PIP_CMD=%%i\Scripts\pip.exe"
        goto :start_menu
    )
)

REM 如果都没找到，部分功能将受限但仍可提供帮助
set "PYTHON_CMD="
set "PIP_CMD="

:start_menu
echo ==========================================
echo        403权限错误修复工具
echo ==========================================
echo.
if not "%PYTHON_CMD%"=="" (
    echo ✅ 已检测到Python: %PYTHON_CMD%
) else (
    echo ⚠️ 未检测到Python，部分功能将受限
)
echo.
echo 403错误通常由以下原因引起：
echo 1. 评价系统未开放或已关闭
echo 2. 账号没有评价权限
echo 3. URL参数已过期
echo 4. 会话状态问题
echo.
echo 请选择修复选项：
echo.
echo [1] 获取最新评价系统URL（信息 & 自动更新尝试）
echo [2] 检查评价时间窗口（信息）
echo [3] 手动获取正确登录链接（信息 & 编辑配置）
echo [4] 清理浏览器缓存并重试（操作 & 信息）
echo [5] 查看详细错误信息（日志 & 测试）
echo [0] 退出
echo.

set /p choice="请输入选项编号: "

if "%choice%"=="1" goto :get_new_url
if "%choice%"=="2" goto :check_time_window
if "%choice%"=="3" goto :manual_link
if "%choice%"=="4" goto :clear_cache_option
if "%choice%"=="5" goto :check_error_details
if "%choice%"=="0" goto :exit_script
goto :invalid_choice

:get_new_url
echo ==== 获取最新评价系统URL ====
echo.
echo 创建URL获取指南...

if not "%PYTHON_CMD%"=="" (
    "%PYTHON_CMD%" -c "
print('=== 南京大学评价系统URL获取指南 ===')
print()
print('由于评价系统URL可能包含时效性参数，您可能需要手动获取最新链接：')
print()
print('步骤1：')
print('  1. 打开浏览器，访问：https://ehallapp.nju.edu.cn')
print('  2. 使用学号和密码登录')
print('  3. 在搜索框中输入「教学评价」')
print('  4. 点击「本科教学评价」应用')
print()
print('步骤2（备选，更技术性）：')
print('  5. 右键点击页面 -> 检查 -> Network标签')
print('  6. 刷新页面')
print('  7. 查找以「index.do」结尾的请求')
print('  8. 复制此类请求的完整URL')
print()
print('步骤3：')
print('  9. 打开脚本目录中的config.py文件')
print('  10. 将LOGIN_URL的值替换为您复制的新URL')
print('  11. 保存文件并重新尝试运行程序')
print()
print('常见正确URL格式示例：')
print('https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do%3Ft_s%3D[时间戳]%26...')
"
) else (
    echo === 南京大学评价系统URL获取指南 ===
    echo.
    echo 由于评价系统URL可能包含时效性参数，您可能需要手动获取最新链接：
    echo.
    echo 步骤1：
    echo   1. 打开浏览器，访问：https://ehallapp.nju.edu.cn
    echo   2. 使用学号和密码登录
    echo   3. 在搜索框中输入「教学评价」
    echo   4. 点击「本科教学评价」应用
    echo.
    echo 步骤2：将获取到的完整URL更新到config.py文件中的LOGIN_URL
)

echo.
echo 是否要自动尝试更新URL配置为简化版本？ (y/N)
set /p update_choice="选择: "

if /I "%update_choice%"=="y" (
    echo 尝试自动更新配置...
    goto :auto_update_config
) else (
    echo 请按照上述步骤手动更新URL。
)

goto :done

:auto_update_config
echo 创建简化配置，移除时效性参数...
(
    echo # 南京大学教师评价系统配置文件
    echo.
    echo # 简化登录页面URL（不含时效性参数）
    echo LOGIN_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # 备用登录URL（标准authserver）
    echo BACKUP_LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # 评价系统URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver设置
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py

echo ✅ 配置已更新为简化版本。
goto :done

:check_time_window
echo ==== 检查评价时间窗口 ====
echo.
echo 教学评价通常有固定的开放时间：
echo.
echo 📅 常见评价时段：
echo   - 期中评价：学期第8-10周
echo   - 期末评价：学期第16-18周
echo   - 具体日期请查看教务处通知。
echo.
echo 🔍 如何查看：
echo   1. 访问南京大学教务处官网。
echo   2. 查找最新的教学评价通知。
echo   3. 确认当前日期是否在评价时间窗口内。
echo.
echo 💡 如果不在评价期间：
echo   - 403错误属正常现象。
echo   - 请等待评价期间开放。
echo   - 关注教务处通知获取最新时间安排。
echo.

if not "%PYTHON_CMD%"=="" (
    "%PYTHON_CMD%" -c "
import datetime
now = datetime.datetime.now()
print(f'当前时间: {now.strftime(\"%Y-%m-%d %H:%M:%S\")}')
print(f'当前周数: 第{now.isocalendar()[1]}周')
print()
print('如果当前不在评价时间窗口内，请等待官方通知。')
"
) else (
    echo 当前时间检查功能需要Python支持。
    echo 请手动确认当前是否在评价时间窗口内。
)

goto :done

:manual_link
echo ==== 手动获取正确登录链接 ====
echo.
echo 这通常是最可靠的解决方案：
echo.
echo 📋 详细步骤：
echo.
echo 1. 打开Chrome浏览器。
echo 2. 访问：https://ehallapp.nju.edu.cn
echo 3. 使用学号和密码登录。
echo 4. 搜索并点击「本科教学评价」。
echo 5. 观察地址栏中的完整URL。
echo.
echo 6. 将此完整URL复制到config.py文件的LOGIN_URL字段中。
echo.
echo 示例：
echo   如果您看到类似这样的URL：
echo   https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do?t_s=1234567890...
echo.
echo   您可能需要在config.py中这样构造LOGIN_URL：
echo   LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=[URL编码后的完整eHall应用URL]"
echo   或者，如果您已登录eHall，可以尝试直接使用eHall应用URL作为LOGIN_URL。

echo.
echo 是否要打开config.py进行编辑？ (y/N)
set /p edit_choice="选择: "

if /I "%edit_choice%"=="y" (
    if exist config.py (
        echo 正在打开config.py...
        notepad config.py
    ) else (
        echo config.py未找到。尝试创建默认配置...
        goto :auto_update_config
    )
)

goto :done

:clear_cache_option
echo ==== 清理缓存并重试 ====
echo.
echo 尝试通过清理缓存解决问题...

echo 1. 清理webdriver缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ Webdriver缓存已清理。

echo 2. 清理本地驱动文件...
rmdir /s /q drivers 2>nul
mkdir drivers 2>nul
echo ✅ 本地驱动文件已清理。

echo 3. 清理程序缓存...
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir logs 2>nul
echo ✅ 程序缓存已清理。

echo.
echo 💡 也建议手动清理Chrome浏览器缓存：
echo   1. 打开Chrome浏览器。
echo   2. 按Ctrl+Shift+Delete。
echo   3. 时间范围选择「时间不限」。
echo   4. 勾选「Cookie和其他网站数据」和「缓存的图片和文件」。
echo   5. 点击「清除数据」。
echo.
echo 缓存清理完成。建议重新运行run.bat。
goto :done

:check_error_details
echo ==== 查看详细错误信息 ====
echo.
echo 检查日志文件...
if exist logs (
    echo 找到日志文件：
    dir logs\*.log /b 2>nul
    echo.
    echo 最新日志内容（错误过滤）：
    for /f %%f in ('dir logs\*.log /b /o:d 2^>nul') do (
        echo --- logs\%%f ---
        type logs\%%f | findstr /i "403 error failed exception abnormal" 2>nul
    )
) else (
    echo 在'logs'目录中未找到日志文件。
)

echo.
echo 测试当前URL可访问性...

if not "%PYTHON_CMD%"=="" (
    "%PYTHON_CMD%" -c "
try:
    import requests
    # 尝试从config.py读取LOGIN_URL
    config = {}
    try:
        with open('config.py', 'r', encoding='utf-8') as f:
            exec(f.read(), config)
        LOGIN_URL = config.get('LOGIN_URL')
        if not LOGIN_URL:
            print('在config.py中未找到LOGIN_URL或为空。')
            LOGIN_URL = 'https://authserver.nju.edu.cn/authserver/login' # 备用
    except FileNotFoundError:
        print('未找到config.py。使用默认URL进行测试。')
        LOGIN_URL = 'https://authserver.nju.edu.cn/authserver/login'
    except Exception as e_conf:
        print(f'读取config.py时出错: {e_conf}。使用默认URL进行测试。')
        LOGIN_URL = 'https://authserver.nju.edu.cn/authserver/login'

    print(f'测试URL: {LOGIN_URL}')
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36'
    }
    response = requests.get(LOGIN_URL, headers=headers, timeout=15, allow_redirects=True)
    print(f'状态码: {response.status_code}')
    print(f'重定向后的最终URL: {response.url}')
    
    if response.status_code == 403:
        print('❌ 确认403错误。')
        print('可能原因：')
        print('1. 评价系统未开放。')
        print('2. URL包含过期参数。')
        print('3. 访问权限受限（IP、账号等）。')
    elif response.status_code == 200:
        print('✅ 状态200 OK。页面似乎可以访问。')
        if 'authserver' in response.url:
            print('   可能在登录页面。')
        elif 'ehallapp' in response.url:
            print('   可能在eHall系统页面。')
    else:
        print(f'状态: {response.status_code}。请检查URL和网络。')
        
except ImportError:
    print('Python requests模块未安装。跳过直接网络测试。')
    print('您可以通过运行安装它: %PIP_CMD% install requests')
except Exception as e:
    print(f'URL测试失败: {e}')
"
) else (
    echo URL测试功能需要Python支持。
    echo 请手动在浏览器中测试URL可访问性。
)

goto :done

:invalid_choice
echo ❌ 无效选项。请重新选择。
PAUSE
cls
goto :start_menu

:done
echo.
echo 操作完成！建议重新运行run.bat检查问题是否解决。
goto :exit_script

:exit_script
echo.
echo 按任意键退出...
PAUSE
exit /b 0 