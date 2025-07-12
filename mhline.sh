#!/bin/bash

# 使用命令：curl -sSL https://raw.githubusercontent.com/wudiming/dmwuspm/main/mhline.sh | bash
# 删除js命令：cloudlinux-selector destroy --interpreter=nodejs --user=$USERNAME --app-root=/home/$USERNAME/domains/$WEBHOST/public_html


# 自动获取当前系统用户名
USERNAME=$(whoami)

# 自动获取主机名（从domains目录获取）
DOMAINS_DIR="/home/$USERNAME/domains"

# 检查domains目录是否存在
if [ ! -d "$DOMAINS_DIR" ]; then
    echo "错误: 找不到domains目录 $DOMAINS_DIR" >&2
    exit 1
fi

# 获取主机名列表
HOSTS=($(ls -1 "$DOMAINS_DIR"))

# 验证主机名数量
if [ ${#HOSTS[@]} -eq 0 ]; then
    echo "错误: domains目录下没有找到主机目录" >&2
    exit 1
elif [ ${#HOSTS[@]} -gt 1 ]; then
    echo "警告: domains目录下有多个主机目录，将使用第一个: ${HOSTS[0]}" >&2
    echo "可用主机目录: ${HOSTS[*]}" >&2
fi

WEBHOST=${HOSTS[0]}

# 计算相关路径
APP_ROOT="/home/$USERNAME/domains/$WEBHOST/public_html"
NODE_BIN_DIR="/home/$USERNAME/nodevenv/domains/$WEBHOST/public_html/22/bin"
NPM_PATH="$NODE_BIN_DIR/npm"
NPM_LOGS_DIR="/home/$USERNAME/.npm/_logs"

# 函数：命令执行与错误处理
execute_command() {
    local cmd="$1"
    local desc="$2"
    
    echo "▶▶ 开始执行: $desc"
    echo "▷ 命令: $cmd"
    echo "--------------------------------------------------"
    
    # 执行命令并显示输出
    if eval "$cmd"; then
        echo "--------------------------------------------------"
        echo "✓✓ 成功完成: $desc"
        echo ""
        return 0
    else
        local exit_status=$?
        echo "--------------------------------------------------"
        echo "✗✗ 执行失败 [代码:$exit_status]: $desc" >&2
        echo "!!! 严重错误：脚本终止 !!!" >&2
        exit $exit_status
    fi
}

# 主脚本开始
echo "===== Node.js 应用安装脚本开始 ====="
echo "开始时间: $(date)"
echo "自动检测用户名: $USERNAME"
echo "自动检测主机名: $WEBHOST"
echo "应用目录: $APP_ROOT"
echo ""

# 1. 创建CloudLinux应用环境
execute_command \
    "cloudlinux-selector create --json --interpreter=nodejs --user=$USERNAME --app-root=$APP_ROOT --app-uri=/ --version=22.14.0 --app-mode=Development --startup-file=index.js" \
    "创建CloudLinux Node.js环境"

# 2. 进入应用目录
execute_command \
    "cd $APP_ROOT" \
    "切换到应用根目录"

# 3. 安装npm依赖
execute_command \
    "$NPM_PATH install" \
    "安装Node.js依赖包"

# 4. 检查npm日志
execute_command \
    "ls -lh $NPM_LOGS_DIR" \
    "列出npm日志文件"

# 5. 清理npm日志
execute_command \
    "rm -fv $NPM_LOGS_DIR/*.log" \
    "清除npm日志文件"

# 脚本完成
echo "===== 所有操作成功完成 ====="
echo "结束时间: $(date)"
