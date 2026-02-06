#!/bin/bash
echo "🚀 Starting RunPod environment setup..."

# === Root-level setup ===
echo "📦 Installing system packages..."
apt-get update -qq
apt-get install -y unzip tmux curl wget git sudo

echo "👤 Creating user 'jake' with sudo privileges..."
useradd -m -s /bin/bash jake
echo "jake ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jake
chmod 0440 /etc/sudoers.d/jake

# === User-level setup (run as jake) ===
sudo -i -u jake bash << 'USEREOF'
set -e

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

mkdir -p ~/huggingface/{hub,datasets}
mkdir -p /workspace/.claude

cat >> ~/.bashrc << 'EOF'
# HuggingFace cache
export HF_HOME=~/huggingface
export HF_DATASETS_CACHE=~/huggingface/datasets
export HUGGINGFACE_HUB_CACHE=~/huggingface/hub
export TRANSFORMERS_CACHE=~/huggingface/hub

# Claude Code - persist sessions to network volume
export CLAUDE_CONFIG_DIR=/workspace/.claude

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm use default --silent 2>/dev/null
EOF

USEREOF

echo "✅ Done! Log in as jake with: su - jake"
