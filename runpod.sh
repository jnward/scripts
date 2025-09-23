#!/bin/bash
echo "🚀 Starting RunPod environment setup..."
echo "📦 Installing system packages..."
apt-get update -qq
apt-get install -y unzip tmux curl wget git
echo "🐍 Installing uv (Python package manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "🖥️  Configuring tmux..."
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
echo "☁️  Installing rclone..."
curl https://rclone.org/install.sh | bash
# if [ -f "/workspace/.config/rclone/rclone.conf" ]; then
#     mkdir -p ~/.config/rclone
#     cp /workspace/.config/rclone/rclone.conf ~/.config/rclone/
#     echo "✅ Rclone configured"
# else
#     echo "⚠️  No rclone config found. Run 'rclone config' to set up Google Drive"
# fi
echo "📗 Setting up Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
nvm alias default 22
echo "🤖 Installing Claude Code..."
npm install -g @anthropic-ai/claude-code
echo "🤖 Installing Codex..."
npm install -g @openai/codex
# echo "🐍 Installing Python packages..."
# cd /workspace
# if [ -f "requirements.txt" ]; then
#     pip install -r requirements.txt
# else
#     echo "⚠️  No requirements.txt found in /workspace"
# fi
mkdir -p /workspace/huggingface/{hub,datasets}
cat >> ~/.bashrc << 'EOF'
# HuggingFace cache
export HF_HOME=/workspace/huggingface
export HF_DATASETS_CACHE=/workspace/huggingface/datasets
export HUGGINGFACE_HUB_CACHE=/workspace/huggingface/hub
export TRANSFORMERS_CACHE=/workspace/huggingface/hub
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm use default --silent 2>/dev/null
EOF
echo "✅ Done!"
