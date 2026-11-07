#!/bin/bash
# 把一台新机器上的输入法宿主从 ibus 换成 fcitx5 + rime（rime 用户数据原样搬过去）。
# 前提：已 apt install fcitx5 fcitx5-rime fcitx5-frontend-{gtk3,gtk4,qt5}（缺了也能跑，只是部分程序走 XIM）
# 说明见同目录 README.md。可重复执行，不会覆盖已有的 rime 用户数据。
set -euo pipefail

DOTFILES=${DOTFILES:-$HOME/dotfiles}
RIME_SRC=$HOME/.config/ibus/rime          # 原来的 ibus-rime 用户目录（只读，不搬走不删除）
RIME_DST=$HOME/.local/share/fcitx5/rime   # fcitx5-rime 的用户目录
AUTOSTART=$HOME/.config/autostart

# 1. 配置进仓库：整目录软链（fcitx5 是 safe-save，单文件软链会被替换掉）
ln -sfn ../dotfiles/fcitx5/.config/fcitx5 "$HOME/.config/fcitx5"

mkdir -p "$AUTOSTART"
ln -sf "$DOTFILES/fcitx5/.config/autostart/fcitx5.desktop" "$AUTOSTART/fcitx5.desktop"

# 旧 ibus 的 HiDPI panel hack 已从仓库删除（见 xfce/README.md 的历史记录）：
# 这里只负责把还在跑的 ibus 停掉，让 XIM 只剩 fcitx 一个 server。
if pgrep -x ibus-daemon >/dev/null 2>&1; then
    ibus exit 2>/dev/null || true
    sleep 1
    echo "已停止 ibus-daemon（包保留，回退见 README）"
fi
if [ -e "$AUTOSTART/ibus-hidpi.desktop" ]; then
    mv "$AUTOSTART/ibus-hidpi.desktop" "$AUTOSTART/ibus-hidpi.desktop.disabled"
    echo "已停用旧的 ibus 自启项（→ .disabled）"
fi

# 2. rime 用户数据：复制而不是软链，两边同时写会抢 LOCK
if [ -d "$RIME_SRC" ] && [ ! -e "$RIME_DST/default.yaml" ]; then
    mkdir -p "$RIME_DST"
    tar -C "$RIME_SRC" --exclude=./build --exclude=LOCK -cf - . | tar -C "$RIME_DST" -xf -
    rm -f "$RIME_DST/LOCK"
    echo "rime 用户数据已复制到 $RIME_DST（$(du -sh "$RIME_DST" | cut -f1)）"
elif [ -e "$RIME_DST/default.yaml" ]; then
    echo "rime 用户数据已存在，跳过复制：$RIME_DST"
else
    echo "警告：$RIME_SRC 不存在，rime 会用自带方案启动"
fi

# 3. im-config 接管环境变量与登录启动（XMODIFIERS / GTK_IM_MODULE / QT_IM_MODULE + fcitx5 -d）
im-config -n fcitx5

# 4. 重启 daemon 让 profile / classicui.conf 生效（先停再起，避免配置被内存版本覆盖）
pkill -x fcitx5 2>/dev/null || true
sleep 1

# XIM server 名取自启动时的 XMODIFIERS（见 README「XIM server 叫什么名字」）：
# 从还没更新的旧终端里重启 fcitx5，会让它以 @server=ibus 注册 → wezterm 反而连不上。
# 所以清空属性 + 显式带环境变量启动，不赌调用者的环境。
xprop -root -remove XIM_SERVERS 2>/dev/null || true
setsid env XMODIFIERS=@im=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx \
    CLUTTER_IM_MODULE=xim SDL_IM_MODULE=fcitx fcitx5 -d >/dev/null 2>&1 || true
sleep 2

echo "--- 状态 ---"
echo "im-config: $(grep '^run_im' "$HOME/.xinputrc")"
echo "fcitx5:    $(pgrep -x fcitx5 >/dev/null && echo running || echo 'not running')"
echo "XIM:       $(xprop -root XIM_SERVERS 2>/dev/null | sed 's/^[^=]*= //')"
echo "IM:        $(fcitx5-remote -n 2>/dev/null || echo '（无焦点客户端时为空，正常）')"
echo
echo "下一步：注销重登，让当前会话里的 GTK/Qt 程序拿到新的环境变量。"
