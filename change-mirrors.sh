#!/bin/bash
#
# Linux 一键换源工具
# 支持全部主流发行版，交互式/命令行双模式
#
# 用法:
#   sudo ./change-mirrors.sh                          # 交互式模式
#   sudo ./change-mirrors.sh --source tsinghua        # 命令行模式
#   sudo ./change-mirrors.sh --list                   # 列出可用源
#   sudo ./change-mirrors.sh --restore                # 从备份恢复
#   sudo ./change-mirrors.sh --official               # 恢复官方源
#
# 远程执行:
#   sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh)
#
set -euo pipefail

## GitHub 仓库地址 (用于远程模式下载依赖模块)
REPO_RAW_URL="https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main"

## 需要下载的依赖模块列表
REMOTE_MODULES=(
    "lib/ui.sh"
    "lib/detect.sh"
    "lib/mirrors.sh"
    "lib/backup.sh"
    "lib/utils.sh"
    "distros/debian.sh"
    "distros/redhat.sh"
    "distros/arch.sh"
    "distros/alpine.sh"
    "distros/gentoo.sh"
    "distros/openeuler.sh"
    "distros/anolis.sh"
    "distros/opencloudos.sh"
    "distros/openkylin.sh"
    "distros/opensuse.sh"
)

## 下载单个文件 (带重试)
fetch_module() {
    local url="$1" target="$2" retries=3 delay=2
    for ((i = 1; i <= retries; i++)); do
        if curl -sSfL "$url" -o "$target" 2>/dev/null; then
            return 0
        fi
        sleep "$delay"
        delay=$((delay * 2))
    done
    return 1
}

## 远程模式: 下载所有依赖模块到临时目录
download_modules() {
    local tmp_dir="$1"
    local total=${#REMOTE_MODULES[@]}
    local count=0
    for mod in "${REMOTE_MODULES[@]}"; do
        count=$((count + 1))
        printf "\r  正在下载模块 [%d/%d]: %s" "$count" "$total" "$mod"
        local target="${tmp_dir}/${mod}"
        mkdir -p "$(dirname "$target")"
        if ! fetch_module "${REPO_RAW_URL}/${mod}" "$target"; then
            echo "" >&2
            echo "错误: 无法下载模块 ${mod}" >&2
            echo "请检查网络连接或手动 git clone 后运行" >&2
            exit 1
        fi
        sleep 0.3  # 避免触发 GitHub 速率限制
    done
    echo ""
}

## 确定脚本运行模式并初始化 SCRIPT_DIR
## 本地模式: lib/ 目录存在，直接使用
## 远程模式: 通过 curl 管道执行，需下载依赖模块
TEMP_DIR=""
init_script_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || script_dir=""

    # 检查本地模块是否存在
    if [[ -n "$script_dir" && -f "${script_dir}/lib/ui.sh" ]]; then
        SCRIPT_DIR="$script_dir"
    else
        # 远程模式: 下载依赖模块
        TEMP_DIR="$(mktemp -d)"
        SCRIPT_DIR="$TEMP_DIR"
        download_modules "$TEMP_DIR"
    fi
}

## 清理临时目录
cleanup() {
    [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

## 初始化
init_script_dir

## 加载所有模块
source "${SCRIPT_DIR}/lib/ui.sh"
source "${SCRIPT_DIR}/lib/detect.sh"
source "${SCRIPT_DIR}/lib/mirrors.sh"
source "${SCRIPT_DIR}/lib/backup.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

## 全局默认值
USE_OFFICIAL_SOURCE="false"
WEB_PROTOCOL="https"
SOURCE_CATEGORY="china"
SELECTED_MIRROR_ID=""
SELECTED_MIRROR_DOMAIN=""
SELECTED_MIRROR_NAME=""
CLI_MODE="false"

## 命令行参数解析
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --source|-s)
            CLI_MODE="true"
            SELECTED_MIRROR_ID="$2"
            shift 2
            ;;
        --source-domain)
            CLI_MODE="true"
            SELECTED_MIRROR_DOMAIN="$2"
            SELECTED_MIRROR_ID="manual"
            shift 2
            ;;
        --protocol|-p)
            WEB_PROTOCOL="$2"
            shift 2
            ;;
        --category|-c)
            SOURCE_CATEGORY="$2"
            shift 2
            ;;
        --official)
            CLI_MODE="true"
            USE_OFFICIAL_SOURCE="true"
            SELECTED_MIRROR_ID="official"
            SELECTED_MIRROR_NAME="官方源"
            shift
            ;;
        --restore)
            main_restore
            exit 0
            ;;
        --list)
            main_list
            exit 0
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        --version|-v)
            echo "ChangeMirrors"
            exit 0
            ;;
        *)
            err "未知选项: $1"
            print_usage
            exit 1
            ;;
        esac
    done
}

