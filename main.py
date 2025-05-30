from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
import os
import sys
import random
from config import LOGIN_URL, WEB_URL
from selenium.common.exceptions import TimeoutException, StaleElementReferenceException

# 尝试从配置文件导入Chrome驱动路径和自动下载设置
# CUSTOM_DRIVER_PATH 和 CHROME_DRIVER_PATH 不再使用，但保留配置文件的读取以防万一
try:
    from config import CHROME_DRIVER_PATH
    CUSTOM_DRIVER_PATH = True
except ImportError:
    CUSTOM_DRIVER_PATH = False

try:
    from config import USE_AUTO_DRIVER
    AUTO_DRIVER = USE_AUTO_DRIVER
except ImportError:
    AUTO_DRIVER = True  # 默认优先使用自动管理

# 创建日志目录
os.makedirs('logs', exist_ok=True)

# 设置日志文件
log_filename = f"logs/clicker_{time.strftime('%Y%m%d')}.log"


def is_exe_environment():
    """检查是否在exe环境中运行"""
    return getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS')


def safe_input(prompt="", timeout=30):
    """安全的输入函数，在exe环境中自动继续"""
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


def log(message):
    """记录日志到文件和控制台"""
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    log_message = f"[{timestamp}] {message}"
    print(log_message)
    with open(log_filename, 'a', encoding='utf-8') as f:
        f.write(log_message + '\n')


# 将 click_element_robustly 提升为全局函数
def click_element_robustly(driver, element_xpath, description, wait_for_element_secs=5, wait_after_click_secs=0.5):
    """辅助函数：查找、滚动并点击元素，记录日志，并在JS点击失败时尝试原生点击。"""
    try:
        log(f"  正在定位元素: '{description}' (XPath: {element_xpath})")
        element = WebDriverWait(driver, wait_for_element_secs).until(
            EC.presence_of_element_located((By.XPATH, element_xpath))
        )
        log(f"  ✅ 成功定位: '{description}'")

        try:
            element_text = element.text.strip()
            if element_text:
                log(f"    元素文本: '{element_text[:50].replace(chr(10), ' ')}...'")
        except Exception:
            pass

        driver.execute_script(
            "arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", element)
        time.sleep(0.5)

        try:
            driver.execute_script("arguments[0].click();", element)
            log(f"  ✅ 已通过 JS 点击: '{description}'")
        except Exception as js_err:
            log(f"  ⚠️ JS click 失败 for '{description}': {js_err}, 尝试原生 click")
            element.click()
            log(f"  ✅ 已通过原生 click 点击: '{description}'")

        log(f"  ...等待 {wait_after_click_secs} 秒...\n")
        time.sleep(wait_after_click_secs)
        return True
    except Exception as e:
        log(f"  ❌ 点击元素 '{description}' 失败: {e}")
        raise


