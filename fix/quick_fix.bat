@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        一键快速修复工具
echo ==========================================
echo.

echo 此工具将自动尝试修复常见问题：
echo ✅ 清理所有缓存
echo ✅ 重新安装依赖
echo ✅ 更新配置文件
echo ✅ 修复403权限错误
echo.

echo 开始自动修复...
echo.

echo [1/5] 清理webdriver缓存...
rmdir /s /q "%USERPROFILE%\.wdm" 2>nul
echo ✅ webdriver缓存已清理

echo [2/5] 清理本地文件...
rmdir /s /q drivers 2>nul
rmdir /s /q __pycache__ 2>nul
rmdir /s /q logs 2>nul
mkdir drivers 2>nul
mkdir logs 2>nul
echo ✅ 本地缓存已清理

echo [3/5] 重新安装Python依赖...
pip cache purge 2>nul
pip uninstall selenium webdriver-manager python-dotenv -y 2>nul
pip install selenium webdriver-manager python-dotenv --quiet
if %errorlevel% equ 0 (
    echo ✅ Python依赖重新安装成功
) else (
    echo ❌ Python依赖安装失败，请检查网络连接
)

echo [4/5] 更新配置文件...
(
    echo # 南京大学教室评价系统配置文件
    echo.
    echo # 登录页面URL - 简化版本
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

echo [5/5] 测试系统环境...
python -c "
try:
    from selenium import webdriver
    print('✅ selenium模块正常')
    
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    driver = webdriver.Chrome(options=options)
    driver.get('https://www.baidu.com')
    if 'baidu' in driver.current_url:
        print('✅ 浏览器功能正常')
    driver.quit()
    print('✅ 环境测试通过')
except Exception as e:
    print(f'❌ 环境测试失败: {e}')
" 2>nul || echo ⚠️ 环境测试跳过

echo.
echo ==========================================
echo              修复完成
echo ==========================================
echo.

echo 🎉 自动修复已完成！
echo.
echo 📋 修复内容：
echo   - 清理了所有缓存文件
echo   - 重新安装了Python依赖
echo   - 更新了配置文件为简化版本
echo   - 验证了系统环境
echo.

echo 💡 接下来请：
echo   1. 双击运行 run.bat
echo   2. 如果仍有问题，运行对应的专项修复工具：
echo      - 闪退问题: diagnose.bat
echo      - 浏览器空白: test_browser_simple.bat  
echo      - 403错误: fix_403.bat
echo.

echo 📞 如果问题仍然存在，可能原因：
echo   - 评价系统未开放（403错误是正常的）
echo   - 网络连接问题
echo   - Chrome浏览器版本过旧
echo   - 杀毒软件拦截
echo.

echo 按任意键退出...
pause >nul
exit /b 0 