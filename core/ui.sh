#!/usr/bin/env bash

# Typing animation
type_text() {
    local text="$1"
    local delay=${2:-0.03}
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Render Cards Visually
render_cards() {
    local hide_mode=$1 # "false", "true" (first), or "all"
    shift
    local cards=("$@")

    local line1="" line2="" line3="" line4="" line5="" line6=""

    for ((i=0; i<${#cards[@]}; i++)); do
        local card="${cards[$i]}"
        if ([ "$i" -eq 0 ] && [ "$hide_mode" == "true" ]) || [ "$hide_mode" == "all" ]; then
            line1+=" $BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR "
            line2+=" $BOX_V░░░░░░░░░$BOX_V "
            line3+=" $BOX_V░░░░░░░░░$BOX_V "
            line4+=" $BOX_V░░░░░░░░░$BOX_V "
            line5+=" $BOX_V░░░░░░░░░$BOX_V "
            line6+=" $BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR "
        else
            local rank=${card%?}
            local suit=${card#$rank}

            # Formatting for rank
            local r_top="$rank"
            local r_bot="$rank"
            [ ${#rank} -eq 1 ] && r_top="$rank " && r_bot=" $rank"

            # Color logic
            local color=$NC
            if [[ "$suit" == "$HEARTS" ]] || [[ "$suit" == "$DIAMONDS" ]]; then
                color=$RED
            fi

            line1+=" $BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR "
            line2+=" $BOX_V $color$r_top$NC      $BOX_V "
            line3+=" $BOX_V         $BOX_V "
            line4+=" $BOX_V    $color$suit$NC    $BOX_V "
            line5+=" $BOX_V      $color$r_bot$NC $BOX_V "
            line6+=" $BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR "
        fi
    done

    print_line "$line1"
    print_line "$line2"
    print_line "$line3"
    print_line "$line4"
    print_line "$line5"
    print_line "$line6"
}

render_dice() {
    local show=$1
    shift
    local dice=("$@")
    local lines=("" "" "" "" "")

    for d in "${dice[@]}"; do
        local -a template
        if [ "$show" == "false" ]; then
            template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║░░░░░░░░░║" "║░░░░░░░░░║" "║░░░░░░░░░║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR")
        else
            case $d in
                1) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║         ║" "║    ●    ║" "║         ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
                2) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║  ●      ║" "║         ║" "║      ●  ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
                3) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║  ●      ║" "║    ●    ║" "║      ●  ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
                4) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║  ●   ●  ║" "║         ║" "║  ●   ●  ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
                5) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║  ●   ●  ║" "║    ●    ║" "║  ●   ●  ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
                6) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║  ●   ●  ║" "║  ●   ●  ║" "║  ●   ●  ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
                *) template=("$BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR" "║         ║" "║         ║" "║         ║" "$BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR") ;;
            esac
        fi
        for i in {0..4}; do
            lines[$i]+=" ${template[$i]} "
        done
    done

    for i in {0..4}; do
        print_line "${lines[$i]}"
    done
}

# Render Whiskey Glass
render_whiskey() {
    local level=$1
    local color=$YELLOW
    local drunk_msg="${TXT[whiskey_$level]}"

    [[ $level -le 1 ]] && color=$RED
    [[ $level -ge 4 ]] && color=$GREEN

    local l1="  $BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR"
    local l2="  $BOX_V"
    local l3="  $BOX_V"
    local l4="  $BOX_V"
    local l5="  $BOX_V"
    local l6="  $BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR"

    [ $level -ge 4 ] && l2+="${color}~~~~~~~${NC}$BOX_V" || l2+="       $BOX_V"
    [ $level -ge 3 ] && l3+="${color}~~~~~~~${NC}$BOX_V" || l3+="       $BOX_V"
    [ $level -ge 2 ] && l4+="${color}~~~~~~~${NC}$BOX_V" || l4+="       $BOX_V"
    [ $level -ge 1 ] && l5+="${color}~~~~~~~${NC}$BOX_V" || l5+="       $BOX_V"

    print_line "$l1  ${TXT[label_status]}: $drunk_msg"
    print_line "$l2"
    print_line "$l3"
    print_line "$l4"
    print_line "$l5"
    print_line "$l6"
}

