# Fcitx5 + Rime（雾凇 / 小鹤双拼）

从 ibus 换成 fcitx5 之后，**输入法本身（rime 方案、词库、用户词频、vim_mode）一个字节都没改**，
所有改动只发生在「谁来做 IM 宿主」这一层。

## 为什么换（动机，不是审美）

原来的问题是 wezterm 里中文时好时坏。定位到的根因：

- wezterm 在 X11 下只能用 XIM（`window::os::x11::connection`），没有别的选择；
- ibus 的 XIM server 是**独立进程 `ibus-x11`**（`/usr/libexec/ibus-x11`），它会自己死掉，
  死了之后 wezterm 的输入连接就断了 —— 现象是「打出拼音，候选框不出」；
- ibus 面板的 HiDPI 还得靠 `GDK_DPI_SCALE` 包一层（见 `../xfce/README.md` 里的历史记录）。

fcitx5 把 XIM 做成 **daemon 内的 addon**（`libclassicui.so` 旁边那套 addon），
不存在「一个独立进程悄悄死掉」这个环节，所以是**结构上**去掉了那个失败模式，而不是靠运气。

`ibus` 未卸载，但 daemon 已退出、旧自启项已删、`~/.xinputrc` 已改成 fcitx5；回退步骤见文末。

## 目录与安装

```
fcitx5/.config/fcitx5/profile                       # 输入法组：rime 排第一
fcitx5/.config/fcitx5/conf/classicui.conf           # 候选框字号（旧 ibus hack 的等价物）
fcitx5/.config/autostart/fcitx5.desktop             # 登录自启（兜底，主路径是 im-config）
fcitx5/init.sh                                      # 新机器一键装好（下面说明）
```

`~/.config/fcitx5` **整个目录**软链接进仓库（跟 `foot` / `git` / `tmux` 一样的做法）：

```sh
ln -sfn ../dotfiles/fcitx5/.config/fcitx5 ~/.config/fcitx5
ln -sf ~/dotfiles/fcitx5/.config/autostart/fcitx5.desktop ~/.config/autostart/fcitx5.desktop
```

> 为什么是整目录软链、不是单文件软链：fcitx5 保存配置用的是「写临时文件再 rename」的
> safe-save，单文件软链在第一次从 `fcitx5-configtool` 改设置时就会被替换成普通文件，
> 仓库里的版本就悄悄失效了。
>
> 副作用：运行时生成的东西也会落在仓库目录里，已用 `.gitignore` 排除
> （`conf/cached_layouts`、`conf/notifications.conf` 等；`conf/*` 只放行 `classicui.conf`）。

## 关键配置（三条，缺一不可）

### 1. `profile` —— rime 是组内第一个

```ini
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=rime          # 第一位 = 新窗口/新焦点默认拿到的 IM
[Groups/0/Items/1]
Name=keyboard-us
```

坑：**必须在 fcitx5 停止时改 profile**。fcitx5 运行时改，它退出/重载时会把内存里的版本写回去，
你的改动直接被吞（排查时踩过：写进去的 `Name=rime` 被改写成只剩 `keyboard-us`）。

### 2. `conf/classicui.conf` —— 候选框字号

```ini
Font="Noto Sans CJK SC 22"        # 候选框；22 ≈ 旧 ibus 的 13pt × GDK_DPI_SCALE 1.7
MenuFont="Noto Sans CJK SC 18"    # 托盘 / 右键菜单
Theme=default
UseDarkTheme=False                # 桌面用浅色，候选框跟着浅色
VerticalCandidateList=False       # 横排候选（跟旧 ibus 候选条一致），想要竖排改 True
WheelForPaging=True               # 滚轮翻页
```

这是旧 ibus hack（`GDK_DPI_SCALE=1.7` 包一层 panel，实现已删，见 git 历史）的**等价物**，
但干净得多：直接给字号，不用给 panel 进程套一层缩放。改完 `fcitx5 -r -d` 立刻生效。

### 3. `im-config` —— 环境变量和登录启动

```sh
im-config -n fcitx5          # 写 ~/.xinputrc: run_im fcitx5
```

`/etc/X11/Xsession.d/70im-config_launch` 会读 `~/.xinputrc`，由
`/usr/share/im-config/data/23_fcitx5.rc` 做两件事：

| 阶段 | 动作 |
| --- | --- |
| phase 1 | `XMODIFIERS=@im=fcitx`、`GTK_IM_MODULE=fcitx`、`QT_IM_MODULE=fcitx`、`CLUTTER_IM_MODULE=xim`、`SDL_IM_MODULE=fcitx` |
| phase 2 | `/usr/bin/fcitx5 -d` |

所以 **wezterm / ghostty / 其它 GUI 程序都不用单独配置**：wezterm（X11）读 `XMODIFIERS` 去连
`@server=fcitx`，GTK 程序走 `gtk-im-module`。`autostart/fcitx5.desktop` 只是兜底
（万一某台机器的 Xsession.d 没跑到），`fcitx5 -d` 已是单实例，重复启动无害。

### Rime 用户数据的位置

```
~/.config/ibus/rime           →  ~/.local/share/fcitx5/rime
```

**复制，不是软链**：两边的 rime 都会往用户目录里写 `LOCK` / `*.userdb`，
共享同一个目录会互相抢锁（会导致部署失败、候选不出）。代价是词频/用户词**从切换那天起各记各的**，
所以 ibus 那份原封不动留在原地，想回退时还在。

排除项：`build/`（可重建的编译缓存）、`LOCK`。当前副本 ≈ 124M，主要是 `cn_dicts` 和 `*.userdb`。

## 验证方法（不靠肉眼）

