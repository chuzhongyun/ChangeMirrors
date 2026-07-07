#!/bin/bash
# 公共工具函数

## 检查 root 权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "请使用 root 权限运行此脚本 (sudo)"
        exit 1
    fi
}

## 错误退出
error_exit() {
    err "$*"
    exit 1
}

## 加载发行版换源模块
load_distro_module() {
    local module_dir="${SCRIPT_DIR}/distros"
    case "$DISTRO_FAMILY" in
    debian)    source "${module_dir}/debian.sh" ;;
    redhat)    source "${module_dir}/redhat.sh" ;;
    arch)      source "${module_dir}/arch.sh" ;;
    alpine)    source "${module_dir}/alpine.sh" ;;
    gentoo)    source "${module_dir}/gentoo.sh" ;;
    openeuler) source "${module_dir}/openeuler.sh" ;;
    anolis)    source "${module_dir}/anolis.sh" ;;
    opencloudos) source "${module_dir}/opencloudos.sh" ;;
    openkylin) source "${module_dir}/openkylin.sh" ;;
    opensuse)  source "${module_dir}/opensuse.sh" ;;
    *)         error_exit "未找到发行版模块: $DISTRO_FAMILY" ;;
    esac
}

## 执行换源调度
apply_mirrors() {
    local source="$SELECTED_MIRROR_DOMAIN"
    local protocol="$WEB_PROTOCOL"
    local branch="$SOURCE_BRANCH"

    working "正在应用镜像源..."

    # 检查内网地址
    if [[ "$USE_OFFICIAL_SOURCE" != "true" ]]; then
        local intranet
        intranet="$(get_intranet_mirror "$source")"
        if [[ -n "$intranet" ]] && confirm_action "检测到该源有内网地址 ${intranet}，是否使用内网地址?"; then
            source="$intranet"
            info "已切换为内网地址: $source"
        fi
    fi

    case "$DISTRO_FAMILY" in
    debian)    apply_debian_mirrors "$source" "$protocol" "$branch" ;;
    redhat)    apply_redhat_mirrors "$source" "$protocol" "$branch" ;;
    arch)      apply_arch_mirrors "$source" "$protocol" ;;
    alpine)    apply_alpine_mirrors "$source" "$protocol" ;;
    gentoo)    apply_gentoo_mirrors "$source" "$protocol" ;;
    openeuler) apply_openeuler_mirrors "$source" "$protocol" "$branch" ;;
    anolis)    apply_anolis_mirrors "$source" "$protocol" "$branch" ;;
    opencloudos) apply_opencloudos_mirrors "$source" "$protocol" "$branch" ;;
    openkylin) apply_openkylin_mirrors "$source" "$protocol" "$branch" ;;
    opensuse)  apply_opensuse_mirrors "$source" "$protocol" ;;
    esac

    success "镜像源已更新"
}

## 可选: 更新软件包索引
upgrade_packages() {
    if ! confirm_action "是否立即更新软件包索引?"; then
        return
    fi
    working "正在更新软件包索引..."
    case "$DISTRO_FAMILY" in
    debian)
        apt-get update -y 2>/dev/null
        ;;
    redhat|openeuler|anolis|opencloudos)
        if command -v dnf &>/dev/null; then
            dnf makecache 2>/dev/null
        elif command -v yum &>/dev/null; then
            yum makecache 2>/dev/null
        fi
        ;;
    opensuse)
        zypper refresh 2>/dev/null
        ;;
    arch)
        pacman -Syy 2>/dev/null
        ;;
    alpine)
        apk update 2>/dev/null
        ;;
    gentoo)
        emerge --sync 2>/dev/null
        ;;
    esac
    success "更新完成"
}

## 打印完成信息
print_summary() {
    echo ""
    print_separator
    echo -e "  ${BOLD}换源完成!${PLAIN}"
    echo ""
    echo -e "  系统:   ${CYAN}${DISTRO_PRETTY}${PLAIN}"
    echo -e "  源:     ${CYAN}${SELECTED_MIRROR_NAME}${PLAIN} (${SELECTED_MIRROR_DOMAIN:-官方})"
    echo -e "  协议:   ${CYAN}${WEB_PROTOCOL}${PLAIN}"
    if [[ "$BACKED_UP" == "true" ]]; then
        echo -e "  备份:   ${CYAN}${BACKUP_DIR}${PLAIN}"
    fi
    print_separator
    echo ""
}