clear_screen() {
    printf "\033[H\033[2J"
}

draw_line() {
    local left=$1 mid=$2 right=$3
    local pad_w=$((BOARD_WIDTH - 2))
    local line
    printf -v line "%*s" "$pad_w" ""
    line="${left}${line// /$mid}${right}"
    echo -e "${BLUE}$line${NC}"
}

draw_grid_line() {
    local left=$1 mid=$2 sep=$3 right=$4
    local col_w=$(( (BOARD_WIDTH - 4) / 3 ))
    local last_col_w=$(( BOARD_WIDTH - 4 - 2 * col_w ))

    local line_mid last_mid
    printf -v line_mid "%*s" "$col_w" ""
    printf -v last_mid "%*s" "$last_col_w" ""

    local line="${left}${line_mid// /$mid}${sep}${line_mid// /$mid}${sep}${last_mid// /$mid}${right}"
    echo -e "${BLUE}$line${NC}"
}

# Helper to print a line with blue side borders and proper padding
print_line() {
    local content="$1"
    local esc=$(printf '\033')
    local stripped=$(printf '%s' "$content" | LC_ALL=C sed "s/${esc}\[[0-9;]*m//g")
    local len=${#stripped}
    local padding=$((BOARD_WIDTH - 2 - len))
    (( padding < 0 )) && padding=0

    printf "${BLUE}%s${NC}%s%*s${BLUE}%s${NC}\n" "$BOX_V" "$content" "$padding" "" "$BOX_V"
}

update_board_width() {
    BOARD_WIDTH=$(tput cols 2>/dev/null || echo 72)
    (( BOARD_WIDTH < 72 )) && BOARD_WIDTH=72
}

game_intro() {
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
    type_text "  ${TXT[intro_welcome]}"
    sleep 1
    type_text "  ${TXT[intro_prompt]}"
    while ! read -n 1 -s; do :; done
}

show_rules() {
    local game=$1
    update_board_width
    clear_screen
    draw_line "$BOX_TL" "$BOX_H" "$BOX_TR"

    local title="${TXT[rules_title]}"
    local name_len=${#title}
    local pad_total=$((BOARD_WIDTH - 2 - name_len))
    local pad_left=$((pad_total / 2))
    local pad_right=$((pad_total - pad_left))
    printf "${BLUE}%s${YELLOW}%*s%s%*s${BLUE}%s${NC}\n" "$BOX_V" $pad_left "" "$title" $pad_right "" "$BOX_V"

    draw_line "$BOX_L_V" "$BOX_H" "$BOX_R_V"

    print_line ""
    case $game in
        blackjack)
            print_line "  ${YELLOW}BLACKJACK${NC}"
            print_line ""
            print_line "  ${TXT[rules_blackjack_1]}"
            print_line "  ${TXT[rules_blackjack_2]}"
            print_line "  ${TXT[rules_blackjack_3]}"
            print_line "  ${TXT[rules_blackjack_4]}"
            print_line "  ${TXT[rules_blackjack_5]}"
            ;;
        poker)
            print_line "  ${YELLOW}TEXAS HOLD'EM${NC}"
            print_line ""
            print_line "  ${TXT[rules_poker_1]}"
            print_line "  ${TXT[rules_poker_2]}"
            print_line "  ${TXT[rules_poker_3]}"
            print_line "  ${TXT[rules_poker_4]}"
            print_line ""
            print_line "  ${YELLOW}${TXT[rules_poker_5]}${NC}"

            # Simple table formatting
            local table_w=$((BOARD_WIDTH - 6))
            local col1_w=18
            local col2_w=$((table_w - col1_w - 4))

            print_line "  $(printf '%.0s─' $(seq 1 $table_w))"
            local header=$(printf "   ${YELLOW}%-*s${NC} ║ ${YELLOW}%-*s${NC}" $col1_w "Hand" $col2_w "Beschreibung")
            print_line "$header"
            print_line "  $(printf '%.0s─' $(seq 1 $table_w))"

            for i in {1..10}; do
                local entry="${TXT[rules_poker_rank_$i]}"
                local name="${entry%%|*}"
                local desc="${entry##*|}"

                # Multi-byte compensation for alignment
                local n_extra=$(( $(LC_ALL=C printf "%s" "$name" | wc -c) - ${#name} ))
                local d_extra=$(( $(LC_ALL=C printf "%s" "$desc" | wc -c) - ${#desc} ))

                local row=$(printf "   %-*s ║ %-*s" $((col1_w + n_extra)) "$name" $((col2_w + d_extra)) "$desc")
                print_line "$row"
            done
            print_line "  $(printf '%.0s─' $(seq 1 $table_w))"
            ;;
        chuck)
            print_line "  ${YELLOW}CHUCK-A-LUCK${NC}"
            print_line ""
            print_line "  ${TXT[rules_chuck_1]}"
            print_line "  ${TXT[rules_chuck_2]}"
            print_line "  ${TXT[rules_chuck_3]}"
            print_line "  ${TXT[rules_chuck_4]}"
            ;;
        bandit)
            print_line "  ${YELLOW}EINARMIGER BANDIT${NC}"
            print_line ""
            print_line "  ${TXT[rules_bandit_1]}"
            print_line "  ${TXT[rules_bandit_2]}"
            print_line "  ${TXT[rules_bandit_3]}"
            print_line "  ${TXT[rules_bandit_4]}"
            ;;
    esac
    print_line ""
    print_line "  ${TXT[rules_back]}"
    draw_line "$BOX_BL" "$BOX_H" "$BOX_BR"

    read -n 1 -s
}

game_over_screen() {
    clear_screen
    echo -e "${RED}"
    cat << "EOF"
   _____          __  __ ______    ______      ________ _____
  / ____|   /\   |  \/  |  ____|  / __ \ \    / /  ____|  __ \
 | |  __   /  \  | \  / | |__    | |  | \ \  / /| |__  | |__) |
 | | |_ | / /\ \ | |\/| |  __|   | |  | |\ \/ / |  __| |  _  /
 | |__| |/ ____ \| |  | | |____  | |__| | \  /  | |____| | \ \
  \_____/_/    \_\_|  |_|______|  \____/   \/   |______|_|  \_\

EOF
    echo -e "${NC}"
    type_text "  ${TXT[msg_game_over]}"
    echo -e "  ${TXT[label_final_balance]}: ${YELLOW}${BALANCE}€${NC} | ${TXT[label_max_balance]}: ${YELLOW}${MAX_BALANCE}€${NC}"
    echo -e "  ${TXT[label_wins]}: ${GREEN}$WINS${NC} | ${TXT[label_losses]}: ${RED}$LOSSES${NC}"
    while true; do
        echo -e "\n  ${TXT[prompt_exit]}"
        if read -n 1; then break; fi
    done
}

caught_cheating() {
    local caught_msg=${1:TXT[msg_caught]}
    update_board_width
    clear_screen
    echo -e "${RED}"
    type_text "  ${caught_msg}" 0.1
    sleep 1
    type_text "  Der Dealer zieht seine Waffe..." 0.1
    sleep 1
    type_text "  * PENG! *" 0.05
    sleep 2

    clear_screen
    echo -e "${RED}"
    cat << "EOF"
  _____ ______  _____ _    _  _____ _    _ _______
 / ____|  ____|/ ____| |  | |/ ____| |  | |__   __|
| |  __| |__  | (___ | |  | | |    | |__| |  | |
| | |_ |  __|  \___ \| |  | | |    |  __  |  | |
| |__| | |____ ____) | |__| | |____| |  | |  | |
 \_____|______|_____/ \____/ \_____|_|  |_|  |_|
EOF
    echo -e "\n          ${YELLOW}N I C H T   W I L L K O M M E N${NC}"
    echo -e "\n  Du wurdest beim Schummeln erwischt und aus dem Saloon geworfen."
    echo -e "  Dein Steckbrief hängt nun an jeder Tür."
    exit 0
}

# Global variable for the resize callback
CURRENT_DISPLAY_FUNC=""

handle_sigwinch() {
    update_board_width
    if [[ -n "$CURRENT_DISPLAY_FUNC" ]]; then
        $CURRENT_DISPLAY_FUNC "$REVEAL_DEALER_STATE"
    fi
}
