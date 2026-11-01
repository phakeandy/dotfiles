# XFCE 相关配置

## `init.sh`

会话级别的 xfconf 设置（easy_click、面板只显示在外接 4K 屏、鼠标指针 36px 等）。

## IBus 候选框在 4K 屏上过小（HiDPI）

### 症状

外接 3840×2160（≈163 PPI）屏幕上，ibus 候选框的字小到几乎看不清；
`sans` 等系统字体调大也没用，`ibus-setup` 里勾选「Use custom font」并调到 72 也毫无变化。

### 原因（两项，缺一不可）

1. **整机是按 96 DPI 渲染的**：`Xft/DPI=96`，而两块屏是 ≈158 / ≈163 PPI。
   ibus 候选框由 `ibus-ui-gtk3` 进程用 GTK3 画，字号 13pt→17px，
   在 163 PPI 屏幕上物理尺寸只有「应有大小」的约 59%。X11 下 GTK 只有
   一个全局 DPI，没有每屏 HiDPI 缩放。

2. **这个版本的 panel 不认字体设置，只认 GDK 缩放**（实测，非猜测）：

   | 设置 | 结果（候选窗尺寸） |
   | --- | --- |
   | 默认（gtk-font-name 13pt） | `346x28` |
   | `use-custom-font=true` + `custom-font` 29 / 40 / 48pt | `346x28`（无变化） |
   | `custom-theme=Adwaita`（含 `ibus restart`） | 无变化 |
   | 全局 `gtk-font-name` 26pt + 重启 panel | `346x28`（无变化） |
   | panel 进程加 `GDK_DPI_SCALE=1.5` | `410x34`（有效） |
   | panel 进程加 `GDK_DPI_SCALE=1.7` | `441x38`（有效） |

   代码上 `use-custom-font` 应该生效（`ui/gtk3/bindingcommon.vala:set_custom_font()`
   会注入 `label { font-family: …; font-size: Npt }`，优先级 APPLICATION），
   但在这套 `ibus 1.5.32-2` + `GTK 3.24`（Debian）上实测无效。
   另外 panel 只在进程启动时确定字号，运行中改 XSETTINGS 不会重排候选窗
   —— 这也是「改了没反应」的一部分原因。

### 方案

只给 **panel 进程**加 `GDK_DPI_SCALE`，其它 GTK 程序不受影响：

- `bin/bin/ibus-panel-hidpi` —— 包一层，设 `IBUS_PANEL_SCALE`（默认 1.7）后 exec `ibus-ui-gtk3`
- `bin/bin/ibus-hidpi-start` —— 用 `ibus-daemon --panel=…` + `--replace` 替换 im-config 起的 daemon
- `xfce/ibus-hidpi.desktop` —— XFCE 登录自启项，内容是 `~/.config/autostart/` 的软链接

安装（换机器时）：

```sh
ln -sf ~/dotfiles/xfce/ibus-hidpi.desktop ~/.config/autostart/ibus-hidpi.desktop
~/bin/ibus-hidpi-start      # 立即生效；下次登录由自启项接管
```

调整大小：改 `bin/bin/ibus-panel-hidpi` 里的 `IBUS_PANEL_SCALE`（1.4 温和 / 1.7 适配 4K / 2.0 更大），
然后 `ibus restart`（`ibus restart` 会带原参数重起 daemon，wrapper 会保留）。

撤销：

```sh
rm ~/.config/autostart/ibus-hidpi.desktop
pkill -x ibus-ui-gtk3; ibus-daemon --daemonize --xim --replace
```

### 验证方法

不想靠肉眼时，可以直接读候选窗的真实尺寸（真实打字时它才会出现/重排）：

```sh
xwininfo -root -tree | grep -E 'ibus-ui-gtk3": \("ibus-ui-gtk3"' | grep -vE "10x10|1x1"
```

高度 28 ≈ 13pt；34 ≈ 1.5 倍；38 ≈ 1.7 倍。

### 备注

- 如果以后想放大**整个桌面**（不只输入法）：`xfconf-query -c xsettings -p /Xft/DPI -s 160`，
  代价是 1080p 那块屏也会一起变大。
- 两块屏 PPI 接近（158 / 163），所以单一缩放值对两块屏都算合适。
