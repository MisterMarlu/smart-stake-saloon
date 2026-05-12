#!/usr/bin/env bash

# Blackjack Implementation

bj_display_board() {
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
        print_line "  ${TXT[label_dealer_value]}: ${YELLOW}$(bj_calculate_hand "${DEALER_HAND[@]}")${NC}"
    else
        render_cards "true" "${DEALER_HAND[@]}"
        print_line "  ${TXT[label_dealer_value]}: ${YELLOW}${TXT[label_unknown]}${NC}"
    fi

    print_line ""
    local _phc=${#PLAYER_HANDS[@]}
    if [ "${_phc:-0}" -le 1 ]; then
        print_line "  ${GREEN}${TXT[label_your_hand]}:${NC}"
        render_cards "false" "${PLAYER_HAND[@]}"
        print_line "  ${TXT[label_your_value]}: ${YELLOW}$(bj_calculate_hand "${PLAYER_HAND[@]}")${NC}"
    else
        local _hidx _marker _hbet
        local -a _h=()
        for _hidx in "${!PLAYER_HANDS[@]}"; do
            _marker=""
            [ "$_hidx" = "${ACTIVE_HAND_INDEX:-0}" ] && _marker=" ${YELLOW}<<${NC}"
            _hbet=${PLAYER_HAND_BETS[$_hidx]}
            print_line "  ${GREEN}${TXT[label_your_hand]} $((_hidx + 1)):${NC} (${YELLOW}${_hbet}€${NC})${_marker}"
            read -r -a _h <<< "${PLAYER_HANDS[$_hidx]}"
            render_cards "false" "${_h[@]}"
            print_line "  ${TXT[label_your_value]}: ${YELLOW}$(bj_calculate_hand "${_h[@]}")${NC}"
            print_line ""
        done
    fi

    print_line ""
    print_line "  ${YELLOW}${TXT[label_your_whiskey]}:${NC}"
    render_whiskey $WHISKEY_LEVEL
    draw_line "$BOX_BL" "$BOX_H" "$BOX_BR"
}

bj_get_rank() {
    local card=$1
    local s
    for s in "$HEARTS" "$DIAMONDS" "$SPADES" "$CLUBS"; do
        if [[ "$card" == *"$s" ]]; then
            echo "${card%$s}"
            return
        fi
    done
}

bj_can_split() {
    [ ${#PLAYER_HAND[@]} -ne 2 ] && return 1
    [ ${#PLAYER_HANDS[@]} -ge 4 ] && return 1
    local idx=${ACTIVE_HAND_INDEX:-0}
    [ "${PLAYER_HAND_FROM_ACES[$idx]:-0}" = "1" ] && return 1
    local current_bet=${PLAYER_HAND_BETS[$idx]:-$BET}
    [ $BALANCE -lt $current_bet ] && return 1
    local v1=$(get_card_value "${PLAYER_HAND[0]}")
    local v2=$(get_card_value "${PLAYER_HAND[1]}")
    [ "$v1" != "$v2" ] && return 1
    return 0
}

bj_split() {
    local idx=${ACTIVE_HAND_INDEX:-0}
    local original_bet=${PLAYER_HAND_BETS[$idx]:-$BET}

    BALANCE=$((BALANCE - original_bet))

    local card_a=${PLAYER_HAND[0]}
    local card_b=${PLAYER_HAND[1]}
    local is_aces=0
    [ "$(bj_get_rank "$card_a")" = "A" ] && is_aces=1

    PLAYER_HAND=("$card_a")
    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD")
    PLAYER_HANDS[$idx]="${PLAYER_HAND[*]}"

    local -a new_hand=("$card_b")
    draw_card; new_hand+=("$LAST_DRAWN_CARD")
    PLAYER_HANDS+=("${new_hand[*]}")
    PLAYER_HAND_BETS+=("$original_bet")

    PLAYER_HAND_FROM_ACES[$idx]=$is_aces
    PLAYER_HAND_FROM_ACES+=("$is_aces")
    PLAYER_HAND_RESULTS+=("active")

    printf "${YELLOW}  ${TXT[msg_split]}${NC}\n" "$original_bet"
    [ $is_aces -eq 1 ] && echo -e "${YELLOW}  ${TXT[msg_split_aces]}${NC}"
    sleep 1
    bj_display_board "false"
    sleep 1
    return 0
}

bj_calculate_hand() {
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


bj_deal_initial() {
    PLAYER_HAND=()
    DEALER_HAND=()
    PLAYER_HANDS=()
    PLAYER_HAND_BETS=()
    PLAYER_HAND_FROM_ACES=()
    PLAYER_HAND_RESULTS=()
    ACTIVE_HAND_INDEX=0
    DEALER_MESSAGE="${TXT[msg_initial_deal]}"

    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD"); bj_display_board "false"; sleep 0.5
    draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD"); bj_display_board "false"; sleep 0.5
    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD"); bj_display_board "false"; sleep 0.5
    draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD"); bj_display_board "false"; sleep 0.5
}

bj_check_initial_blackjack() {
    local p_val=$(bj_calculate_hand "${PLAYER_HAND[@]}")
    local d_val=$(bj_calculate_hand "${DEALER_HAND[@]}")

    if [ $p_val -eq 21 ]; then
        bj_display_board "true"
        sleep 1
        if [ $d_val -eq 21 ]; then
            dealer_talk "push"
            bj_display_board "true"
            echo -e "${YELLOW}  ${TXT[msg_both_blackjack]}${NC}"
            BALANCE=$((BALANCE + BET))
            PUSHES=$((PUSHES + 1))
        else
            dealer_talk "blackjack"
            bj_display_board "true"
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

bj_play_one_hand() {
    local idx=$1
    ACTIVE_HAND_INDEX=$idx
    BET=${PLAYER_HAND_BETS[$idx]}

    # Hand stems from split aces: exactly one extra card, then auto-stand.
    if [ "${PLAYER_HAND_FROM_ACES[$idx]:-0}" = "1" ]; then
        bj_display_board "false"
        sleep 1
        PLAYER_HAND_RESULTS[$idx]="stand"
        return
    fi

    local can_double=1
    while true; do
        bj_display_board "false"
        local opts="${TXT[options_hit]}, ${TXT[options_stand]}"
        [ $can_double -eq 1 ] && [ $BALANCE -ge $BET ] && opts+=", ${TXT[options_double]}"
        bj_can_split && opts+=", ${TXT[options_split]}"
        [ $can_double -eq 1 ] && [ ${#PLAYER_HANDS[@]} -eq 1 ] && opts+=", ${TXT[options_surrender]}"
        opts+=", ${TXT[options_rules]}"

        if [ ${#PLAYER_HANDS[@]} -gt 1 ]; then
            printf "  ${TXT[label_playing_hand]} ${TXT[prompt_action]}: ($opts): " $((idx + 1)) ${#PLAYER_HANDS[@]}
        else
            printf "  ${TXT[prompt_action]}: ($opts): "
        fi
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
                PLAYER_HANDS[$idx]="${PLAYER_HAND[*]}"
                bj_display_board "false"
                sleep 0.5
                can_double=0
                if [ $(bj_calculate_hand "${PLAYER_HAND[@]}") -gt 21 ]; then
                    PLAYER_HAND_RESULTS[$idx]="bust"
                    return
                fi
                ;;
            s)
                PLAYER_HAND_RESULTS[$idx]="stand"
                return
                ;;
            d)
                if [ $can_double -eq 1 ] && [ $BALANCE -ge $BET ]; then
                    BALANCE=$((BALANCE - BET))
                    BET=$((BET * 2))
                    PLAYER_HAND_BETS[$idx]=$BET
                    draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD")
                    PLAYER_HANDS[$idx]="${PLAYER_HAND[*]}"
                    bj_display_board "false"
                    sleep 1
                    if [ $(bj_calculate_hand "${PLAYER_HAND[@]}") -gt 21 ]; then
                        PLAYER_HAND_RESULTS[$idx]="bust"
                    else
                        PLAYER_HAND_RESULTS[$idx]="stand"
                    fi
                    return
                fi
                ;;
            p)
                if bj_can_split; then
                    bj_split
                    can_double=1
                    # If we split aces, this hand is now done (one card only).
                    if [ "${PLAYER_HAND_FROM_ACES[$idx]:-0}" = "1" ]; then
                        PLAYER_HAND_RESULTS[$idx]="stand"
                        return
                    fi
                else
                    echo -e "${RED}  ${TXT[msg_split_invalid]}${NC}"
                    sleep 1
                fi
                ;;
            u)
                if [ $can_double -eq 1 ] && [ ${#PLAYER_HANDS[@]} -eq 1 ]; then
                    PLAYER_HAND_RESULTS[$idx]="surrender"
                    return
                fi
                ;;
        esac
    done
}

bj_player_turn() {
    local idx=0
    while [ $idx -lt ${#PLAYER_HANDS[@]} ]; do
        read -r -a PLAYER_HAND <<< "${PLAYER_HANDS[$idx]}"
        bj_play_one_hand $idx
        idx=$((idx + 1))
    done
}

bj_dealer_turn() {
    DEALER_MESSAGE="${TXT[msg_bj_dealer_turn]}"
    bj_display_board "true"
    sleep 1
    while [ $(bj_calculate_hand "${DEALER_HAND[@]}") -lt 17 ]; do
        DEALER_MESSAGE="${TXT[msg_dealer_draw]}"
        bj_display_board "true"
        sleep 1
        draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD")
        bj_display_board "true"
        sleep 1
    done
}

bj_resolve_hands() {
    local need_dealer=0 idx
    for idx in "${!PLAYER_HAND_RESULTS[@]}"; do
        [ "${PLAYER_HAND_RESULTS[$idx]}" = "stand" ] && { need_dealer=1; break; }
    done

    ACTIVE_HAND_INDEX=-1
    [ $need_dealer -eq 1 ] && bj_dealer_turn

    local d_final=$(bj_calculate_hand "${DEALER_HAND[@]}")
    local total_committed=0 total_returned=0
    local -a outcome_lines=()
    local prefix line

    for idx in "${!PLAYER_HANDS[@]}"; do
        local -a h=()
        read -r -a h <<< "${PLAYER_HANDS[$idx]}"
        local hbet=${PLAYER_HAND_BETS[$idx]}
        local status=${PLAYER_HAND_RESULTS[$idx]}
        local p_val=$(bj_calculate_hand "${h[@]}")
        total_committed=$((total_committed + hbet))

        if [ ${#PLAYER_HANDS[@]} -gt 1 ]; then
            prefix=$(printf "${YELLOW}  ${TXT[label_hand_result]}${NC} " $((idx + 1)))
        else
            prefix="  "
        fi

        if [ "$status" = "surrender" ]; then
            local refund=$((hbet / 2))
            BALANCE=$((BALANCE + refund))
            total_returned=$((total_returned + refund))
            LOSSES=$((LOSSES + 1))
            line=$(printf "${prefix}${YELLOW}${TXT[msg_surrendered]}${NC}" "$refund")
        elif [ "$status" = "bust" ]; then
            LOSSES=$((LOSSES + 1))
            line=$(printf "${prefix}${RED}${TXT[msg_bust]}${NC}" "$hbet")
        elif [ $d_final -gt 21 ]; then
            BALANCE=$((BALANCE + hbet * 2))
            total_returned=$((total_returned + hbet * 2))
            WINS=$((WINS + 1))
            line=$(printf "${prefix}${GREEN}${TXT[msg_dealer_bust]}${NC}" "$hbet")
        elif [ $p_val -gt $d_final ]; then
            BALANCE=$((BALANCE + hbet * 2))
            total_returned=$((total_returned + hbet * 2))
            WINS=$((WINS + 1))
            line=$(printf "${prefix}${GREEN}${TXT[msg_win]}${NC}" "$hbet")
        elif [ $d_final -gt $p_val ]; then
            LOSSES=$((LOSSES + 1))
            line=$(printf "${prefix}${RED}${TXT[msg_dealer_win]}${NC}" "$d_final" "$hbet")
        else
            BALANCE=$((BALANCE + hbet))
            total_returned=$((total_returned + hbet))
            PUSHES=$((PUSHES + 1))
            line=$(printf "${prefix}${YELLOW}${TXT[msg_push]}${NC}")
        fi
        outcome_lines+=("$line")
    done

    if [ $total_returned -gt $total_committed ]; then
        dealer_talk "loss"
    elif [ $total_returned -lt $total_committed ]; then
        dealer_talk "win"
    else
        dealer_talk "push"
    fi

    ACTIVE_HAND_INDEX=-1
    bj_display_board "true"
    for line in "${outcome_lines[@]}"; do
        echo -e "$line"
    done
    sleep 2
}

bj_render_rules() {
    print_line "  ${YELLOW}BLACKJACK${NC}"
    print_line ""
    print_line "  ${TXT[rules_blackjack_1]}"
    print_line "  ${TXT[rules_blackjack_2]}"
    print_line "  ${TXT[rules_blackjack_3]}"
    print_line "  ${TXT[rules_blackjack_4]}"
    print_line "  ${TXT[rules_blackjack_5]}"
}

play_blackjack() {
    CURRENT_GAME="blackjack"
    CURRENT_DISPLAY_FUNC="bj_display_board"
    CURRENT_GAME_RULES="bj_render_rules"
    init_deck 6
    shuffle_deck
    DEALER_MESSAGE="${TXT[welcome_msg]}"

    while [ $BALANCE -gt 0 ]; do
        update_random
        [ $BALANCE -gt $MAX_BALANCE ] && MAX_BALANCE=$BALANCE

        place_bet || break
        bj_deal_initial

        PLAYER_HANDS=("${PLAYER_HAND[*]}")
        PLAYER_HAND_BETS=("$BET")
        PLAYER_HAND_FROM_ACES=(0)
        PLAYER_HAND_RESULTS=("active")
        ACTIVE_HAND_INDEX=0

        if bj_check_initial_blackjack; then
            bj_player_turn
            bj_resolve_hands
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

register_game "blackjack" "${TXT[menu_blackjack]}" "play_blackjack" "bj_display_board" "bj_render_rules"
