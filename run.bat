@echo off
echo ==========================================
echo    教室评价表自动填写程序 - 一键启动脚本
echo ==========================================
echo.

REM 检查Python是否已安装
echo 正在检查Python环境...
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo Python未安装，正在准备自动下载并安装...
    
    REM 创建临时目录用于下载安装程序
    mkdir temp 2>nul
    cd temp
    
    echo 正在下载Python安装程序...
    REM 下载64位Python安装程序
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe', 'python_installer.exe')"
    
    if not exist python_installer.exe (
        echo 下载Python安装程序失败！
        echo 正在打开Python官方下载页面...
        cd ..
        rmdir /s /q temp 2>nul
        start https://www.python.org/downloads/
        echo 请手动安装Python 3.8或以上版本，安装时勾选"Add Python to PATH"选项
        echo 安装完成后请重新运行此脚本
        echo 按任意键退出...
        pause
        exit /b 1
    )
    
    echo 正在安装Python...
    echo 请在弹出的安装向导中点击"Install Now"，并确保勾选"Add Python to PATH"选项
    start /wait python_installer.exe /quiet PrependPath=1
    
    cd ..
    rmdir /s /q temp 2>nul
    
    echo Python安装完成，正在检查安装结果...
    
    REM 刷新环境变量
    echo 刷新环境变量...
    call refreshenv.cmd 2>nul
    if %errorlevel% neq 0 (
        REM 如果refreshenv.cmd不可用，尝试其他方法刷新环境变量
        echo 使用PowerShell刷新环境变量...
        powershell -Command "$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')"
    )
    
    REM 等待Python环境就绪
    timeout /t 10 /nobreak > nul
    
    REM 检查Python是否已成功安装
    python --version > nul 2>&1
    if %errorlevel% neq 0 (
        echo Python安装似乎未成功完成，请手动安装...
        start https://www.python.org/downloads/
        echo 请安装Python 3.8或以上版本，安装时勾选"Add Python to PATH"选项
        echo 安装完成后请重新运行此脚本
        echo 按任意键退出...
        pause
        exit /b 1
    )
    
    echo Python已成功安装！
    
    REM 重新启动脚本以确保环境变量生效
    echo 正在重新启动脚本以确保环境变量生效...
    echo 请等待...
    timeout /t 3 /nobreak > nul
    start cmd /c "%~f0"
    exit /b 0
)

REM 验证Python版本
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set pyver=%%i
echo 检测到Python版本: %pyver%

REM 检查是否需要创建虚拟环境
if not exist venv (
    echo 正在创建Python虚拟环境...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo 创建虚拟环境失败，尝试安装venv模块...
        python -m pip install virtualenv --user
        if %errorlevel% neq 0 (
            echo 安装venv模块失败
            echo 按任意键退出...
            pause
            exit /b 1
        )
        python -m virtualenv venv
        if %errorlevel% neq 0 (
            echo 创建虚拟环境仍然失败
            echo 按任意键退出...
            pause
            exit /b 1
        )
    )
    echo 虚拟环境创建成功
) else (
    echo 检测到已存在的虚拟环境
)

REM 激活虚拟环境
echo 正在激活虚拟环境...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo 激活虚拟环境失败，尝试其他方法...
    if exist venv\Scripts\activate (
        call venv\Scripts\activate
    ) else (
        echo 无法激活虚拟环境，将尝试在全局环境中继续
    )
)

REM 检查依赖是否已安装
echo 正在检查并安装依赖...
pip install selenium

REM 检查requirements.txt是否存在，如果存在则安装其中的依赖
if exist requirements.txt (
    echo 从requirements.txt安装依赖...
    pip install -r requirements.txt
)

REM 检查配置文件是否存在
if not exist config.py (
    echo 配置文件不存在，正在创建默认配置...
    (
        echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
        echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
        echo CHROME_DRIVER_PATH = "%LOCAL_CHROME_DRIVER_PATH_PY%"
        echo USE_AUTO_DRIVER = %USE_AUTO_DRIVER_CONFIG%
    ) > config.py
    echo 已创建默认配置文件
)

REM 检查Chrome浏览器驱动
echo 正在检查Chrome浏览器驱动...
mkdir drivers 2>nul
set LOCAL_CHROME_DRIVER_PATH_BAT=drivers\\chromedriver.exe
set LOCAL_CHROME_DRIVER_PATH_PY=drivers/chromedriver.exe
REM Default to True for USE_AUTO_DRIVER_CONFIG, will be set to False if local driver is successfully set up
set USE_AUTO_DRIVER_CONFIG=True

REM 尝试获取Chrome版本
echo 正在获取本地Chrome浏览器版本...
set CHROME_VERSION_FULL=
for /f "tokens=* USEBACKQ" %%a in (`powershell -Command "try { (Get-Item 'C:\Program Files\Google\Chrome\Application\chrome.exe').VersionInfo.FileVersion } catch { try { (Get-Item 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe').VersionInfo.FileVersion } catch { Write-Output '' } }"`) do set CHROME_VERSION_FULL=%%a

