@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        403权限错误修复工具
echo ==========================================
echo.

echo 403错误通常由以下原因造成：
echo 1. 评价系统未开放或已关闭
echo 2. 账号没有评价权限
echo 3. URL参数过期
echo 4. 会话状态问题
echo.

echo 请选择修复方案：
echo.
echo [1] 获取最新的评价系统URL
echo [2] 检查评价时间窗口
echo [3] 手动获取正确的登录链接
echo [4] 清除浏览器缓存并重试
echo [5] 查看详细错误信息
echo [0] 退出
echo.

set /p choice="请输入选项编号: "

if "%choice%"=="1" goto :get_new_url
if "%choice%"=="2" goto :check_time_window
if "%choice%"=="3" goto :manual_link
if "%choice%"=="4" goto :clear_cache
if "%choice%"=="5" goto :check_error_details
if "%choice%"=="0" goto :exit
goto :invalid_choice

:get_new_url
echo ════ 获取最新评价系统URL ════
echo.
echo 正在创建URL获取脚本...

python -c "
print('=== 南京大学评价系统URL获取指南 ===')
print()
print('由于评价系统URL包含时效性参数，需要手动获取最新链接：')
print()
print('步骤1：')
print('  1. 打开浏览器，访问: https://ehallapp.nju.edu.cn')
print('  2. 用学号密码登录')
print('  3. 在搜索框中输入\"教学评价\"')
print('  4. 点击\"本科教学评价\"应用')
print()
print('步骤2：')
print('  5. 右键点击页面 → 检查 → Network标签')
print('  6. 刷新页面')
print('  7. 查找以\"index.do\"结尾的请求')
print('  8. 复制完整URL')
print()
print('步骤3：')
print('  9. 打开config.py文件')
print('  10. 将新URL替换LOGIN_URL的值')
print('  11. 保存文件并重新运行程序')
print()
print('常见正确URL格式示例：')
print('https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do%3Ft_s%3D[时间戳]%26...')
"

echo.
echo 是否需要自动尝试更新URL配置？ (y/N)
set /p update_choice="请选择: "

if /I "%update_choice%"=="y" (
    echo 正在尝试自动更新配置...
    goto :auto_update_config
) else (
    echo 请按照上述步骤手动更新URL
)

goto :done

:auto_update_config
echo 创建简化的配置，移除时效性参数...
(
    echo # 南京大学教室评价系统配置文件
    echo.
    echo # 简化的登录页面URL（无时效性参数）
    echo LOGIN_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # 备用登录URL
    echo BACKUP_LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
    echo.
    echo # 评价系统URL
    echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
    echo.
    echo # ChromeDriver设置
    echo USE_AUTO_DRIVER = True
    echo CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
) > config.py

echo ✅ 配置已更新为简化版本
goto :done

:check_time_window
echo ════ 检查评价时间窗口 ════
echo.
echo 教学评价通常有固定的开放时间：
echo.
echo 📅 常见评价时间：
echo   - 期中评价：学期第8-10周
echo   - 期末评价：学期第16-18周
echo   - 具体时间请查看教务处通知
echo.
echo 🔍 检查方法：
echo   1. 访问南京大学教务处官网
echo   2. 查看最新教学评价通知
echo   3. 确认当前是否在评价时间窗口内
echo.
echo 💡 如果不在评价时间内：
echo   - 403错误是正常的
echo   - 请等待评价开放时间
echo   - 关注教务处通知获取最新时间安排
echo.

python -c "
import datetime
now = datetime.datetime.now()
print(f'当前时间: {now.strftime(\"%Y-%m-%d %H:%M:%S\")}')
print(f'当前周数: 第{now.isocalendar()[1]}周')
print()
print('如果当前不在评价时间窗口内，请等待官方通知。')
"

goto :done

