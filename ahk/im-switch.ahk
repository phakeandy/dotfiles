#Requires AutoHotkey v2.0
; 基于 AutoHotkey v2.0 的脚本
; 该脚本用于在 Vim 模式下处理 Esc 键 、Ctrl+[ 和 Ctrl+C 的行为
; 可以替代 im-select.exe 的功能
; 基于 AHK 提供的 Window Spy，读取输入法的颜色

GetInputLangID() {
    ; 获取当前激活窗口的线程 ID
    activeHwnd := WinExist("A")
    threadId := DllCall("GetWindowThreadProcessId", "UInt", activeHwnd, "Ptr", 0)

    ; 获取键盘布局句柄
    hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")

    ; 获取语言 ID (低位字)
    langID := hkl & 0xFFFF

    return langID
}

SetInputLang(langID) {
    ; 0x50 = WM_INPUTLANGCHANGEREQUEST
    ; 0x1 = INPUTLANGCHANGE_SYSCHARSET
    PostMessage(0x50, 0x1, langID, , "A")
}

; 获取坐标的模式，相对于屏幕
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; Screen:	2628, 1880
; Window:	1448, 1659
; Client:	1435, 1601 (default)
; Color:	111111 (Red=11 Green=11 Blue=11)
VimEsc(mode := "") {
    if (GetInputLangID() == 2052 && PixelGetColor(2628, 1880) = "0x111111") {
        ; if (GetInputLangID() == 2052) {
        if (mode == "Ctrl_C") {
            ; Ctrl+C 的特殊处理
            Send "{Ctrl Down}c{Ctrl Up}"
        } else if (mode == "Ctrl_[") {
            ; Ctrl+[ 的特殊处理
            Send "^{[}"
        }
        Send "{Shift}" ; Shift 切换输入法的中英文
        ; SetInputLang(1033)

    }
    Send "{Esc}"
}

EscChangeIM() {
    ; 首先禁用ESC热键，避免递归
    Hotkey "ESC", "Off"

    ; 执行输入法切换
    if (GetInputLangID() == 2052) {
        SetInputLang(1033)
    }

    ; 发送Esc键
    Send "{Esc}"

    ; 重新启用ESC热键
    Hotkey "ESC", "On"
}

ESC:: EscChangeIM()

; 应用vim模式的窗口组
GroupAdd "VimMode", "ahk_exe WindowsTerminal.exe"
GroupAdd "VimMode", "ahk_exe Code.exe"
GroupAdd "VimMode", "ahk_exe Obsidian.exe"

#HotIf WinActive("ahk_group VimMode")
; ESC:: VimEsc()
; ^c:: VimEsc("Ctrl_C")
; ^[:: VimEsc("Ctrl_[")
#HotIf