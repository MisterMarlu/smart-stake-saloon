# Smart Stake Saloon

Smart Stake Saloon is a modular Bash-based terminal game suite, featuring classics like Blackjack, Texas Hold'em, and Chuck-a-Luck.

## Features
- Clean terminal UI with ASCII art.
- Multiple games included.
- Cross-platform support (Debian-based Linux and macOS).
- Automatic daily updates.
- Easy installation and uninstallation.

## Requirements
- **Bash**: Version 4.0 or higher is recommended.
- **Git**: Required for installation and self-updates.

## Installation

To install Smart Stake Saloon, clone this repository and run the installer:

```bash
git clone git@github.com/MisterMarlu/smart-stake-saloon.git
cd smart-stake-saloon
bash install.sh
```

### PATH Troubleshooting
The installer places the `smart-stake-saloon` command in `~/.local/bin`. If your shell reports "command not found", add this directory to your `PATH` by adding the following line to your profile (`~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then restart your terminal or run `source ~/.bashrc`.

## Usage

Start the game globally:
```bash
smart-stake-saloon
```

### Commands
- `smart-stake-saloon update`: Force a manual update from GitHub.
- `smart-stake-saloon version`: Show the currently installed version and commit hash.
- `smart-stake-saloon doctor`: Check if all dependencies and files are correctly set up.
- `smart-stake-saloon help`: Show available commands and options.

### Options
- `--no-update`: Start the game without checking for updates.

## How Auto-Update Works
The game checks for updates at most once per day on startup.
- It pulls the latest changes from the `main` branch on GitHub.
- If the update fails (e.g., no internet connection), the game continues with the local version.
- Updates never require `sudo` privileges.

## Uninstallation

To remove the game and its data:
```bash
# If you have the repo locally
bash uninstall.sh

# Or manually remove:
# ~/.local/bin/smart-stake-saloon
# ~/.local/share/smart-stake-saloon
# ~/.local/state/smart-stake-saloon
# ~/.config/smart-stake-saloon
```

## Release Workflow Recommendation

We recommend the following workflow for maintaining this project:
- **Develop on `main`**: Use the `main` branch for active development.
- **Stable Releases**: Merge tested features into the `main` branch (or a dedicated `stable` branch if preferred).
- **Versioning**: Create Git tags for releases (e.g., `git tag -a v1.0.0 -m "Initial release"`). The `version` command will reflect these updates.
