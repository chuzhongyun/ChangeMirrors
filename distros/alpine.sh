#!/bin/bash
# Alpine 换源模块

apply_alpine_mirrors() {
    local source="$1" protocol="$2"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        cat > /etc/apk/repositories <<'EOF'
https://dl-cdn.alpinelinux.org/alpine/latest-stable/main
https://dl-cdn.alpinelinux.org/alpine/latest-stable/community
EOF
        success "已恢复官方源"
        return
    fi

    local alpine_ver
    if [[ -f /etc/alpine-release ]]; then
        alpine_ver="$(cat /etc/alpine-release | cut -d. -f1,2)"
    else
        alpine_ver="latest-stable"
    fi

    cat > /etc/apk/repositories <<EOF
${protocol}://${source}/alpine/v${alpine_ver}/main
${protocol}://${source}/alpine/v${alpine_ver}/community
EOF
    success "已写入 /etc/apk/repositories"
}