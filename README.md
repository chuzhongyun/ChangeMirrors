# ChangeMirrors

模块化的一键换源工具，帮助 GNU/Linux 用户快速切换软件源镜像。

本项目基于 [SuperManito/LinuxMirrors](https://github.com/SuperManito/LinuxMirrors) 的旧版单文件脚本进行重构，将 6000+ 行的单体脚本拆分为独立模块，便于阅读、维护和扩展。

## 它能做什么

- 自动识别当前系统发行版和版本
- 提供国内 / 教育网 / 海外三类共 106 个镜像源可选
- 一键替换系统软件源配置文件
- 操作前自动备份，随时可恢复
- 检测云厂商内网镜像并提示切换

## 支持的系统

**Debian 系：** Debian 8-13 / Ubuntu 14-26 / Kali / Deepin / Linux Mint / Zorin OS

**RedHat 系：** RHEL 7-9 / CentOS 7-8 / CentOS Stream 8-9 / Rocky 8-9 / AlmaLinux 8-9 / Fedora 30-44

**其他：** openEuler / Anolis OS / OpenCloudOS / openKylin / openSUSE / Arch Linux / Alpine / Gentoo

## 安装

有两种方式使用本工具，功能完全相同：

### 方式一：远程一键执行（无需克隆仓库）

脚本会自动从 GitHub 下载所需模块到临时目录，执行完毕后自动清理，不会在系统中留下任何文件。

```bash
sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh)
```

### 方式二：本地克隆

```bash
git clone https://github.com/chuzhongyun/ChangeMirrors.git
cd ChangeMirrors
sudo bash change-mirrors.sh
```

## 使用方法

以下示例同时展示两种方式的命令，`<入口>` 在远程模式下替换为 `<(curl -sSL ...change-mirrors.sh)`，在本地模式下替换为 `change-mirrors.sh`。

### 交互模式

不带参数运行，进入菜单引导操作。脚本会自动检测系统，依次选择源类别、镜像源、协议：

```bash
# 远程
sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh)

# 本地
sudo bash change-mirrors.sh
```

### 命令行模式

适合脚本调用或跳过交互：

```bash
# 指定清华源
sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh) -s tsinghua
sudo bash change-mirrors.sh -s tsinghua

# 阿里云 + HTTP 协议
sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh) -s aliyun -p http
sudo bash change-mirrors.sh -s aliyun -p http

# 恢复官方源
sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh) --official
sudo bash change-mirrors.sh --official

# 从备份恢复
sudo bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh) --restore
sudo bash change-mirrors.sh --restore
```

### 查看所有可用源

```bash
# 远程
bash <(curl -sSL https://raw.githubusercontent.com/chuzhongyun/ChangeMirrors/main/change-mirrors.sh) --list

# 本地
bash change-mirrors.sh --list
```

### 完整参数

| 参数 | 简写 | 说明 |
|------|------|------|
| `--source <id>` | `-s` | 镜像源 ID，如 `tsinghua`、`aliyun`、`ustc` |
| `--source-domain <域名>` | | 直接指定域名 |
| `--protocol <协议>` | `-p` | `https`(默认) 或 `http` |
| `--category <类别>` | `-c` | `china`(默认) / `edu` / `abroad` |
| `--official` | | 切回官方源 |
| `--restore` | | 从备份恢复 |
| `--list` | | 列出全部源 |
| `--help` | `-h` | 显示帮助 |
| `--version` | `-v` | 显示版本 |

参数在远程和本地模式下完全通用，直接追加在命令末尾即可。

## 镜像源一览

**国内（14 个）：** 阿里云、腾讯云、华为云、网易、火山引擎、清华、北大、浙大、南大、兰大、上交、重邮、中科大、中科院

**教育网（29 个）：** 覆盖全国主要高校镜像节点

**海外（63 个）：** 亚洲、欧洲、北美、南美、大洋洲、非洲

完整列表运行 `--list` 参数查看。

## 项目结构

这个项目和原版最大的区别是模块化。原版把所有逻辑塞在一个 6000 行的文件里，这里拆成了职责单一的小文件：

```
ChangeMirrors/
├── change-mirrors.sh      # 入口：参数解析 + 远程模块下载 + 调度
├── lib/
│   ├── detect.sh          # 系统检测
│   ├── mirrors.sh         # 镜像源数据
│   ├── ui.sh              # 交互界面
│   ├── backup.sh          # 备份恢复
│   └── utils.sh           # 工具函数
└── distros/
    ├── debian.sh          # Debian/Ubuntu/Kali/Deepin/Mint/Zorin
    ├── redhat.sh          # RHEL/CentOS/Rocky/Alma/Fedora
    ├── arch.sh            # Arch Linux
    ├── alpine.sh          # Alpine
    ├── gentoo.sh          # Gentoo
    ├── opensuse.sh        # openSUSE
    ├── openeuler.sh       # openEuler
    ├── anolis.sh          # Anolis OS
    ├── opencloudos.sh     # OpenCloudOS
    └── openkylin.sh       # openKylin
```

如果要支持新的发行版，只需在 `distros/` 下加一个文件，实现 `apply_xxx_mirrors()` 函数即可。

## 致谢

- [SuperManito/LinuxMirrors](https://github.com/SuperManito/LinuxMirrors) -- 本项目的原始参考

## 许可证

[MIT](https://github.com/chuzhongyun/ChangeMirrors/blob/main/LICENSE)
