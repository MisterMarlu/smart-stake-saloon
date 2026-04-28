#!/usr/bin/env bash

# Game State
BALANCE=100
MAX_BALANCE=100
BET=0
POT=0
DECK=()
PLAYER_HAND=()
DEALER_HAND=()
COMMUNITY_CARDS=()
WHISKEY_LEVEL=4
HAS_SOLD_WATCH=0
WINS=0
LOSSES=0
PUSHES=0
DEALER_NAME="${TXT[dealer_name]}"
DEALER_MESSAGE="${TXT[welcome_msg]}"
REVEAL_DEALER_STATE="false"
CHOSEN_NUMBER=0
CHUCK_DICE=(0 0 0)
CURRENT_GAME=""
BOARD_WIDTH=72

# Game registration
GAMES_NAMES=()
GAMES_CMDS=()
GAMES_DISPLAYS=()

register_game() {
    GAMES_NAMES+=("$1")
    GAMES_CMDS+=("$2")
    GAMES_DISPLAYS+=("$3")
}

# Initialize Deck
init_deck() {
    DECK=()
    local suits=("$HEARTS" "$DIAMONDS" "$SPADES" "$CLUBS")
    local ranks=("2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K" "A")
    local num_decks=${1:-1}

    for ((d=0; d<num_decks; d++)); do
        for s in "${suits[@]}"; do
            for r in "${ranks[@]}"; do
                DECK+=("$r$s")
            done
        done
    done
}

# Shuffle Deck (Fisher-Yates)
shuffle_deck() {
    local i j tmp
    for ((i=${#DECK[@]}-1; i>0; i--)); do
        j=$((RANDOM % (i+1)))
        tmp=${DECK[$i]}
        DECK[$i]=${DECK[$j]}
        DECK[$j]=$tmp
    done
}

# Draw Card
draw_card() {
    if [ ${#DECK[@]} -eq 0 ]; then
        init_deck
        shuffle_deck
    fi
    LAST_DRAWN_CARD=${DECK[0]}
    DECK=("${DECK[@]:1}")
}

# Get Card Value (Common)
get_card_value() {
    local card=$1
    local rank=""
    for s in "$HEARTS" "$DIAMONDS" "$SPADES" "$CLUBS"; do
        if [[ "$card" == *"$s" ]]; then
            rank="${card%$s}"
            break
        fi
    done

    if [[ "$rank" =~ ^[0-9]+$ ]]; then
        echo "$rank"
    elif [[ "$rank" == "A" ]]; then
        echo "11"
    else
        echo "10"
    fi
}

dealer_talk() {
    local category=$1
    local messages=()

    if [[ "$DEALER_NAME" == "Kay Snider" ]]; then
        case $category in
            win)
                messages=("Habs dir doch gesagt, du Versager!" "Geld her, du Lappen." "War ja klar bei deinem Gesicht." "Geh nach Hause, du kannst nichts.")
                ;;
            loss)
                messages=("Glück für Dumme, Snider gewinnt trotzdem." "Das war Absicht, ich wollte dich nur in Sicherheit wiegen." "Du denkst du wärst schlau, was?" "Purer Zufall, du Nichtskönner.")
                ;;
            push)
                messages=("Gähn. Du langweilst mich." "Ein Unentschieden rettet dir auch nicht den Arsch." "Zitterst du etwa?" "Sogar zum Verlieren bist du zu dumm.")
                ;;
            bust)
                messages=("Zu dumm zum Rechnen?" "Klassischer Vollidioten-Move." "Soll ich dir ein Mathebuch leihen?" "Überkauft. Du bist echt ein hoffnungsloser Fall.")
                ;;
            blackjack)
                messages=("Blackjack? Du hast doch geschummelt!" "Sogar ein blindes Huhn findet mal ein Korn, du Vogel." "Freu dich nicht zu früh." "Reines Glück, keine Skills.")
                ;;
            idle)
                messages=("Mach schon, du Trödelheini." "Ich hab nicht den ganzen Tag Zeit." "Deine Uhr sieht auch billig aus." "Hör auf zu glotzen und setz!")
                ;;
            invalid_bet)
                messages=("Willst du mich verarschen? Setz was vernünftiges oder es gibt eine Klage!" "Versuchst du das nochmal, schicke ich meine Brüder!" "In Russland würdest du dafür Roulette spielen müssen.")
                ;;
        esac
    else
        case $category in
            win)
                messages=("Das Haus gewinnt immer. Irgendwann." "Tja, heute ist wohl nicht dein Glückstag." "Ich nehme das Geld gerne." "Besser Glück beim nächsten Mal, Kumpel.")
                ;;
            loss)
                messages=("Anfängerglück." "Genieß es, solange es anhält." "Ein blindes Huhn findet auch mal ein Korn." "Das war ein guter Zug, das muss ich zugeben.")
                ;;
            push)
                messages=("Ein Unentschieden... wie aufregend." "Niemand gewinnt, niemand verliert. Langweilig." "Wir machen's nochmal.")
                ;;
            bust)
                messages=("Gier frisst Hirn, was?" "Zu nah an der Sonne geflogen." "Überkauft. Klassiker.")
                ;;
            blackjack)
                messages=("Blackjack! Nicht schlecht." "Ein Naturtalent?" "Die Karten lieben dich heute.")
                ;;
            idle)
                messages=("Karten werden gemischt..." "Der Abend ist noch jung." "Hast du noch was anderes außer deiner Uhr zu bieten?")
                ;;
            invalid_bet)
                messages=("Willst du mich verarschen? Setz was vernünftiges." "Du kannst nur das setzen, was du hast.")
                ;;
        esac
    fi
    DEALER_MESSAGE=${messages[$((RANDOM % ${#messages[@]}))]}
}

whiskey_watch_event() {
    if [ $WHISKEY_LEVEL -gt 0 ]; then
        WHISKEY_LEVEL=$((WHISKEY_LEVEL - 1))
    fi

    if [ $BALANCE -le 0 ] && [ $HAS_SOLD_WATCH -eq 0 ]; then
        echo ""
        type_text "  ${TXT[msg_search_pockets]}"
        type_text "  ${TXT[msg_watch_glimmers]}"
        while true; do
            printf "  ${TXT[prompt_sell_watch]}" "$YELLOW" "$NC"
            if read -n 1 -s sell_watch; then echo ""; break; fi
        done
        if [[ ${sell_watch,,} == "y" ]]; then
            BALANCE=50
            HAS_SOLD_WATCH=1
            DEALER_MESSAGE="${TXT[msg_sold_watch]}"
            echo -e "  ${GREEN}${TXT[msg_sold_watch_confirm]}${NC}"
        fi
    fi

    if [ $BALANCE -ge 10 ] && [ $WHISKEY_LEVEL -lt 2 ]; then
        while true; do
            printf "  ${TXT[prompt_buy_whiskey]}" "$YELLOW" "$NC"
            if read -n 1 -s buy_whiskey; then echo ""; break; fi
        done
        if [[ ${buy_whiskey,,} == "y" ]]; then
            BALANCE=$((BALANCE - 10))
            WHISKEY_LEVEL=4
            echo -e "  ${GREEN}${TXT[msg_whiskey_burn]}${NC}"
            sleep 1
        fi
    fi
}

update_random() {
    RANDOM=$(date +%s)
}

place_bet() {
    local display_func=${CURRENT_DISPLAY_FUNC}
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
                update_random
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
