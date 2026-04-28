#!/usr/bin/env bash

# Chuck-a-Luck Implementation

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

display_chuck_board() {
    local reveal=$1
    REVEAL_DEALER_STATE=$reveal
    update_board_width
    clear_screen

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

    # Euro symbol handling
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

    if [ "$CHOSEN_NUMBER" -gt 0 ]; then
        print_line "  ${TXT[chuck_label_chosen]}: ${YELLOW}$CHOSEN_NUMBER${NC}"
    else
        print_line "  ${TXT[chuck_label_chosen]}: ${YELLOW}-${NC}"
    fi
    print_line ""
    print_line "  ${BLUE}${TXT[chuck_label_dice]}:${NC}"
    render_dice "$reveal" "${CHUCK_DICE[@]}"

    print_line ""
    print_line "  ${YELLOW}${TXT[label_your_whiskey]}:${NC}"
    render_whiskey $WHISKEY_LEVEL
    draw_line "$BOX_BL" "$BOX_H" "$BOX_BR"
}

caught_cheating() {
    update_board_width
    clear_screen
    echo -e "${RED}"
    type_text "  ${TXT[chuck_msg_caught]}" 0.1
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

play_chuck_a_luck() {
    CURRENT_GAME="chuck"
    CURRENT_DISPLAY_FUNC="display_chuck_board"
    DEALER_MESSAGE="${TXT[chuck_msg_welcome]}"
    CHOSEN_NUMBER=0
    CHUCK_DICE=(0 0 0)
    REVEAL_DEALER_STATE="false"

    while [ $BALANCE -gt 0 ]; do
        [ $BALANCE -gt $MAX_BALANCE ] && MAX_BALANCE=$BALANCE
        update_random
        REVEAL_DEALER_STATE="false"
        CHOSEN_NUMBER=0
        CHUCK_DICE=(0 0 0)

        # Bet
        place_bet || break

        # Choose number
        while true; do
            display_chuck_board "false"
            printf "  ${TXT[chuck_prompt_number]}"
            if read -n 1 input; then
                echo ""
                if [[ "$input" == "r" ]]; then
                    show_rules "chuck"
                    continue
                fi
                if [[ "$input" =~ ^[1-6]$ ]]; then
                    CHOSEN_NUMBER=$input
                    break
                fi
            fi
        done

        # Tilt?
        display_chuck_board "false"
        printf "  ${TXT[chuck_prompt_tilt]}"
        if ! read -n 1 -s tilt; then tilt="n"; fi
        echo ""

        local rigged="false"
        if [[ ${tilt,,} == "t" ]]; then
            # 15% chance caught
            if (( RANDOM % 100 < 15 )); then
                caught_cheating
                return
            fi
            rigged="true"
        fi

        # Roll
        for i in {0..2}; do
            CHUCK_DICE[$i]=$((RANDOM % 6 + 1))
            if [[ "$rigged" == "true" ]]; then
                # Increase chance: if not chosen, 40% chance to reroll to chosen
                if [ "${CHUCK_DICE[$i]}" -ne "$CHOSEN_NUMBER" ]; then
                    if (( RANDOM % 100 < 40 )); then
                        CHUCK_DICE[$i]=$CHOSEN_NUMBER
                    fi
                fi
            fi
        done

        REVEAL_DEALER_STATE="true"
        # Count matches
        local matches=0
        for d in "${CHUCK_DICE[@]}"; do
            [ "$d" -eq "$CHOSEN_NUMBER" ] && ((matches++))
        done

        display_chuck_board "true"
        sleep 1

        if [ $matches -eq 1 ]; then
            local win=$BET
            BALANCE=$((BALANCE + win * 2))
            WINS=$((WINS + 1))
            dealer_talk "loss"
            display_chuck_board "true"
            printf "${GREEN}  "
            printf "${TXT[chuck_msg_win_1]}" "$win"
            echo -e "${NC}"
        elif [ $matches -eq 2 ]; then
            local win=$((BET * 2))
            BALANCE=$((BALANCE + win + BET))
            WINS=$((WINS + 1))
            dealer_talk "loss"
            display_chuck_board "true"
            printf "${GREEN}  "
            printf "${TXT[chuck_msg_win_2]}" "$win"
            echo -e "${NC}"
        elif [ $matches -eq 3 ]; then
            local win=$((BET * 10))
            BALANCE=$((BALANCE + win + BET))
            WINS=$((WINS + 1))
            dealer_talk "loss"
            display_chuck_board "true"
            printf "${GREEN}  "
            printf "${TXT[chuck_msg_win_3]}" "$win"
            echo -e "${NC}"
        else
            LOSSES=$((LOSSES + 1))
            dealer_talk "win"
            display_chuck_board "true"
            printf "${RED}  ${TXT[chuck_msg_loss]}${NC}\n"
        fi

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
}

register_game "${TXT[menu_chuck]}" "play_chuck_a_luck" "display_chuck_board"