if defined CHROME_VERSION_FULL (
    echo 检测到Chrome完整版本: %CHROME_VERSION_FULL%
    for /f "tokens=1 delims=." %%v in ("%CHROME_VERSION_FULL%") do set CHROME_MAJOR_VERSION=%%v
    echo 检测到Chrome主版本: %CHROME_MAJOR_VERSION%

    REM 尝试从新的 JSON 端点下载驱动
    echo 正在尝试从官方JSON端点下载匹配 %CHROME_MAJOR_VERSION% 的ChromeDriver...
    set DRIVER_DOWNLOAD_URL=
    REM PowerShell命令获取下载URL (此命令较长，为一行)
    for /f "tokens=*" %%u in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $chromeMajor = '%CHROME_MAJOR_VERSION%'; $knownVersionsUrl = 'https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json'; $versions = Invoke-RestMethod -Uri $knownVersionsUrl | Select-Object -ExpandProperty versions; $latestPatch = ($versions | Where-Object {$_.version -match "^$chromeMajor"} | Sort-Object -Property @{Expression={[System.Version]$_.version}} -Descending | Select-Object -First 1); if ($latestPatch) { $driverInfo = $latestPatch.downloads.chromedriver | Where-Object {$_.platform -eq 'win64'}; if ($driverInfo) { Write-Output $driverInfo.url } else { Write-Output '' } } else { Write-Output '' } } catch { Write-Output '' } "') do set DRIVER_DOWNLOAD_URL=%%u

    if defined DRIVER_DOWNLOAD_URL (
        echo ChromeDriver下载链接: %DRIVER_DOWNLOAD_URL%
        echo 下载中...
        powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%DRIVER_DOWNLOAD_URL%', 'drivers\\chromedriver_temp.zip')"
        if exist drivers\\chromedriver_temp.zip (
            echo 下载完成，解压中...
            powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; try { [System.IO.Compression.ZipFile]::ExtractToDirectory('drivers\\chromedriver_temp.zip', 'drivers_temp_extract') } catch { Write-Error $_; exit 1 } "
            REM 在解压后的文件夹中查找chromedriver.exe，可能在子目录中
            if exist drivers_temp_extract\\chromedriver-win64\\chromedriver.exe (
                move /Y drivers_temp_extract\\chromedriver-win64\\chromedriver.exe "%LOCAL_CHROME_DRIVER_PATH_BAT%" > nul
            ) else if exist drivers_temp_extract\\chromedriver.exe (
                move /Y drivers_temp_extract\\chromedriver.exe "%LOCAL_CHROME_DRIVER_PATH_BAT%" > nul
            )
            rmdir /s /q drivers_temp_extract 2>nul
            del drivers\\chromedriver_temp.zip 2>nul
            if exist "%LOCAL_CHROME_DRIVER_PATH_BAT%" (
                echo ChromeDriver已成功下载并放置到 %LOCAL_CHROME_DRIVER_PATH_BAT%
                set USE_AUTO_DRIVER_CONFIG=False
            ) else (
                echo 解压或移动ChromeDriver失败，将依赖webdriver-manager.
            )
        ) else (
            echo 通过JSON端点下载ChromeDriver失败，将依赖webdriver-manager.
        )
    ) else (
        echo 未能从JSON端点找到匹配 %CHROME_MAJOR_VERSION% 的win64驱动下载链接，将依赖webdriver-manager.
    )
) else (
    echo 未能检测到本地Chrome浏览器版本，将依赖webdriver-manager.
)

REM 更新或创建config.py
echo 正在配置config.py...
if exist config.py (
    REM 如果config.py存在，检查是否需要更新
    powershell -Command "$path = 'config.py'; $content = Get-Content $path -Raw; $driverPathLine = 'CHROME_DRIVER_PATH = \"%LOCAL_CHROME_DRIVER_PATH_PY%\"'; $autoDriverLine = 'USE_AUTO_DRIVER = %USE_AUTO_DRIVER_CONFIG%'; if ($content -notmatch 'CHROME_DRIVER_PATH') { Add-Content $path -Value $driverPathLine } else { $content = $content -replace 'CHROME_DRIVER_PATH = .*', $driverPathLine }; if ($content -notmatch 'USE_AUTO_DRIVER') { Add-Content $path -Value $autoDriverLine } else { $content = $content -replace 'USE_AUTO_DRIVER = .*', $autoDriverLine }; $content | Set-Content $path "
) else (
    echo 创建默认配置文件...
    (
        echo WEB_URL = "https://ehallapp.nju.edu.cn/jwapp/sys/wspjyyapp/*default/index.do"
        echo LOGIN_URL = "https://authserver.nju.edu.cn/authserver/login?service=https%%3A%%2F%%2Fehallapp.nju.edu.cn%%2Fjwapp%%2Fsys%%2Fwspjyyapp%%2F*default%%2Findex.do"
        echo CHROME_DRIVER_PATH = "%LOCAL_CHROME_DRIVER_PATH_PY%"
        echo USE_AUTO_DRIVER = %USE_AUTO_DRIVER_CONFIG%
    ) > config.py
)

REM 清理可能存在的旧测试文件
del test_driver.py 2>nul
del test_local_driver.py 2>nul
del download_driver.py 2>nul
del driver_path.txt 2>nul

echo.
echo ==========================================
echo            准备工作已完成
echo        开始运行教室评价自动填写程序
echo ==========================================
echo.

REM 启动主程序
python main.py

REM 完成后暂停
echo.
echo 程序已执行完毕，请按任意键退出...
pause
exit /b 0 