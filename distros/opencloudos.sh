#!/bin/bash
# OpenCloudOS 换源模块

apply_opencloudos_mirrors() {
    local source="$1" protocol="$2" branch="$3"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        source="mirrors.tencent.com"
        branch="opencloudos"
    fi

    local version="${DISTRO_VERSION}"
    local major="${DISTRO_VERSION_MAJOR}"
    local base_url="${protocol}://${source}/${branch}/${version}/"

    cat > /etc/yum.repos.d/OpenCloudOS-${major}.repo <<EOF
[opencloudos-${major}-base]
name=OpenCloudOS ${version} - Base
baseurl=${base_url}everything/\$basearch/
gpgcheck=1
gpgkey=${protocol}://${source}/${branch}/${version}/RPM-GPG-KEY-OpenCloudOS-${major}

[opencloudos-${major}-updates]
name=OpenCloudOS ${version} - Updates
baseurl=${base_url}updates/\$basearch/
gpgcheck=1
gpgkey=${protocol}://${source}/${branch}/${version}/RPM-GPG-KEY-OpenCloudOS-${major}
EOF
    success "已写入 /etc/yum.repos.d/OpenCloudOS-${major}.repo"
}