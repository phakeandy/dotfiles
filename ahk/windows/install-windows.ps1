# ============================================================================
#  install-windows.ps1 —— 在 Windows 侧把 dotfiles 的 AHK 脚本装成开机自启
#
#  做四件事（可重复运行，幂等）：
#    1) 建 %LOCALAPPDATA%\dotfiles-ahk，放入启动器 start-ahk.ps1
#    2) 在「启动」文件夹建快捷方式，登录时自动跑启动器
#    3) 在开始菜单建一个「Reload AHK (dotfiles)」快捷方式，改完仓库脚本点一下即可
#    4) 立刻跑一次启动器，本次登录就生效
#
#  用法：powershell -ExecutionPolicy Bypass -File install-windows.ps1
#
#  注意：本文件必须存成 UTF-8 with BOM（Windows PowerShell 5.1 没 BOM 会按 GBK 解码）。
#        快捷方式文件名一律用 ASCII，避免编码来回折腾。
# ============================================================================

$RepoAhk  = '\\wsl.localhost\Debian\home\andy\dotfiles\ahk'
$RepoWin  = Join-Path $RepoAhk 'windows'
$LocalDir = Join-Path $env:LOCALAPPDATA 'dotfiles-ahk'
$Launcher = Join-Path $LocalDir 'start-ahk.ps1'
$psExe    = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$psArgs   = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$Launcher`""

New-Item -ItemType Directory -Force -Path $LocalDir | Out-Null
Copy-Item (Join-Path $RepoWin 'start-ahk.ps1') $Launcher -Force
Write-Host "launcher  -> $Launcher"

$shell = New-Object -ComObject WScript.Shell

function New-AhkShortcut($path, $description) {
    try {
        $sc = $shell.CreateShortcut($path)
        $sc.TargetPath       = $psExe
        $sc.Arguments        = $psArgs
        $sc.WorkingDirectory = $LocalDir
        $sc.Description      = $description
        $sc.Save()
        Write-Host "shortcut  -> $path"
    } catch {
        Write-Warning "建快捷方式失败: $path -- $($_.Exception.Message)"
    }
}

# 登录自启
New-AhkShortcut (Join-Path ([Environment]::GetFolderPath('Startup')) 'dotfiles-ahk.lnk') `
    '登录时同步并启动 dotfiles 里的 AHK 脚本'

# 开始菜单：手工重新同步 + 重启
New-AhkShortcut (Join-Path ([Environment]::GetFolderPath('Programs')) 'Reload AHK (dotfiles).lnk') `
    '同步 dotfiles 里的 AHK 脚本并重启'

# 立刻生效
& $psExe -NoProfile -ExecutionPolicy Bypass -File $Launcher
Write-Host "已执行一次启动器"
