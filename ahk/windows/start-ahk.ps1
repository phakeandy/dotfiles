# ============================================================================
#  start-ahk.ps1 —— dotfiles 里的 AHK 脚本的 Windows 侧启动器
#
#  做三件事：
#    1) 把 WSL 发行版叫起来（\\wsl.localhost 要 WSL 在跑才可用）
#    2) 把仓库 ahk/ 下的脚本同步到 %LOCALAPPDATA%\dotfiles-ahk（连不上就用上次的副本）
#    3) 启动 AutoHotkey 跑这些脚本（#SingleInstance Force 会自动替换旧实例）
#
#  由「启动」文件夹里的快捷方式在登录时调用；改完仓库里的脚本后，随时手工再跑一次
#  这个文件就能“重新同步 + 重启”。
#
#  注意：本文件必须存成 UTF-8 with BOM —— Windows PowerShell 5.1 没有 BOM 时会按
#  GBK 解码，中文会变成乱码甚至语法错误。
# ============================================================================

# ------------------------------- 配置 --------------------------------------
$Distro    = 'Debian'
$RepoAhk   = '\\wsl.localhost\Debian\home\andy\dotfiles\ahk'
$Scripts   = @('desktop-switch.ahk')                 # 要常驻的脚本（都在仓库 ahk/ 下）
$AhkExe    = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'
$LocalDir  = Join-Path $env:LOCALAPPDATA 'dotfiles-ahk'
# ---------------------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $LocalDir | Out-Null
$log = Join-Path $LocalDir 'start-ahk.log'
function Note($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg" | Add-Content $log -Encoding UTF8
}

# 1) 叫起 WSL（失败也不致命，后面有本地副本兜底）
try {
    Start-Process -FilePath 'wsl.exe' -ArgumentList '-d', $Distro, '-e', 'true' -WindowStyle Hidden -Wait -ErrorAction Stop
    Note "wsl -d $Distro 就绪"
} catch {
    Note "启动 WSL 失败: $($_.Exception.Message)"
}
for ($i = 0; $i -lt 40 -and -not (Test-Path $RepoAhk); $i++) { Start-Sleep -Milliseconds 500 }

# 2) 同步仓库 -> 本地
$synced = @()
if (Test-Path $RepoAhk) {
    foreach ($s in $Scripts) {
        $src = Join-Path $RepoAhk $s
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $LocalDir $s) -Force
            $synced += $s
        } else {
            Note "仓库里没有 $s"
        }
    }
} else {
    Note "连不上 $RepoAhk, 改用上次的本地副本"
}
if ($synced.Count -gt 0) { Note ("同步完成: " + ($synced -join ', ')) }
else                     { Note "同步完成: 无(用旧副本)" }

# 3) 启动（AutoHotkey 或脚本不在就记一笔并退出）
if (-not (Test-Path $AhkExe)) {
    Note "找不到 AutoHotkey: $AhkExe"
    exit 1
}
foreach ($s in $Scripts) {
    $path = Join-Path $LocalDir $s
    if (Test-Path $path) {
        Start-Process -FilePath $AhkExe -ArgumentList $path
        Note "已启动 $s"
    }
}
