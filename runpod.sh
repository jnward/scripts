#!/bin/bash
echo "🚀 Starting RunPod environment setup..."
echo "📦 Installing system packages..."
apt-get update -qq
apt-get install -y unzip tmux curl wget git
echo "🔧 Configuring git..."
git config --global user.email "jakenicholasward@gmail.com"
git config --global user.name "Jake Ward"
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
echo "📗 Setting up Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 22
nvm alias default 22
echo "🤖 Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
echo "🤖 Installing Codex..."
npm install -g @openai/codex
mkdir -p /root/huggingface/{hub,datasets}
mkdir -p /workspace/.claude
cat >> ~/.bashrc << 'EOF'
# HuggingFace cache
export HF_HOME=/root/huggingface
export HF_DATASETS_CACHE=/root/huggingface/datasets
export HUGGINGFACE_HUB_CACHE=/root/huggingface/hub
export TRANSFORMERS_CACHE=/root/huggingface/hub
# Claude Code - persist sessions to network volume
export CLAUDE_CONFIG_DIR=/workspace/.claude
export PATH="$HOME/.local/bin:$PATH"
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm use default --silent 2>/dev/null
EOF
echo ""
echo "  ┌───────────────────────────────────────────┐"
echo "  │           ◆ RunPod Environment ◆          │"
echo "  └───────────────────────────────────────────┘"
echo ""
echo "       ◇            OS:      $(. /etc/os-release && echo $PRETTY_NAME)"
echo "      ◇◆◇           Kernel:  $(uname -r)"
echo "     ◇◆◆◆◇          GPU:     $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo 'N/A') x$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | wc -l)"
echo "    ◇◆◇─◇◆◇         VRAM:    $(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | awk '{s+=$1} END {printf "%.0f MiB", s}' || echo 'N/A')"
echo "   ◇◆◆◆◇◆◆◆◇        Python:  $(python3 --version 2>/dev/null | cut -d' ' -f2)"
echo "  ◇◆◇─◇◆◇─◇◆◇       CUDA:    $(nvcc --version 2>/dev/null | grep release | awk '{print $6}' | tr -d ',' || echo 'N/A')"
echo "   ◇◆◆◆◇◆◆◆◇        Node:    $(node --version 2>/dev/null || echo 'N/A')"
echo "    ◇◆◇─◇◆◇         Disk:    $(df -h /workspace 2>/dev/null | awk 'NR==2{print $3"/"$2" used"}' || echo 'N/A')"
echo "     ◇◆◆◆◇"
echo "      ◇◆◇           Tools: uv · claude-code · codex · rclone · tmux"
echo "       ◇"
echo ""
