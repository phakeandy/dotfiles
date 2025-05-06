; 需要安装 AutoHotKey v1 `scoop install extras/autohotkey`

; ================
; vim-like 按键映射
; ================
;
; Alt + hjkl map to + Arrow key

!h::Send, {Left}   ; Alt+H -> 左箭头
!j::Send, {Down}   ; Alt+J -> 下箭头
!k::Send, {Up}     ; Alt+K -> 上箭头
!l::Send, {Right}  ; Alt+L -> 右箭头

+!h::Send, ^{Left}   ; Alt+Shift+H -> Ctrl+左箭头
+!l::Send, ^{Right}  ; Alt+Shift+L -> Ctrl+右箭头