def navigate_to_evaluation_from_ehall(driver):
    """
    从服务大厅导航到评教界面

    Args:
        driver: WebDriver实例

    Returns:
        bool: 是否成功导航到评教界面
    """
    log("-" * 50)
    log("开始从服务大厅导航到评教界面...")
    log("-" * 50)

    try:
        # 等待服务大厅页面加载
        log("等待服务大厅页面加载...")
        time.sleep(1)

        # 获取当前页面信息
        current_url = driver.current_url
        page_title = driver.title
        log(f"当前页面URL: {current_url}")
        log(f"页面标题: {page_title}")

        log(f"页面标题 (服务大厅入口): {driver.title}")

        log("🔍 正在寻找评教入口...")

        # 主方法：通过三步点击导航到评教系统
        log("尝试通过三步点击导航到评教系统...")

        try:
            # 第1步: 点击"本科生服务"
            xpath_step1 = "/html/body/div[2]/div/div[1]/div/div[2]/div[2]/div/div[2]/div[3]/div[1]/div/div[2]/div/div/div/div[1]/ul/li[7]"
            log("步骤 1/3: 准备点击 '本科生服务'")
            click_element_robustly(
                driver, xpath_step1, "'本科生服务'", wait_after_click_secs=0)
            log(f"  步骤 1/3 点击后 - 当前 URL: {driver.current_url}")
            log(f"  步骤 1/3 点击后 - 当前标题: {driver.title}")

            # 第2步: 点击"课程评估"
            xpath_step2 = "//*[@id=\"app\"]/div/div[1]/div/div[2]/div[2]/div/div[2]/div[3]/div[1]/div/div[2]/div/div/div/div[2]/div[9]/div/ul/li[6]"
            log("步骤 2/3: 准备点击 '课程评估'")
            click_element_robustly(driver, xpath_step2, "'课程评估'",
                                   wait_after_click_secs=0)
            log(f"  步骤 2/3 点击后 - 当前 URL: {driver.current_url}")
            log(f"  步骤 2/3 点击后 - 当前标题: {driver.title}")

            # 第3步: 点击"本-网上评教"
            xpath_step3 = "//*[@id=\"app\"]/div/div[1]/div/div[2]/div[2]/div/div[2]/div[3]/div[1]/div/div[2]/div/div/div/div[2]/div[9]/ul/li"
            log("步骤 3/3: 准备点击 '本-网上评教'")
            click_element_robustly(
                driver, xpath_step3, "'本-网上评教'", wait_after_click_secs=0)
            log(f"  步骤 3/3 点击后 - 当前 URL: {driver.current_url}")
            log(f"  步骤 3/3 点击后 - 当前标题: {driver.title}")

            log(f"当前页面URL: {driver.current_url}")

            log("✅ 完成三步点击导航操作。假定已成功导航到评教入口，继续执行...")
            time.sleep(0.5)
            return True

        except Exception as multistep_error:
            log(f"❌ 执行三步XPath点击导航时发生错误: {multistep_error}")
            log("将尝试备用方法...")

        # 备用方法：通过关键词查找
        log("尝试备用方法：通过关键词查找...")
        try:
            keywords = ["本-网上评教", "评教", "教学评价", "课程评价", "教师评价", "学生评教"]
            evaluation_element = None
            for keyword in keywords:
                try:
                    log(f"搜索关键词: '{keyword}'")
                    elements = driver.find_elements(
                        By.XPATH, f"//*[contains(text(), '{keyword}')]")
                    if elements:
                        log(f"找到包含 '{keyword}' 的元素 {len(elements)} 个")
                        for i, elem in enumerate(elements):
                            try:
                                elem_text = elem.text.strip()
                                if elem_text:
                                    log(f"  元素{i+1}: '{elem_text}'")
                                    if elem.is_displayed() and elem.is_enabled():
                                        evaluation_element = elem
                                        log(f"选择可点击的元素: '{elem_text}'")
                                        break
                            except:
                                log(f"  元素{i+1}: [无法获取文本]")
                        if evaluation_element:
                            break
                except Exception as e_kw_find:
                    log(f"查找 '{keyword}' 时出错: {e_kw_find}")
                    continue

            if evaluation_element:
                log("找到评教入口 (备用方法)，准备点击...")
                driver.execute_script(
                    "arguments[0].scrollIntoView(true);", evaluation_element)
                time.sleep(1)
                driver.execute_script(
                    "arguments[0].click();", evaluation_element)
                log("已点击评教入口 (备用方法)")
                time.sleep(3)
                log("✅ 已通过备用方法点击评教入口，假定导航成功。")
                return True
            else:
                log("❌ 未找到评教入口 (备用方法)")

        except Exception as method1_err:
            log(f"备用方法执行失败: {method1_err}")

        log("⚠️ 自动查找评教入口失败，请手动操作。")
        log("通常评教入口的名称可能是：本-网上评教, 教学评价, 课程评价, 学生评教, 教师评价")
        safe_input("请手动点击评教入口，完成后按回车继续...")
        log("✅ 用户已手动操作，假定已进入评教界面。")
        return True

    except Exception as e:
        log(f"导航过程中发生最外层意外错误: {e}")
        log("请尝试手动操作进入评教界面")
        safe_input("手动操作完成后按回车继续...")
        return True


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
            log(f"成功点击 '{description}' (JS)")
            return True
        except Exception as e:
            log(f"点击 '{description}' 失败 (JS): {e}")
            return False

    def find_and_click_submit_button(self, type_name=""):
        """查找并点击提交按钮"""
        log(f"所有{type_name}评价指标已处理完毕，准备提交表单")
        try:
            # 查找提交按钮
            submit_btn = self.driver.find_element(
                By.CLASS_NAME, "bh-btn.bh-btn-success.bh-btn-large")

            # 滚动到按钮位置并点击
            self.click_with_js(submit_btn, f"{type_name}评价提交按钮")
            return True
        except Exception as e:
            log(f"提交{type_name}评价表单失败: {e}")

            # 尝试备选方法找提交按钮
            try:
                # 通过XPath查找包含"提交"文本的按钮
                submit_xpath = self.driver.find_element(
                    By.XPATH, "//button[contains(text(), '提交')]")
                self.click_with_js(submit_xpath, f"{type_name}评价提交按钮(通过XPath)")
                return True
            except Exception as xpath_submit_error:
                log(f"通过XPath查找提交按钮失败: {xpath_submit_error}")

                # 尝试用LINE_TEXT查找提交按钮
                try:
                    submit_line_text = self.driver.find_element(
                        By.LINK_TEXT, "提交")
                    self.click_with_js(
                        submit_line_text, f"{type_name}评价提交按钮(通过LINE_TEXT)")
                    return True
                except Exception as line_text_submit_error:
                    log(f"通过LINE_TEXT查找提交按钮失败: {line_text_submit_error}")
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
                    log("已点击确认按钮(方法1)")
                    return True
                elif attempt == 1:
                    # 方法2：通过LINK_TEXT查找确认按钮
                    confirm_link_text = self.driver.find_element(
                        By.LINK_TEXT, "确认")
                    self.driver.execute_script(
                        "arguments[0].click();", confirm_link_text)
                    log("已点击确认按钮(方法2)")
                    return True
                elif attempt == 2:
                    # 方法3：通过其他XPath查找按钮
                    confirm_btn = self.driver.find_element(
                        By.XPATH, "//div[contains(@class, 'bh-dialog')]//button")
                    self.driver.execute_script(
                        "arguments[0].click();", confirm_btn)
                    log("已点击确认按钮(方法3)")
                    return True
                else:
                    # 方法4：通过LINK_TEXT查找确认按钮
                    confirm_link_text = self.driver.find_element(
                        By.LINK_TEXT, "确定")
                    self.driver.execute_script(
                        "arguments[0].click();", confirm_link_text)
                    log("已点击确认按钮(方法4)")
                    return True
            except Exception as e:
                log(f"尝试第 {attempt+1} 种方法点击确认按钮失败: {e}")
                time.sleep(0.5)  # 等待一下再尝试
        return False

    def click_evaluation_options(self, judge_elements, type_name=""):
        """点击评价选项（单选按钮）"""
        if not judge_elements or len(judge_elements) == 0:
            log(f"未找到任何{type_name}评价指标元素")
            return False

        log(f"找到 {len(judge_elements)} 个{type_name}评价指标")

        # 循环处理所有评价指标（除最后一个外）
        for idx, judge in enumerate(judge_elements):
            # 跳过最后一个评价指标，因为它通常是文本填写指标
            if idx == len(judge_elements) - 1:
                log(f"跳过最后一个指标（第 {idx+1} 个），因为它通常是文本填写指标")
                continue

            log(f"处理第 {idx+1} 个评价指标")

            # 尝试点击单选按钮
            try:
                radio_btn = judge.find_element(
                    By.CLASS_NAME, "bh-radio-label.fontcolor")
                self.click_with_js(radio_btn, f"第 {idx+1} 个指标的单选按钮", 0.00005)
            except Exception as radio_err:
                log(f"点击单选按钮失败: {radio_err}")

        return True


