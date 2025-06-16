#Requires AutoHotkey v2.0

; 获取当前激活窗口的输入法语言 ID (LOWORD)
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

; 切换输入法到指定语言 ID
SetInputLang(langID) {
    ; 0x50 = WM_INPUTLANGCHANGEREQUEST
    ; 0x1 = INPUTLANGCHANGE_SYSCHARSET
    PostMessage(0x50, 0x1, langID, , "A")
}

~Shift::
{
    ; 等待 Shift 键释放
    KeyWait("Shift")

    ; 检查当前是否是英语输入法 (1033)
    try {
        if (GetInputLangID() == 1033) {
            SetInputLang(2052) ; 切换到中文输入法
        }
    }
    return
}
