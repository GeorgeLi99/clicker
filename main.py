from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
import os
from config import LOGIN_URL, WEB_URL

# 创建日志目录
os.makedirs('logs', exist_ok=True)

# 设置日志文件
log_filename = f"logs/clicker_{time.strftime('%Y%m%d')}.log"


def log(message):
    """记录日志到文件和控制台"""
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    log_message = f"[{timestamp}] {message}"
    print(log_message)
    with open(log_filename, 'a', encoding='utf-8') as f:
        f.write(log_message + '\n')


class Evaluator:
    """基础评价类，提供通用的评价功能"""

    def __init__(self, driver):
        self.driver = driver

    def click_with_js(self, element, description="元素", wait_time=0.5):
        """使用JavaScript点击元素，并增加日志输出"""
        try:
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", element)
            time.sleep(wait_time)
            self.driver.execute_script("arguments[0].click();", element)
            print(f"成功点击{description}")
            return True
        except Exception as e:
            print(f"点击{description}失败: {e}")
            return False

    def find_and_click_submit_button(self, type_name=""):
        """查找并点击提交按钮"""
        print(f"所有{type_name}评价指标已处理完毕，准备提交表单")
        try:
            # 查找提交按钮
            submit_btn = self.driver.find_element(
                By.CLASS_NAME, "bh-btn.bh-btn-success.bh-btn-large")

            # 滚动到按钮位置并点击
            self.click_with_js(submit_btn, f"{type_name}评价提交按钮")
            return True
        except Exception as e:
            print(f"提交{type_name}评价表单失败: {e}")

            # 尝试备选方法找提交按钮
            try:
                # 通过XPath查找包含"提交"文本的按钮
                submit_xpath = self.driver.find_element(
                    By.XPATH, "//button[contains(text(), '提交')]")
                self.click_with_js(submit_xpath, f"{type_name}评价提交按钮(通过XPath)")
                return True
            except Exception as xpath_submit_error:
                print(f"通过XPath查找提交按钮失败: {xpath_submit_error}")
                return False

    def click_confirm_button(self, method_count=2):
        """尝试多种方法点击确认按钮"""
        for attempt in range(method_count):
            try:
                if attempt == 0:
                    # 方法1：通过CLASS_NAME查找确认按钮
                    confirm_btn = self.driver.find_element(
                        By.CLASS_NAME, "bh-dialog-btn.bh-bg-primary.bh-color-primary-5")
                    confirm_btn.click()
                    print("已点击确认按钮(方法1)")
                    return True
                elif attempt == 1:
                    # 方法2：通过XPath查找确认按钮
                    confirm_xpath = self.driver.find_element(
                        By.XPATH, "//button[contains(text(), '确定') or contains(text(), '确认')]")
                    self.driver.execute_script(
                        "arguments[0].click();", confirm_xpath)
                    print("已点击确认按钮(方法2)")
                    return True
                else:
                    # 方法3：通过其他XPath查找按钮
                    confirm_btn = self.driver.find_element(
                        By.XPATH, "//div[contains(@class, 'bh-dialog')]//button")
                    self.driver.execute_script(
                        "arguments[0].click();", confirm_btn)
                    print("已点击确认按钮(方法3)")
                    return True
            except Exception as e:
                print(f"尝试第 {attempt+1} 种方法点击确认按钮失败: {e}")
                time.sleep(0.5)  # 等待一下再尝试
        return False

    def click_evaluation_options(self, judge_elements, type_name=""):
        """点击评价选项（单选按钮）"""
        if not judge_elements or len(judge_elements) == 0:
            print(f"未找到任何{type_name}评价指标元素")
            return False

        print(f"找到 {len(judge_elements)} 个{type_name}评价指标")

        # 循环处理所有评价指标（除最后一个外）
        for idx, judge in enumerate(judge_elements):
            # 跳过最后一个评价指标，因为它通常是文本填写指标
            if idx == len(judge_elements) - 1:
                print(f"跳过最后一个指标（第 {idx+1} 个），因为它通常是文本填写指标")
                continue

            print(f"处理第 {idx+1} 个评价指标")

            # 尝试点击单选按钮
            try:
                radio_btn = judge.find_element(
                    By.CLASS_NAME, "bh-radio-label.fontcolor")
                self.click_with_js(radio_btn, f"第 {idx+1} 个指标的单选按钮", 0.00005)
            except Exception as radio_err:
                print(f"点击单选按钮失败: {radio_err}")

        return True