class TeacherEvaluator(Evaluator):
    """教师评价类，负责处理教师评价相关功能"""

    def process_teacher_card(self, card_element, card_index):
        """处理单个教师评价卡片"""
        time.sleep(0.7)
        try:
            # 在卡片中查找底部元素
            log(f"查找第 {card_index+1} 个评价卡片的底部元素")
            card_bottom = WebDriverWait(card_element, 10).until(
                EC.element_to_be_clickable((By.CLASS_NAME, "card-btn.blue"))
            )

            # 尝试点击底部元素
            log(f"点击第 {card_index+1} 个评价卡片的底部元素")
            success = self.click_with_js(
                card_bottom, f"第 {card_index+1} 个评价卡片的底部元素", 0.5)
            if not success:
                # 尝试备选点击方法
                return self.try_alternative_click_methods(card_element, card_index)

            time.sleep(1)  # 等待页面加载

            # 获取评价卡片中的评价指标
            return self.process_teacher_evaluation_form(card_index)

        except Exception as click_error:
            log(f"直接点击底部元素失败: {click_error}")
            return self.try_alternative_click_methods(card_element, card_index)

    def try_alternative_click_methods(self, card_element, card_index):
        """尝试备选的点击方法"""
        try:
            # 策略2：先滑动窗口，再点击底部元素
            log(f"策略2：滑动窗口后点击第 {card_index+1} 个评价卡片的底部元素")
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", card_element)
            time.sleep(0.5)

            card_bottom = card_element.find_element(
                By.CLASS_NAME, "card-bottom")
            self.driver.execute_script("arguments[0].click();", card_bottom)
            log(f"滑动后点击底部元素成功")
            time.sleep(1)  # 增加等待时间

            # 获取评价卡片中的评价指标
            return self.process_teacher_evaluation_form(card_index)

        except Exception as scroll_error:
            log(f"滑动后点击底部元素失败: {scroll_error}")

            try:
                # 策略3：尝试原生点击底部元素
                log(f"策略3：使用原生点击第 {card_index+1} 个评价卡片的底部元素")
                card_bottom = card_element.find_element(
                    By.CLASS_NAME, "card-bottom")
                card_bottom.click()
                log(f"原生点击底部元素成功")
                time.sleep(1)  # 增加等待时间

                # 获取评价卡片中的评价指标
                return self.process_teacher_evaluation_form(card_index)

            except Exception as native_error:
                log(f"原生点击底部元素失败: {native_error}")
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
                        log(f"处理第 {idx+1} 个评价指标: {judge_index.text}")

                        # 跳过最后一个评价指标，因为它通常是文本填写指标
                        if idx == len(judge_indexes) - 1:
                            log(f"跳过最后一个评价指标（第 {idx+1} 个），因为它通常是文本填写指标")
                            continue

                        # 如果该课程有多个老师，那么需要点击多个评价指标
                        judge_index_elements = judge_index.find_elements(
                            By.CLASS_NAME, "sc-panel-content.bh-clearfix.bh-mv-8.wjzb-card-jskc")
                        log(f"找到 {len(judge_index_elements)} 个judge-index元素")

                        # 确定要处理的元素列表
                        elements_to_process = []
                        if len(judge_index_elements) > 1:
                            elements_to_process = judge_index_elements
                            log(f"将处理 {len(elements_to_process)} 个教师评价")
                        else:
                            # 如果没有找到多教师元素，就处理当前评价指标
                            elements_to_process = [judge_index]
                            log("将处理单个评价指标")

                        # 循环处理所有需要评价的元素
                        for element_idx, element in enumerate(elements_to_process):
                            try:
                                element_desc = "教师" if len(
                                    judge_index_elements) > 1 else "评价指标"
                                log(f"处理第 {element_idx+1} 个{element_desc}")

                                # 尝试点击单选按钮
                                try:
                                    input_box = element.find_element(
                                        By.CLASS_NAME, "bh-radio-label.fontcolor")
                                    # 输入评价
                                    self.click_with_js(
                                        input_box, f"第 {element_idx+1} 个{element_desc}", 0.00005)
                                    time.sleep(1)
                                except Exception as radio_error:
                                    log(
                                        f"点击第 {element_idx+1} 个{element_desc}失败: {radio_error}")
                                    # 如果点击失败，直接跳过
                                    log(
                                        f"跳过第 {element_idx+1} 个{element_desc}的处理")

                            except Exception as element_error:
                                log(
                                    f"处理第 {element_idx+1} 个{element_desc}时出错: {element_error}")
                    except Exception as index_error:
                        log(f"处理第 {idx+1} 个评价指标时出错: {index_error}")
            else:
                log("未找到任何评价指标元素")
                return False

            # 所有评价指标处理完毕后，提交表单
            if self.find_and_click_submit_button("教师"):
                # 点击确认按钮
                self.click_confirm_button(4)
                # 等待确认操作完成
                time.sleep(1)
                return True

            return False

        except Exception as judge_error:
            log(f"获取评价指标失败: {judge_error}")
            return False

    def evaluate_all_teachers(self):
        """评价所有教师"""
        try:
            # 等待评价页面加载
            time.sleep(1)

            # 首先获取总共需要评价的教师数量
            initial_cards_on_page = []
            try:
                WebDriverWait(self.driver, 5).until(
                    EC.presence_of_all_elements_located(
                        (By.CLASS_NAME, "pj-card.bh-pull-left"))
                )
                initial_cards_on_page = self.driver.find_elements(
                    By.CLASS_NAME, "pj-card.bh-pull-left")
                log("教师评价卡片列表初次加载完成。")
            except TimeoutException:
                log("❌ 初始加载教师评价卡片列表超时。可能页面没有卡片或加载失败。")
                return False

            num_teachers_to_evaluate = len(initial_cards_on_page)
            log(f"检测到总共有 {num_teachers_to_evaluate} 位教师需要评价。")

            if num_teachers_to_evaluate == 0:
                log("未发现需要评价的教师。")
                return True  # 没有教师则认为成功

            # 循环处理每一位教师
            for i in range(num_teachers_to_evaluate):
                log(f"--- 开始处理第 {i + 1} 位教师 (共 {num_teachers_to_evaluate} 位) ---")

                # 在每次迭代开始时，等待并重新获取卡片列表，确保元素是新鲜的
                try:
                    WebDriverWait(self.driver, 5).until(
                        EC.presence_of_all_elements_located(
                            (By.CLASS_NAME, "pj-card.bh-pull-left"))
                    )
                    log(f"教师列表页面已稳定，准备定位第 {i + 1} 张卡片。")
                except TimeoutException:
                    log(f"❌ 在尝试处理第 {i + 1} 位教师前，等待教师列表刷新超时。评价可能无法继续。")
                    return False  # 如果列表不出现，关键错误

                current_cards_on_page = self.driver.find_elements(
                    By.CLASS_NAME, "pj-card.bh-pull-left")

                if i >= len(current_cards_on_page):
                    log(
                        f"❌ 严重错误：期望处理索引为 {i} 的卡片 (即第 {i+1} 张)，但刷新后页面上只有 {len(current_cards_on_page)} 张卡片。")
                    log("这可能是由于前一个评价操作导致卡片数量非预期改变，或页面未能正确返回列表。")
                    return False

                teacher_card_element = current_cards_on_page[i]

                # 尝试记录卡片信息，增加调试信息
                try:
                    card_text_preview = teacher_card_element.text.strip().replace(chr(10), ' ')[
                        :100]  # 增加预览长度
                    log(f"  即将处理的卡片 (第 {i+1} 张) 文本预览: '{card_text_preview}...'")
                except StaleElementReferenceException:
                    # 理论上，因为刚获取元素，这里不应发生。但以防万一。
                    log(f"⚠️ 警告: 在尝试获取第 {i+1} 张卡片的文本时，发生StaleElementReferenceException。这非常意外。")
                    # 即使发生，也尝试继续，process_teacher_card 内部有自己的健壮性处理
                except Exception as e_text:
                    log(f"  (获取第 {i+1} 张卡片文本预览时发生错误: {e_text})")

                # 调用处理单个卡片的函数
                # process_teacher_card 内部有用户添加的 time.sleep(0.7)
                if not self.process_teacher_card(teacher_card_element, i):
                    log(f"处理第 {i + 1} 位教师的评价表单失败。")
                    # 此处可以根据需求决定是继续评价下一位还是中止 (例如 return False)
                    # 当前逻辑：记录日志并继续尝试下一位

                log(f"--- 第 {i + 1} 位教师处理流程结束。准备返回或刷新列表页面。 ---")
                # 在处理完一个教师后，增加必要的等待，确保页面回到列表状态并稳定
                # 这里的等待非常重要，因为process_teacher_card后页面状态会改变
                time.sleep(2)  # 等待列表页面刷新和稳定，可以根据实际情况调整或替换为显式等待特定元素

            log("✅ 所有已检测到的教师均已尝试处理完毕。")
            return True

        except Exception as e:
            log(f"评价所有教师的过程中发生无法处理的顶层错误: {e}")
            return False


