''
bind -n M-C source-file ~/.config/tmux/tmux.conf

bind-key -n M-h select-pane -L
bind-key -n M-j select-pane -D
bind-key -n M-k select-pane -U
bind-key -n M-l select-pane -R

bind-key -n M-q kill-pane
''
