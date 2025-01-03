#!/bin/bash

# 检查是否提供了 conda 环境名称
if [ $# -ne 1 ]; then
    echo "使用方法: $0 <conda环境名称>"
    echo "例如: $0 ruc_net"
    exit 1
fi

CONDA_ENV_NAME=$1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_PATH="$SCRIPT_DIR/go_ruc.py"

# 检查脚本是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "错误: 找不到 go_ruc.py"
    exit 1
fi

# 获取 conda 的路径
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    CONDA_PATH="$HOME/miniconda3"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    CONDA_PATH="$HOME/anaconda3"
else
    echo "错误: 找不到 conda 安装路径"
    exit 1
fi

# 创建守护进程脚本
DAEMON_SCRIPT="$SCRIPT_DIR/run_login_daemon.sh"
cat > "$DAEMON_SCRIPT" << EOL
#!/bin/bash
source "$CONDA_PATH/etc/profile.d/conda.sh"
conda activate $CONDA_ENV_NAME

while true; do
    python "$SCRIPT_PATH"
    sleep 3
done
EOL

# 创建服务启动脚本
SERVICE_SCRIPT="$SCRIPT_DIR/start_service.sh"
cat > "$SERVICE_SCRIPT" << EOL
#!/bin/bash
nohup $DAEMON_SCRIPT > /dev/null 2>&1 &
echo \$! > "$SCRIPT_DIR/service.pid"
EOL

# 创建服务停止脚本
STOP_SCRIPT="$SCRIPT_DIR/stop_service.sh"
cat > "$STOP_SCRIPT" << EOL
#!/bin/bash
if [ -f "$SCRIPT_DIR/service.pid" ]; then
    kill \$(cat "$SCRIPT_DIR/service.pid")
    rm "$SCRIPT_DIR/service.pid"
    echo "服务已停止"
else
    echo "服务未运行"
fi
EOL

# 添加执行权限
chmod +x "$DAEMON_SCRIPT"
chmod +x "$SERVICE_SCRIPT"
chmod +x "$STOP_SCRIPT"

# 安装依赖
source "$CONDA_PATH/etc/profile.d/conda.sh"
conda activate $CONDA_ENV_NAME
pip install playwright requests
playwright install chromium

# 添加到开机自启动
STARTUP_SCRIPT="$HOME/.config/autostart/ruc_login.desktop"
mkdir -p "$HOME/.config/autostart"
cat > "$STARTUP_SCRIPT" << EOL
[Desktop Entry]
Type=Application
Name=RUC Login
Exec=$SERVICE_SCRIPT
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL

# 启动服务
$SERVICE_SCRIPT

echo "安装完成！"
echo "服务已启动，每3秒执行一次检查"
echo "使用 '$STOP_SCRIPT' 停止服务"
echo "使用 '$SERVICE_SCRIPT' 启动服务"
echo "服务已添加到开机自启动"