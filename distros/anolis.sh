#!/bin/bash
# Anolis OS 换源模块

apply_anolis_mirrors() {
    local source="$1" protocol="$2" branch="$3"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        source="mirrors.openanolis.cn"
        branch="anolis"
    fi

    local version="${DISTRO_VERSION}"
    local major="${DISTRO_VERSION_MAJOR}"
    local base_url="${protocol}://${source}/${branch}/${version}/"

    # Anolis 使用 centos 兼容源结构
    cat > /etc/yum.repos.d/AnolisOS-${major}.repo <<EOF
[anolis-${major}-base]
name=AnolisOS-${major} - Base
baseurl=${base_url}os/\$basearch/
gpgcheck=1
gpgkey=${protocol}://${source}/${branch}/${version}/RPM-GPG-KEY-ANOLIS-${major}

[anolis-${major}-updates]
name=AnolisOS-${major} - Updates
baseurl=${base_url}updates/\$basearch/
gpgcheck=1
gpgkey=${protocol}://${source}/${branch}/${version}/RPM-GPG-KEY-ANOLIS-${major}
EOF
    success "已写入 /etc/yum.repos.d/AnolisOS-${major}.repo"
}