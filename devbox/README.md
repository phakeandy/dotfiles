# devbox

Arch CLI 开发容器，给 distrobox 用。镜像只装工具，不装配置（dotfiles 走共享 `$HOME`）。

## 命令

```bash
# 构建
podman build -t localhost/devbox:latest ~/dotfiles/devbox

# 创建（一次）
distrobox create --name devbox --image localhost/devbox:latest

# 日常进入
distrobox enter devbox --clean-path

# 更新（改了 Dockerfile 之后）
podman build -t localhost/devbox:latest ~/dotfiles/devbox
podman rm -f devbox && distrobox create --name devbox --image localhost/devbox:latest
```

试错成本就是这个 `podman rm -f` + `create`，所以容器里随便折腾。

## 加包

repo 包：改 Dockerfile 最后的「加料区」那一段，rebuild 只失效该层。

```dockerfile
RUN pacman -S --needed --noconfirm github-cli ffmpeg just \
 && rm -rf /var/cache/pacman/pkg/*
```

AUR 包：优先找 `-bin` 变体（作者上传二进制，不编译）。`yay-bin` 已经在镜像里，新包只需写一行：

```dockerfile
RUN su builder -c 'yay -S --noconfirm --answerclean None --answerdiff None --removemake some-tool-bin'
```

但 builder 用户是临时创建的，所以要么把它塞进 L5 那条 `su builder` 里，要么在加料区自己建一次（模板）：

```dockerfile
RUN useradd -m -s /bin/bash builder \
 && echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder \
 && su builder -c 'yay -S --noconfirm --answerclean None --answerdiff None --removemake some-tool-bin' \
 && rm -f /etc/sudoers.d/builder && userdel -r builder
```

真需要编译（`-git` 类）或要自己 `makepkg` 时才写完整的 clone 流程。

```dockerfile
RUN useradd -m -s /bin/bash builder \
 && echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder \
 && install -d -o builder -g builder /tmp/aur \
 && su builder -c 'set -e; cd /tmp/aur \
      && git clone --depth 1 https://aur.archlinux.org/some-tool.git \
      && cd some-tool && makepkg -si --noconfirm --nocheck' \
 && rm -rf /tmp/aur /etc/sudoers.d/builder && userdel -r builder
```

## 分层

| 层 | 内容 | 改动频率 | 缓存代价 |
|---|---|---|---|
| L0 | `FROM archlinux:base-devel`（浮动，跟着上游走） | — | 全部 |
| L1 | 解 NoExtract + keyring + `-Syu` + 重装全部包 | 每次重建都可能变 | 全部 |
| L2 | distrobox 环境依赖（自包含） | 几乎不变 | L2 之后 |
| L3 | 语言运行时 `nodejs npm pnpm go python uv` | 半年 | L3 之后 |
| L4 | 核心 CLI `git tmux ripgrep fd fzf bat zoxide jq git-delta xclip` | 季度 | L4 之后 |
| L5 | AUR：`yay-bin`（makepkg 自举）+ `neovim-nightly-bin`（走 yay） | 半年 | 之后 |
| L6 | `mandb -q`（几秒，必须在所有 man 页之后） | 随时 | 之后 |
| L7 | 加料区 | 随时 | 只自己 |

规则只有一条：**越稳定的越靠里，新东西一律加在最外层**。L1 一定会脏（`-Syu` 跟随上游仓库），所以它必须最靠里且内容最少。

顺序不影响功能，只影响缓存：L2 的包和 L3/L4 没有依赖关系，把它放在前面纯粹因为它几乎永不改。`mandb` 单独一层是因为它必须在**所有** man 页装好之后跑（否则 `man -k`/`apropos` 会漏，`man 命令` 本身不受影响）。

## 几个不写注释就不明显的地方

- **每层都以 `rm -rf /var/cache/pacman/pkg/*` 结尾**：清理必须和安装同层，删在后续层里不会减小镜像。
- **L1 的 `pacman -S --noconfirm $(pacman -Qqn)`**：显式指定已装包名 = 重装，用来把被 NoExtract 跳过的 man/doc/locale 补回来。不带 `--needed`，带了就变成空操作。
- **官方 base 镜像没有 sync 数据库**（`/var/lib/pacman/sync` 为空），L1 的 `-Syu` 同时充当 `-Sy`，不要把它删掉或后移。
- **`pacman-key --init/--populate` 必须做**：官方镜像出于安全 strip 了 lsign key，不做的话装包验签/构建 AUR 会失败。
- **L2 那批包 distrobox-init 每次 `create` 也会装**：写死是为了镜像自包含，不随 distrobox 版本变化。
- **`yay-bin` 必须用 makepkg 自举**（还没有 yay 可用），其余 AUR 包交给 yay，这样 AUR 之间的依赖顺序也有人管。
- **`base-devel` 镜像已含 gcc/make/pkgconf/fakeroot/sudo/patch/texinfo**，不要重复装。
- **不用 `SHELL` 指令**：podman 默认 OCI 格式会忽略它（要生效得加 `--format docker`）。这里靠 `&&` 链和 `su -c 'set -e'` 保证失败即停。

## 已知冲突

- `neovim-nightly-bin` 与 `neovim-git` / `neovim` 互斥，只能装一个。
- 不要在容器里用 `fnm`/`nvm`：二进制会落到共享的 `~/.local/share/fnm`，跨发行版会坏，且与 pacman 的 node 语义打架。

## 环境变量（暂不启用）

`docker` 已包装成宿主机 docker（`dotfiles/zsh/.config/zsh/cli.zsh` 里的 `docker()` 函数，容器内走 `distrobox-host-exec`）。下面这些暂不加：

这些属于「容器内 shell」的职责，不进镜像。需要时加到 dotfiles 的容器分支（`[ -e /run/.containerenv ]`）：

```sh
export NPM_CONFIG_PREFIX="$HOME/.local/share/npm-devbox"   # npm i -g 不用 sudo
export PNPM_HOME="$HOME/.local/share/pnpm-devbox"
export PATH="$PNPM_HOME:$PATH"
```

## 多版本运行时

| 需求 | 做法 |
|---|---|
| Node LTS | 官方仓库自带 `nodejs-lts-jod`(22) / `nodejs-lts-krypton`(24)，与 `nodejs`(26) 可并存 |
| JDK | `jdk8/11/17/21/25` 并存，`archlinux-java set java-21-openjdk` 切换 |
| 旧版 Go / Python | 上游 tarball 解到 `/opt/go1.22` 之类；python 也可 `uv python install 3.12` |
| 整个系统回滚 | 把 `FROM` 换成旧的日期 tag（`base-devel-20261101.0.620205`）+ pacman 指向 `archive.archlinux.org` 快照，另建一个容器名并存 |
