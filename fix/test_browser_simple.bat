@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

echo ==========================================
echo        浏览器连接测试工具
echo ==========================================
echo.

echo 正在测试浏览器连接...
echo.

python -c "
import sys
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service
    from webdriver_manager.chrome import ChromeDriverManager
    import time

    print('=== 浏览器连接测试开始 ===')
    print()

    # 测试1：基础浏览器启动
    print('1. 测试基础Chrome启动...')
    try:
        options = webdriver.ChromeOptions()
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        driver = webdriver.Chrome(options=options)
        print('✅ Chrome浏览器启动成功')
        
        # 测试百度
        print('2. 测试网络连接（百度）...')
        driver.get('https://www.baidu.com')
        time.sleep(3)
        if 'baidu' in driver.current_url and len(driver.page_source) > 1000:
            print('✅ 网络连接正常，页面内容加载成功')
        else:
            print('❌ 页面加载异常')
            print(f'当前URL: {driver.current_url}')
            print(f'页面源码长度: {len(driver.page_source)}')
        
        # 测试南大登录页面
        print('3. 测试南大登录页面...')
        login_url = 'https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do'
        driver.get(login_url)
        time.sleep(5)
        
        current_url = driver.current_url
        page_title = driver.title
        page_length = len(driver.page_source)
        
        print(f'   当前URL: {current_url}')
        print(f'   页面标题: {page_title}')
        print(f'   页面内容长度: {page_length}')
        
        if 'authserver.nju.edu.cn' in current_url and page_length > 1000:
            print('✅ 南大登录页面访问正常')
            
            # 检查关键元素
            try:
                username_element = driver.find_element_by_id('username')
                print('✅ 检测到用户名输入框')
            except:
                print('⚠️ 未检测到用户名输入框')
                
        elif page_length < 100:
            print('❌ 页面内容为空或加载失败')
            print('可能原因：')
            print('  - 网络连接问题')
            print('  - Chrome驱动版本不匹配')
            print('  - 防火墙阻止访问')
        else:
            print(f'⚠️ 页面跳转异常: {current_url}')
        
        driver.quit()
        print('✅ 浏览器已关闭')
        
    except Exception as e:
        print(f'❌ 浏览器测试失败: {e}')
        try:
            driver.quit()
        except:
            pass
    
    print()
    print('=== 测试完成 ===')
    
except ImportError as ie:
    print(f'❌ 导入模块失败: {ie}')
    print('请确保已安装selenium和webdriver-manager')
except Exception as e:
    print(f'❌ 测试过程出错: {e}')
"

echo.
echo 测试完成！
echo 如果上面显示 "页面内容为空或加载失败"，请尝试：
echo 1. 运行 fix.bat 选择选项 2 清理ChromeDriver
echo 2. 确保网络连接正常
echo 3. 尝试以管理员身份运行
echo.
echo 按任意键退出...
PAUSE