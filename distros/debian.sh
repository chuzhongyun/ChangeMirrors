#!/bin/bash
# Debian 族系换源模块
# 支持: Debian, Ubuntu, Kali, Deepin, Linux Mint, Zorin

apply_debian_mirrors() {
    local source="$1" protocol="$2" branch="$3"
    local base_url="${protocol}://${source}/${branch}"
    local tips="## 默认禁用源码镜像以提高速度，如需启用请自行取消注释"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        case "$DISTRO_JUDGMENT" in
        Debian)     source="deb.debian.org" ;;
        Ubuntu|Zorin) source="archive.ubuntu.com" ;;
        Kali)       source="http.kali.org" ;;
        Deepin)     source="community-packages.deepin.com" ;;
        Linuxmint)  source="packages.linuxmint.com" ;;
        esac
        base_url="${protocol}://${source}/${branch}"
    fi

    case "$DISTRO_JUDGMENT" in
    Debian)
        apply_debian "$base_url" "$tips"
        ;;
    Ubuntu|Zorin)
        apply_ubuntu "$base_url" "$tips"
        ;;
    Kali)
        apply_kali "$base_url" "$tips"
        ;;
    Deepin)
        apply_deepin "$base_url" "$tips"
        ;;
    Linuxmint)
        apply_linuxmint "$base_url" "$tips"
        ;;
    *)
        err "不支持的 Debian 系发行版: $DISTRO_JUDGMENT"
        return 1
        ;;
    esac

    # Armbian 附加源
    if [[ -f /etc/armbian-release ]]; then
        apply_armbian_extra "$base_url"
    fi
    # Proxmox 附加源
    if [[ -f /etc/pve/.version ]]; then
        apply_proxmox_extra "$source" "$protocol"
    fi
}

## Debian
apply_debian() {
    local base_url="$1" tips="$2"
    local target="/etc/apt/sources.list"
    local sections

    case "$DISTRO_VERSION_MAJOR" in
    8|9|10|11) sections="main contrib non-free" ;;
    *)          sections="main contrib non-free non-free-firmware" ;;
    esac

    if [[ "$DISTRO_CODENAME" == "sid" ]]; then
        cat > "$target" <<EOF
${tips}
deb ${base_url} ${DISTRO_CODENAME} ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME} ${sections}
EOF
    else
        local security_url="${protocol}://${source}/${branch}-security"
        cat > "$target" <<EOF
${tips}
deb ${base_url} ${DISTRO_CODENAME} ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME} ${sections}
deb ${base_url} ${DISTRO_CODENAME}-updates ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME}-updates ${sections}
deb ${base_url} ${DISTRO_CODENAME}-backports ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME}-backports ${sections}
deb ${security_url} ${DISTRO_CODENAME}-security ${sections}
# deb-src ${security_url} ${DISTRO_CODENAME}-security ${sections}
EOF
    fi
    success "已写入 ${target}"
}

## Ubuntu / Zorin
apply_ubuntu() {
    local base_url="$1" tips="$2"
    local target="/etc/apt/sources.list"
    local sections="main restricted universe multiverse"

    cat > "$target" <<EOF
${tips}
deb ${base_url} ${DISTRO_CODENAME} ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME} ${sections}
deb ${base_url} ${DISTRO_CODENAME}-updates ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME}-updates ${sections}
deb ${base_url} ${DISTRO_CODENAME}-backports ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME}-backports ${sections}
deb ${base_url} ${DISTRO_CODENAME}-security ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME}-security ${sections}
EOF
    success "已写入 ${target}"
}

## Kali
apply_kali() {
    local base_url="$1" tips="$2"
    local target="/etc/apt/sources.list"
    local sections="main contrib non-free non-free-firmware"

    cat > "$target" <<EOF
${tips}
deb ${base_url} ${DISTRO_CODENAME} ${sections}
# deb-src ${base_url} ${DISTRO_CODENAME} ${sections}
EOF
    success "已写入 ${target}"
}

