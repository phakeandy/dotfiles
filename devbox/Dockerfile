FROM docker.io/library/archlinux:base-devel

LABEL org.opencontainers.image.title="devbox" \
      org.opencontainers.image.description="Arch CLI devbox for distrobox"

# 官方镜像用 NoExtract 裁掉了 man/locale，必须重装全部包才会解出来
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    sed -i '1i Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist \
    && sed -i "s|NoExtract.*||g" /etc/pacman.conf \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    && pacman -Syu --noconfirm \
    && pacman -S --noconfirm $(pacman -Qqn) \
    && rm -rf /var/cache/pacman/pkg/* /tmp/*

RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -S --needed --noconfirm \
        openssh less man-db man-pages rsync tree unzip zip wget curl lsof bc \
        nodejs npm pnpm go gopls python uv \
        git tmux ripgrep fd fzf bat zoxide jq git-delta xclip direnv delve

RUN <<'EOF'
set -eu

# makepkg cannot run as root
useradd -m -s /bin/bash builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder

install -d -o builder -g builder /tmp/aur
su builder -c 'set -e; cd /tmp/aur \
  && git clone --depth 1 https://aur.archlinux.org/yay-bin.git \
  && cd yay-bin && makepkg -si --noconfirm --nocheck'

su builder -c 'yay -S --noconfirm --answerclean None --answerdiff None --removemake sesh-bin neovim-nightly-bin'

rm -rf /tmp/aur /etc/sudoers.d/builder
userdel -r builder 2>/dev/null || true
rm -rf /var/cache/pacman/pkg/*
EOF

# mandb 必须在所有 man 页装完之后跑
RUN mandb -q

RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# RUN pacman -S --needed --noconfirm <pkg...> && rm -rf /var/cache/pacman/pkg/*
