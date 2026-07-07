#!/bin/bash
# 系统检测模块 -- 检测发行版、版本、架构

## 检测发行版族系和具体名称
detect_distro() {
    local os_release="/etc/os-release"

    if [[ ! -f "$os_release" ]]; then
        error_exit "未找到 /etc/os-release，无法检测系统"
    fi

    # 从 os-release 提取字段
    DISTRO_ID="$(get_os_release_field ID)"
    DISTRO_NAME="$(get_os_release_field NAME)"
    DISTRO_VERSION="$(get_os_release_field VERSION_ID)"
    DISTRO_VERSION_MAJOR="${DISTRO_VERSION%%.*}"
    DISTRO_CODENAME="$(get_os_release_field VERSION_CODENAME)"
    DISTRO_PRETTY="$(get_os_release_field PRETTY_NAME)"

    # 检测族系
    if [[ -f /etc/debian_version ]]; then
        DISTRO_FAMILY="debian"
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO_FAMILY="redhat"
    elif [[ -f /etc/arch-release ]]; then
        DISTRO_FAMILY="arch"
    elif [[ -f /etc/alpine-release ]]; then
        DISTRO_FAMILY="alpine"
    elif [[ -f /etc/gentoo-release ]]; then
        DISTRO_FAMILY="gentoo"
    elif [[ -f /etc/openEuler-release ]]; then
        DISTRO_FAMILY="openeuler"
    elif [[ -f /etc/anolis-release ]]; then
        DISTRO_FAMILY="anolis"
    elif [[ -f /etc/opencloudos-release ]]; then
        DISTRO_FAMILY="opencloudos"
    elif [[ -f /etc/kylin-version/kylin-system-version.conf ]]; then
        DISTRO_FAMILY="openkylin"
    elif [[ "$DISTRO_NAME" == *"openSUSE"* ]]; then
        DISTRO_FAMILY="opensuse"
    else
        error_exit "不支持的发行版: $DISTRO_PRETTY"
    fi

    # 检测具体发行版名称 (用于族系内区分)
    detect_specific_distro

    # 检测代号 (Debian 系用 lsb_release)
    if [[ "$DISTRO_FAMILY" == "debian" ]] && [[ -z "$DISTRO_CODENAME" ]]; then
        if command -v lsb_release &>/dev/null; then
            DISTRO_CODENAME="$(lsb_release -cs)"
        fi
    fi

    # 分支名 (镜像路径)
    detect_source_branch
}

## 族系内区分具体发行版
detect_specific_distro() {
    case "$DISTRO_FAMILY" in
    debian)
        if command -v lsb_release &>/dev/null; then
            DISTRO_JUDGMENT="$(lsb_release -is)"
        else
            DISTRO_JUDGMENT="$DISTRO_NAME"
        fi
        ;;
    redhat)
        local rhel_release
        rhel_release="$(cat /etc/redhat-release)"
        if [[ "$rhel_release" == *"Red Hat Enterprise"* ]]; then
            DISTRO_JUDGMENT="RHEL"
        elif [[ "$rhel_release" == *"CentOS Stream"* ]]; then
            DISTRO_JUDGMENT="CentOS-Stream"
        elif [[ "$rhel_release" == *"CentOS"* ]]; then
            DISTRO_JUDGMENT="CentOS"
        elif [[ "$rhel_release" == *"Rocky"* ]]; then
            DISTRO_JUDGMENT="Rocky"
        elif [[ "$rhel_release" == *"AlmaLinux"* ]]; then
            DISTRO_JUDGMENT="AlmaLinux"
        elif [[ "$rhel_release" == *"Fedora"* ]]; then
            DISTRO_JUDGMENT="Fedora"
        else
            DISTRO_JUDGMENT="Unknown-RedHat"
        fi
        ;;
    *)
        DISTRO_JUDGMENT="$DISTRO_NAME"
        ;;
    esac
}

## 检测镜像分支名 (源路径)
detect_source_branch() {
    case "$DISTRO_FAMILY" in
    debian)
        case "$DISTRO_JUDGMENT" in
        Debian)
            if [[ "$DISTRO_VERSION_MAJOR" -le 10 ]]; then
                SOURCE_BRANCH="debian-archive"
            else
                SOURCE_BRANCH="debian"
            fi
            ;;
        Ubuntu|Zorin)
            if [[ "$ARCH" == "x86_64" || "$ARCH" == i?86 ]]; then
                SOURCE_BRANCH="ubuntu"
            else
                SOURCE_BRANCH="ubuntu-ports"
            fi
            ;;
        Kali)       SOURCE_BRANCH="kali" ;;
        Deepin)     SOURCE_BRANCH="deepin" ;;
        Linuxmint)
            if [[ "$ARCH" == "x86_64" || "$ARCH" == i?86 ]]; then
                SOURCE_BRANCH="linuxmint"
            else
                SOURCE_BRANCH="ubuntu-ports"
            fi
            ;;
        *)          SOURCE_BRANCH="${DISTRO_JUDGMENT,,}" ;;
        esac
        ;;
    redhat)
        case "$DISTRO_JUDGMENT" in
        CentOS)       SOURCE_BRANCH="centos-vault" ;;
        CentOS-Stream) SOURCE_BRANCH="centos-stream" ;;
        Rocky)        SOURCE_BRANCH="rocky" ;;
        AlmaLinux)    SOURCE_BRANCH="almalinux" ;;
        Fedora)       SOURCE_BRANCH="fedora" ;;
        RHEL)
            if [[ "$DISTRO_VERSION_MAJOR" -ge 9 ]]; then
                SOURCE_BRANCH="centos-stream"
            else
                SOURCE_BRANCH="centos-vault"
            fi
            ;;
        esac
        ;;
    arch)           SOURCE_BRANCH="" ;;
    alpine)         SOURCE_BRANCH="alpine" ;;
    gentoo)         SOURCE_BRANCH="gentoo" ;;
    openeuler)      SOURCE_BRANCH="openeuler" ;;
    anolis)         SOURCE_BRANCH="anolis" ;;
    opencloudos)    SOURCE_BRANCH="opencloudos" ;;
    openkylin)      SOURCE_BRANCH="openkylin" ;;
    opensuse)       SOURCE_BRANCH="opensuse" ;;
    esac
}

## 检测处理器架构
detect_arch() {
    case "$(uname -m)" in
    x86_64)  ARCH="x86_64" ;;
    aarch64) ARCH="aarch64" ;;
    armv7l)  ARCH="armv7l" ;;
    armv6l)  ARCH="armv6l" ;;
    i686)    ARCH="i686" ;;
    *)       ARCH="$(uname -m)" ;;
    esac
}

## 辅助: 从 os-release 提取字段
get_os_release_field() {
    local key="$1"
    grep -E "^${key}=" /etc/os-release 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"'"'"
}

## 打印检测结果
print_system_info() {
    echo -e "  发行版: ${CYAN}${DISTRO_PRETTY}${PLAIN}"
    echo -e "  族系:   ${CYAN}${DISTRO_FAMILY}${PLAIN} (${DISTRO_JUDGMENT})"
    echo -e "  版本:   ${CYAN}${DISTRO_VERSION}${PLAIN} (代号: ${DISTRO_CODENAME:-N/A})"
    echo -e "  架构:   ${CYAN}${ARCH}${PLAIN}"
    echo -e "  分支:   ${CYAN}${SOURCE_BRANCH:-N/A}${PLAIN}"
}