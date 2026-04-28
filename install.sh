#!/usr/bin/env bash

# Smart Stake Saloon - Installer
# Compatibility: Debian-based Linux and macOS

set -e

# Configurable Repository URL
REPO_URL="ssh://git@github.com/username/smart-stake-saloon.git"
STABLE_BRANCH="main"

INSTALL_DIR="$HOME/.local/share/smart-stake-saloon"
BIN_DIR="$HOME/.local/bin"
LAUNCHER_NAME="smart-stake-saloon"

echo "----------------------------------------"
echo "   Installing Smart Stake Saloon...     "
echo "----------------------------------------"

# 1. Dependency Check
if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git is not installed."
    echo "Please install Git (e.g., 'sudo apt install git' or 'brew install git') and try again."
    exit 1
fi

if [[ -z "$BASH_VERSION" ]]; then
    echo "Error: This installer must be run with Bash."
    exit 1
fi

# 2. Create directories
mkdir -p "$BIN_DIR"

# 3. Handle installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        echo "Found existing installation. Updating..."
        cd "$INSTALL_DIR"

        # Check if it's the correct repository
        CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
        if [[ "$CURRENT_REMOTE" != "$REPO_URL" ]]; then
            echo "Warning: Existing directory $INSTALL_DIR has a different remote: $CURRENT_REMOTE"
            echo "Expected: $REPO_URL"
            echo "Aborting to avoid overwriting an unrelated repository."
            exit 1
        fi

        git fetch origin "$STABLE_BRANCH"
        git reset --hard "origin/$STABLE_BRANCH"
    else
        echo "Error: Directory $INSTALL_DIR already exists and is not a Git repository."
        echo "Please move or delete it and try again."
        exit 1
    fi
else
    echo "Cloning repository into $INSTALL_DIR..."
    git clone -b "$STABLE_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

# 4. Install launcher
echo "Installing launcher command to $BIN_DIR/$LAUNCHER_NAME..."
ln -sf "$INSTALL_DIR/bin/smart-stake-saloon" "$BIN_DIR/$LAUNCHER_NAME"
chmod +x "$INSTALL_DIR/bin/smart-stake-saloon"
chmod +x "$INSTALL_DIR/start.sh"

# 5. PATH check
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "⚠️  WARNING: $BIN_DIR is not in your PATH."
    echo "To run the game globally, add this line to your shell profile (e.g., ~/.bashrc or ~/.zshrc):"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then restart your terminal or run 'source <your-profile-file>'."
fi

# 6. Finish
echo ""
echo "✅ Installation complete!"
echo "You can now start the game by typing:"
echo ""
echo "  $LAUNCHER_NAME"
echo ""