class TeacherEvaluator(Evaluator):
    """教师评价类，负责处理教师评价相关功能"""

    def process_teacher_card(self, card_element, card_index):
        """处理单个教师评价卡片"""
        try:
            # 在卡片中查找底部元素
            print(f"查找第 {card_index+1} 个评价卡片的底部元素")
            card_bottom = card_element.find_element(
                By.CLASS_NAME, "card-btn.blue")

            # 尝试点击底部元素
            print(f"点击第 {card_index+1} 个评价卡片的底部元素")
            success = self.click_with_js(
                card_bottom, f"第 {card_index+1} 个评价卡片的底部元素", 1)
            if not success:
                # 尝试备选点击方法
                return self.try_alternative_click_methods(card_element, card_index)

            time.sleep(2)  # 等待页面加载

            # 获取评价卡片中的评价指标
            return self.process_teacher_evaluation_form(card_index)

        except Exception as click_error:
            print(f"直接点击底部元素失败: {click_error}")
            return self.try_alternative_click_methods(card_element, card_index)

    def try_alternative_click_methods(self, card_element, card_index):
        """尝试备选的点击方法"""
        try:
            # 策略2：先滑动窗口，再点击底部元素
            print(f"策略2：滑动窗口后点击第 {card_index+1} 个评价卡片的底部元素")
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", card_element)
            time.sleep(2)
            card_bottom = card_element.find_element(
                By.CLASS_NAME, "card-bottom")
            self.driver.execute_script("arguments[0].click();", card_bottom)
            print(f"滑动后点击底部元素成功")
            time.sleep(1)  # 增加等待时间

            # 获取评价卡片中的评价指标
            return self.process_teacher_evaluation_form(card_index)

        except Exception as scroll_error:
            print(f"滑动后点击底部元素失败: {scroll_error}")

            try:
                # 策略3：尝试原生点击底部元素
                print(f"策略3：使用原生点击第 {card_index+1} 个评价卡片的底部元素")
                card_bottom = card_element.find_element(
                    By.CLASS_NAME, "card-bottom")
                card_bottom.click()
                print(f"原生点击底部元素成功")
                time.sleep(3)  # 增加等待时间

                # 获取评价卡片中的评价指标
                return self.process_teacher_evaluation_form(card_index)

            except Exception as native_error:
                print(f"原生点击底部元素失败: {native_error}")
                return False

    def process_teacher_evaluation_form(self, card_index):
        """处理教师评价表单"""
        try:
            # 获取评价指标
            judge_indexes = self.driver.find_elements(
                By.CLASS_NAME, "sc-panel-thingNoImg-1-container.bh-mv-8.wjzb-card")

            if len(judge_indexes) > 0:
                for idx, judge_index in enumerate(judge_indexes):
                    try:
                        print(f"处理第 {idx+1} 个评价指标: {judge_index.text}")

                        # 跳过最后一个评价指标，因为它通常是文本填写指标
                        if idx == len(judge_indexes) - 1:
                            print(f"跳过最后一个评价指标（第 {idx+1} 个），因为它通常是文本填写指标")
                            continue

                        # 如果该课程有多个老师，那么需要点击多个评价指标
                        judge_index_elements = judge_index.find_elements(
                            By.CLASS_NAME, "sc-panel-content.bh-clearfix.bh-mv-8.wjzb-card-jskc")
                        print(f"找到 {len(judge_index_elements)} 个judge-index元素")

                        # 确定要处理的元素列表
                        elements_to_process = []
                        if len(judge_index_elements) > 1:
                            elements_to_process = judge_index_elements
                            print(f"将处理 {len(elements_to_process)} 个教师评价")
                        else:
                            # 如果没有找到多教师元素，就处理当前评价指标
                            elements_to_process = [judge_index]
                            print("将处理单个评价指标")

                        # 循环处理所有需要评价的元素
                        for element_idx, element in enumerate(elements_to_process):
                            try:
                                element_desc = "教师" if len(
                                    judge_index_elements) > 1 else "评价指标"
                                print(f"处理第 {element_idx+1} 个{element_desc}")

                                # 尝试点击单选按钮
                                try:
                                    input_box = element.find_element(
                                        By.CLASS_NAME, "bh-radio-label.fontcolor")
                                    # 输入评价
                                    self.click_with_js(
                                        input_box, f"第 {element_idx+1} 个{element_desc}", 0.00005)
                                    time.sleep(0.00005)
                                except Exception as radio_error:
                                    print(
                                        f"点击第 {element_idx+1} 个{element_desc}失败: {radio_error}")
                                    # 如果点击失败，直接跳过
                                    print(
                                        f"跳过第 {element_idx+1} 个{element_desc}的处理")

                            except Exception as element_error:
                                print(
                                    f"处理第 {element_idx+1} 个{element_desc}时出错: {element_error}")
                    except Exception as index_error:
                        print(f"处理第 {idx+1} 个评价指标时出错: {index_error}")
            else:
                print("未找到任何评价指标元素")
                return False

            # 所有评价指标处理完毕后，提交表单
            if self.find_and_click_submit_button("教师"):
                # 点击确认按钮
                self.click_confirm_button(3)
                # 等待确认操作完成
                time.sleep(2)
                return True

            return False

        except Exception as judge_error:
            print(f"获取评价指标失败: {judge_error}")
            return False

    def evaluate_all_teachers(self):
        """评价所有教师"""
        try:
            # 等待评价页面加载
            time.sleep(2)
            card_elements = self.driver.find_elements(
                By.CLASS_NAME, "pj-card.bh-pull-left")
            print(f"找到 {len(card_elements)} 个教师评价卡片元素")

            # 显示找到的评价卡片文本
            for element in card_elements:
                print(element.text)

            # 循环点击所有评价卡片的底部元素
            for i, element in enumerate(card_elements):
                self.process_teacher_card(element, i)

            return True

        except Exception as e:
            print(f"评价教师过程中出错: {e}")
            return False


