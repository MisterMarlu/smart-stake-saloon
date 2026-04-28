#!/usr/bin/env bash

# Blackjack Implementation

display_board() {
    local reveal_dealer=$1
    REVEAL_DEALER_STATE=$reveal_dealer
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

    if [ "$reveal_dealer" == "true" ]; then
        render_cards "false" "${DEALER_HAND[@]}"
        print_line "  ${TXT[label_dealer_value]}: ${YELLOW}$(calculate_hand "${DEALER_HAND[@]}")${NC}"
    else
        render_cards "true" "${DEALER_HAND[@]}"
        print_line "  ${TXT[label_dealer_value]}: ${YELLOW}${TXT[label_unknown]}${NC}"
    fi

    print_line ""
    print_line "  ${GREEN}${TXT[label_your_hand]}:${NC}"
    render_cards "false" "${PLAYER_HAND[@]}"
    print_line "  ${TXT[label_your_value]}: ${YELLOW}$(calculate_hand "${PLAYER_HAND[@]}")${NC}"

    print_line ""
    print_line "  ${YELLOW}${TXT[label_your_whiskey]}:${NC}"
    render_whiskey $WHISKEY_LEVEL
    draw_line "$BOX_BL" "$BOX_H" "$BOX_BR"
}

calculate_hand() {
    local hand=("$@")
    local total=0
    local aces=0

    for card in "${hand[@]}"; do
        local val=$(get_card_value "$card")
        total=$((total + val))
        if [[ "$card" == A* ]]; then
            aces=$((aces + 1))
        fi
    done

    while [ $total -gt 21 ] && [ $aces -gt 0 ]; do
        total=$((total - 10))
        aces=$((aces - 1))
    done
    echo "$total"
}

place_bet() {
    local display_func=${CURRENT_DISPLAY_FUNC:-display_board}
    while true; do
        dealer_talk "idle"
        $display_func "false"
        echo -e "\n  ${TXT[prompt_balance]}: ${YELLOW}${BALANCE}€${NC}"
        printf "  ${TXT[prompt_bet]}" "$BALANCE"
        if read input; then
            if [[ "$input" == "r" ]]; then
                show_rules "$CURRENT_GAME"
                continue
            fi
            if [[ "$input" == "q" ]]; then
                return 1
            fi

            if ! [[ "$input" =~ ^[0-9]+$ ]] || [ "$input" -lt 1 ] || [ "$input" -gt $BALANCE ]; then
                dealer_talk "invalid_bet"
                $display_func "false"
                sleep 2
                continue
            fi

            BET=$input
            BALANCE=$((BALANCE - BET))
            return 0
        fi
    done
}

deal_initial() {
    PLAYER_HAND=()
    DEALER_HAND=()
    DEALER_MESSAGE="${TXT[msg_initial_deal]}"

    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD"); display_board "false"; sleep 0.5
    draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD"); display_board "false"; sleep 0.5
    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD"); display_board "false"; sleep 0.5
    draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD"); display_board "false"; sleep 0.5
}

check_initial_blackjack() {
    local p_val=$(calculate_hand "${PLAYER_HAND[@]}")
    local d_val=$(calculate_hand "${DEALER_HAND[@]}")

    if [ $p_val -eq 21 ]; then
        display_board "true"
        sleep 1
        if [ $d_val -eq 21 ]; then
            dealer_talk "push"
            display_board "true"
            echo -e "${YELLOW}  ${TXT[msg_both_blackjack]}${NC}"
            BALANCE=$((BALANCE + BET))
            PUSHES=$((PUSHES + 1))
        else
            dealer_talk "blackjack"
            display_board "true"
            local win_amt=$((BET * 3 / 2))
            local total_win=$((BET + win_amt))
            printf "${GREEN}  ${TXT[msg_blackjack_win]}${NC}\n" "$win_amt"
            BALANCE=$((BALANCE + total_win))
            WINS=$((WINS + 1))
        fi
        sleep 2
        return 1
    fi
    return 0
}

