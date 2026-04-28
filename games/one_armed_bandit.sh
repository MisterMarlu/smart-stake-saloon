#!/usr/bin/env bash

# One-Armed Bandit Implementation

BANDIT_REELS=("?" "?" "?")

display_bandit() {
    update_board_width
    clear_screen

    # Blurry effect if level is 0
    if [ $WHISKEY_LEVEL -eq 0 ] && [ $((RANDOM % 3)) -eq 0 ]; then
        echo -e "${RED}${TXT[msg_blurry]}${NC}"
    fi

    draw_line "$BOX_TL" "$BOX_H" "$BOX_TR"

    local saloon="${TXT[saloon_name]}"
    local name_len=${#saloon}
    local pad_total=$((BOARD_WIDTH - 2 - name_len))
    local pad_left=$((pad_total / 2))
    local pad_right=$((pad_total - pad_left))
    printf "${BLUE}%s${YELLOW}%*s%s%*s${BLUE}%s${NC}\n" "$BOX_V" $pad_left "" "$saloon" $pad_right "" "$BOX_V"

    draw_grid_line "$BOX_L_V" "$BOX_H" "$BOX_T_H" "$BOX_R_V"

    local col_w=$(( (BOARD_WIDTH - 4) / 3 ))
    local last_col_w=$(( BOARD_WIDTH - 4 - 2 * col_w ))

    local pad1=$(( col_w - 4 - ${#TXT[label_balance]} ))
    local pad2=$(( col_w - 4 - ${#TXT[label_bet]} ))
    local pad3=$(( last_col_w - 4 - ${#TXT[label_max]} ))
    (( pad1 < 0 )) && pad1=0; (( pad2 < 0 )) && pad2=0; (( pad3 < 0 )) && pad3=0

    printf "${BLUE}%s${NC} ${TXT[label_balance]}: ${YELLOW}%-*s${NC}" "$BOX_V" $((pad1 + 3)) "${BALANCE}€"
    printf "${BLUE}%s${NC} ${TXT[label_bet]}: ${YELLOW}%-*s${NC}" "$BOX_V" $((pad2 + 3)) "${BET}€"
    printf "${BLUE}%s${NC} ${TXT[label_max]}: ${YELLOW}%-*s${NC}" "$BOX_V" $((pad3 + 3)) "${MAX_BALANCE}€"
    printf "${BLUE}%s${NC}\n" "$BOX_V"

    draw_grid_line "$BOX_L_V_THIN" "$BOX_H_THIN" "$BOX_C_V" "$BOX_R_V_THIN"

    local pad4=$(( col_w - 3 - ${#TXT[label_wins]} ))
    local pad5=$(( col_w - 3 - ${#TXT[label_losses]} ))
    local pad6=$(( last_col_w - 3 - ${#TXT[label_pushes]} ))
    (( pad4 < 0 )) && pad4=0; (( pad5 < 0 )) && pad5=0; (( pad6 < 0 )) && pad6=0

    printf "${BLUE}%s${NC} ${TXT[label_wins]}: ${GREEN}%-*d${NC}" "$BOX_V" $pad4 $WINS
    printf "${BLUE}%s${NC} ${TXT[label_losses]}: ${RED}%-*d${NC}" "$BOX_V" $pad5 $LOSSES
    printf "${BLUE}%s${NC} ${TXT[label_pushes]}: ${BLUE}%-*d${NC}" "$BOX_V" $pad6 $PUSHES
    printf "${BLUE}%s${NC}\n" "$BOX_V"

    draw_grid_line "$BOX_L_V" "$BOX_H" "$BOX_B_H" "$BOX_R_V"

    print_line " ${RED}${TXT[label_dealer]} [${DEALER_NAME}]:${NC} \"$DEALER_MESSAGE\""
    print_line ""
    print_line "  ${YELLOW}${TXT[bandit_label_reels]}:${NC}"
    render_reels "${BANDIT_REELS[@]}"
    print_line ""
    print_line "  ${YELLOW}${TXT[label_your_whiskey]}:${NC}"
    render_whiskey $WHISKEY_LEVEL
    draw_line "$BOX_BL" "$BOX_H" "$BOX_BR"
}

render_reels() {
    local r1=$1 r2=$2 r3=$3

    local line1="    $BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR  $BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR  $BOX_TL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_TR"
    local line2="    $BOX_V  $r1  $BOX_V  $BOX_V  $r2  $BOX_V  $BOX_V  $r3  $BOX_V"
    local line3="    $BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR  $BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR  $BOX_BL$BOX_H$BOX_H$BOX_H$BOX_H$BOX_H$BOX_BR"

    print_line "$line1"
    print_line "$line2"
    print_line "$line3"
}

place_bandit_bet() {
    local display_func=${CURRENT_DISPLAY_FUNC:-display_bandit}
    while true; do
        dealer_talk "idle"
        $display_func
        echo -e "\n  ${TXT[prompt_balance]}: ${YELLOW}${BALANCE}€${NC}"
        printf "  ${TXT[prompt_bet]}" "$BALANCE"
        if read input; then
            if [[ "$input" == "r" ]]; then
                show_rules "bandit"
                continue
            fi
            if [[ "$input" == "q" ]]; then
                return 1
            fi

            if ! [[ "$input" =~ ^[0-9]+$ ]] || [ "$input" -lt 1 ] || [ "$input" -gt $BALANCE ]; then
                dealer_talk "invalid_bet"
                $display_func
                sleep 2
                continue
            fi

            BET=$input
            BALANCE=$((BALANCE - BET))
            return 0
        fi
    done
}

spin_reels() {
    local delay=0.05
    DEALER_MESSAGE="..."
    for i in {1..15}; do
        BANDIT_REELS[0]="${BANDIT_SYMBOLS[$((RANDOM % ${#BANDIT_SYMBOLS[@]}))]}"
        BANDIT_REELS[1]="${BANDIT_SYMBOLS[$((RANDOM % ${#BANDIT_SYMBOLS[@]}))]}"
        BANDIT_REELS[2]="${BANDIT_SYMBOLS[$((RANDOM % ${#BANDIT_SYMBOLS[@]}))]}"
        display_bandit
        sleep $delay
    done

    for i in {1..8}; do
        BANDIT_REELS[1]="${BANDIT_SYMBOLS[$((RANDOM % ${#BANDIT_SYMBOLS[@]}))]}"
        BANDIT_REELS[2]="${BANDIT_SYMBOLS[$((RANDOM % ${#BANDIT_SYMBOLS[@]}))]}"
        display_bandit
        sleep $delay
    done

    for i in {1..8}; do
        BANDIT_REELS[2]="${BANDIT_SYMBOLS[$((RANDOM % ${#BANDIT_SYMBOLS[@]}))]}"
        display_bandit
        sleep $delay
    done
}

calculate_payout() {
    local r1="${BANDIT_REELS[0]}"
    local r2="${BANDIT_REELS[1]}"
    local r3="${BANDIT_REELS[2]}"

    if [[ "$r1" == "$r2" && "$r2" == "$r3" ]]; then
        case "$r1" in
            "$BANDIT_SEVEN")       echo 50 ;;
            "$BANDIT_DIAMOND_SYM") echo 20 ;;
            "$BANDIT_STAR")        echo 15 ;;
            "$BANDIT_CROSS")       echo 10 ;;
            "$BANDIT_CIRCLE")      echo 5 ;;
            "$BANDIT_CLOVER")      echo 3 ;;
        esac
    elif [[ "$r1" == "$r2" ]]; then
        echo 2
    else
        echo 0
    fi
}

handle_bandit_outcome() {
    local multiplier=$(calculate_payout)
    if [ "$multiplier" -gt 0 ]; then
        local win_amt=$((BET * multiplier))
        BALANCE=$((BALANCE + win_amt))
        WINS=$((WINS + 1))

        if [ "$multiplier" -eq 2 ]; then
            dealer_talk "loss"
            printf "  ${TXT[bandit_msg_win_2]}\n" "${BANDIT_REELS[0]}" "$win_amt"
        else
            dealer_talk "blackjack" # Use blackjack messages for big wins
            printf "  ${TXT[bandit_msg_win]}\n" "${BANDIT_REELS[0]}" "$win_amt"
        fi
    else
        dealer_talk "win" # Dealer wins
        LOSSES=$((LOSSES + 1))
        echo -e "  ${RED}${TXT[bandit_msg_loss]}${NC}"
    fi
}

play_bandit() {
    CURRENT_GAME="bandit"
    CURRENT_DISPLAY_FUNC="display_bandit"
    BANDIT_REELS=("?" "?" "?")
    DEALER_MESSAGE="${TXT[bandit_msg_welcome]}"

    while [ $BALANCE -gt 0 ]; do
        [ $BALANCE -gt $MAX_BALANCE ] && MAX_BALANCE=$BALANCE
        update_random

        place_bandit_bet || break
        spin_reels
        handle_bandit_outcome

        display_bandit
        whiskey_watch_event

        if [ $BALANCE -le 0 ]; then
            game_over_screen
            return
        fi

        while true; do
            echo -e "\n  ${TXT[prompt_next_round]}"
            if read -n 1 -s next_round; then break; fi
        done
        [[ "$next_round" == "q" ]] && break
    done

    clear_screen
    echo -e "  ${TXT[msg_game_ended]}: ${YELLOW}${BALANCE}€${NC}"
    printf "  ${TXT[msg_stats_summary]}\n" "$GREEN" "$WINS" "$NC" "$RED" "$LOSSES" "$NC" "$BLUE" "$PUSHES" "$NC"
    echo -e "  ${TXT[label_high_score]}: ${YELLOW}${MAX_BALANCE}€${NC}"
    [ $HAS_SOLD_WATCH -eq 1 ] && echo -e "  ${RED}${TXT[msg_watch_gone]}${NC}" || echo -e "  ${GREEN}${TXT[msg_watch_kept]}${NC}"
    sleep 2
}

register_game "${TXT[menu_bandit]}" "play_bandit" "display_bandit"
