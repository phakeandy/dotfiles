#set -g mouse on
set -g prefix C-s
set -g mode-keys vi
set -a terminal-features 'xterm-256color:RGB'
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on
set -s set-clipboard external # Support OSC52
#set -g status-position top
set -g status-style "bg=default"
set -g window-status-current-style "fg=blue bold"
set -g status-right ""
set -g status-left "#S  "

bind C-s send-prefix
bind -n C-q copy-mode
bind r source-file ~/.config/tmux/tmux.conf
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

bind -T copy-mode-vi C-q send -X cancel
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi Y send -X copy-end-of-line-and-cancel
bind -T copy-mode-vi C-c send -X clear-selection
