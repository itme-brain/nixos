''
bind -n M-C source-file ~/.config/tmux/tmux.conf

# Navigation (matches hyprland Alt+hjkl)
bind-key -n M-h select-pane -L
bind-key -n M-j select-pane -D
bind-key -n M-k select-pane -U
bind-key -n M-l select-pane -R

# Move/swap pane (matches hyprland Alt+Shift+hjkl)
bind-key -n M-H swap-pane -s '{left-of}'
bind-key -n M-J swap-pane -s '{down-of}'
bind-key -n M-K swap-pane -s '{up-of}'
bind-key -n M-L swap-pane -s '{right-of}'

# Actions
bind-key -n M-q kill-pane
bind-key -n M-Return split-window -c "#{pane_current_path}"
bind-key -n M-f resize-pane -Z

# Windows (like workspaces)
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9
bind-key -n M-0 select-window -t 10

# Move pane to window (like move to workspace)
bind-key -n M-! join-pane -t :1
bind-key -n M-@ join-pane -t :2
bind-key -n M-'#' join-pane -t :3
bind-key -n M-'$' join-pane -t :4
bind-key -n M-% join-pane -t :5
bind-key -n M-^ join-pane -t :6
bind-key -n M-& join-pane -t :7
bind-key -n M-* join-pane -t :8
bind-key -n M-( join-pane -t :9
bind-key -n M-) join-pane -t :10
''
