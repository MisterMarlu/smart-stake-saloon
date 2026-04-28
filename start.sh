#!/usr/bin/env bash

# Blackjack Terminal Game - Modular Runner
# Compatibility: Linux and macOS

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load Core Modules
source "$SCRIPT_DIR/core/constants.sh"
source "$SCRIPT_DIR/core/engine.sh"
source "$SCRIPT_DIR/core/ui.sh"

# Load Games
for game_dir in "$SCRIPT_DIR/games"/*; do
    if [[ -d "$game_dir" ]]; then
        if [[ -f "$game_dir/strings.sh" ]]; then
            source "$game_dir/strings.sh"
        fi
        if [[ -f "$game_dir/logic.sh" ]]; then
            source "$game_dir/logic.sh"
        fi
    fi
done

main_menu() {
    while true; do
        clear_screen
        echo -e "${YELLOW}"
        cat << "EOF"
   ____  __  __     _    ____  _____     ____  _____  _    _  _  _____
  / ___||  \/  |   / \  |  _ \|_   _|   / ___||_   _|/ \  | |/ /| ____|
  \___ \| |\/| |  / _ \ | |_) | | |     \___ \  | | / _ \ | ' / |  _|
   ___) | |  | | / ___ \|  _ <  | |      ___) | | |/ ___ \| . \ | |___
  |____/|_|  |_|_/    \_\_| \_\ |_|     |____/  |_/_/   \_\_|\_\|_____|

                           S  A  L  O  O  N

EOF
        echo -e "${NC}"
        echo -e "  ${TXT[menu_title]}"
        echo -e "  ----------------"

        # Dynamically list registered games
        for i in "${!GAMES_NAMES[@]}"; do
            echo -e "  $((i+1))) ${GAMES_NAMES[$i]}"
        done
        echo -e "  ${TXT[menu_exit]}"
        if ! read -n 1 choice; then continue; fi
        echo ""

        if [[ "$choice" == "q" ]] || [[ "$choice" == "Q" ]]; then
            clear_screen
            break
        fi

        if [[ "$choice" =~ ^[1-9]$ ]]; then
            idx=$((choice - 1))
            if [[ -n "${GAMES_CMDS[$idx]}" ]]; then
                ${GAMES_CMDS[$idx]}
            fi
        fi
    done
}

play_game() {
    # Hide cursor
    tput civis
    trap 'tput cnorm; exit 130' SIGINT
    trap 'tput cnorm; exit 143' SIGTERM

    update_random
    if (( RANDOM % 1000 == 0 )); then
        DEALER_NAME="Kay Snider"
        DEALER_MESSAGE="Was willst du hier, du kleiner Wicht?"
    fi
    trap handle_sigwinch SIGWINCH
    game_intro
    main_menu

    # Show cursor
    tput cnorm
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    play_game
fi