```sh
fcitx5-remote -n                  # 当前 IM，应该是 rime
xprop -root XIM_SERVERS           # 应该有 @server=fcitx
pgrep -a fcitx5                   # daemon 在跑

# 端到端：让 wezterm 把收到的字符写进文件，再读它
XMODIFIERS=@im=fcitx wezterm-gui start --always-new-process --cwd /tmp \
  -e bash -c 'cat > /tmp/typed.txt'
# 在该窗口里打几个字，然后 cat /tmp/typed.txt
```

`--always-new-process` 是必须的：否则 `wezterm-gui start` 会复用已经在跑的 GUI 进程，
而那个进程的环境变量还是旧的 `XMODIFIERS`（排查时被这一点骗过一次）。

想确认 XIM 握手是否真的连上了 fcitx：

```sh
WEZTERM_LOG='window::os::x11::connection=debug' wezterm-gui start --always-new-process
# 日志应出现 XIM_ENCODING_NEGOTIATION_REPLY → XIM_CREATE_IC_REPLY → XIM_FORWARD_EVENT
# 若是 `Ime: try_open_ic timed out, retrying` → 见下面「XIM server 叫什么名字」
```

### XIM server 叫什么名字（最容易踩的一个坑）

XIM 的握手靠 X root window 上的 `XIM_SERVERS` 属性，客户端（wezterm）拿 `XMODIFIERS=@im=fcitx`
去匹配同名 server。而 **fcitx5 的 XIM server 名不是写死的，它取自启动时环境里的 `XMODIFIERS`**
（没设就用默认的 `fcitx`）。实测：

| fcitx5 启动时的 `XMODIFIERS` | 注册出来的 XIM server | wezterm（@im=fcitx）能否连上 |
| --- | --- | --- |
| 未设置 / `@im=fcitx` | `@server=fcitx` | ✅ |
| `@im=ibus`（旧会话里重启 fcitx5） | `@server=ibus` | ❌ `try_open_ic timed out` |

所以「候选框不出、按键当英文走」的真实机理是：**fcitx5 被一个还带着 `@im=ibus` 的环境启动，
于是它冒充成了 ibus**，wezterm 找不到叫 `fcitx` 的 server。不是候选框坏了，也不是 fcitx 不稳。

排查三步：

```sh
xprop -root XIM_SERVERS                          # 期望 @server=fcitx
P=$(pgrep -x fcitx5); tr '\0' '\n' < /proc/$P/environ | grep XMODIFIERS   # 期望 @im=fcitx
echo "$XMODIFIERS"                               # 你所在的 shell 也可能是旧值
```

修法（`init.sh` 里就是这么做的：显式带环境变量启动，不赌调用者的环境）：

```sh
xprop -root -remove XIM_SERVERS
pkill -x fcitx5; sleep 1
setsid env XMODIFIERS=@im=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx CLUTTER_IM_MODULE=xim \
    fcitx5 -d &
# 之后 `xprop -root XIM_SERVERS` 应当正好是 @server=fcitx
```

推论：**不要在改动之前的旧终端里手动 `fcitx5 -r`**。正常路径（登录时 im-config 先导环境变量、
再 `fcitx5 -d`）永远是对的，因为它拿到的就是 `@im=fcitx`。

## 需要留意的地方

- 候选框字体对**新起的** fcitx5 生效，改完 `fcitx5 -r -d`。
- 候选框是横排（`VerticalCandidateList=False`）；若改 True 需重启。
- XFCE 面板要看到输入法图标，需要「状态托盘（Status Tray）」插件；没有图标不影响打字。
- rime 的 schema 是 `double_pinyin_flypy`（小鹤），`default.yaml` 里其它方案已注释掉 —— 这是原文
  件，没动。
- `wezterm` 配置里**不要**写死 `xim_im_name`，靠 `XMODIFIERS` 更通用（同一份配置还要在 Windows 用）。

## 新机器 / 重装

```sh
sudo apt install fcitx5 fcitx5-rime fcitx5-config-qt \
     fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5
bash ~/dotfiles/fcitx5/init.sh      # 建软链、搬 rime、切 im-config、停 ibus、重启 fcitx5
# 然后注销重登（让会话里的 GTK/Qt 程序拿到新环境变量）
```

## 回退到 ibus

```sh
im-config -n ibus                 # 改写 ~/.xinputrc，重登后由 im-config 自己起 ibus
xprop -root -remove XIM_SERVERS   # 清掉 fcitx 的条目，避免 wezterm 连到已停的 server
# 注销重登；rime 的 ibus 配置（~/.config/ibus/rime）从未被改动，词频/用户词都还在
```

注意：ibus 时代的 HiDPI 候选框 hack（`GDK_DPI_SCALE` 包一层 `ibus-ui-gtk3`）已随这次切换删除，
回退后候选框会变小；需要的话从 git 历史里把 `xfce/ibus-hidpi*` 拿回来（说明见
[../xfce/README.md](../xfce/README.md)）。

## 从 ibus 迁移时踩到的坑（留给下一次的自己）

1. **写 profile 时 fcitx5 必须停着**，否则被内存版本覆盖。
2. rime addon 是 `OnDemand` 的：profile 里写了 `Name=rime`、但当时 addon 没加载，
   fcitx5 就会把这一项丢掉；先停 daemon 再写 profile 就能正常加载（日志里有 `Loaded addon rime`）。
3. `fcitx5-remote` 的状态（`1`/`2`）和 `-n` 的 IM 名，在**没有 fcitx 客户端焦点**时没有参考意义
   —— 从普通 shell 里查到的值会和实际打字行为不一致。
4. XIM server 名 = 启动 fcitx5 时的 `XMODIFIERS`。在还没更新的旧会话里重启 fcitx5，它就会以
   `@server=ibus` 注册，wezterm 反而连不上。所以重启 fcitx5 要显式带环境变量（见上）。