:manual_link
echo ════ 手动获取正确的登录链接 ════
echo.
echo 这是最可靠的解决方法：
echo.
echo 📋 详细步骤：
echo.
echo 1. 打开Chrome浏览器
echo 2. 访问: https://ehallapp.nju.edu.cn
echo 3. 用学号密码登录
echo 4. 搜索并点击"本科教学评价"
echo 5. 观察地址栏的完整URL
echo.
echo 6. 将完整URL复制到config.py文件的LOGIN_URL中
echo.
echo 示例操作：
echo   如果看到URL是：
echo   https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do?t_s=1234567890...
echo.
echo   则将config.py中的LOGIN_URL修改为：
echo   LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=[URL编码后的完整地址]"
echo.

echo 是否打开config.py文件进行编辑？ (y/N)
set /p edit_choice="请选择: "

if /I "%edit_choice%"=="y" (
    if exist config.py (
        echo 正在打开config.py...
        notepad config.py
    ) else (
        echo config.py文件不存在，正在创建...
        goto :auto_update_config
    )
)

goto :done

:clear_cache
echo ════ 清除浏览器缓存并重试 ════
echo.
echo 正在清理可能的缓存问题...

echo 1. 清理webdriver缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ webdriver缓存已清理

echo 2. 清理本地驱动文件...
rmdir /s /q drivers 2>nul
mkdir drivers 2>nul
echo ✅ 本地驱动已清理

echo 3. 清理程序缓存...
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir logs 2>nul
echo ✅ 程序缓存已清理

echo.
echo 💡 建议手动清理Chrome缓存：
echo   1. 打开Chrome浏览器
echo   2. 按Ctrl+Shift+Delete
echo   3. 选择"全部时间"
echo   4. 勾选"Cookie和其他网站数据"
echo   5. 点击"清除数据"
echo.

echo 缓存清理完成，建议重新运行run.bat
goto :done

:check_error_details
echo ════ 查看详细错误信息 ════
echo.

echo 正在检查日志文件...
if exist logs (
    echo 找到日志文件：
    dir logs\*.log /b 2>nul
    echo.
    echo 最新日志内容：
    for /f %%f in ('dir logs\*.log /b /o:d 2^>nul') do (
        echo --- logs\%%f ---
        type logs\%%f | findstr /i "403\|error\|失败\|异常" 2>nul
    )
) else (
    echo 未找到日志文件
)

echo.
echo 正在测试当前URL访问情况...

python -c "
try:
    import requests
    from config import LOGIN_URL
    
    print(f'测试URL: {LOGIN_URL}')
    
    response = requests.get(LOGIN_URL, timeout=10, allow_redirects=False)
    print(f'状态码: {response.status_code}')
    
    if response.status_code == 403:
        print('❌ 确认是403错误')
        print('可能原因：')
        print('1. 评价系统未开放')
        print('2. URL包含过期参数')
        print('3. 访问权限限制')
    elif response.status_code == 302:
        print('✅ 重定向正常，可能可以访问')
    else:
        print(f'状态: {response.status_code}')
        
except ImportError:
    print('requests模块未安装，跳过网络测试')
except Exception as e:
    print(f'测试失败: {e}')
" 2>nul || echo 无法进行网络测试

goto :done

:invalid_choice
echo ❌ 无效选项，请重新选择
pause
cls
goto :start

:done
echo.
echo ═══════════════════════════════════════
echo 修复建议总结：
echo.
echo 1. 📅 确认评价时间窗口是否开放
echo 2. 🔗 获取最新的评价系统URL
echo 3. 🧹 清理所有缓存数据
echo 4. 🔄 重新运行run.bat
echo.
echo 如果问题仍然存在，可能是：
echo - 评价系统确实未开放
echo - 账号没有评价权限
echo - 系统正在维护
echo.
echo 建议联系教务处或等待官方通知
echo ═══════════════════════════════════════
goto :exit

:exit
echo.
echo 按任意键退出...
PAUSE
exit /b 0 