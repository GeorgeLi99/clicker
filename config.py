# 南京大学教室评价系统配置文件

# 登录页面URL
LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%3A%2F%2Fehallapp.nju.edu.cn%2Fjwapp%2Fsys%2Fwspjyyapp%2F*default%2Findex.do"

# 评价系统URL
WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"

# ChromeDriver设置（优先使用自动管理）
USE_AUTO_DRIVER = True
CHROME_DRIVER_PATH = "drivers/chromedriver.exe"
