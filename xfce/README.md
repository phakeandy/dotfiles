# XFCE 相关配置

## `init.sh`

会话级别的 xfconf 设置（easy_click、面板只显示在外接 4K 屏、鼠标指针 36px 等）。

## 历史：ibus 候选框在 4K 屏上过小（HiDPI）—— 已随换用 fcitx5 移除

> 2026-11 输入法整体换成 fcitx5 + rime，候选框字号改成在
> `fcitx5/.config/fcitx5/conf/classicui.conf` 里直接写 `Font="Noto Sans CJK SC 22"`，
> 不再需要给 panel 进程套 `GDK_DPI_SCALE`。原实现（`bin/bin/ibus-hidpi-start`、
> `bin/bin/ibus-panel-hidpi`、`xfce/ibus-hidpi.desktop`）已删除，动机与迁移过程见
> [../fcitx5/README.md](../fcitx5/README.md)。下面是当时的结论，留着备用。

### 结论（当时实测）

- 整机按 96 DPI 渲染（`Xft/DPI=96`），两块屏实际 ≈158 / ≈163 PPI。X11 下 GTK 只有一个全局
  DPI，没有每屏 HiDPI 缩放，所以 13pt 的候选框在 4K 屏上只有「应有大小」的约 59%。
- 这个版本的 panel **不认字体设置，只认 GDK 缩放**：

  | 设置 | 候选窗尺寸 |
  | --- | --- |
  | 默认（gtk-font-name 13pt） | `346x28` |
  | `use-custom-font=true` + custom-font 29 / 40 / 48pt | `346x28`（无变化） |
  | `custom-theme=Adwaita`（含 `ibus restart`） | 无变化 |
  | 全局 `gtk-font-name` 26pt + 重启 panel | `346x28`（无变化） |
  | panel 进程加 `GDK_DPI_SCALE=1.5` | `410x34` |
  | panel 进程加 `GDK_DPI_SCALE=1.7` | `441x38` |

  代码上 `use-custom-font` 应该生效（`ui/gtk3/bindingcommon.vala:set_custom_font()` 注入
  `label { font-family: …; font-size: Npt }`，优先级 APPLICATION），但在这套
  `ibus 1.5.32-2` + `GTK 3.24`（Debian）上实测无效；另外 panel 只在进程启动时确定字号，
  运行中改 XSETTINGS 不会重排候选窗 —— 这也是「改了没反应」的一部分原因。
- 测量方法：`xwininfo -root -tree | grep ibus-ui-gtk3`，高度 28 ≈ 13pt / 34 ≈ 1.5 倍 / 38 ≈ 1.7 倍。

### 真要回 ibus 的话

```sh
im-config -n ibus    # 重登
xprop -root -remove XIM_SERVERS   # 免得 fcitx 时代残留的 server 名干扰 wezterm
```

候选框字号得重新做一遍（历史实现见 git 历史里的 `xfce/ibus-hidpi*`：包一层
`GDK_DPI_SCALE=1.7` 的 `ibus-ui-gtk3`，再用 `ibus-daemon --panel=…` 替换默认 daemon）。

- 想放大**整个桌面**（不只输入法）：`xfconf-query -c xsettings -p /Xft/DPI -s 160`，
  代价是 1080p 那块屏也会一起变大。
- 两块屏 PPI 接近（158 / 163），所以单一缩放值对两块屏都算合适。
