import os
import sys
import shutil
from datetime import datetime


def clean_build():
    """清理构建目录"""
    dirs = ['build', 'dist', '__pycache__']
    for d in dirs:
        if os.path.exists(d):
            print(f"清理: {d}")
            shutil.rmtree(d)

    # 删除spec文件
    for f in os.listdir('.'):
        if f.endswith('.spec'):
            os.remove(f)


def check_pyinstaller():
    """检查并安装PyInstaller"""
    try:
        import PyInstaller
        print("✅ PyInstaller已安装")
    except ImportError:
        print("安装PyInstaller...")
        os.system('pip install pyinstaller')


def build_exe():
    """打包程序"""
    print("=" * 60)
    print("南京大学教师评价程序 - 快速打包工具")
    print("=" * 60)

    # 检查文件
    if not os.path.exists('main.py'):
        print("❌ 未找到main.py")
        return False

    # 检查依赖
    check_pyinstaller()

    # 清理
    clean_build()

    # 打包命令
    cmd = [
        'pyinstaller',
        '--onefile',           # 单文件
        '--console',           # 显示控制台
        '--noconfirm',         # 不确认
        '--clean',             # 清理
        '--name', 'NJU_Teacher_Evaluation_v2.1.0',  # 文件名
        '--hidden-import', 'selenium',
        '--hidden-import', 'webdriver_manager',
        'main.py'
    ]

    print("\n开始打包...")
    print("命令:", ' '.join(cmd))

    result = os.system(' '.join(cmd))

    if result == 0:
        exe_path = 'dist/NJU_Teacher_Evaluation_v2.1.0.exe'
        if os.path.exists(exe_path):
            size = os.path.getsize(exe_path) / (1024*1024)
            print(f"\n🎉 打包成功!")
            print(f"文件: {os.path.abspath(exe_path)}")
            print(f"大小: {size:.1f} MB")
            print("\n使用说明:")
            print("1. 双击exe文件即可运行")
            print("2. 无需安装Python")
            print("3. 如果被杀毒软件拦截，请添加信任")
            return True
        else:
            print("❌ 打包失败: 未找到exe文件")
            return False
    else:
        print("❌ 打包失败")
        return False


if __name__ == '__main__':
    try:
        success = build_exe()
        if success:
            print("\n✅ 打包完成!")
        else:
            print("\n❌ 打包失败!")
    except Exception as e:
        print(f"\n错误: {e}")

    input("\n按回车键退出...")