class TAEvaluator(Evaluator):
    """助教评价类，负责处理助教评价相关功能"""

    def process_ta_tab(self, ta_tab, tab_index):
        """处理单个助教标签页"""
        try:
            print(f"点击第 {tab_index+1} 个助教标签页")
            # 尝试滚动到元素位置
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", ta_tab)
            time.sleep(1)  # 等待滚动完成

            # 尝试点击元素
            success = self.click_with_js(ta_tab, f"第 {tab_index+1} 个助教标签页", 1)

            # 如果JavaScript点击失败，尝试直接点击
            if not success:
                try:
                    print(f"尝试直接点击第 {tab_index+1} 个助教标签页")
                    ta_tab.click()
                    print(f"成功直接点击第 {tab_index+1} 个助教标签页")
                except Exception as click_err:
                    print(f"直接点击第 {tab_index+1} 个助教标签页失败: {click_err}")
                    return False

            print(f"成功点击第 {tab_index+1} 个助教标签页")
            time.sleep(2)  # 延长等待时间，确保页面完全加载

            # 处理该标签页下的所有助教
            ta_card_processed = 0
            retry_count = 0
            max_retries = 50

            while retry_count < max_retries:
                # 每次循环重新获取助教卡片，避免stale element问题
                ta_card_elements = None

                # 方法1：通过CLASS_NAME查找
                try:
                    ta_card_elements = self.driver.find_elements(
                        By.CLASS_NAME, "pj-card.bh-pull-left")
                    if ta_card_elements and len(ta_card_elements) > 0:
                        print(f"方法1：找到 {len(ta_card_elements)} 个助教卡片元素")
                    else:
                        print("方法1：未找到助教卡片元素")
                        ta_card_elements = None
                except Exception as e:
                    print(f"方法1：查找助教卡片失败: {e}")
                    ta_card_elements = None

                # 方法2：通过更宽松的选择器查找（如果方法1失败）
                if not ta_card_elements or len(ta_card_elements) == 0:
                    try:
                        ta_card_elements = self.driver.find_elements(
                            By.CSS_SELECTOR, ".pj-card")
                        if ta_card_elements and len(ta_card_elements) > 0:
                            print(f"方法2：找到 {len(ta_card_elements)} 个助教卡片元素")
                        else:
                            print("方法2：未找到助教卡片元素")
                    except Exception as e:
                        print(f"方法2：查找助教卡片失败: {e}")

                if not ta_card_elements or ta_card_processed >= len(ta_card_elements):
                    if ta_card_processed > 0:
                        print(f"该标签页下的所有助教评价已完成，共处理 {ta_card_processed} 个助教")
                        break
                    else:
                        retry_count += 1
                        if retry_count >= max_retries:
                            print(f"尝试 {max_retries} 次后仍未找到助教卡片，跳过此标签页")
                            break
                        print(
                            f"未找到助教卡片，等待并重试... ({retry_count}/{max_retries})")
                        time.sleep(2)  # 等待页面可能的加载
                        continue

                print(
                    f"找到 {len(ta_card_elements)} 个助教卡片元素，正在处理第 {ta_card_processed+1} 个")

                # 打印所有卡片的文本内容，便于调试
                for i, card in enumerate(ta_card_elements):
                    try:
                        if i == ta_card_processed:  # 只打印当前要处理的卡片
                            print(f"卡片 {i+1} 内容: {card.text[:100]}")
                    except:
                        print(f"卡片 {i+1}: [无法获取文本]")

                if ta_card_processed < len(ta_card_elements):
                    if self.process_ta_card(ta_card_elements[ta_card_processed], ta_card_processed):
                        # 成功处理一个助教卡片
                        ta_card_processed += 1
                        retry_count = 0  # 成功处理后重置重试计数
                    else:
                        # 处理失败，递增计数器，但要有一定次数的重试
                        print(f"处理第 {ta_card_processed+1} 个助教卡片失败，将重试")
                        retry_count += 1
                        if retry_count >= max_retries:
                            print(f"尝试 {max_retries} 次后仍未成功处理，跳过此卡片")
                            ta_card_processed += 1  # 跳过当前卡片
                            retry_count = 0  # 重置重试计数
                        time.sleep(2)  # 等待一下再处理

            return True

        except Exception as tab_err:
            print(f"处理助教标签页失败: {tab_err}")
            return False

    def process_ta_card(self, current_card, card_index):
        """处理单个助教卡片"""
        try:
            print(f"处理第 {card_index+1} 个助教卡片")

            # 在卡片中查找底部元素
            ta_card_bottom = current_card.find_element(
                By.CLASS_NAME, "card-btn.blue")

            # 点击底部元素
            self.click_with_js(
                ta_card_bottom, f"第 {card_index+1} 个助教卡片的底部元素", 1)
            time.sleep(2)  # 确保评价页面加载完成

            # 处理评价选项
            ta_judge_indexes = self.driver.find_elements(
                By.CLASS_NAME, "sc-panel-thingNoImg-1-container.bh-mv-8.wjzb-card")

            # 先循环点击所有评价指标（除最后一个外）
            self.click_evaluation_options(ta_judge_indexes, "助教")

            # 所有评价指标处理完毕后，提交表单
            print("所有助教评价指标已处理完毕，准备提交表单")

            if self.find_and_click_submit_button("助教"):
                # 处理确认弹窗 - 尝试多种方法
                self.click_confirm_button(3)
                # 增加等待时间，确保确认操作完成并返回到列表页
                time.sleep(3)
                return True

            return False

        except Exception as card_err:
            print(f"处理第 {card_index+1} 个助教卡片失败: {card_err}")
            return False

    def evaluate_all_tas(self):
        """评价所有助教"""
        try:
            print("开始评价助教...")
            # 等待页面充分加载
            time.sleep(3)

            # 尝试多种方法查找助教标签页
            ta_tabs = None

            # 方法1：通过CLASS_NAME查找
            try:
                ta_tabs = self.driver.find_elements(
                    By.CLASS_NAME, "jqx-reset.jqx-disableselect.jqx-tabs-title.jqx-item.jqx-rc-t")
                if ta_tabs and len(ta_tabs) > 0:
                    print(f"方法1：通过CLASS_NAME找到 {len(ta_tabs)} 个助教标签页")
                else:
                    print("方法1：通过CLASS_NAME未找到助教标签页")
                    ta_tabs = None
            except Exception as e:
                print(f"方法1：通过CLASS_NAME查找助教标签页失败: {e}")
                ta_tabs = None

            # 方法2：通过XPath查找（如果方法1失败）
            if not ta_tabs or len(ta_tabs) == 0:
                try:
                    # 尝试更宽松的XPath
                    ta_tabs = self.driver.find_elements(
                        By.XPATH, "//div[contains(@class, 'jqx-tabs-title')]")
                    if ta_tabs and len(ta_tabs) > 0:
                        print(f"方法2：通过XPath找到 {len(ta_tabs)} 个助教标签页")
                    else:
                        print("方法2：通过XPath未找到助教标签页")
                except Exception as e:
                    print(f"方法2：通过XPath查找助教标签页失败: {e}")

            # 方法3：通过部分CLASS_NAME查找（如果方法1和2都失败）
            if not ta_tabs or len(ta_tabs) == 0:
                try:
                    # 尝试使用部分class name
                    ta_tabs = self.driver.find_elements(
                        By.CSS_SELECTOR, "div.jqx-tabs-title")
                    if ta_tabs and len(ta_tabs) > 0:
                        print(f"方法3：通过CSS_SELECTOR找到 {len(ta_tabs)} 个助教标签页")
                    else:
                        print("方法3：通过CSS_SELECTOR未找到助教标签页")
                except Exception as e:
                    print(f"方法3：通过CSS_SELECTOR查找助教标签页失败: {e}")

            # 输出所有找到的标签页文本
            if ta_tabs and len(ta_tabs) > 0:
                print("找到的助教标签页文本内容:")
                for i, tab in enumerate(ta_tabs):
                    try:
                        print(f"标签页 {i+1}: {tab.text}")
                    except:
                        print(f"标签页 {i+1}: [无法获取文本]")

                # 点击助教标签页 - 进入助教评价页面
                for ta_idx, ta_tab in enumerate(ta_tabs):
                    self.process_ta_tab(ta_tab, ta_idx)

                return True
            else:
                print("未找到任何助教标签页，可能没有助教需要评价或页面结构不符合预期")

                # 打印页面源码以便调试
                print("页面结构分析:")
                try:
                    # 查找可能包含助教标签的区域
                    tabs_container = self.driver.find_elements(
                        By.CLASS_NAME, "jqx-tabs")
                    if tabs_container and len(tabs_container) > 0:
                        print(f"找到 {len(tabs_container)} 个标签容器")
                        for i, container in enumerate(tabs_container):
                            print(
                                f"容器 {i+1} 内容: {container.get_attribute('innerHTML')[:200]}...")
                    else:
                        print("未找到标签容器")
                except Exception as e:
                    print(f"分析页面结构失败: {e}")

                return False

        except Exception as ta_error:
            print(f"评价助教过程中出错: {ta_error}")
            return False


