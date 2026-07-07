#!/bin/bash
# openKylin 换源模块

apply_openkylin_mirrors() {
    local source="$1" protocol="$2" branch="$3"
    local base_url="${protocol}://${source}/${branch}"
    local tips="## 默认禁用源码镜像以提高速度，如需启用请自行取消注释"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        source="mirrors.openkylin.cn"
        branch="openkylin"
        base_url="${protocol}://${source}/${branch}"
    fi

    local target="/etc/apt/sources.list"
    cat > "$target" <<EOF
${tips}
deb ${base_url} ${DISTRO_CODENAME} main
# deb-src ${base_url} ${DISTRO_CODENAME} main
EOF
    success "已写入 ${target}"
}