## 打印用法
print_usage() {
    cat <<EOF

Linux 一键换源工具

用法:
  sudo ./change-mirrors.sh [选项]

远程一键执行:
  sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh)

选项:
  --source, -s <id>       指定镜像源 ID (如: tsinghua, aliyun, ustc)
  --source-domain <域名>   直接指定镜像源域名
  --protocol, -p <协议>    指定协议 (https|http)，默认 https
  --category, -c <类别>    源类别 (china|edu|abroad)，默认 china
  --official               恢复为官方源
  --restore                从备份恢复原始配置
  --list                   列出所有可用镜像源
  --help, -h               显示此帮助
  --version, -v            显示版本

示例:
  sudo ./change-mirrors.sh                              # 交互式
  sudo ./change-mirrors.sh -s tsinghua                  # 清华源
  sudo ./change-mirrors.sh -s aliyun -p http            # 阿里云 HTTP
  sudo ./change-mirrors.sh --source-domain 10.0.0.1     # 内网源

EOF
}

## 列出所有可用源
main_list() {
    print_banner
    echo -e "  ${BOLD}国内源 (--category china):${PLAIN}\n"
    _print_mirror_table MIRROR_CHINA
    echo -e "\n  ${BOLD}教育网源 (--category edu):${PLAIN}\n"
    _print_mirror_table MIRROR_EDU
    echo -e "\n  ${BOLD}海外源 (--category abroad):${PLAIN}\n"
    _print_mirror_table MIRROR_ABROAD
}

_print_mirror_table() {
    local -n list="$1"
    for entry in "${list[@]}"; do
        local id="${entry%%|*}"
        local rest="${entry#*|}"
        local domain="${rest%%|*}"
        local name="${rest#*|}"
        printf "  %-20s %-35s %s\n" "$id" "$domain" "$name"
    done
}

## 从备份恢复
main_restore() {
    print_banner
    check_root
    detect_arch
    detect_distro
    restore_backup
}

## 主交互流程
main_interactive() {
    print_banner

    # 检测系统
    working "正在检测系统信息..."
    detect_arch
    detect_distro

    echo -e "\n  ${BOLD}系统信息:${PLAIN}"
    print_system_info
    echo ""

    # 选择源类别
    choose_source_category

    # 选择镜像源
    choose_mirror_interactive "$SOURCE_CATEGORY"

    # 选择协议
    choose_protocol

    # 确认
    echo ""
    echo -e "  ${BOLD}操作摘要:${PLAIN}"
    echo -e "  源:   ${CYAN}${SELECTED_MIRROR_NAME}${PLAIN} (${SELECTED_MIRROR_DOMAIN:-官方})"
    echo -e "  协议: ${CYAN}${WEB_PROTOCOL}${PLAIN}"
    if ! confirm_action "确认执行换源?"; then
        info "已取消"
        exit 0
    fi

    # 加载发行版模块并执行
    load_distro_module
    backup_original_mirrors
    apply_mirrors
    upgrade_packages
    print_summary
}

## 命令行模式
main_cli() {
    check_root
    detect_arch
    detect_distro

    info "系统: ${DISTRO_PRETTY}"

    # 解析镜像 ID 到域名
    if [[ "$USE_OFFICIAL_SOURCE" != "true" && "$SELECTED_MIRROR_ID" != "manual" ]]; then
        local domain
        domain="$(find_mirror_domain "$SELECTED_MIRROR_ID")"
        if [[ -z "$domain" ]]; then
            error_exit "未找到镜像源 ID: ${SELECTED_MIRROR_ID}，使用 --list 查看可用源"
        fi
        SELECTED_MIRROR_DOMAIN="$domain"
        SELECTED_MIRROR_NAME="$(find_mirror_name "$SELECTED_MIRROR_ID")"
    fi

    info "源: ${SELECTED_MIRROR_NAME} (${SELECTED_MIRROR_DOMAIN:-官方})"

    # 执行
    load_distro_module
    backup_original_mirrors
    apply_mirrors
    upgrade_packages
    print_summary
}

## 入口
parse_args "$@"

if [[ "$CLI_MODE" == "true" ]]; then
    main_cli
else
    main_interactive
fi