def main():
    # 使用webdriver_manager自动下载并配置最新的Chrome驱动
    log("正在初始化Chrome浏览器...")
    try:
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service)
        log("Chrome浏览器初始化成功")
    except Exception as e:
        log(f"Chrome浏览器初始化失败: {e}")
        log("请确保已安装Chrome浏览器，并且网络连接正常")
        input("按任意键退出...")
        return None

    # 设置浏览器窗口大小
    driver.maximize_window()

    # 打开登录页面
    log(f"正在打开登录页面: {LOGIN_URL}")
    driver.get(LOGIN_URL)
    time.sleep(3)  # 等待页面加载

    # 完全手动登录
    log("请在浏览器中手动输入学号和密码，然后点击登录按钮")
    log("正在等待登录完成...")

    # 检测登录跳转并执行点击
    try:
        # 保存当前URL，用于检测页面是否跳转
        start_url = driver.current_url

        # 等待URL变化，最多等待60秒
        log("等待页面跳转...")
        max_wait = 60
        for i in range(max_wait):
            current_url = driver.current_url
            if current_url != start_url and "authserver" not in current_url:
                log(f"检测到页面跳转: {current_url}")
                break
            time.sleep(1)

        if driver.current_url == start_url or "authserver" in driver.current_url:
            log("登录超时，请确认是否成功登录")
            return driver

        log("登录成功，已跳转到评价系统")

        # 等待页面加载
        time.sleep(3)

        # 查找并点击评价入口
        log("查找评价入口...")
        cards = driver.find_element(
            By.CLASS_NAME, "pj-total-card.bh-clearfix")
        elements = cards.find_elements(By.XPATH, "//*[@id=\"pjglTopCard\"]")
        log(f"找到 {len(elements)} 个bh-clearfix元素:")
        for element in elements:
            log(element.text)

        if elements:
            # 直接点击第1个元素，因为它之前成功了
            target_element = elements[0]  # 索引是第1个元素
            log(f"直接点击第1个元素: {target_element.text}")

            # 使用JavaScript点击
            driver.execute_script(
                "arguments[0].scrollIntoView(true);", target_element)
            time.sleep(1)
            driver.execute_script("arguments[0].click();", target_element)
            log("已点击评价入口")
            time.sleep(1)  # 等待点击后页面加载
        else:
            log(f"元素数量只有 {len(elements)} 个")
            log("请手动点击进入评价页面")
            input("完成手动点击后按回车继续...")
            time.sleep(1)  # 等待手动点击后页面加载

    except Exception as e:
        log(f"出错: {e}")
        log("请手动操作，程序将继续运行...")

    try:
        # 首先评价所有教师
        log("-" * 50)
        log("开始评价所有教师...")
        log("-" * 50)
        teacher_evaluator = TeacherEvaluator(driver)
        teacher_evaluator.evaluate_all_teachers()

        # 然后评价所有助教
        log("-" * 50)
        log("所有课程教师评价完成，开始评价助教...")
        log("-" * 50)
        ta_evaluator = TAEvaluator(driver)
        ta_evaluator.evaluate_all_tas()

    except Exception as e:
        log(f"处理评价过程中出错: {e}")

    # 返回driver对象，方便后续操作
    return driver


if __name__ == "__main__":
    try:
        log("=" * 60)
        log("南京大学教室评价表自动填写程序 - 开始运行")
        log("=" * 60)
        driver = main()

        # 在这里可以添加后续操作
        log("程序执行完毕，可以关闭浏览器退出...")
        input()
    except Exception as e:
        log(f"程序执行出错: {e}")
        input("可以关闭浏览器退出...")
    finally:
        # 确保driver已初始化且存在才尝试关闭
        if 'driver' in locals() and driver:
            driver.quit()
            log("浏览器已关闭")
        log("程序已退出")