class TAEvaluator(Evaluator):
    """助教评价类，负责处理助教评价相关功能"""

    def process_ta_tab(self, ta_tab, tab_index):
        """处理单个助教标签页"""
        try:
            log(f"点击第 {tab_index+1} 个助教标签页")
            # 尝试滚动到元素位置
            self.driver.execute_script(
                "arguments[0].scrollIntoView(true);", ta_tab)
            time.sleep(0.5)  # 等待滚动完成

            # 尝试点击元素
            success = self.click_with_js(ta_tab, f"第 {tab_index+1} 个助教标签页", 1)

            # 如果JavaScript点击失败，尝试直接点击
            if not success:
                try:
                    log(f"尝试直接点击第 {tab_index+1} 个助教标签页")
                    ta_tab.click()
                    log(f"成功直接点击第 {tab_index+1} 个助教标签页")
                except Exception as click_err:
                    log(f"直接点击第 {tab_index+1} 个助教标签页失败: {click_err}")
                    return False

            log(f"成功点击第 {tab_index+1} 个助教标签页")

            # 等待该标签页下的第一个助教卡片出现，表明内容已加载
            try:
                WebDriverWait(self.driver, 10).until(
                    EC.presence_of_element_located(
                        (By.CLASS_NAME, "pj-card.bh-pull-left"))
                )
                log(f"助教内容已初步加载于标签页 {tab_index+1}。")
            except TimeoutException:
                log(f"❌ 点击标签页 {tab_index+1} 后，等待助教卡片初步加载超时。可能此标签页无助教内容。")
                return True  # 认为此标签页处理完成（无内容）

            time.sleep(0.5)  # 短暂等待，确保DOM更新

            # 获取此标签页中总共需要评价的助教数量
            initial_ta_cards_in_tab = []
            try:
                # 等待卡片列表稳定并获取初始列表
                WebDriverWait(self.driver, 15).until(
                    EC.presence_of_all_elements_located(
                        (By.CLASS_NAME, "pj-card.bh-pull-left"))
                )
                initial_ta_cards_in_tab = self.driver.find_elements(
                    By.CLASS_NAME, "pj-card.bh-pull-left")
                log(f"助教卡片列表在标签页 {tab_index + 1} 中初次统计完成。")
            except TimeoutException:
                log(f"❌ 初始统计助教卡片列表超时 (标签页 {tab_index + 1})。")
                return False  # 如果无法统计，则此标签页处理失败

            num_tas_in_tab = len(initial_ta_cards_in_tab)
            log(f"检测到标签页 {tab_index + 1} 中总共有 {num_tas_in_tab} 位助教需要评价。")

            if num_tas_in_tab == 0:
                log(f"标签页 {tab_index + 1} 中未发现需要评价的助教。")
                return True  # 没有助教则认为此标签页成功处理完毕

            # 循环处理此标签页中的每一位助教
            for card_idx_in_tab in range(num_tas_in_tab):
                log(f"--- 开始处理标签页 {tab_index + 1} 中的第 {card_idx_in_tab + 1} 位助教 (共 {num_tas_in_tab} 位) ---")

                current_ta_card_element = None
                # 在每次迭代开始时，等待并重新获取卡片列表
                try:
                    WebDriverWait(self.driver, 20).until(
                        EC.presence_of_all_elements_located(
                            (By.CLASS_NAME, "pj-card.bh-pull-left"))
                    )
                    log(f"助教列表页面 (标签页 {tab_index + 1}) 已稳定，准备定位第 {card_idx_in_tab + 1} 张卡片。")
                except TimeoutException:
                    log(f"❌ 在尝试处理标签页 {tab_index + 1} 中第 {card_idx_in_tab + 1} 位助教前，等待助教列表刷新超时。")
                    return False  # 关键错误，无法继续处理此标签页

                current_ta_cards_on_page = self.driver.find_elements(
                    By.CLASS_NAME, "pj-card.bh-pull-left")

                if card_idx_in_tab >= len(current_ta_cards_on_page):
                    log(f"❌ 严重错误：期望处理索引为 {card_idx_in_tab} 的助教卡片 (标签页 {tab_index + 1})，但刷新后页面上只有 {len(current_ta_cards_on_page)} 张。")
                    return False  # 无法继续处理此标签页

                current_ta_card_element = current_ta_cards_on_page[card_idx_in_tab]

                try:
                    card_text_preview = current_ta_card_element.text.strip().replace(chr(10), ' ')[
                        :100]
                    log(f"  即将处理的助教卡片 (第 {card_idx_in_tab + 1} 张于标签页 {tab_index+1}) 文本预览: '{card_text_preview}...'")
                except StaleElementReferenceException:
                    log(f"⚠️ 警告: 在尝试获取第 {card_idx_in_tab + 1} 张助教卡片的文本时发生StaleElementReferenceException。这非常意外。")
                except Exception as e_text:
                    log(f"  (获取第 {card_idx_in_tab + 1} 张助教卡片文本预览时发生错误: {e_text})")

                # 调用 process_ta_card 处理单个助教卡片
                if not self.process_ta_card(current_ta_card_element, card_idx_in_tab):
                    log(f"处理标签页 {tab_index + 1} 中第 {card_idx_in_tab + 1} 位助教的评价表单失败。")
                    # 当前逻辑：记录日志并继续尝试下一位助教

                log(f"--- 标签页 {tab_index + 1} 中第 {card_idx_in_tab + 1} 位助教处理流程结束。等待列表页稳定。 ---")
                # 关键：在处理完一个助教后，等待页面回到列表状态并稳定
                time.sleep(2)  # 可以根据实际情况调整或替换为更明确的等待条件

            log(f"✅ 所有已检测到的助教 (标签页 {tab_index + 1}) 均已尝试处理完毕。")
            return True

        except Exception as tab_err:
            log(f"处理助教标签页失败: {tab_err}")
            return False

    def process_ta_card(self, current_card, card_index):
        """处理单个助教卡片"""
        try:
            log(f"处理第 {card_index+1} 个助教卡片")

            # 在卡片中查找底部元素
            ta_card_bottom = current_card.find_element(
                By.CLASS_NAME, "card-btn.blue")

            # 点击底部元素
            self.click_with_js(
                ta_card_bottom, f"第 {card_index+1} 个助教卡片的底部元素", 1)

            # 等待评价选项容器可见
            try:
                WebDriverWait(self.driver, 10).until(
                    EC.visibility_of_element_located(
                        (By.CLASS_NAME, "sc-panel-thingNoImg-1-container.bh-mv-8.wjzb-card"))
                )
                log(f"✅ 至少一个评价选项容器对助教卡片 {card_index+1} 可见。")
            except TimeoutException:
                # 如果评价选项容器未出现，则尝试通过链接文本查找
                try:
                    WebDriverWait(self.driver, 10).until(
                        EC.presence_of_element_located(
                            (By.LINK_TEXT, "很好"))
                    )
                    log(f"✅ 通过链接文本找到评价选项容器对助教卡片 {card_index+1} 可见。")
                except TimeoutException:
                    log(f"❌ 等待评价选项容器对助教卡片 {card_index+1} 可见超时。")
                    return False  # 如果容器未出现，则此卡片处理失败

            time.sleep(1)  # 增加延时，确保所有评价项加载

            # 处理评价选项
            ta_judge_indexes = self.driver.find_elements(
                By.CLASS_NAME, "sc-panel-thingNoImg-1-container.bh-mv-8.wjzb-card")

            if not ta_judge_indexes:
                log(f"⚠️ 等待后，仍未找到助教卡片 {card_index+1} 的评价选项元素 ('sc-panel-thingNoImg-1-container.bh-mv-8.wjzb-card')。表单可能为空或页面结构已更改。")
                return False  # 如果未找到评价项，则无法继续

            # 先循环点击所有评价指标（除最后一个外）
            evaluation_options_processed = self.click_evaluation_options(
                ta_judge_indexes, "助教")

            if not evaluation_options_processed:
                log(f"处理助教卡片 {card_index+1} 的评价选项失败 (例如，没有可点击的项目，或在 click_evaluation_options 中发生错误)。")
                return False  # 如果评价选项处理失败，则此卡片处理失败

            # 所有评价指标处理完毕后，提交表单
            log("所有助教评价指标已处理完毕，准备提交表单")

            if self.find_and_click_submit_button("助教"):
                # 处理确认弹窗 - 尝试多种方法
                self.click_confirm_button(4)
                # 增加等待时间，确保确认操作完成并返回到列表页
                time.sleep(1)
                return True

            return False

        except Exception as card_err:
            log(f"处理第 {card_index+1} 个助教卡片失败: {card_err}")
            return False

    def evaluate_all_tas(self):
        """评价所有助教"""
        try:
            log("开始评价助教...")
            # 等待页面充分加载
            time.sleep(1)

            # 尝试多种方法查找助教标签页
            ta_tabs = None

            # 方法1：通过ID查找
            try:
                ta_tabs = self.driver.find_elements(
                    By.ID, "tabName-content-1")
                if ta_tabs and len(ta_tabs) > 0:
                    log(f"方法1：通过ID找到 {len(ta_tabs)} 个助教标签页")
                else:
                    log("方法1：通过ID未找到助教标签页")
                    ta_tabs = None
            except Exception as e:
                log(f"方法1：通过ID查找助教标签页失败: {e}")
                ta_tabs = None

            # 方法2：通过CLASS_NAME查找
            if not ta_tabs or len(ta_tabs) == 0:
                try:
                    ta_tabs = self.driver.find_elements(
                        By.CLASS_NAME, "jqx-reset.jqx-disableselect.jqx-tabs-title.jqx-item.jqx-rc-t")
                except Exception as e:
                    log(f"方法2：通过CLASS_NAME查找助教标签页失败: {e}")

            # 输出所有找到的标签页文本
            if ta_tabs and len(ta_tabs) > 0:
                log("找到的助教标签页文本内容:")
                for i, tab in enumerate(ta_tabs):
                    try:
                        log(f"标签页 {i+1}: {tab.text}")
                    except:
                        log(f"标签页 {i+1}: [无法获取文本]")

                # 点击助教标签页 - 进入助教评价页面
                for ta_idx, ta_tab in enumerate(ta_tabs):
                    self.process_ta_tab(ta_tab, ta_idx)

                return True
            else:
                log("未找到任何助教标签页，可能没有助教需要评价或页面结构不符合预期")

                # 打印页面源码以便调试
                log("页面结构分析:")
                try:
                    # 查找可能包含助教标签的区域
                    tabs_container = self.driver.find_elements(
                        By.CLASS_NAME, "jqx-tabs")
                    if tabs_container and len(tabs_container) > 0:
                        log(f"找到 {len(tabs_container)} 个标签容器")
                        for i, container in enumerate(tabs_container):
                            log(
                                f"容器 {i+1} 内容: {container.get_attribute('innerHTML')[:200]}...")
                    else:
                        log("未找到标签容器")
                except Exception as e:
                    log(f"分析页面结构失败: {e}")

                return False

        except Exception as ta_error:
            log(f"评价助教过程中出错: {ta_error}")
            return False


