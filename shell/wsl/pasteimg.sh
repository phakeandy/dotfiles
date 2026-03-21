#!/bin/bash

# 从 Windows 剪贴板粘贴图片到当前 WSL 目录
# 如果没有指定文件名，则自动使用时间戳命名
filename="${1:-image_$(date +%Y%m%d_%H%M%S).png}"
wsl_path="$PWD/$filename"


# 将 WSL 路径转换为 Windows 能够识别的 UNC 路径 (\\wsl.localhost\...)
win_path=$(wslpath -w "$wsl_path")

# 调用 PowerShell 提取剪贴板图片并保存为 PNG 格式
powershell.exe -STA -NoProfile -Command "
    Add-Type -AssemblyName System.Windows.Forms;
    Add-Type -AssemblyName System.Drawing;
    \$img = [System.Windows.Forms.Clipboard]::GetImage();
    if (\$img -ne \$null) {
        \$img.Save('$win_path', [System.Drawing.Imaging.ImageFormat]::Png);

        Write-Host '$wsl_path';
    } else {
        Write-Host 'Error: No image found in Windows clipboard!';
    }
"
