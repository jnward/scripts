#!/bin/bash

set -e

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

PYTHON_VERSION=${1:-3.12}

if [ "$EUID" -ne 0 ]; then
    log "Please run as root"
    exit 1
fi

ACTUAL_USER=$(whoami | awk '{print $1}')
if [ -z "$ACTUAL_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
fi

if [ -z "$ACTUAL_USER" ]; then
    log "Could not determine the actual user"
    exit 1
fi

USER_HOME=$(eval echo ~$ACTUAL_USER)

log "Installing system dependencies..."
apt-get update
apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

log "Installing pyenv..."
su - $ACTUAL_USER -c 'curl https://pyenv.run | bash'

SHELL_CONFIG="$USER_HOME/.bashrc"
if [ -f "$USER_HOME/.zshrc" ]; then
    SHELL_CONFIG="$USER_HOME/.zshrc"
fi

log "Configuring shell for pyenv ($SHELL_CONFIG)..."
if ! grep -q "PYENV_ROOT" "$SHELL_CONFIG"; then
    su - $ACTUAL_USER -c "echo 'export PYENV_ROOT=\"\$HOME/.pyenv\"' >> $SHELL_CONFIG"
    su - $ACTUAL_USER -c "echo 'command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\"' >> $SHELL_CONFIG"
    su - $ACTUAL_USER -c "echo 'eval \"\$(pyenv init -)\"' >> $SHELL_CONFIG"
fi

log "Installing Python and setting up virtualenv..."
su - $ACTUAL_USER -c "export PYENV_ROOT=\"\$HOME/.pyenv\" && \
    export PATH=\"\$PYENV_ROOT/bin:\$PATH\" && \
    eval \"\$(pyenv init -)\" && \
    pyenv install $PYTHON_VERSION --skip-existing && \
    pyenv virtualenv $PYTHON_VERSION jake-base"

log "Setup complete! To activate the virtualenv, use:"
log "    pyenv activate jake-base"