def perform_login(driver):
    """执行登录操作，包括打开登录页、检测表单、等待用户输入和跳转。"""
    log(f"正在打开登录页面: {LOGIN_URL}")

    try:
        driver.get(LOGIN_URL)
        log("URL请求已发送，等待页面加载...")
        time.sleep(1)  # 等待页面基本加载

        current_url = driver.current_url
        page_title = driver.title
        log(f"当前页面URL: {current_url}")
        log(f"页面标题: {page_title}")

        if "authserver.nju.edu.cn" in current_url:
            log("✅ 成功访问南大认证服务器")
            login_form_detected = False
            try:
                WebDriverWait(driver, 5).until(
                    EC.presence_of_element_located((By.ID, "username"))
                )
                log("✅ 登录表单已加载 (检测到ID 'username')")
                login_form_detected = True
            except TimeoutException:
                log("⚠️ 未检测到ID 'username'")

            if not login_form_detected:
                try:
                    WebDriverWait(driver, 2).until(
                        EC.presence_of_element_located((By.ID, "password"))
                    )
                    log("✅ 登录表单已加载 (检测到ID 'password')")
                    login_form_detected = True
                except TimeoutException:
                    log("⚠️ 未检测到ID 'password'")

            if not login_form_detected:
                try:
                    WebDriverWait(driver, 2).until(
                        EC.presence_of_element_located(
                            (By.CLASS_NAME, "auth_tab_content"))
                    )
                    log("✅ 登录表单已加载 (检测到CLASS_NAME 'auth_tab_content')")
                    login_form_detected = True
                except TimeoutException:
                    log("⚠️ 未检测到CLASS_NAME 'auth_tab_content'")

            if not login_form_detected:
                try:
                    WebDriverWait(driver, 2).until(
                        EC.presence_of_element_located(
                            (By.XPATH, "/html/body/div[3]/div[1]/div[2]/div[1]/div[3]"))
                    )
                    log("✅ 登录表单已加载 (通过指定XPath检测到登录相关元素)")
                    login_form_detected = True
                except TimeoutException:
                    log("⚠️ 未通过指定XPath检测到登录相关元素")

            if not login_form_detected:
                log("⚠️ 未能通过多种方法检测到明确的登录表单元素，但页面可能仍然可用或已自动登录。")

        elif "ehallapp.nju.edu.cn" in current_url or "ehall.nju.edu.cn" in current_url:
            log("✅ 已直接进入ehall系统 (可能已登录或自动跳转)")
            # 如果直接进入ehall，也视为一种登录成功状态，但后续的"等待跳转"逻辑可能不需要那么严格
            # 这里可以直接返回 True，或者让后续的跳转检测逻辑来确认
            # 为了统一，让后续逻辑处理
            pass  # 继续执行后续的登录流程，它会处理URL的判断
        else:
            log(f"⚠️ 页面跳转到了意外的URL: {current_url}")
            log("这可能是网络问题或服务器维护，请检查网络连接")

    except Exception as load_err:
        log(f"❌ 登录页面加载失败: {load_err}")
        try:
            log("尝试简单的连通性测试...")
            driver.get("https://www.baidu.com")
            time.sleep(3)
            if "baidu.com" in driver.current_url:
                log("✅ 网络连接正常，问题可能是南大服务器")
                log("正在重新尝试访问南大登录页面...")
                driver.get(LOGIN_URL)
                time.sleep(5)  # 给更长的时间加载
            else:
                log("❌ 网络连接异常")
                return False  # 网络异常，登录失败
        except Exception as test_err:
            log(f"❌ 连通性测试失败: {test_err}")
            return False  # 连通性测试失败，登录失败

    # 重新启用JavaScript（如果之前禁用了）
    try:
        driver.execute_script("console.log('JavaScript已启用');")
        log("✅ JavaScript功能正常")
    except:
        log("⚠️ JavaScript可能被禁用")

    # 完全手动登录
    log("请在浏览器中手动输入学号和密码，然后点击登录按钮")
    log("程序将等待您完成登录操作...")

    # 检测登录跳转
    try:
        start_url = driver.current_url
        log(f"登录操作发起前URL: {start_url}")

        # 等待URL变化，最多等待60秒
        log("等待登录后页面跳转...")
        max_wait_login_jump = 60
        login_jump_successful = False
        final_url = start_url

        for i in range(max_wait_login_jump):
            current_url_check = driver.current_url
            if current_url_check != start_url and "authserver" not in current_url_check:
                log(f"检测到页面跳转 (尝试 {i+1}/{max_wait_login_jump}): 新URL: {current_url_check}")
                final_url = current_url_check
                if "ehallapp.nju.edu.cn" in final_url or "ehall.nju.edu.cn" in final_url:
                    log("✅ 成功跳转到ehall相关页面")
                    login_jump_successful = True
                    break
                else:
                    # 跳转了但不是ehall，继续等待，可能还会有后续跳转
                    log(f"⚠️ 跳转到了非预期的ehall页面: {final_url}，继续观察...")

            if (i + 1) % 10 == 0:
                log(f"等待登录跳转中... ({i+1}/{max_wait_login_jump}秒), 当前URL: {driver.current_url}")
            time.sleep(1)

        if not login_jump_successful:
            final_url = driver.current_url  # 获取等待结束时的最终URL
            log(f"登录跳转等待结束。最终URL: {final_url}")
            if final_url == start_url or "authserver" in final_url:
                log("登录超时或未成功跳转出认证页面。")
            elif "ehallapp.nju.edu.cn" in final_url or "ehall.nju.edu.cn" in final_url:
                log("✅ 在等待超时前，已成功跳转到ehall相关页面 (可能是最后一次检查时发现)。")
                login_jump_successful = True
            else:
                log(f"⚠️ 登录后跳转到了非ehall的未知页面: {final_url}")

        if login_jump_successful:
            log("✅ 登录并成功导航到服务大厅 (ehall)")
            return True
        else:
            log("❌ 未能自动检测到成功登录并跳转到服务大厅 (ehall)。")
            # 询问用户是否已正确进入服务大厅
            response = safe_input(
                "程序未能自动确认登录状态。您是否已手动成功登录并进入了【服务大厅 (ehall)】？请回答 y/n: ").lower()
            if response == 'y':
                log("✅ 用户确认已在服务大厅")
                # 再次检查当前URL，以防万一
                current_final_url = driver.current_url
                if "ehallapp.nju.edu.cn" in current_final_url or "ehall.nju.edu.cn" in current_final_url:
                    log(f"用户确认后，当前URL为: {current_final_url}，符合ehall特征。")
                    return True
                else:
                    log(
                        f"⚠️ 用户确认在ehall，但当前URL ({current_final_url}) 并不直接指向ehall。继续执行，但可能存在风险。")
                    return True  # 相信用户的判断
            else:
                log("❌ 用户确认未在服务大厅，或登录失败。")
                return False

    except Exception as e:
        log(f"登录跳转检测过程中发生意外错误: {e}")
        # 即使出错，也询问用户是否已在ehall
        response = safe_input(
            "登录过程中出现错误。您是否已手动成功登录并进入了【服务大厅 (ehall)】？请回答 y/n: ").lower()
        if response == 'y':
            log("✅ 用户确认已在服务大厅")
            return True
        else:
            log("❌ 用户确认未在服务大厅，或登录失败。")
            return False


