from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
from config import LOGIN_URL, WEB_URL


class Clicker:
    def __init__(self, driver):
        self.driver = driver

    def click_element(self, by, value):
        self.driver.find_element(by, value).click()

    def input_text(self, by, value, text):
        self.driver.find_element(by, value).send_keys(text)


def main():
    driver = webdriver.Chrome()
    driver.get(LOGIN_URL)
    time.sleep(3)  # 等待页面加载

    # 完全手动登录
    print("请在浏览器中手动输入学号和密码，然后点击登录按钮")
    print("正在等待登录完成...")

    # 检测登录跳转并执行点击
    try:
        # 保存当前URL，用于检测页面是否跳转
        start_url = driver.current_url

        # 等待URL变化，最多等待60秒
        print("等待页面跳转...")
        max_wait = 60
        for i in range(max_wait):
            current_url = driver.current_url
            if current_url != start_url and "authserver" not in current_url:
                print(f"检测到页面跳转: {current_url}")
                break
            time.sleep(1)

        if driver.current_url == start_url or "authserver" in driver.current_url:
            print("登录超时，请确认是否成功登录")
            return driver

        print("登录成功，已跳转到评价系统")

        # 等待页面加载
        time.sleep(4)

        # 查找并点击评价入口
        cards = driver.find_element(
            By.CLASS_NAME, "pj-total-card.bh-clearfix")
        elements = cards.find_elements(By.XPATH, "//*[@id=\"pjglTopCard\"]")
        print(f"找到 {len(elements)} 个bh-clearfix元素:")
        for element in elements:
            print(element.text)

        if elements:
            # 直接点击第1个元素，因为它之前成功了
            target_element = elements[0]  # 索引是第1个元素
            print(f"直接点击第1个元素: {target_element.text}")

            # 使用JavaScript点击
            driver.execute_script(
                "arguments[0].scrollIntoView(true);", target_element)
            time.sleep(1)
            driver.execute_script("arguments[0].click();", target_element)
            print("已点击评价入口")
            time.sleep(1)  # 等待点击后页面加载
        else:
            print(f"元素数量只有 {len(elements)} 个")
            print("请手动点击进入评价页面")
            input("完成手动点击后按回车继续...")
            time.sleep(1)  # 等待手动点击后页面加载

    except Exception as e:
        print(f"出错: {e}")
        print("请手动操作，程序将继续运行...")

    # 进入评价页面，查找评价卡片元素
    try:
        # 等待评价页面加载
        time.sleep(3)
        card_elements = driver.find_elements(
            By.CLASS_NAME, "pj-card.bh-pull-left")
        print(f"找到 {len(card_elements)} 个评价卡片元素")

        # 显示找到的评价卡片文本
        for element in card_elements:
            print(element.text)

        # 循环点击所有评价卡片的底部元素
        for i, element in enumerate(card_elements):
            try:
                # 在卡片中查找底部元素
                print(f"查找第 {i+1} 个评价卡片的底部元素")
                card_bottom = element.find_element(
                    By.CLASS_NAME, "card-btn.blue")

                # 策略1：直接尝试点击底部元素
                print(f"策略1：直接点击第 {i+1} 个评价卡片的底部元素")
                driver.execute_script(
                    "arguments[0].scrollIntoView(true);", card_bottom)
                time.sleep(1)
                driver.execute_script("arguments[0].click();", card_bottom)
                print(f"直接点击底部元素成功")
                time.sleep(3)  # 增加等待时间

                # 获取评价卡片中的评价指标
                try:
                    judge_indexes = driver.find_elements(
                        By.CLASS_NAME, "sc-panel-thingNoImg-1-container.bh-mv-8.wjzb-card")
                    print(f"找到 {len(judge_indexes)} 个judge-index元素")

                    if len(judge_indexes) > 0:
                        for idx, judge_index in enumerate(judge_indexes):
                            try:
                                print(f"处理第 {idx+1} 个评价指标: {judge_index.text}")

                                # 获取评价指标的输入框
                                try:
                                    input_box = judge_index.find_element(
                                        By.CLASS_NAME, "bh-radio-label.fontcolor")
                                    # 输入评价
                                    driver.execute_script(
                                        "arguments[0].scrollIntoView(true);", input_box)
                                    time.sleep(0.5)
                                    driver.execute_script(
                                        "arguments[0].click();", input_box)
                                    print(f"已点击第 {idx+1} 个评价指标")
                                    time.sleep(0.05)
                                except Exception as radio_error:
                                    print(
                                        f"点击第 {idx+1} 个评价指标失败: {radio_error}")

                                    # 如果点击失败，尝试将其作为文本框处理
                                    try:
                                        print(f"尝试将第 {idx+1} 个评价指标作为文本框处理")

                                        # 尝试各种方法找到文本输入框
                                        try:
                                            # 方法1: 通过类名查找
                                            text_input = judge_index.find_element(
                                                By.CLASS_NAME, "bh-pull-left")
                                            print("通过类名找到文本框")
                                        except:
                                            try:
                                                # 方法2: 通过textarea标签查找
                                                text_input = judge_index.find_element(
                                                    By.TAG_NAME, "textarea")
                                                print("通过textarea标签找到文本框")
                                            except:
                                                # 方法3: 通过XPath查找任何文本输入元素
                                                text_input = judge_index.find_element(
                                                    By.XPATH, ".//textarea | .//input[@type='text']")
                                                print("通过XPath找到文本框")

                                        # 评价文本内容
                                        comment_text = "在本学期的学习过程中，我对课程内容和教学方式有了较为全面的了解。\
                                            总体而言，老师的讲解逻辑清晰，课程内容丰富，理论与实践结合较好，提升了我对相关知识的理解和应用能力。\
                                            同时，课堂上的互动环节增强了学习的积极性，也促进了同学之间的交流。"

                                        # 填写评价文本
                                        driver.execute_script(
                                            "arguments[0].scrollIntoView(true);", text_input)
                                        time.sleep(0.5)
                                        # 清空文本框
                                        driver.execute_script(
                                            "arguments[0].value = '';", text_input)
                                        time.sleep(0.5)
                                        # 填写内容
                                        driver.execute_script(
                                            f"arguments[0].value = '{comment_text}';", text_input)
                                        print(f"已为第 {idx+1} 个评价指标填写文本内容")
                                        time.sleep(0.5)

                                        # 触发输入事件，确保值被正确设置
                                        driver.execute_script("""
                                            var event = new Event('input', {
                                                bubbles: true,
                                                cancelable: true,
                                            });
                                            arguments[0].dispatchEvent(event);
                                        """, text_input)

                                    except Exception as text_error:
                                        print(f"文本框处理失败: {text_error}")
                            except Exception as index_error:
                                print(f"处理第 {idx+1} 个评价指标时出错: {index_error}")
                    else:
                        print("未找到任何评价指标元素")

                    # 提交填写的评价
                    try:
                        print("尝试找到并点击提交按钮")
                        time.sleep(1)
                        submit_button = driver.find_element(
                            By.CLASS_NAME, "bh-btn.bh-btn-success.bh-btn-large")

                        # 滚动到按钮位置并点击
                        driver.execute_script(
                            "arguments[0].scrollIntoView(true);", submit_button)
                        time.sleep(1)
                        driver.execute_script(
                            "arguments[0].click();", submit_button)
                        print("已点击提交按钮")
                        driver.find_element(
                            By.CLASS_NAME, "bh-dialog-btn.bh-bg-primary.bh-color-primary-5").click()
                        print("已点击确认")
                        time.sleep(3)

                        # 检查是否有确认弹窗
                        try:
                            confirm_button = driver.find_element(
                                By.XPATH, "//button[contains(text(), '确定') or contains(text(), '确认')]")
                            driver.execute_script(
                                "arguments[0].click();", confirm_button)
                            print("已点击确认按钮")
                            time.sleep(2)
                        except Exception as confirm_error:
                            print(f"未找到或点击确认按钮失败: {confirm_error}")

                    except Exception as submit_error:
                        print(f"提交评价失败: {submit_error}")

                        # 尝试备选方法找提交按钮
                        try:
                            # 通过XPath查找包含"提交"文本的按钮
                            submit_xpath = driver.find_element(
                                By.XPATH, "//button[contains(text(), '提交')]")
                            driver.execute_script(
                                "arguments[0].scrollIntoView(true);", submit_xpath)
                            time.sleep(1)
                            driver.execute_script(
                                "arguments[0].click();", submit_xpath)
                            print("通过XPath点击提交按钮成功")
                            time.sleep(2)
                        except Exception as xpath_submit_error:
                            print(f"通过XPath查找提交按钮失败: {xpath_submit_error}")

                except Exception as judge_error:
                    print(f"获取评价指标失败: {judge_error}")

            except Exception as click_error:
                print(f"直接点击底部元素失败: {click_error}")

                try:
                    # 策略2：先滑动窗口，再点击底部元素
                    print(f"策略2：滑动窗口后点击第 {i+1} 个评价卡片的底部元素")
                    driver.execute_script(
                        "arguments[0].scrollIntoView(true);", element)
                    time.sleep(2)
                    card_bottom = element.find_element(
                        By.CLASS_NAME, "card-bottom")
                    driver.execute_script("arguments[0].click();", card_bottom)
                    print(f"滑动后点击底部元素成功")
                    time.sleep(1)  # 增加等待时间

                except Exception as scroll_error:
                    print(f"滑动后点击底部元素失败: {scroll_error}")

                    try:
                        # 策略3：尝试原生点击底部元素
                        print(f"策略3：使用原生点击第 {i+1} 个评价卡片的底部元素")
                        card_bottom = element.find_element(
                            By.CLASS_NAME, "card-bottom")
                        card_bottom.click()
                        print(f"原生点击底部元素成功")
                        time.sleep(3)  # 增加等待时间
                    except Exception as native_error:
                        print(f"原生点击底部元素失败: {native_error}")

    except Exception as e:
        print(f"处理评价卡片时出错: {e}")

    # 返回driver对象，方便后续操作
    return driver


if __name__ == "__main__":
    driver = main()

    # 在这里可以添加后续操作
    try:
        # 保持浏览器窗口打开
        input("程序执行完毕，按回车键退出...")
    finally:
        # 关闭浏览器
        driver.quit()
