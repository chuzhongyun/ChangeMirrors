#!/bin/bash
# UI 模块 -- 颜色定义、菜单、交互

## 颜色变量
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
CYAN='\033[36m'
PLAIN='\033[0m'
BOLD='\033[1m'

## 状态符号
SUCCESS="${BOLD}${GREEN}✔${PLAIN}"
WARN="${BOLD}${YELLOW}⚠${PLAIN}"
ERROR="${BOLD}${RED}✘${PLAIN}"
TIP="${BOLD}${BLUE}ℹ${PLAIN}"
WORKING="${BOLD}${CYAN}>_${PLAIN}"

## 打印横幅
print_banner() {
    echo ""
    echo -e "${CYAN}============================================${PLAIN}"
    echo -e "${CYAN}      Linux 一键换源工具${PLAIN}"
    echo -e "${CYAN}============================================${PLAIN}"
    echo ""
}

## 打印分隔线
print_separator() {
    echo -e "${CYAN}--------------------------------------------${PLAIN}"
}

## 交互式选择镜像源
# 参数: $1=源类别 (china/edu/abroad)
# 返回: 选中的镜像 ID 存入 SELECTED_MIRROR_ID, 域名存入 SELECTED_MIRROR_DOMAIN
choose_mirror_interactive() {
    local category="${1:-china}"
    local -a ids=() domains=() names=()
    local entry id domain name

    # 解析列表
    for entry in $(get_mirror_list "$category"); do
        id="${entry%%|*}"
        local rest="${entry#*|}"
        domain="${rest%%|*}"
        name="${rest#*|}"
        ids+=("$id")
        domains+=("$domain")
        names+=("$name")
    done

    local total=${#ids[@]}

    echo -e "\n  ${BOLD}请选择镜像源:${PLAIN}\n"
    for i in $(seq 0 $((total - 1))); do
        printf "  %2d) %-30s %s\n" $((i + 1)) "${names[$i]}" "${domains[$i]}"
    done
    echo ""
    echo -e "  $((total + 1))) 使用官方源"
    echo -e "  $((total + 2))) 手动输入源地址"
    echo ""

    local choice
    while true; do
        read -rp "  请输入编号 [1-$((total + 2))]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if (( choice >= 1 && choice <= total )); then
                local idx=$((choice - 1))
                SELECTED_MIRROR_ID="${ids[$idx]}"
                SELECTED_MIRROR_DOMAIN="${domains[$idx]}"
                SELECTED_MIRROR_NAME="${names[$idx]}"
                USE_OFFICIAL_SOURCE="false"
                return 0
            elif (( choice == total + 1 )); then
                USE_OFFICIAL_SOURCE="true"
                SELECTED_MIRROR_ID="official"
                SELECTED_MIRROR_DOMAIN=""
                SELECTED_MIRROR_NAME="官方源"
                return 0
            elif (( choice == total + 2 )); then
                local manual_domain
                read -rp "  请输入源地址(域名或IP): " manual_domain
                if [[ -n "$manual_domain" ]]; then
                    SELECTED_MIRROR_ID="manual"
                    SELECTED_MIRROR_DOMAIN="$manual_domain"
                    SELECTED_MIRROR_NAME="手动输入"
                    USE_OFFICIAL_SOURCE="false"
                    return 0
                fi
            fi
        fi
        echo -e "  ${ERROR} 输入无效，请重新选择"
    done
}

## 选择源类别
choose_source_category() {
    echo -e "\n  ${BOLD}请选择源类别:${PLAIN}\n"
    echo "  1) 国内源 (默认)"
    echo "  2) 教育网源"
    echo "  3) 海外源"
    echo ""

    local choice
    read -rp "  请输入编号 [1-3] (默认 1): " choice
    case "${choice:-1}" in
    1) SOURCE_CATEGORY="china" ;;
    2) SOURCE_CATEGORY="edu" ;;
    3) SOURCE_CATEGORY="abroad" ;;
    *) SOURCE_CATEGORY="china" ;;
    esac
}

## 选择 WEB 协议
choose_protocol() {
    echo -e "\n  ${BOLD}请选择协议:${PLAIN}\n"
    echo "  1) HTTPS (默认，推荐)"
    echo "  2) HTTP"
    echo ""

    local choice
    read -rp "  请输入编号 [1-2] (默认 1): " choice
    case "${choice:-1}" in
    1) WEB_PROTOCOL="https" ;;
    2) WEB_PROTOCOL="http" ;;
    *) WEB_PROTOCOL="https" ;;
    esac
}

## 确认操作
confirm_action() {
    local msg="${1:-确认执行换源操作?}"
    echo ""
    read -rp "  ${msg} [Y/n]: " confirm
    [[ -z "$confirm" || "$confirm" =~ ^[Yy] ]]
}

## 进度提示
info()    { echo -e "  ${TIP} $*"; }
success() { echo -e "  ${SUCCESS} $*"; }
warn()    { echo -e "  ${WARN} $*"; }
err()     { echo -e "  ${ERROR} $*"; }
working() { echo -e "  ${WORKING} $*"; }