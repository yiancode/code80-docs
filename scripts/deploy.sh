#!/bin/bash
#
# Code80 Docs 部署脚本
# 本地构建，上传静态文件到服务器，原子替换
#

set -e

# ============================================================
# 配置区域
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 默认配置
REMOTE_HOST="YOUR_SERVER_IP"
REMOTE_USER="root"
REMOTE_DIR="/www/wwwroot/docs.ai80.vip"
SSH_KEY=""

# 加载本地配置（不提交到 git）
if [ -f "$SCRIPT_DIR/deploy.local.conf" ]; then
    source "$SCRIPT_DIR/deploy.local.conf"
fi

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# SSH/SCP 命令封装
ssh_cmd() {
    if [ -n "$SSH_KEY" ]; then
        ssh -o ConnectTimeout=10 -i "$SSH_KEY" "${REMOTE_USER}@${REMOTE_HOST}" "$@"
    else
        ssh -o ConnectTimeout=10 "${REMOTE_USER}@${REMOTE_HOST}" "$@"
    fi
}

scp_cmd() {
    if [ -n "$SSH_KEY" ]; then
        scp -o ConnectTimeout=10 -i "$SSH_KEY" "$@"
    else
        scp -o ConnectTimeout=10 "$@"
    fi
}

# ============================================================
# 主流程
# ============================================================

main() {
    echo ""
    echo "=============================================="
    echo "   Code80 Docs 部署"
    echo "=============================================="
    echo ""

    SKIP_BUILD=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --help|-h)
                echo "用法: $0 [选项]"
                echo ""
                echo "选项:"
                echo "  --skip-build  跳过本地构建，直接上传已有构建产物"
                echo "  -h, --help    显示帮助"
                exit 0
                ;;
            *)
                print_error "未知参数: $1"
                exit 1
                ;;
        esac
    done

    cd "$PROJECT_ROOT"
    print_info "项目目录: $PROJECT_ROOT"
    print_info "目标服务器: ${REMOTE_USER}@${REMOTE_HOST}"
    print_info "部署目录: ${REMOTE_DIR}"
    echo ""

    # Step 1: 本地构建
    if [ "$SKIP_BUILD" = false ]; then
        print_info "Step 1/4: 本地构建..."
        pnpm install --frozen-lockfile 2>/dev/null || pnpm install
        pnpm run build
        print_success "构建完成"
    else
        print_warning "Step 1/4: 跳过构建"
    fi

    # 检查构建产物
    DIST_DIR="$PROJECT_ROOT/.vitepress/dist"
    if [ ! -d "$DIST_DIR" ] || [ ! -f "$DIST_DIR/index.html" ]; then
        print_error "构建产物不存在: $DIST_DIR"
        exit 1
    fi

    FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')
    print_info "构建产物: ${FILE_COUNT} 个文件"

    # Step 2: 打包并上传到临时位置
    print_info "Step 2/4: 打包并上传..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    TAR_FILE="/tmp/code80-docs-${TIMESTAMP}.tar.gz"
    REMOTE_TMP="/tmp/code80-docs-${TIMESTAMP}.tar.gz"

    cd "$DIST_DIR"
    tar -czf "$TAR_FILE" .
    TAR_SIZE=$(du -h "$TAR_FILE" | cut -f1)
    print_info "压缩包大小: ${TAR_SIZE}"

    scp_cmd "$TAR_FILE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TMP}"
    rm -f "$TAR_FILE"
    print_success "上传完成"

    # Step 3: 服务器端原子替换
    print_info "Step 3/4: 服务器端原子替换..."

    ssh_cmd bash << REMOTEOF
set -e

# 解压到临时目录
TMP_DIR="/tmp/code80-docs-new-${TIMESTAMP}"
mkdir -p "\$TMP_DIR"
tar -xzf "${REMOTE_TMP}" -C "\$TMP_DIR"
rm -f "${REMOTE_TMP}"

# 备份当前版本
if [ -d "${REMOTE_DIR}" ]; then
    BACKUP="${REMOTE_DIR}.backup"
    rm -rf "\$BACKUP"
    cp -a "${REMOTE_DIR}" "\$BACKUP" 2>/dev/null || true
fi

# 原子替换：先准备好新目录，再 mv
NEW_DIR="${REMOTE_DIR}.new"
rm -rf "\$NEW_DIR"
mv "\$TMP_DIR" "\$NEW_DIR"

# 交换目录
if [ -d "${REMOTE_DIR}" ]; then
    mv "${REMOTE_DIR}" "${REMOTE_DIR}.old"
fi
mv "\$NEW_DIR" "${REMOTE_DIR}"
rm -rf "${REMOTE_DIR}.old"

echo "FILES: \$(find ${REMOTE_DIR} -type f | wc -l)"
REMOTEOF

    print_success "原子替换完成"

    # Step 4: 验证
    print_info "Step 4/4: 验证部署..."
    if ssh_cmd "[ -f ${REMOTE_DIR}/index.html ]"; then
        print_success "index.html 存在"
    else
        print_error "index.html 不存在，部署可能失败"
        print_warning "尝试回滚..."
        ssh_cmd "[ -d ${REMOTE_DIR}.backup ] && rm -rf ${REMOTE_DIR} && mv ${REMOTE_DIR}.backup ${REMOTE_DIR}" || true
        exit 1
    fi

    echo ""
    echo "=============================================="
    print_success "部署完成"
    echo "=============================================="
    echo ""
    echo "访问地址: https://docs.ai80.vip"
    echo ""
}

main "$@"
