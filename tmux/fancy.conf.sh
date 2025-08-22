#############################################################
###                  基础配置 (Basic Settings)             ###
#############################################################

# 鼠标支持配置
set -g mouse on                  # 启用鼠标交互
set -sg escape-time 10           # 减少模式切换延迟(单位毫秒)

# 剪贴板集成
set -s set-clipboard on          # 支持现代终端剪贴板
set -g allow-passthrough on      # 允许终端直通序列(用于图像预览等)

# 终端兼容性设置
# set -g default-terminal "tmux-256color"
# set -ga terminal-overrides 'xterm*:smcup@:rmcup@'  # 兼容老旧终端
set-option -a terminal-features 'xterm-256color:RGB'


#############################################################
###                  会话管理 (Session Management)         ###
#############################################################

# 窗口编号从1开始 (更符合日常习惯)
set -g base-index 1              # 窗口起始编号
set -g pane-base-index 1         # 窗格起始编号
set -g renumber-windows on       # 自动重排窗口编号

# 新窗口/窗格在当前路径打开
bind c new-window -c "#{pane_current_path}"        # 创建新窗口
bind '"' split-window -c "#{pane_current_path}"    # 垂直分割
bind % split-window -h -c "#{pane_current_path}"  # 水平分割


#############################################################
###                  快捷键配置 (Key Bindings)             ###
#############################################################

# 重载配置快捷键 (前缀 + r)
unbind r
bind r source-file ~/.tmux.conf \; display "配置已重载!"

# Vim式窗格导航
#unbind-key j; unbind-key k; unbind-key l; unbind-key h
#bind-key h select-pane -L  # 向左移动
#bind-key j select-pane -D  # 向下移动
#bind-key k select-pane -U  # 向上移动
#bind-key l select-pane -R  # 向右移动

# 模式键位设置
set-window-option -g mode-keys vi        # 复制模式使用vim键位

# 弹窗窗口管理 (前缀 + g)
bind-key g if-shell -F '#{==:#{session_name},popup}' {
    detach-client
} {
    display-popup -d "#{pane_current_path}" -xC -yC -w60% -h70% -E \
    'tmux new -s popup && tmux kill-session -t popup || true'
}

# 状态栏显隐切换 (前缀 + b)
bind b run-shell "tmux setw -g status \$(tmux show -g -w status | grep -q off && echo on || echo off)"


#############################################################
###                  插件管理 (Plugin Management)          ###
#############################################################

# 插件列表 (使用 TPM 管理)
set -g @plugin 'tmux-plugins/tpm'               # 插件管理器
set -g @plugin 'tmux-plugins/tmux-sensible'     # 合理默认配置
set -g @plugin 'tmux-plugins/tmux-resurrect'    # 会话持久化
set -g @plugin 'tmux-plugins/tmux-yank'         # 剪贴板集成
set -g @plugin 'catppuccin/tmux'                # 主题皮肤

# tmux-resurrect 配置
set -g @resurrect-save 'S'          # 手动保存快捷键: 前缀 + S
set -g @resurrect-auto 'on'         # 启用自动保存


#############################################################
###                  主题定制 (Theme Customization)        ###
#############################################################

set -g @catppuccin_flavor "mocha"
set -g @catppuccin_window_status_style "rounded"

#roundedset -g @catppuccin_pane_default_text "##{b:pane_current_path}"
#roundedset -g @catppuccin_window_default_text "#W"
set -g @catppuccin_window_default_text " #W"
set -g @catppuccin_window_current_text " #W"
set -g @catppuccin_window_text " #W"

set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g status-right "#{E:@catppuccin_status_application}"
set -agF status-right "#{E:@catppuccin_status_cpu}"
set -ag status-right "#{E:@catppuccin_status_session}"
set -ag status-right "#{E:@catppuccin_status_uptime}"
set -agF status-right "#{E:@catppuccin_status_battery}"


#############################################################
###                  高级功能 (Advanced Features)          ###
#############################################################

# 支持 Yazi 图像预览
set -ga update-environment TERM
set -ga update-environment TERM_PROGRAM

# 初始化 TPM 插件管理器 (必须放在配置文件最后)
run '~/.tmux/plugins/tpm/tpm'
