# 🏫 RUC 校园网自动登录工具 🛠️

这是一个用于人民大学校园网自动登录的 Python 脚本。它能够自动检测网络状态，当发现无法访问常用网站时，会自动进行校园网登录。

默认每3秒检测一次网络连接 ⏱️

## 🌟 特性

- 🕸️ 自动检测网络连通性
- 🧹 自动清除系统代理设置
- 🖥️ 支持无头浏览器模式
- 📜 详细的日志输出
- 🌐 多站点检测，避免误判

## 📦 安装要求

```bash
# 安装依赖
pip install playwright requests

# 安装 playwright 浏览器
playwright install chromium
```

## 🔧 环境变量配置

使用前需要设置以下环境变量：

```bash
export RUC_ID="你的校园网ID"
export RUC_KEY="你的校园网密码"
```

## 🚀 使用方法

```bash
chmod +x install.sh
./install.sh your_conda_env_name
```

## ⚙️ 配置说明

- `is_test_no_network`: 测试模式开关，设为 `True` 时将跳过网络检测直接执行登录流程 🧪
- `test_sites`: 用于检测网络连通性的网站列表 🌍
- `headless`: 无头模式开关，默认为 `True` 👻

## ⚠️ 免责声明

本工具仅用于学习研究，请勿用于非法用途。使用本工具所造成的任何后果由使用者自行承担。🔒
