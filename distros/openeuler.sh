#!/bin/bash
# openEuler 换源模块

apply_openeuler_mirrors() {
    local source="$1" protocol="$2" branch="$3"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        source="repo.openeuler.org"
        branch="openeuler"
    fi

    local version="${DISTRO_VERSION}"
    local base_url="${protocol}://${source}/${branch}/${version}/"

    cat > /etc/yum.repos.d/openEuler.repo <<EOF
[openEuler]
name=openEuler ${version}
baseurl=${base_url}
enabled=1
gpgcheck=1
gpgkey=${protocol}://${source}/${branch}/${version}/RPM-GPG-KEY-openEuler
EOF
    success "已写入 /etc/yum.repos.d/openEuler.repo"
}