import os
import sys
import shutil
from datetime import datetime


def clean_build_dirs():
    """清理构建目录"""
    dirs_to_clean = ['build', 'dist']
    for dir_name in dirs_to_clean:
        if os.path.exists(dir_name):
            print(f"清理目录: {dir_name}")
            shutil.rmtree(dir_name)


def create_version_file():
    """创建版本信息文件"""
    version_info = f"""
# UTF-8
#
# For more details about fixed file info 'ffi' see:
# http://msdn.microsoft.com/en-us/library/ms646997.aspx
VSVersionInfo(
  ffi=FixedFileInfo(
    # filevers and prodvers should be always a tuple with four items: (1, 2, 3, 4)
    # Set not needed items to zero 0.
    filevers=(1, 0, 0, 0),
    prodvers=(1, 0, 0, 0),
    # Contains a bitmask that specifies the valid bits 'flags'r
    mask=0x3f,
    # Contains a bitmask that specifies the Boolean attributes of the file.
    flags=0x0,
    # The operating system for which this file was designed.
    # 0x4 - NT and there is no need to change it.
    OS=0x40004,
    # The general type of file.
    # 0x1 - the file is an application.
    fileType=0x1,
    # The function of the file.
    # 0x0 - the function is not defined for this fileType
    subtype=0x0,
    # Creation date and time stamp.
    date=(0, 0)
    ),
  kids=[
    StringFileInfo(
      [
      StringTable(
        u'080404b0',
        [StringStruct(u'CompanyName', u'南京大学'),
        StringStruct(u'FileDescription', u'南京大学教室评价表自动填写程序'),
        StringStruct(u'FileVersion', u'1.0.0'),
        StringStruct(u'InternalName', u'clicker'),
        StringStruct(u'LegalCopyright', u'Copyright (C) 2024'),
        StringStruct(u'OriginalFilename', u'clicker.exe'),
        StringStruct(u'ProductName', u'教室评价表自动填写程序'),
        StringStruct(u'ProductVersion', u'1.0.0')])
      ]), 
    VarFileInfo([VarStruct(u'Translation', [2052, 1200])])
  ]
)
"""
    with open('version_info.txt', 'w', encoding='utf-8') as f:
        f.write(version_info)


def build_exe():
    """使用PyInstaller打包程序"""
    # 清理旧的构建文件
    clean_build_dirs()

    # 创建版本信息文件
    create_version_file()

    # 构建命令
    build_cmd = (
        'pyinstaller '
        '--noconfirm '  # 不询问确认
        '--onefile '    # 打包成单个文件
        '--noconsole '  # 不显示控制台窗口
        '--clean '      # 清理临时文件
        '--name "clicker" '  # 输出文件名
        '--version-file version_info.txt '  # 版本信息
        '--add-data "config.py;." '  # 添加配置文件
        '--hidden-import selenium '  # 添加隐藏导入
        '--hidden-import webdriver_manager '
        '--hidden-import python-dotenv '
        'main.py'  # 主程序文件
    )

    # 执行打包命令
    print("开始打包程序...")
    os.system(build_cmd)

    # 清理临时文件
    if os.path.exists('version_info.txt'):
        os.remove('version_info.txt')

    print("\n打包完成！")
    print(f"可执行文件位置: {os.path.abspath('dist/clicker.exe')}")


if __name__ == '__main__':
    # 检查是否安装了PyInstaller
    try:
        import PyInstaller
    except ImportError:
        print("正在安装PyInstaller...")
        os.system('pip install pyinstaller')

    # 开始打包
    build_exe()
