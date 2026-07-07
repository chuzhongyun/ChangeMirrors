#!/bin/bash
# 备份与恢复模块

BACKUP_DIR="/etc/apt-mirror-backup"
BACKED_UP="false"

## 初始化备份目录
init_backup_dir() {
    mkdir -p "$BACKUP_DIR"
}

## 备份文件 (单个)
backup_file() {
    local src="$1"
    if [[ -f "$src" ]]; then
        local backup_path="${BACKUP_DIR}$(dirname "$src")"
        mkdir -p "$backup_path"
        cp -a "$src" "${backup_path}/$(basename "$src").bak"
        BACKED_UP="true"
    fi
}

## 备份目录 (整体)
backup_dir() {
    local src="$1"
    if [[ -d "$src" ]]; then
        local backup_path="${BACKUP_DIR}${src}"
        mkdir -p "$(dirname "$backup_path")"
        cp -a "$src" "${backup_path}.bak"
        BACKED_UP="true"
    fi
}

## 根据发行版族系执行标准备份流程
backup_original_mirrors() {
    init_backup_dir
    working "正在备份原始源配置..."

    case "$DISTRO_FAMILY" in
    debian)
        case "$DISTRO_JUDGMENT" in
        Linuxmint)
            backup_file "/etc/apt/sources.list.d/official-package-repositories.list"
            ;;
        *)
            # Debian/Ubuntu 等: 备份 sources.list 或 ubuntu.sources
            if [[ -f /etc/apt/sources.list ]]; then
                backup_file "/etc/apt/sources.list"
            fi
            if [[ -f /etc/apt/sources.list.d/ubuntu.sources ]]; then
                backup_file "/etc/apt/sources.list.d/ubuntu.sources"
            fi
            if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
                backup_file "/etc/apt/sources.list.d/debian.sources"
            fi
            ;;
        esac
        # Armbian / Proxmox 附加源
        [[ -f /etc/armbian-release ]] && backup_file "/etc/apt/sources.list.d/armbian.list"
        [[ -f /etc/pve/.version ]] && backup_file "/etc/apt/sources.list.d/pve-no-subscription.list"
        ;;
    redhat)
        backup_dir "/etc/yum.repos.d"
        ;;
    opensuse)
        backup_dir "/etc/zypp/repos.d"
        ;;
    arch)
        backup_file "/etc/pacman.d/mirrorlist"
        ;;
    alpine)
        backup_file "/etc/apk/repositories"
        ;;
    gentoo)
        backup_file "/etc/portage/make.conf"
        backup_file "/etc/portage/repos.conf/gentoo.conf"
        ;;
    *)
        warn "当前发行版暂无标准备份流程"
        ;;
    esac

    success "备份完成 -> ${BACKUP_DIR}"
}

## 恢复备份
restore_backup() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        err "未找到备份目录: $BACKUP_DIR"
        return 1
    fi

    working "正在从备份恢复..."

    case "$DISTRO_FAMILY" in
    debian)
        restore_file "/etc/apt/sources.list"
        restore_file "/etc/apt/sources.list.d/ubuntu.sources"
        restore_file "/etc/apt/sources.list.d/debian.sources"
        restore_file "/etc/apt/sources.list.d/official-package-repositories.list"
        restore_file "/etc/apt/sources.list.d/armbian.list"
        restore_file "/etc/apt/sources.list.d/pve-no-subscription.list"
        ;;
    redhat)
        if [[ -d "${BACKUP_DIR}/etc/yum.repos.d.bak" ]]; then
            rm -rf /etc/yum.repos.d
            cp -a "${BACKUP_DIR}/etc/yum.repos.d.bak" /etc/yum.repos.d
        fi
        ;;
    opensuse)
        if [[ -d "${BACKUP_DIR}/etc/zypp/repos.d.bak" ]]; then
            rm -rf /etc/zypp/repos.d
            cp -a "${BACKUP_DIR}/etc/zypp/repos.d.bak" /etc/zypp/repos.d
        fi
        ;;
    arch)
        restore_file "/etc/pacman.d/mirrorlist"
        ;;
    alpine)
        restore_file "/etc/apk/repositories"
        ;;
    gentoo)
        restore_file "/etc/portage/make.conf"
        restore_file "/etc/portage/repos.conf/gentoo.conf"
        ;;
    esac

    success "恢复完成"
}

## 恢复单个文件
restore_file() {
    local original="$1"
    local backup_path="${BACKUP_DIR}${original}.bak"
    if [[ -f "$backup_path" ]]; then
        cp -a "$backup_path" "$original"
    fi
}