player_turn() {
    local can_double=1
    while true; do
        display_board "false"
        local opts="${TXT[options_hit]}, ${TXT[options_stand]}"
        [ $can_double -eq 1 ] && [ $BALANCE -ge $BET ] && opts+=", ${TXT[options_double]}"
        [ $can_double -eq 1 ] && opts+=", ${TXT[options_surrender]}"
        opts+=", ${TXT[options_rules]}"

        printf "  ${TXT[prompt_action]}: ($opts): "
        if ! read -n 1 -s choice; then continue; fi
        echo ""

        case ${choice,,} in
            r)
                show_rules "blackjack"
                continue
                ;;
            h)
                dealer_talk "idle"
                draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD")
                display_board "false"
                sleep 0.5
                can_double=0
                if [ $(calculate_hand "${PLAYER_HAND[@]}") -gt 21 ]; then
                    return 1
                fi
                ;;
            s)
                return 0
                ;;
            d)
                if [ $can_double -eq 1 ] && [ $BALANCE -ge $BET ]; then
                    BALANCE=$((BALANCE - BET))
                    BET=$((BET * 2))
                    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD")
                    display_board "false"
                    sleep 1
                    [ $(calculate_hand "${PLAYER_HAND[@]}") -gt 21 ] && return 1
                    return 0
                fi
                ;;
            u)
                if [ $can_double -eq 1 ]; then
                    return 2
                fi
                ;;
        esac
    done
}

dealer_turn() {
    DEALER_MESSAGE="${TXT[msg_dealer_turn]}"
    display_board "true"
    sleep 1
    while [ $(calculate_hand "${DEALER_HAND[@]}") -lt 17 ]; do
        DEALER_MESSAGE="${TXT[msg_dealer_draw]}"
        display_board "true"
        sleep 1
        draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD")
        display_board "true"
        sleep 1
    done
}

handle_outcome() {
    local status=$1
    if [ "$status" -eq 2 ]; then
        display_board "true"
        local refund=$((BET / 2))
        printf "${YELLOW}  ${TXT[msg_surrendered]}${NC}\n" "$refund"
        BALANCE=$((BALANCE + refund))
        LOSSES=$((LOSSES + 1))
    elif [ "$status" -eq 1 ]; then
        dealer_talk "bust"
        display_board "true"
        sleep 1
        printf "${RED}  ${TXT[msg_bust]}${NC}\n" "$BET"
        LOSSES=$((LOSSES + 1))
    else
        dealer_turn
        local p_final=$(calculate_hand "${PLAYER_HAND[@]}")
        local d_final=$(calculate_hand "${DEALER_HAND[@]}")

        if [ $d_final -gt 21 ]; then
            dealer_talk "bust"
            display_board "true"
            printf "${GREEN}  ${TXT[msg_dealer_bust]}${NC}\n" "$BET"
            BALANCE=$((BALANCE + BET * 2))
            WINS=$((WINS + 1))
        elif [ $p_final -gt $d_final ]; then
            dealer_talk "loss"
            display_board "true"
            printf "${GREEN}  ${TXT[msg_win]}${NC}\n" "$BET"
            BALANCE=$((BALANCE + BET * 2))
            WINS=$((WINS + 1))
        elif [ $d_final -gt $p_final ]; then
            dealer_talk "win"
            display_board "true"
            printf "${RED}  ${TXT[msg_dealer_win]}${NC}\n" "$d_final" "$BET"
            LOSSES=$((LOSSES + 1))
        else
            dealer_talk "push"
            display_board "true"
            echo -e "${YELLOW}  ${TXT[msg_push]}${NC}"
            BALANCE=$((BALANCE + BET))
            PUSHES=$((PUSHES + 1))
        fi
    fi
}

play_blackjack() {
    CURRENT_GAME="blackjack"
    CURRENT_DISPLAY_FUNC="display_board"
    init_deck
    shuffle_deck
    DEALER_MESSAGE="${TXT[welcome_msg]}"

    while [ $BALANCE -gt 0 ]; do
        [ $BALANCE -gt $MAX_BALANCE ] && MAX_BALANCE=$BALANCE

        place_bet || break
        deal_initial

        if check_initial_blackjack; then
            player_turn
            handle_outcome $?
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

    clear_screen
    echo -e "  ${TXT[msg_game_ended]}: ${YELLOW}${BALANCE}€${NC}"
    printf "  ${TXT[msg_stats_summary]}\n" "$GREEN" "$WINS" "$NC" "$RED" "$LOSSES" "$NC" "$BLUE" "$PUSHES" "$NC"
    echo -e "  ${TXT[label_high_score]}: ${YELLOW}${MAX_BALANCE}€${NC}"
    [ $HAS_SOLD_WATCH -eq 1 ] && echo -e "  ${RED}${TXT[msg_watch_gone]}${NC}" || echo -e "  ${GREEN}${TXT[msg_watch_kept]}${NC}"
    sleep 2
}

register_game "${TXT[menu_blackjack]}" "play_blackjack" "display_board"