## Deepin
apply_deepin() {
    local base_url="$1" tips="$2"
    local target="/etc/apt/sources.list"

    cat > "$target" <<EOF
${tips}
deb ${base_url} apricot main contrib non-free
# deb-src ${base_url} apricot main contrib non-free
EOF
    success "已写入 ${target}"
}

## Linux Mint
apply_linuxmint() {
    local base_url="$1" tips="$2"
    local target="/etc/apt/sources.list.d/official-package-repositories.list"

    # Linux Mint 专用源
    cat > "$target" <<EOF
deb ${base_url} ${DISTRO_CODENAME} main upstream import backport
EOF

    # 底层系统源
    local ubuntu_branch="ubuntu"
    [[ "$ARCH" != "x86_64" && "$ARCH" != i?86 ]] && ubuntu_branch="ubuntu-ports"
    local ubuntu_url="${WEB_PROTOCOL}://${source}/${ubuntu_branch}"

    local base_codename
    if [[ "$DISTRO_VERSION_MAJOR" == 6 ]]; then
        # LMDE (Debian 底层)
        base_codename="bookworm"
        local debian_url="${WEB_PROTOCOL}://${source}/debian"
        cat > /etc/apt/sources.list.d/official-source-repositories.list <<EOF
${tips}
deb ${debian_url} ${base_codename} main contrib non-free non-free-firmware
# deb-src ${debian_url} ${base_codename} main contrib non-free non-free-firmware
deb ${debian_url} ${base_codename}-updates main contrib non-free non-free-firmware
# deb-src ${debian_url} ${base_codename}-updates main contrib non-free non-free-firmware
deb ${debian_url}-security ${base_codename}-security main contrib non-free non-free-firmware
# deb-src ${debian_url}-security ${base_codename}-security main contrib non-free non-free-firmware
EOF
    else
        # Ubuntu 底层
        base_codename="$(_mint_to_ubuntu_codename "$DISTRO_CODENAME")"
        cat > /etc/apt/sources.list.d/official-source-repositories.list <<EOF
${tips}
deb ${ubuntu_url} ${base_codename} main restricted universe multiverse
# deb-src ${ubuntu_url} ${base_codename} main restricted universe multiverse
deb ${ubuntu_url} ${base_codename}-updates main restricted universe multiverse
# deb-src ${ubuntu_url} ${base_codename}-updates main restricted universe multiverse
deb ${ubuntu_url} ${base_codename}-backports main restricted universe multiverse
# deb-src ${ubuntu_url} ${base_codename}-backports main restricted universe multiverse
deb ${ubuntu_url} ${base_codename}-security main restricted universe multiverse
# deb-src ${ubuntu_url} ${base_codename}-security main restricted universe multiverse
EOF
    fi
    success "已写入 ${target}"
}

## Mint 代号 -> Ubuntu 代号映射
_mint_to_ubuntu_codename() {
    local mint_codename="$1"
    case "$mint_codename" in
    tina|tessa|tara|tricia) echo "bionic" ;;
    ulyana|ulyssa|uma|una)   echo "focal" ;;
    vanessa|vera|victoria|virginia) echo "jammy" ;;
    wilma)                   echo "noble" ;;
    *)                       echo "$mint_codename" ;;
    esac
}

## Armbian 附加源
apply_armbian_extra() {
    local base_url="$1"
    local target="/etc/apt/sources.list.d/armbian.list"
    cat > "$target" <<EOF
deb ${base_url} ${DISTRO_CODENAME} main ${DISTRO_CODENAME}-utils ${DISTRO_CODENAME}-desktop
EOF
    info "Armbian 附加源已更新"
}

## Proxmox 附加源
apply_proxmox_extra() {
    local source="$1" protocol="$2"
    local target="/etc/apt/sources.list.d/pve-no-subscription.list"
    cat > "$target" <<EOF
deb ${protocol}://${source}/debian/pve ${DISTRO_CODENAME} pve-no-subscription
EOF
    info "Proxmox 附加源已更新"
}