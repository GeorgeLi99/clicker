"""
南大服务大厅导航到评教界面的Selenium实现示例

这个文件提供了在navigate_to_evaluation_from_ehall函数中实现具体selenium逻辑的示例代码。
请根据实际的服务大厅页面结构修改以下代码。

使用方法：
1. 先在浏览器中手动访问服务大厅
2. 使用开发者工具（F12）查看评教入口的HTML结构
3. 根据实际结构修改下面的选择器和逻辑
4. 将修改后的代码复制到main.py中的navigate_to_evaluation_from_ehall函数
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import time

# ================================
# 常用的评教入口查找方法示例
# ================================


def find_evaluation_entrance_method1(driver):
    """方法1：通过文本内容查找"""
    try:
        # 查找包含"评教"、"教学评价"等文字的元素
        keywords = ["评教", "教学评价", "课程评价", "教师评价", "学生评教"]

        for keyword in keywords:
            try:
                # XPath: 查找包含特定文本的元素
                elements = driver.find_elements(
                    By.XPATH, f"//*[contains(text(), '{keyword}')]")

                for element in elements:
                    # 检查元素是否可见且可点击
                    if element.is_displayed() and element.is_enabled():
                        print(f"找到评教入口: {element.text}")
                        return element

            except Exception as e:
                print(f"搜索'{keyword}'时出错: {e}")
                continue

        return None

    except Exception as e:
        print(f"方法1出错: {e}")
        return None


def find_evaluation_entrance_method2(driver):
    """方法2：通过CSS类名或ID查找"""
    try:
        # 常见的服务大厅卡片选择器（根据实际页面修改）
        selectors = [
            # 通用卡片选择器
            ".service-card",
            ".app-card",
            ".function-card",
            ".module-card",

            # 可能的评教专用选择器（需要根据实际页面确定）
            "#evaluation-card",
            ".evaluation-entrance",
            "[data-service='evaluation']",

            # 通过链接href属性查找
            "a[href*='pj']",  # pj可能是评价(pingjia)的缩写
            "a[href*='evaluation']",
            "a[href*='teaching']",
        ]

        for selector in selectors:
            try:
                elements = driver.find_elements(By.CSS_SELECTOR, selector)
                print(f"选择器 '{selector}' 找到 {len(elements)} 个元素")

                for element in elements:
                    # 检查元素文本是否包含评教相关关键词
                    element_text = element.text.strip()
                    if any(keyword in element_text for keyword in ["评教", "教学评价", "课程评价"]):
                        print(f"找到疑似评教元素: {element_text}")
                        return element

            except Exception as e:
                print(f"选择器 '{selector}' 查找失败: {e}")
                continue

        return None

    except Exception as e:
        print(f"方法2出错: {e}")
        return None


def find_evaluation_entrance_method3(driver):
    """方法3：通过父容器查找"""
    try:
        # 首先找到服务列表容器
        container_selectors = [
            ".service-list",
            ".app-list",
            ".function-list",
            ".grid-container",
            ".card-container"
        ]

        for container_selector in container_selectors:
            try:
                containers = driver.find_elements(
                    By.CSS_SELECTOR, container_selector)

                for container in containers:
                    # 在容器内查找所有可点击元素
                    clickable_elements = container.find_elements(
                        By.CSS_SELECTOR, "a, button, .clickable")

                    for element in clickable_elements:
                        element_text = element.text.strip()
                        if any(keyword in element_text for keyword in ["评教", "教学评价", "课程评价"]):
                            print(f"在容器内找到评教元素: {element_text}")
                            return element

            except Exception as e:
                print(f"容器选择器 '{container_selector}' 查找失败: {e}")
                continue

        return None

    except Exception as e:
        print(f"方法3出错: {e}")
        return None


def wait_for_page_load(driver, timeout=10):
    """等待页面加载完成"""
    try:
        # 等待页面Ready状态
        WebDriverWait(driver, timeout).until(
            lambda driver: driver.execute_script(
                "return document.readyState") == "complete"
        )

        # 额外等待一段时间确保动态内容加载
        time.sleep(2)
        return True

    except TimeoutException:
        print("页面加载超时")
        return False


def check_if_evaluation_page(driver):
    """检查是否已经进入评教页面"""
    try:
        current_url = driver.current_url
        page_title = driver.title
        page_source = driver.page_source

        # 检查URL特征
        url_indicators = ["pj", "evaluation", "assess", "rating"]
        if any(indicator in current_url.lower() for indicator in url_indicators):
            return True

        # 检查页面标题
        title_indicators = ["评价", "评教", "教学评价", "课程评价"]
        if any(indicator in page_title for indicator in title_indicators):
            return True

        # 检查页面内容
        content_indicators = ["教师评价", "课程评价", "评价指标", "评价表"]
        if any(indicator in page_source for indicator in content_indicators):
            return True

        return False

    except Exception as e:
        print(f"检查评教页面时出错: {e}")
        return False

# ================================
# 完整的导航函数实现示例
# ================================


def navigate_to_evaluation_example(driver):
    """
    完整的导航函数实现示例
    请将此逻辑复制到main.py中的navigate_to_evaluation_from_ehall函数
    """
    print("开始从服务大厅导航到评教界面...")

    try:
        # 等待页面加载
        if not wait_for_page_load(driver):
            print("页面加载失败")
            return False

        # 记录当前页面信息
        current_url = driver.current_url
        page_title = driver.title
        print(f"当前页面: {page_title}")
        print(f"当前URL: {current_url}")

        # 尝试多种方法查找评教入口
        evaluation_element = None

        # 方法1：通过文本查找
        print("尝试方法1：通过文本查找...")
        evaluation_element = find_evaluation_entrance_method1(driver)

        # 方法2：通过CSS选择器查找
        if not evaluation_element:
            print("尝试方法2：通过CSS选择器查找...")
            evaluation_element = find_evaluation_entrance_method2(driver)

        # 方法3：通过父容器查找
        if not evaluation_element:
            print("尝试方法3：通过父容器查找...")
            evaluation_element = find_evaluation_entrance_method3(driver)

        # 如果找到了评教入口
        if evaluation_element:
            print("找到评教入口，准备点击...")

            # 滚动到元素位置
            driver.execute_script(
                "arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", evaluation_element)
            time.sleep(1)

            # 点击元素
            driver.execute_script("arguments[0].click();", evaluation_element)
            print("已点击评教入口")

            # 等待页面跳转
            time.sleep(5)

            # 检查是否成功进入评教页面
            if check_if_evaluation_page(driver):
                print("✅ 成功进入评教界面")
                return True
            else:
                print("⚠️ 点击后页面可能不是评教界面")

        # 如果自动查找失败，提供调试信息
        print("❌ 未能自动找到评教入口")
        print("\n调试信息：")
        print("页面中所有可点击元素的文本内容：")

        try:
            clickable_elements = driver.find_elements(
                By.CSS_SELECTOR, "a, button, [onclick], .clickable")
            for i, elem in enumerate(clickable_elements[:20]):  # 只显示前20个
                try:
                    text = elem.text.strip()
                    if text:
                        print(f"  {i+1}. {text}")
                except:
                    print(f"  {i+1}. [无法获取文本]")

        except Exception as e:
            print(f"获取调试信息失败: {e}")

        print("\n请手动点击评教入口...")
        return False

    except Exception as e:
        print(f"导航过程出错: {e}")
        return False

# ================================
# 使用说明
# ================================


"""
如何使用这些示例代码：

1. 首先手动访问南大服务大厅，观察评教入口的具体位置和样式

2. 使用浏览器开发者工具（F12）检查评教入口的HTML结构：
   - 右键点击评教入口 → 检查元素
   - 查看该元素的标签、类名、ID、文本内容等
   - 记录其父容器的结构

3. 根据实际结构修改上面的选择器：
   - 如果评教入口有特定的class，修改CSS选择器
   - 如果评教入口有特定的ID，使用ID选择器
   - 如果评教入口在特定容器内，修改容器选择器

4. 将修改后的逻辑复制到main.py的navigate_to_evaluation_from_ehall函数中

5. 测试运行，如果还有问题，可以：
   - 添加更多的调试信息
   - 尝试不同的查找策略
   - 使用WebDriverWait等待特定元素出现

示例修改：
如果发现评教入口的HTML是：
<div class="service-card" data-service="teaching-evaluation">
    <span class="card-title">教学评价</span>
</div>

那么可以使用：
driver.find_element(By.CSS_SELECTOR, ".service-card[data-service='teaching-evaluation']")
或者
driver.find_element(By.XPATH, "//div[@data-service='teaching-evaluation']")
"""
