#!/bin/bash
# openSUSE 换源模块

apply_opensuse_mirrors() {
    local source="$1" protocol="$2"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        source="download.opensuse.org"
        protocol="https"
    fi

    local version_url
    case "$DISTRO_ID" in
    opensuse-tumbleweed)
        version_url="tumbleweed"
        ;;
    opensuse-leap)
        version_url="${DISTRO_VERSION}"
        ;;
    *)
        version_url="${DISTRO_VERSION}"
        ;;
    esac

    # 定义需要替换的仓库
    local repos=("repo-oss" "repo-non-oss" "repo-update" "repo-update-non-oss")
    local repo_names=("Main OSS" "Main Non-OSS" "Update OSS" "Update Non-OSS")

    for i in "${!repos[@]}"; do
        local repo_id="${repos[$i]}"
        local repo_name="${repo_names[$i]}"
        local target="/etc/zypp/repos.d/${repo_id}.repo"

        cat > "$target" <<EOF
[${repo_id}]
name=${repo_name}
enabled=1
autorefresh=1
baseurl=${protocol}://${source}/distribution/${version_url}/repo/oss/
type=rpm-md
gpgcheck=1
EOF
    done

    # 更新仓库
    zypper --quiet refresh 2>/dev/null || true
    success "openSUSE 源已更新"
}