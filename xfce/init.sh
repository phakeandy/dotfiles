#!/bin/bash

xfconf-query -c xfwm4 -p /general/easy_click -s Super

# 鼠标指针放大（Adwaita 提供的尺寸：24/30/36/48/72/96）
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s Adwaita
xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s 36

# xfconf-query -c xfwm4 -p /general/easy_click -s Shift # super 键有 bug：https://forum.xfce.org/viewtopic.php?id=12932&utm_source=chatgpt.com
