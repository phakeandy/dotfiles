#Requires AutoHotkey v2.0
#SingleInstance Force
; ============================================================================
;  desktop-switch.ahk —— Ctrl+Alt+1..9 直接跳到第 N 个虚拟桌面
;
;  实现思路：
;    Windows 没有公开“切到第 N 个桌面”的接口，只有“上一个/下一个”，所以本脚本
;    读注册表拿到桌面顺序和当前桌面，按差值只发最少的 Win+Ctrl+←/→ ——
;    因此无论跨几个桌面，都只闪一次切换动画。
;    发完校验一次（注册表 200ms 内就更新），万一按键被吞就重算差值补一次。
;
;  注册表位置（HKCU\...\Explorer\VirtualDesktops）：
;    VirtualDesktopIDs      每个桌面一个 16 字节 GUID，按从左到右排列
;    CurrentVirtualDesktop  当前桌面的 GUID
;
;  平台：Windows 10 / 11（Windows 11 25H2 build 26200 实测通过）
;  依赖：AutoHotkey v2      winget install AutoHotkey.AutoHotkey
;  启动：AutoHotkey64.exe desktop-switch.ahk     （常驻，无窗口）
; ============================================================================

; --------------------------------- 配置 ------------------------------------
MODS       := "^!"   ; 修饰键： ^=Ctrl  !=Alt  +=Shift  #=Win   （Ctrl+Alt 默认）
COUNT      := 9      ; 注册 Ctrl+Alt+1 .. Ctrl+Alt+9
STEP_DELAY := 45     ; 相邻两次 Win+Ctrl+←/→ 之间的间隔(ms)，太短会丢键
DEBUG      := false  ; true = 额外注册 Ctrl+Alt+F12 显示诊断信息
; ---------------------------------------------------------------------------

VD_KEY := "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"

Loop COUNT
    Hotkey(Format("{}{}", MODS, A_Index), SwitchToDesktop.Bind(A_Index))
if DEBUG
    Hotkey(Format("{}F12", MODS), ShowDesktopInfo)

; ------------------------------- 主流程 ------------------------------------

; 切到第 n 个虚拟桌面（n 从 1 开始）；多余参数用于接收热键名
SwitchToDesktop(n, *) {
    ids := GetDesktopIDs()
    if (!ids.Length)                     ; 读不到桌面列表 → 不依赖状态，纯按键兜底
        return WalkToDesktop(n)
    if (n > ids.Length)                  ; 目标桌面还不存在：什么都不做
        return
    idx := IndexOfID(ids, GetCurrentDesktopID())
    if (!idx)                            ; 读不到当前位置 → 纯按键兜底
        return WalkToDesktop(n)
    if (idx != n)
        StepTo(n - idx)
    if (!WaitForDesktop(ids[n], 800)) {  ; 校验：没到位就重算差值补一次
        ids := GetDesktopIDs()
        idx := IndexOfID(ids, GetCurrentDesktopID())
        if (idx && idx != n)
            StepTo(n - idx)
    }
}

; 按差值发按键：正数往右，负数往左
StepTo(delta) {
    SendDesktopKey(delta > 0 ? "Right" : "Left", Abs(delta))
}

; 兜底：不看状态，先按足够多次 Win+Ctrl+← 回到最左，再往右数 n-1 次
WalkToDesktop(n) {
    static BLIND_MAX := 16               ; 读不到状态时盲走的次数（桌面多于 16 个请调大）
    SendDesktopKey("Left", BLIND_MAX)
    SendDesktopKey("Right", n - 1)
}

SendDesktopKey(dir, count := 1) {
    static KEYS := Map("Left", "#^{Left}", "Right", "#^{Right}")
    SetKeyDelay(20, 20)
    Loop count {
        SendEvent(KEYS[dir])
        Sleep(STEP_DELAY)
    }
}

; ------------------------------- 状态读取 ----------------------------------

; 桌面顺序：数组，每个元素是 32 位十六进制 GUID（注册表里的原始字节序）
GetDesktopIDs() {
    ids := []
    raw := ReadHexValue(VD_KEY, "VirtualDesktopIDs")
    Loop StrLen(raw) // 32
        ids.Push(SubStr(raw, (A_Index - 1) * 32 + 1, 32))
    return ids
}

; 当前桌面 GUID（AHK v2 读 REG_BINARY 得到的是十六进制字符串）
GetCurrentDesktopID() => ReadHexValue(VD_KEY, "CurrentVirtualDesktop")

ReadHexValue(key, name) {
    try
        return RegRead(key, name, "")
    catch
        return ""
}

IndexOfID(ids, id) {
    if (id = "")
        return 0
    Loop ids.Length
        if (ids[A_Index] = id)
            return A_Index
    return 0
}

; 等切换真正生效（最长 timeout 毫秒）
WaitForDesktop(id, timeout) {
    endTick := A_TickCount + timeout
    Loop {
        if (GetCurrentDesktopID() = id)
            return true
        if (A_TickCount > endTick)
            return false
        Sleep(25)
    }
}

; ------------------------------- 诊断 --------------------------------------

ShowDesktopInfo(*) {
    ids := GetDesktopIDs()
    cur := GetCurrentDesktopID()
    txt := "桌面总数：" ids.Length
    txt .= "`n当前是第 " IndexOfID(ids, cur) " 个"
    txt .= "`n当前 GUID：" (cur = "" ? "(读不到)" : cur)
    ToolTip(txt, 20, 20)
    SetTimer(() => ToolTip(), -5000)
}
