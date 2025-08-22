#set -g mouse on
set -g prefix C-a
set -g mode-keys vi
set -a terminal-features 'xterm-256color:RGB'
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on
set -s set-clipboard external # Support OSC52
set -g status-style "bg=default"
set -g window-status-current-style "fg=blue bold"
set -g status-right ""
set -g status-left "#S  "

bind r source-file ~/.tmux.conf
bind C-a send-prefix
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi C-c send -X clear-selection
