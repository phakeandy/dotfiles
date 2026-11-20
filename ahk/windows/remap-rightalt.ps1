# ============================================================================
#  remap-rightalt.ps1 —— 把「右 Alt」映射成「右 Ctrl」（改注册表 Scancode Map）
#
#  为什么不用 AHK：AHK 的重映射是在用户态拦截按键，对管理员权限的窗口、部分游戏、
#  远程桌面不生效；而 Scancode Map 是键盘驱动层把物理扫描码换掉，系统只看到新的键，
#  所以一切程序/一切会话都一致生效，且不占任何后台进程。
#
#  用法（需要管理员）：
#    powershell -ExecutionPolicy Bypass -File remap-rightalt.ps1       # 应用：右Alt -> 右Ctrl
#    powershell -ExecutionPolicy Bypass -File remap-rightalt.ps1 -Remove   # 撤销，恢复右Alt
#    powershell -ExecutionPolicy Bypass -File remap-rightalt.ps1 -Status   # 只看当前值
#
#  生效时间：需要重启（登录/注销不够，键盘布局在开机时加载）。
#
#  二进制格式（MS 文档里的 Scancode Map）：
#    8 字节 版本+标志（全 0）
#    4 字节 条目数，含结尾的 0 项  -> 这里 1 条映射 + 结尾 = 2
#    每项 4 字节 DWORD：低 16 位=目标扫描码，高 16 位=源扫描码
#      右 Alt  = 0xE038   右 Ctrl = 0xE01D
#      -> DWORD 0xE038E01D，小端字节序：1D E0 38 E0
#    4 字节 0 结尾
#
#  注意：本文件必须存成 UTF-8 with BOM —— Windows PowerShell 5.1 没有 BOM 时会按
#  GBK 解码，中文会变成乱码甚至语法错误。
# ============================================================================

param(
    [switch]$Remove,
    [switch]$Status
)

$KeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$ValName = 'Scancode Map'

function Get-Map {
    (Get-ItemProperty -Path $KeyPath -Name $ValName -ErrorAction SilentlyContinue).$ValName
}

function Show-Map {
    $cur = Get-Map
    if ($null -eq $cur) {
        Write-Host "当前: (没有 Scancode Map —— 键盘是原生映射)"
    } else {
        Write-Host ("当前: " + (($cur | ForEach-Object { $_.ToString('X2') }) -join ' '))
    }
}

if ($Status) {
    Show-Map
    exit 0
}

# 下面两个操作都要写 HKLM
$isAdmin = (New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning '需要管理员权限：请用「以管理员身份运行」打开 PowerShell 再执行。'
    exit 1
}

Show-Map

if ($Remove) {
    if ($null -eq (Get-Map)) {
        Write-Host '本来就没有 Scancode Map，无需撤销。'
        exit 0
    }
    Remove-ItemProperty -Path $KeyPath -Name $ValName -Force
    Write-Host '已删除 Scancode Map：重启后右 Alt 恢复原样。'
    exit 0
}

# 右 Alt(0xE038) -> 右 Ctrl(0xE01D)
$bytes = [byte[]]@(
    0x00, 0x00, 0x00, 0x00,          # 版本 + 标志
    0x00, 0x00, 0x00, 0x00,
    0x02, 0x00, 0x00, 0x00,          # 条目数 = 1 条 + 结尾
    0x1D, 0xE0,                      # 目标扫描码 = 0xE01D 右 Ctrl
    0x38, 0xE0,                      # 源扫描码   = 0xE038 右 Alt
    0x00, 0x00, 0x00, 0x00           # 结尾
)

New-ItemProperty -Path $KeyPath -Name $ValName -PropertyType Binary -Value $bytes -Force | Out-Null

Show-Map
Write-Host '已写入：右 Alt -> 右 Ctrl。重启后生效。'
