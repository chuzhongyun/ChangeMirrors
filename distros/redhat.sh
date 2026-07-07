#!/bin/bash
# RedHat 族系换源模块
# 支持: RHEL, CentOS, CentOS Stream, Rocky, AlmaLinux, Fedora

apply_redhat_mirrors() {
    local source="$1" protocol="$2" branch="$3"

    if [[ "$USE_OFFICIAL_SOURCE" == "true" ]]; then
        restore_redhat_repos
        return
    fi

    # 先生成标准 repo 文件
    generate_redhat_repos "$source" "$protocol" "$branch"
    # 替换 baseurl 中的镜像地址
    sed_redhat_repos "$source" "$protocol" "$branch"
    # 处理 EPEL
    apply_epel "$source" "$protocol"
}

## 生成标准 repo 文件 (从模板)
generate_redhat_repos() {
    local source="$1" protocol="$2" branch="$3"
    local template_key

    case "$DISTRO_JUDGMENT" in
    RHEL)
        if [[ "$DISTRO_VERSION_MAJOR" -ge 9 ]]; then
            template_key="centos-stream-${DISTRO_VERSION_MAJOR}"
        else
            template_key="centos-${DISTRO_VERSION_MAJOR}"
        fi
        ;;
    CentOS)          template_key="centos-${DISTRO_VERSION_MAJOR}" ;;
    CentOS-Stream)   template_key="centos-stream-${DISTRO_VERSION_MAJOR}" ;;
    Rocky)           template_key="rocky-${DISTRO_VERSION_MAJOR}" ;;
    AlmaLinux)       template_key="almalinux-${DISTRO_VERSION_MAJOR}" ;;
    Fedora)          template_key="fedora-${DISTRO_VERSION}" ;;
    esac

    local template_dir="${SCRIPT_DIR}/templates"
    local template_file="${template_dir}/${template_key}.repo"

    if [[ ! -f "$template_file" ]]; then
        warn "未找到模板 ${template_key}.repo，使用 sed 直接修改现有 repo 文件"
        return
    fi

    # 清空并重建 repo 目录
    rm -f /etc/yum.repos.d/*.repo
    cp "$template_file" /etc/yum.repos.d/
    # 如果模板是目录形式则拷贝所有
    if [[ -d "${template_dir}/${template_key}" ]]; then
        cp "${template_dir}/${template_key}"/*.repo /etc/yum.repos.d/
    fi
}

## 用 sed 替换 repo 文件中的镜像地址
sed_redhat_repos() {
    local source="$1" protocol="$2" branch="$3"

    cd /etc/yum.repos.d || return

    for repo in *.repo; do
        [[ -f "$repo" ]] || continue

        # 替换 baseurl: 注释掉的 #baseurl 也要处理
        sed -i \
            -e "s|^#baseurl=https\?://[^/]*\(.*\)|baseurl=${protocol}://${source}${branch:+/${branch}}\1|g" \
            -e "s|^baseurl=https\?://[^/]*\(.*\)|baseurl=${protocol}://${source}${branch:+/${branch}}\1|g" \
            -e "s|^metalink=|#metalink=|g" \
            "$repo"
    done

    success "RedHat 系源文件已更新"
}

## 恢复 RedHat 系官方源
restore_redhat_repos() {
    if [[ -d "${BACKUP_DIR}/etc/yum.repos.d.bak" ]]; then
        rm -rf /etc/yum.repos.d
        cp -a "${BACKUP_DIR}/etc/yum.repos.d.bak" /etc/yum.repos.d
        success "已恢复官方源"
    else
        warn "未找到备份，尝试还原 metalink..."
        cd /etc/yum.repos.d || return
        for repo in *.repo; do
            [[ -f "$repo" ]] || continue
            sed -i \
                -e "s|^baseurl=|#baseurl=|g" \
                -e "s|^#metalink=|metalink=|g" \
                "$repo"
        done
    fi
}

## EPEL 附加仓库
apply_epel() {
    local source="$1" protocol="$2"

    if ! confirm_action "是否安装/启用 EPEL 附加软件包仓库?"; then
        return
    fi

    # 安装 epel-release
    if command -v dnf &>/dev/null; then
        dnf install -y epel-release 2>/dev/null || true
    elif command -v yum &>/dev/null; then
        yum install -y epel-release 2>/dev/null || true
    fi

    # 替换 EPEL 源地址
    if [[ -f /etc/yum.repos.d/epel.repo ]]; then
        sed -i \
            -e "s|^#baseurl=https\?://download.fedoraproject.org\(.*\)|baseurl=${protocol}://${source}/epel\1|g" \
            -e "s|^baseurl=https\?://download.fedoraproject.org\(.*\)|baseurl=${protocol}://${source}/epel\1|g" \
            -e "s|^metalink=|#metalink=|g" \
            /etc/yum.repos.d/epel.repo
        success "EPEL 源已更新"
    fi
}