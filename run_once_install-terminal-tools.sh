#!/usr/bin/env bash

set -euo pipefail

# This installer supports Debian/Ubuntu, Fedora and Arch Linux.
[[ $(uname -s) == Linux ]] || { echo "Linux only" >&2; exit 1; }
export PATH="$HOME/.local/bin:$PATH"
if (( EUID == 0 )); then
    elevate=()
else
    command -v sudo >/dev/null || { echo "Install sudo first" >&2; exit 1; }
    elevate=(sudo)
fi
if command -v apt-get >/dev/null 2>&1; then
    "${elevate[@]}" apt-get update
    "${elevate[@]}" apt-get install -y git curl wget unzip make gawk fzf fd-find bat tmux figlet
elif command -v dnf >/dev/null 2>&1; then
    "${elevate[@]}" dnf install -y git curl wget unzip make gawk fzf fd-find bat tmux figlet
elif command -v pacman >/dev/null 2>&1; then
    "${elevate[@]}" pacman -Syu --needed --noconfirm git curl wget unzip make gawk fzf fd bat tmux figlet
else
    echo "Unsupported Linux package manager; install the tools manually (see README)." >&2
    exit 1
fi
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# ------------------------------------------------------------
# fd / bat compatibility
# ------------------------------------------------------------

mkdir -p "$HOME/.local/bin"

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

# ------------------------------------------------------------
# ble.sh
# ------------------------------------------------------------

echo "==> Installing ble.sh"

if [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
    TMP_DIR="$work_dir/blesh"
    mkdir -p "$TMP_DIR"

    git clone \
        --recursive \
        --depth 1 \
        --shallow-submodules \
        https://github.com/akinomyoga/ble.sh.git \
        "$TMP_DIR/ble.sh"

    make -C "$TMP_DIR/ble.sh" install PREFIX="$HOME/.local"

    rm -rf "$TMP_DIR"
else
    echo "ble.sh already installed"
fi

# ------------------------------------------------------------
# Oh My Posh
# ------------------------------------------------------------

echo "==> Installing Oh My Posh"

if ! command -v oh-my-posh >/dev/null 2>&1; then
    curl -fsSL https://ohmyposh.dev/install.sh -o "$work_dir/install-posh.sh"
    bash "$work_dir/install-posh.sh" -d "$HOME/.local/bin"
else
    echo "Oh My Posh already installed"
fi

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo
echo "============================================="
echo "Terminal environment installed successfully."
echo "============================================="
echo
echo "Installed:"
echo "  - fzf"
echo "  - fd"
echo "  - bat"
echo "  - tmux"
echo "  - ble.sh"
echo "  - Oh My Posh"
echo "  - stelbent-compact.minimal theme"
echo
echo "Theme:"
echo "  ~/.config/oh-my-posh/stelbent-compact.minimal.omp.json"
echo
echo "Restart Bash or run:"
echo
echo "  exec bash"
echo