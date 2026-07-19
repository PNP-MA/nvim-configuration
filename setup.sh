#!/usr/bin/env bash
set -euo pipefail

# nvim-configuration setup script
# Symlinks this config into a user's ~/.config/nvim
# Usage: ./setup.sh              # sets up for current user
#        ./setup.sh <username>   # sets up for another user

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

setup_for_user() {
    local user="$1"
    local home_dir
    home_dir="$(getent passwd "$user" | cut -d: -f6)"

    if [ -z "$home_dir" ]; then
        echo "Error: user '$user' does not exist"
        exit 1
    fi

    local user_config="$home_dir/.config/nvim"

    if [ -L "$user_config" ]; then
        local current_target
        current_target="$(readlink "$user_config")"
        if [ "$current_target" = "$REPO_DIR" ]; then
            echo "[$user] Already configured -> no change"
            return 0
        fi
        echo "[$user] Replacing existing symlink ($current_target -> $REPO_DIR)"
        rm "$user_config"
    elif [ -e "$user_config" ]; then
        local backup="${user_config}.bak.$(date +%s)"
        echo "[$user] Backing up existing config to $backup"
        mv "$user_config" "$backup"
    fi

    mkdir -p "$home_dir/.config"
    ln -sf "$REPO_DIR" "$user_config"
    chown -h "$user:" "$user_config"
    echo "[$user] Symlinked $user_config -> $REPO_DIR"
}

if [ $# -ge 1 ]; then
    for username in "$@"; do
        setup_for_user "$username"
    done
else
    # Set up for current user
    if [ "$EUID" -eq 0 ]; then
        echo "Running as root. Usage: $0 <username>"
        echo "Or run as the target user directly."
        exit 1
    fi
    setup_for_user "$(whoami)"
fi

echo ""
echo "Done. Run 'nvim' to let lazy.nvim install all plugins."
echo "Each user has their own plugin data under ~/.local/share/nvim/"
