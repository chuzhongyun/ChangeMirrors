#!/bin/bash
# Gentoo 换源模块

apply_gentoo_mirrors() {
    local source="$1" protocol="$2"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        # 还原 make.conf 中的 GENTOO_MIRRORS
        if [[ -f "${BACKUP_DIR}/etc/portage/make.conf.bak" ]]; then
            cp -a "${BACKUP_DIR}/etc/portage/make.conf.bak" /etc/portage/make.conf
            cp -a "${BACKUP_DIR}/etc/portage/repos.conf.bak/gentoo.conf" /etc/portage/repos.conf/gentoo.conf
            success "已恢复官方源"
        else
            warn "未找到备份，无法恢复"
        fi
        return
    fi

    # make.conf -- 更新 GENTOO_MIRRORS
    local mirror_url="${protocol}://${source}/gentoo"
    if grep -q "^GENTOO_MIRRORS=" /etc/portage/make.conf; then
        sed -i "s|^GENTOO_MIRRORS=.*|GENTOO_MIRRORS=\"${mirror_url}\"|" /etc/portage/make.conf
    else
        echo "GENTOO_MIRRORS=\"${mirror_url}\"" >> /etc/portage/make.conf
    fi
    success "已更新 /etc/portage/make.conf"

    # repos.conf -- 更新 gentoo.conf sync-uri
    local sync_url="${protocol}://${source}/gentoo.git"
    mkdir -p /etc/portage/repos.conf
    if [[ -f /etc/portage/repos.conf/gentoo.conf ]]; then
        sed -i "s|sync-uri = .*|sync-uri = ${sync_url}|" /etc/portage/repos.conf/gentoo.conf
    else
        cat > /etc/portage/repos.conf/gentoo.conf <<EOF
[gentoo]
location = /var/db/repos/gentoo
sync-type = git
sync-uri = ${sync_url}
auto-sync = yes
EOF
    fi
    success "已更新 /etc/portage/repos.conf/gentoo.conf"
}