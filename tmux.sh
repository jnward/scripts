#!/usr/bin/env bash

# Update package list
apt update

# Install tmux and xclip (for clipboard support)
apt install -y tmux xclip

# Create minimal tmux config
cat > ~/.tmux.conf << 'EOF'
# Enable mouse support
set -g mouse on

# Increase scrollback buffer size
set -g history-limit 10000

# Use vi-style keys in copy mode
setw -g mode-keys vi

# Copy to system clipboard on mouse selection
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
EOF
