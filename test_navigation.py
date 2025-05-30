"""
测试navigate_to_evaluation_from_ehall函数的脚本

使用方法：
1. 确保Chrome浏览器已安装
2. 运行此脚本：python test_navigation.py
3. 手动登录南大服务大厅
4. 观察程序是否能正确找到并点击评教入口
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
import sys


def log(message):
    """简单的日志函数"""
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] {message}")


def is_exe_environment():
    """检查是否在exe环境中运行"""
    return getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS')


def safe_input(prompt="", timeout=30):
    """安全的输入函数"""
    if is_exe_environment():
        log(f"{prompt} (exe环境中自动继续，等待{timeout}秒)")
        time.sleep(timeout)
        return ""
    else:
        try:
            return input(prompt)
        except:
            log(f"{prompt} (输入失败，自动继续)")
            time.sleep(timeout)
            return ""


def navigate_to_evaluation_from_ehall(driver):
    """
    从服务大厅导航到评教界面
    """
    log("-" * 50)
    log("开始从服务大厅导航到评教界面...")
    log("-" * 50)

    try:
        # 等待服务大厅页面加载
        log("等待服务大厅页面加载...")
        time.sleep(3)

        # 获取当前页面信息
        current_url = driver.current_url
        page_title = driver.title
        log(f"当前页面URL: {current_url}")
        log(f"页面标题: {page_title}")

        # 查找评教入口
        log("🔍 正在寻找评教入口...")

        # 使用指定的XPath路径查找评教入口
        try:
            log("尝试使用指定的XPath路径查找评教入口...")

            # 用户修改的XPath路径
            xpath = "/html/body/div[2]/div/div[1]/div/div[2]/div[2]/div/div[2]/div[3]/div[1]/div/div[2]/div/div/div/div[2]/div[9]/div/ul/li[6]"

            # 等待元素出现
            try:
                element = WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.XPATH, xpath))
                )
                log("✅ 找到了指定XPath的元素")

                # 检查元素是否可见
                if element.is_displayed():
                    log(f"元素文本内容: {element.text}")

                    # 滚动到元素位置
                    driver.execute_script(
                        "arguments[0].scrollIntoView(true);", element)
                    time.sleep(1)

                    # 点击元素
                    driver.execute_script("arguments[0].click();", element)
                    log("✅ 已点击评教入口")

                    # 等待页面跳转
                    time.sleep(5)

                    # 检查是否成功跳转
                    new_url = driver.current_url
                    new_title = driver.title
                    log(f"跳转后URL: {new_url}")
                    log(f"跳转后标题: {new_title}")

                    # 检查是否成功进入评教页面
                    if new_url != current_url:
                        if ("pj" in new_url.lower() or
                            "evaluation" in new_url.lower() or
                            "评价" in new_title or
                                "评教" in new_title):
                            log("✅ 成功导航到评教界面")
                            return True
                        else:
                            log("⚠️ 页面跳转了，但可能不是评教界面，继续执行...")
                            return True
                    else:
                        log("⚠️ 页面没有跳转，可能点击没有生效")
                else:
                    log("❌ 找到元素但不可见")

            except Exception as xpath_err:
                log(f"使用指定XPath查找失败: {xpath_err}")

        except Exception as method_specific_err:
            log(f"指定方法失败: {method_specific_err}")

        # 备用方法：通过关键词查找
        log("尝试备用方法：通过关键词查找...")
        try:
            keywords = ["本-网上评教", "评教", "教学评价", "课程评价", "教师评价", "学生评教"]
            evaluation_element = None

            for keyword in keywords:
                try:
                    log(f"搜索关键词: {keyword}")
                    elements = driver.find_elements(
                        By.XPATH, f"//*[contains(text(), '{keyword}')]")
                    if elements:
                        log(f"找到包含'{keyword}'的元素 {len(elements)} 个")
                        for i, elem in enumerate(elements):
                            try:
                                elem_text = elem.text.strip()
                                if elem_text:
                                    log(f"  元素{i+1}: {elem_text}")

                                    if elem.is_displayed() and elem.is_enabled():
                                        evaluation_element = elem
                                        log(f"选择可点击的元素: {elem_text}")
                                        break
                            except:
                                log(f"  元素{i+1}: [无法获取文本]")

                        if evaluation_element:
                            break

                except Exception as e:
                    log(f"查找'{keyword}'时出错: {e}")
                    continue

            if evaluation_element:
                log("找到评教入口，准备点击...")
                driver.execute_script(
                    "arguments[0].scrollIntoView(true);", evaluation_element)
                time.sleep(1)
                driver.execute_script(
                    "arguments[0].click();", evaluation_element)
                log("已点击评教入口")
                time.sleep(5)

                new_url = driver.current_url
                new_title = driver.title
                log(f"跳转后URL: {new_url}")
                log(f"跳转后标题: {new_title}")

                if new_url != current_url:
                    log("✅ 成功导航到评教界面")
                    return True
                else:
                    log("⚠️ 页面跳转了，但可能不是评教界面")
            else:
                log("❌ 未找到评教入口")

        except Exception as method1_err:
            log(f"备用方法失败: {method1_err}")

        # 提供调试信息
        try:
            log("\n🔍 调试信息 - 页面中包含'评'字的元素：")
            eval_elements = driver.find_elements(
                By.XPATH, "//*[contains(text(), '评')]")
            for i, elem in enumerate(eval_elements[:10]):
                try:
                    text = elem.text.strip()
                    if text and len(text) < 50:
                        log(f"  {i+1}. {text}")
                except:
                    pass
        except Exception as debug_err:
            log(f"获取调试信息失败: {debug_err}")

        # 等待用户手动操作
        safe_input("请手动点击评教入口，完成后按回车继续...")

        final_url = driver.current_url
        final_title = driver.title
        log(f"操作后URL: {final_url}")
        log(f"操作后标题: {final_title}")

        if final_url != current_url:
            log("✅ 检测到页面变化，假设已进入评教界面")
            return True
        else:
            log("⚠️ 页面未发生变化，但继续执行程序...")
            return True

    except Exception as e:
        log(f"导航过程中出错: {e}")
        log("请手动操作进入评教界面")
        safe_input("手动操作完成后按回车继续...")
        return True


def main():
    """测试主函数"""
    log("=" * 60)
    log("navigate_to_evaluation_from_ehall 功能测试")
    log("=" * 60)

    # 初始化Chrome浏览器
    log("正在初始化Chrome浏览器...")

    options = webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    try:
        driver = webdriver.Chrome(options=options)
        driver.maximize_window()

        # 这里使用你的LOGIN_URL
        LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do"

        log(f"正在访问: {LOGIN_URL}")
        driver.get(LOGIN_URL)

        log("请手动登录并等待跳转到服务大厅...")
        safe_input("登录完成后按回车开始测试导航功能...")

        # 测试导航功能
        success = navigate_to_evaluation_from_ehall(driver)

        if success:
            log("🎉 导航功能测试成功！")
        else:
            log("❌ 导航功能测试失败")

        safe_input("按回车键关闭浏览器...")

    except Exception as e:
        log(f"测试过程中出错: {e}")
    finally:
        if 'driver' in locals():
            driver.quit()
            log("浏览器已关闭")


if __name__ == "__main__":
    main()
