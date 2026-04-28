#!/usr/bin/env bash

# Texas Hold'em Implementation

th_get_poker_value() {
    local card=$1
    local rank=${card%?}
    case $rank in
        A) echo 14 ;;
        K) echo 13 ;;
        Q) echo 12 ;;
        J) echo 11 ;;
        10) echo 10 ;;
        *) echo "$rank" ;;
    esac
}

th_get_poker_suit() {
    echo "${1: -1}"
}

th_evaluate_poker_hand() {
    local cards=("$@")
    local ranks=()
    local suits=()
    for c in "${cards[@]}"; do
        ranks+=($(th_get_poker_value "$c"))
        suits+=($(th_get_poker_suit "$c"))
    done

    # Sort ranks descending
    local sorted_ranks=($(printf "%s\n" "${ranks[@]}" | sort -nr))

    # Count ranks
    declare -A rank_counts
    for r in "${sorted_ranks[@]}"; do
        ((rank_counts[$r]++))
    done

    # Count suits
    declare -A suit_counts
    local flush_suit=""
    for s in "${suits[@]}"; do
        ((suit_counts[$s]++))
        if [ ${suit_counts[$s]} -ge 5 ]; then
            flush_suit="$s"
        fi
    done

    # Check for Straight
    local unique_ranks=($(printf "%s\n" "${sorted_ranks[@]}" | sort -nu -r))
    local straight_high=0
    # Add low Ace if present
    local unique_ranks_with_low_ace
    if [[ " ${unique_ranks[*]} " =~ " 14 " ]]; then
        unique_ranks_with_low_ace=("${unique_ranks[@]}" 1)
    else
        unique_ranks_with_low_ace=("${unique_ranks[@]}")
    fi

    for ((i=0; i<=${#unique_ranks_with_low_ace[@]}-5; i++)); do
        if [ $((unique_ranks_with_low_ace[i] - unique_ranks_with_low_ace[i+4])) -eq 4 ]; then
            straight_high=${unique_ranks_with_low_ace[i]}
            break
        fi
    done

    # Check for Flush and Straight Flush
    if [ -n "$flush_suit" ]; then
        local flush_ranks=()
        for c in "${cards[@]}"; do
            if [ "$(th_get_poker_suit "$c")" == "$flush_suit" ]; then
                flush_ranks+=($(th_get_poker_value "$c"))
            fi
        done
        local sorted_flush_ranks=($(printf "%s\n" "${flush_ranks[@]}" | sort -nr))

        # Straight flush check
        local sf_high=0
        local u_flush_ranks=($(printf "%s\n" "${sorted_flush_ranks[@]}" | sort -nu -r))
        local u_flush_ranks_with_low_ace
        if [[ " ${u_flush_ranks[*]} " =~ " 14 " ]]; then
            u_flush_ranks_with_low_ace=("${u_flush_ranks[@]}" 1)
        else
            u_flush_ranks_with_low_ace=("${u_flush_ranks[@]}")
        fi
        for ((i=0; i<=${#u_flush_ranks_with_low_ace[@]}-5; i++)); do
            if [ $((u_flush_ranks_with_low_ace[i] - u_flush_ranks_with_low_ace[i+4])) -eq 4 ]; then
                sf_high=${u_flush_ranks_with_low_ace[i]}
                break
            fi
        done

        if [ $sf_high -eq 14 ]; then
            printf "91400000000"
            return
        elif [ $sf_high -gt 0 ]; then
            printf "8%02d00000000" $sf_high
            return
        fi
    fi

    # 4 of a kind
    for r in "${!rank_counts[@]}"; do
        if [ ${rank_counts[$r]} -eq 4 ]; then
            local kicker=0
            for k in "${sorted_ranks[@]}"; do
                if [ $k -ne $r ]; then kicker=$k; break; fi
            done
            printf "7%02d%02d000000" $r $kicker
            return
        fi
    done

    # Full House
    local triple=0
    local pair=0
    for r in $(printf "%s\n" "${!rank_counts[@]}" | sort -nr); do
        if [ ${rank_counts[$r]} -ge 3 ] && [ $triple -eq 0 ]; then
            triple=$r
        elif [ ${rank_counts[$r]} -ge 2 ] && [ $pair -eq 0 ]; then
            pair=$r
        fi
    done
    if [ $triple -gt 0 ] && [ $pair -gt 0 ]; then
        printf "6%02d%02d000000" $triple $pair
        return
    fi

    # Flush
    if [ -n "$flush_suit" ]; then
        printf "5%02d%02d%02d%02d%02d" ${sorted_flush_ranks[0]} ${sorted_flush_ranks[1]} ${sorted_flush_ranks[2]} ${sorted_flush_ranks[3]} ${sorted_flush_ranks[4]}
        return
    fi

    # Straight
    if [ $straight_high -gt 0 ]; then
        printf "4%02d00000000" $straight_high
        return
    fi

    # 3 of a kind
    if [ $triple -gt 0 ]; then
        local k1=0 k2=0
        for k in "${sorted_ranks[@]}"; do
            if [ $k -ne $triple ]; then
                if [ $k1 -eq 0 ]; then k1=$k; elif [ $k2 -eq 0 ]; then k2=$k; fi
            fi
        done
        printf "3%02d%02d%02d0000" $triple $k1 $k2
        return
    fi

    # 2 Pair
    local p1=0 p2=0
    for r in $(printf "%s\n" "${!rank_counts[@]}" | sort -nr); do
        if [ ${rank_counts[$r]} -ge 2 ]; then
            if [ $p1 -eq 0 ]; then p1=$r; elif [ $p2 -eq 0 ]; then p2=$r; fi
        fi
    done
    if [ $p1 -gt 0 ] && [ $p2 -gt 0 ]; then
        local k1=0
        for k in "${sorted_ranks[@]}"; do
            if [ $k -ne $p1 ] && [ $k -ne $p2 ]; then k1=$k; break; fi
        done
        printf "2%02d%02d%02d0000" $p1 $p2 $k1
        return
    fi

    # 1 Pair
    if [ $p1 -gt 0 ]; then
        local k1=0 k2=0 k3=0
        for k in "${sorted_ranks[@]}"; do
            if [ $k -ne $p1 ]; then
                if [ $k1 -eq 0 ]; then k1=$k; elif [ $k2 -eq 0 ]; then k2=$k; elif [ $k3 -eq 0 ]; then k3=$k; fi
            fi
        done
        printf "1%02d%02d%02d%02d00" $p1 $k1 $k2 $k3
        return
    fi

    # High Card
    printf "0%02d%02d%02d%02d%02d" ${sorted_ranks[0]} ${sorted_ranks[1]} ${sorted_ranks[2]} ${sorted_ranks[3]} ${sorted_ranks[4]}
}

th_get_hand_name() {
    local score=$1
    local type=${score:0:1}
    echo "${TXT[poker_hand_$type]}"
}

th_display_poker_board() {
    local reveal_dealer=$1
    REVEAL_DEALER_STATE=$reveal_dealer
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
    local pad2=$(( col_w - 4 - ${#TXT[label_pot]} ))
    local pad3=$(( last_col_w - 4 - ${#TXT[label_max]} ))
    (( pad1 < 0 )) && pad1=0; (( pad2 < 0 )) && pad2=0; (( pad3 < 0 )) && pad3=0

    printf "${BLUE}%s${NC} ${TXT[label_balance]}: ${YELLOW}%-*s${NC}" "$BOX_V" $((pad1 + 3)) "${BALANCE}€"
    printf "${BLUE}%s${NC} ${TXT[label_pot]}: ${YELLOW}%-*s${NC}" "$BOX_V" $((pad2 + 3)) "${POT}€"
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
    else
        render_cards "all" "${DEALER_HAND[@]}"
    fi

    print_line ""
    print_line "  ${BLUE}${TXT[label_community]}:${NC}"
    if [ ${#COMMUNITY_CARDS[@]} -eq 0 ]; then
        print_line "  (Noch keine Karten)"
    else
        render_cards "false" "${COMMUNITY_CARDS[@]}"
    fi

    print_line ""
    print_line "  ${GREEN}${TXT[label_your_hand]}:${NC}"
    render_cards "false" "${PLAYER_HAND[@]}"

    print_line ""
    print_line "  ${YELLOW}${TXT[label_your_whiskey]}:${NC}"
    render_whiskey $WHISKEY_LEVEL
    draw_line "$BOX_BL" "$BOX_H" "$BOX_BR"
}

th_poker_betting_round() {
    local round_name=$1
    while true; do
        dealer_talk "idle"
        th_display_poker_board "false"
        printf "  %s" "${TXT[poker_prompt_bet]}"
        read -n 1 -s choice
        echo ""
        case ${choice,,} in
            r) show_rules "poker"; continue ;;
            f) return 1 ;; # Folded
            c) return 0 ;; # Checked/Called
            b)
                printf "  "
                printf "${TXT[poker_prompt_raise]}" "$BALANCE"
                read input
                if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le $BALANCE ]; then
                    local raise=$input
                    BALANCE=$((BALANCE - raise))
                    POT=$((POT + raise * 2)) # Dealer calls
                    return 0
                else
                    continue
                fi
                ;;
        esac
    done
}

play_texas_holdem() {
    CURRENT_GAME="poker"
    CURRENT_DISPLAY_FUNC="th_display_poker_board"
    DEALER_MESSAGE="${TXT[poker_msg_welcome]}"
    init_deck
    shuffle_deck

    while [ $BALANCE -gt 0 ]; do
        [ $BALANCE -gt $MAX_BALANCE ] && MAX_BALANCE=$BALANCE
        update_random
        POT=0
        PLAYER_HAND=()
        DEALER_HAND=()
        COMMUNITY_CARDS=()
        REVEAL_DEALER_STATE="false"

        # Ante
        local ante=5
        if [ $BALANCE -lt $ante ]; then ante=$BALANCE; fi
        BALANCE=$((BALANCE - ante))
        POT=$((ante * 2))

        # Deal hole cards
        draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD")
        draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD")
        draw_card; PLAYER_HAND+=("$LAST_DRAWN_CARD")
        draw_card; DEALER_HAND+=("$LAST_DRAWN_CARD")

        # Pre-flop betting
        th_poker_betting_round "Pre-flop" || {
            LOSSES=$((LOSSES + 1)); whiskey_watch_event;
            # Check for quit even after folding
            while true; do
                echo -e "\n  ${TXT[prompt_next_round]}"
                if read -n 1 -s next_round; then break; fi
            done
            [[ "$next_round" == "q" ]] && break
            continue
        }

        # Flop
        DEALER_MESSAGE="${TXT[poker_msg_deal]}"
        draw_card; COMMUNITY_CARDS+=("$LAST_DRAWN_CARD")
        draw_card; COMMUNITY_CARDS+=("$LAST_DRAWN_CARD")
        draw_card; COMMUNITY_CARDS+=("$LAST_DRAWN_CARD")
        th_display_poker_board "false"
        sleep 1

        th_poker_betting_round "Flop" || {
            LOSSES=$((LOSSES + 1)); whiskey_watch_event;
            while true; do
                echo -e "\n  ${TXT[prompt_next_round]}"
                if read -n 1 -s next_round; then break; fi
            done
            [[ "$next_round" == "q" ]] && break
            continue
        }

        # Turn
        DEALER_MESSAGE="${TXT[poker_msg_turn]}"
        draw_card; COMMUNITY_CARDS+=("$LAST_DRAWN_CARD")
        th_display_poker_board "false"
        sleep 1

        th_poker_betting_round "Turn" || {
            LOSSES=$((LOSSES + 1)); whiskey_watch_event;
            while true; do
                echo -e "\n  ${TXT[prompt_next_round]}"
                if read -n 1 -s next_round; then break; fi
            done
            [[ "$next_round" == "q" ]] && break
            continue
        }

        # River
        DEALER_MESSAGE="${TXT[poker_msg_river]}"
        draw_card; COMMUNITY_CARDS+=("$LAST_DRAWN_CARD")
        th_display_poker_board "false"
        sleep 1

        th_poker_betting_round "River" || {
            LOSSES=$((LOSSES + 1)); whiskey_watch_event;
            while true; do
                echo -e "\n  ${TXT[prompt_next_round]}"
                if read -n 1 -s next_round; then break; fi
            done
            [[ "$next_round" == "q" ]] && break
            continue
        }

        # Showdown
        REVEAL_DEALER_STATE="true"
        local p_score=$(th_evaluate_poker_hand "${PLAYER_HAND[@]}" "${COMMUNITY_CARDS[@]}")
        local d_score=$(th_evaluate_poker_hand "${DEALER_HAND[@]}" "${COMMUNITY_CARDS[@]}")

        th_display_poker_board "true"
        echo -e "  ${TXT[label_your_hand]}: $(th_get_hand_name $p_score)"
        echo -e "  ${TXT[label_dealer]}: $(th_get_hand_name $d_score)"
        sleep 2

        if [[ "$p_score" > "$d_score" ]]; then
            dealer_talk "loss"
            th_display_poker_board "true"
            printf "${GREEN}  ${TXT[poker_msg_win]}${NC}\n" "$POT"
            BALANCE=$((BALANCE + POT))
            WINS=$((WINS + 1))
        elif [[ "$p_score" < "$d_score" ]]; then
            dealer_talk "win"
            th_display_poker_board "true"
            printf "${RED}  ${TXT[poker_msg_loss]}${NC}\n" "$POT"
            LOSSES=$((LOSSES + 1))
        else
            dealer_talk "push"
            th_display_poker_board "true"
            echo -e "${YELLOW}  ${TXT[poker_msg_push]}${NC}"
            BALANCE=$((BALANCE + POT / 2))
            PUSHES=$((PUSHES + 1))
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

register_game "${TXT[menu_poker]}" "play_texas_holdem" "th_display_poker_board"