def main():
    # 初始化Chrome浏览器
    log("正在初始化Chrome浏览器...")
    driver = None
    options = webdriver.ChromeOptions()

    # Explicitly set Chrome binary location (try common paths)
    chrome_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        os.path.expandvars(
            r"%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe")
    ]
    found_chrome_path = None
    for path in chrome_paths:
        if os.path.exists(path):
            found_chrome_path = path
            break
    if found_chrome_path:
        options.binary_location = found_chrome_path
        log(f"Explicitly set Chrome binary location to: {found_chrome_path}")
    else:
        log("Could not find Chrome binary at common locations. Relying on system PATH.")

    # 优化Chrome启动参数
    options.add_argument("--no-sandbox")  # Re-adding, often needed
    options.add_argument("--disable-dev-shm-usage")  # Keep for compatibility
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--ignore-ssl-errors")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-gpu")
    options.add_argument("--start-maximized")
    options.add_argument("--disable-infobars")
    options.add_argument("--enable-automation")
    options.add_argument("--test-type")  # Often used with --no-sandbox
    # Helps with WebDriver navigation
    options.add_argument("--disable-browser-side-navigation")
    options.add_argument("--disable-blink-features=AutomationControlled")
    # Reduce Chrome's own logging verbosity displayed to console by driver
    options.add_argument("--log-level=0")

    # 设置用户代理，避免被检测为自动化工具
    # 定义一组常用的User-Agent
    user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/119.0',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
        'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36'
    ]
    # 随机选择一个User-Agent
    selected_user_agent = random.choice(user_agents)
    options.add_argument(f"--user-agent={selected_user_agent}")
    log(f"使用随机User-Agent: {selected_user_agent}")

    # 1. 尝试 Selenium Manager（推荐）
    try:
        log("尝试使用Selenium Manager自动解析驱动...")
        driver = webdriver.Chrome(options=options)  # Selenium 4.6+ 会自动下载
        log("Selenium Manager初始化成功")
    except Exception as sm_err:
        log(f"Selenium Manager初始化失败: {sm_err}")
        driver = None

    # 2. 如果Selenium Manager失败，尝试 webdriver_manager
    if driver is None:
        try:
            log("尝试使用webdriver_manager自动下载驱动...")
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=options)
            log("webdriver_manager初始化成功")
        except Exception as wdm_err:
            log(f"webdriver_manager初始化失败: {wdm_err}")
            driver = None

    if driver is None:
        log("未能成功初始化Chrome驱动，程序退出。请检查驱动版本或手动配置CHROME_DRIVER_PATH。")
        safe_input("按任意键退出...")
        return None

    log("Chrome驱动初始化完成.")  # 新增日志
    time.sleep(1)  # 给浏览器进程一点额外时间启动

    try:
        # 设置浏览器窗口大小 - 已通过 options.add_argument("--start-maximized") 实现
        # driver.maximize_window()
        # log("浏览器窗口已最大化")

        # 设置页面加载超时
        driver.set_page_load_timeout(30)
        log("页面加载超时设置为30秒")

        # 执行登录操作
        if not perform_login(driver):
            log("❌ 登录失败或未能导航到服务大厅，程序将退出。")
            return driver  # 返回driver以便在finally中关闭

        # 等待页面加载
        time.sleep(1)  # 给ehall页面一点加载时间

        # 从服务大厅导航到评教界面
        log("开始从服务大厅导航到评教界面...")
        navigation_success = navigate_to_evaluation_from_ehall(driver)

        if not navigation_success:
            log("❌ 导航到评教界面失败")
            log("程序将退出，请检查服务大厅页面或手动进入评教界面")
            return driver  # 返回driver以便在finally中关闭

    except Exception as browser_err:
        log(f"浏览器操作过程中出错: {browser_err}")
        return driver

    # 等待页面加载，并切换到新窗口
    log("等待页面加载...")
    windows = driver.window_handles
    log(f"当前窗口句柄: {windows}")
    driver.switch_to.window(windows[-1])

    # 打印当前页面的信息
    log(f"当前页面URL: {driver.current_url}")
    log(f"当前页面标题: {driver.title}")

    target_xpath_classroom_eval = "//*[@id=\"pjglTopCard\"]"
    log(f"准备点击教室评价界面入口，XPath: {target_xpath_classroom_eval}")

    try:
        # 使用 click_element_robustly 点击
        if click_element_robustly(driver, target_xpath_classroom_eval, "'教室评价界面入口'", wait_after_click_secs=2):
            log("✅ 成功通过 click_element_robustly 点击教室评价界面入口。")
        else:
            # click_element_robustly 内部在失败时会 raise Exception,
            # 所以正常情况下不应该执行到这个 else 分支。
            # 但保留以防万一该函数的行为未来被修改。
            log("⚠️ 调用 click_element_robustly 点击教室评价入口返回 False (理论上应抛出异常)。")
            # 可以考虑是否需要错误处理或直接让程序尝试继续执行后续代码
    except Exception as e:
        log(f"❌ 点击教室评价界面入口时发生错误 (通过 click_element_robustly): {e}")
        # 此处可以决定是否因为此关键步骤失败而中止程序
        # 例如: log("关键导航步骤失败，程序将退出。"); return driver

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
        safe_input()
    except Exception as e:
        log(f"程序执行出错: {e}")
        safe_input("可以关闭浏览器退出...")
    finally:
        # 确保driver已初始化且存在才尝试关闭
        if 'driver' in locals() and driver:
            driver.quit()
            log("浏览器已关闭")
        log("程序已退出")
