# 南京大学教师评价自动填写程序

## 📋 功能特点

- ✅ 自动填写教师评价表单
- ✅ 自动填写助教评价表单
- ✅ **🆕 自动安装Python环境**
- ✅ 支持多种Python安装方式检测
- ✅ 完善的错误处理和修复工具
- ✅ 详细的日志记录

## 🚀 快速开始

### 方法一：一键运行（推荐，零配置）
1. **双击运行 `run.bat`**
2. 如果没有Python，程序会提示自动安装：
   - 选择 `[1] 自动安装Python（推荐）`
   - 程序会自动下载并安装Python 3.11
   - 需要管理员权限，请在UAC提示时点击"是"
3. 等待Python安装完成后，程序会自动重启
4. 按提示在浏览器中手动登录
5. 程序会自动完成评价填写

### 方法二：手动安装依赖
1. 确保已安装Python 3.8+
2. 运行：`pip install -r requirements.txt`
3. 运行：`python main.py`

### 方法三：使用独立Python安装工具
如果想单独安装Python：
1. 双击运行 `install_python.bat`
2. 按提示完成Python安装
3. 然后运行 `run.bat`

## 🛠️ 环境要求

- **操作系统**：Windows 10/11
- **Python**：3.8 或更高版本（可自动安装）
- **浏览器**：Google Chrome（最新版本）
- **网络**：能够访问南京大学内网
- **权限**：自动安装Python需要管理员权限

## 🔧 故障排除

如果遇到问题，请按以下顺序尝试：

### 0. 📝 文件编码问题（重要！）

如果bat文件运行时出现**中文乱码**或**脚本错误**，请按以下步骤修复：

#### 🔧 修复方法：
1. **右键点击** 任意 `.bat` 文件（如 `run.bat`）
2. 选择 **"编辑"** 或 **"用记事本打开"**
3. 在记事本中，点击 **"文件"** → **"另存为"**
4. 在保存对话框底部，找到 **"编码"** 下拉菜单
5. 将编码从 `UTF-8` 改为 **`ANSI`**
6. 点击 **"保存"**，覆盖原文件
7. 对所有 `.bat` 文件重复此操作

#### 📋 需要修复的文件列表：
- `run.bat`
- `install_python.bat`  
- `test_environment.bat`
- `fix/quick_fix.bat`
- `fix/fix.bat`
- `fix/fix_403.bat`
- `fix/test_browser_simple.bat`
- `fix/diagnose.bat`

#### ⚠️ 编码问题的表现：
- 运行bat文件时显示乱码
- 中文提示显示为问号或方框
- 脚本运行异常中断
- 无法正确识别用户输入

### 1. 运行修复工具
- `fix/quick_fix.bat` - 快速修复（推荐）
- `fix/fix.bat` - 高级修复工具
- `fix/diagnose.bat` - 系统诊断工具
- `test_environment.bat` - 快速环境测试

### 2. 特定问题修复
- **Python环境问题**：
  - 运行 `install_python.bat` 重新安装Python
  - 或在 `run.bat` 中选择自动安装
- **403权限错误**：运行 `fix/fix_403.bat`
- **浏览器问题**：运行 `fix/test_browser_simple.bat`

### 3. 常见错误解决

#### 💾 自动安装Python相关
**安装失败 - 权限不足**
- 右键点击 `run.bat` 或 `install_python.bat`
- 选择"以管理员身份运行"

**下载失败 - 网络问题**
- 检查网络连接
- 临时关闭防火墙/杀毒软件
- 尝试使用其他网络环境

**安装完成但Python命令无效**
- 重启命令提示符窗口
- 或重启计算机
- 运行 `fix/diagnose.bat` 检查环境

#### 🐍 Python环境问题
**"python不是命令"**
- 程序会自动提示安装Python
- 选择选项1进行自动安装
- 或手动安装时确保勾选"Add Python to PATH"

#### 🌐 网络和权限问题
**403错误**
- 评价系统可能未开放，检查教务处通知
- 运行 `fix/fix_403.bat` 获取最新URL

**Chrome驱动问题**
- 运行 `fix/fix.bat` 选择选项2清理驱动缓存
- 确保Chrome浏览器是最新版本

## 📁 文件说明

```
clicker/
├── main.py              # 主程序文件
├── config.py            # 配置文件
├── run.bat              # 一键运行脚本（含自动安装Python）
├── install_python.bat   # 独立Python安装工具
├── test_environment.bat # 快速环境测试工具
├── requirements.txt     # Python依赖列表
├── fix/                 # 修复工具文件夹
│   ├── quick_fix.bat    # 快速修复
│   ├── fix.bat          # 高级修复
│   ├── fix_403.bat      # 403错误修复
│   ├── test_browser_simple.bat  # 浏览器测试
│   └── diagnose.bat     # 系统诊断
└── logs/                # 日志文件夹
```

## ⚠️ 注意事项

1. **评价时间**：只能在教务处规定的评价时间内使用
2. **网络环境**：需要能够访问南京大学内网
3. **管理员权限**：自动安装Python需要管理员权限
4. **文件编码**：所有bat文件必须保存为ANSI格式，否则可能出现中文乱码
5. **安全提醒**：请在自己的计算机上运行，不要在公共计算机上使用
6. **手动确认**：程序会自动填写，但建议最后手动检查一遍
7. **网络要求**：自动安装Python需要约30MB的下载量

## 🔄 更新日志

### v2.1.0（最新）
- 🆕 **新增自动安装Python功能**
- 🆕 新增独立Python安装工具 `install_python.bat`
- 🆕 新增环境测试工具 `test_environment.bat`
- ✨ 智能检测系统架构（32位/64位）
- ✨ 自动下载适配的Python版本
- ✨ 静默安装，自动配置PATH
- 🔧 改进pip修复功能
- 📝 完善错误提示和解决方案

### v2.0.0
- 新增多种Python路径检测
- 完善错误处理机制
- 优化修复工具
- 支持更多Windows环境

## 📞 技术支持

如果遇到问题：
1. 首先运行 `test_environment.bat` 进行快速测试
2. 运行 `fix/diagnose.bat` 进行系统诊断
3. 尝试相应的修复工具
4. 查看 `logs/` 文件夹中的错误日志

### 🛟 常见问题快速解决
- **Python问题**：运行 `install_python.bat`
- **环境问题**：运行 `test_environment.bat`
- **综合修复**：运行 `fix/quick_fix.bat`
- **中文乱码**：将所有bat文件保存为ANSI格式

## 📄 许可证

仅供学习交流使用，请勿用于商业用途。 