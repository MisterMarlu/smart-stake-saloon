#!/usr/bin/env bash

# Smart Stake Saloon - Uninstaller

set -e

LAUNCHER="$HOME/.local/bin/smart-stake-saloon"
SHARE_DIR="$HOME/.local/share/smart-stake-saloon"
STATE_DIR="$HOME/.local/state/smart-stake-saloon"
CONFIG_DIR="$HOME/.config/smart-stake-saloon"

echo "----------------------------------------"
echo "   Uninstalling Smart Stake Saloon...   "
echo "----------------------------------------"

# 1. Remove the launcher
if [[ -f "$LAUNCHER" ]]; then
    echo "Removing launcher command: $LAUNCHER"
    rm "$LAUNCHER"
else
    echo "Launcher command not found at $LAUNCHER."
fi

# Function to ask before removal
ask_and_remove() {
    local target="$1"
    local description="$2"

    if [[ -d "$target" ]]; then
        echo ""
        printf "Do you want to remove %s?\nPath: %s\n[y/N]: " "$description" "$target"
        read -r choice
        case "$choice" in
            y|Y)
                echo "Removing $target..."
                rm -rf "$target"
                ;;
            *)
                echo "Skipped: $target"
                ;;
        esac
    fi
}

# 2. Ask for other directories
ask_and_remove "$SHARE_DIR" "the game files (Git repository)"
ask_and_remove "$STATE_DIR" "update state and temporary data"
ask_and_remove "$CONFIG_DIR" "user configuration files"

echo ""
echo "✅ Uninstallation finished."
