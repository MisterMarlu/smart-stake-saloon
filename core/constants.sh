#!/usr/bin/env bash

# Colors and Symbols
RED=$(printf '\033[0;31m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[1;33m')
BLUE=$(printf '\033[0;34m')
NC=$(printf '\033[0m') # No Color

# Suits
HEARTS="♥"
DIAMONDS="♦"
SPADES="♠"
CLUBS="♣"

# UI Symbols
BOX_TL="╔"
BOX_TR="╗"
BOX_BL="╚"
BOX_BR="╝"
BOX_H="═"
BOX_V="║"
BOX_T_H="╦"
BOX_B_H="╩"
BOX_L_V="╠"
BOX_R_V="╣"
BOX_C_V="╫"
BOX_L_V_THIN="╟"
BOX_R_V_THIN="╢"
BOX_H_THIN="─"

# Localization
declare -A TXT
TXT[saloon_name]="SMART STAKE SALOON"
TXT[welcome_msg]="Willkommen im 'Smart Stake Saloon'. Setz dich."
TXT[dealer_name]="Luca"
TXT[label_balance]="Guthaben"
TXT[label_bet]="Einsatz"
TXT[label_max]="Max"
TXT[label_wins]="Siege"
TXT[label_losses]="Niederlagen"
TXT[label_pushes]="Unentschieden"
TXT[label_pot]="Pot"
TXT[label_dealer]="DEALER"
TXT[label_your_hand]="DEINE KARTEN"
TXT[label_community]="GEMEINSCHAFTSKARTEN"
TXT[label_your_whiskey]="DEIN WHISKEY"
TXT[label_status]="Status"
TXT[label_dealer_value]="Dealer Wert"
TXT[label_your_value]="Dein Wert"
TXT[label_unknown]="???"
TXT[whiskey_0]="Brandbeschleuniger"
TXT[whiskey_1]="Betrunken"
TXT[whiskey_2]="Leicht beschwipst"
TXT[whiskey_3]="Entspannt"
TXT[whiskey_4]="Scharfsinnig"
TXT[msg_blurry]="* Deine Sicht verschwimmt etwas... *"
TXT[menu_title]="WÄHLE DEIN SPIEL"
TXT[menu_exit]="q) Beenden"
TXT[intro_welcome]="Willkommen im 'Smart Stake Saloon'. Hier gewinnt das Haus... meistens."
TXT[intro_prompt]="Drücke eine Taste, um dein Schicksal zu besiegeln..."
TXT[msg_caught]="HEY! Du hast geschummelt!"
TXT[prompt_balance]="Dein Guthaben"
TXT[prompt_bet]="Einsatz (1-%d), 'r' Regeln, 'q' Ende: "
TXT[options_rules]="[R]egeln"
TXT[prompt_action]="Aktion"
TXT[msg_search_pockets]="Du durchsuchst deine Taschen... Nichts."
TXT[msg_watch_glimmers]="Deine goldene Uhr glänzt im schummrigen Licht."
TXT[prompt_sell_watch]="Möchtest du deine Uhr für %s50€%s versetzen? [y/n]: "
TXT[msg_sold_watch]="Ein schönes Stück. Ich passe gut darauf auf."
TXT[msg_sold_watch_confirm]="Du hast deine Uhr für 50€ versetzt."
TXT[prompt_buy_whiskey]="Dein Hals ist trocken. Whiskey kaufen für %s10€%s? [y/n]: "
TXT[msg_whiskey_burn]="Ah, das brennt gut."
TXT[msg_game_over]="Du hast alles verloren. Sogar deinen Stolz."
TXT[label_final_balance]="Endguthaben"
TXT[label_max_balance]="Max. Guthaben"
TXT[prompt_exit]="Drücke eine Taste zum Beenden..."
TXT[prompt_next_round]="Drücke eine Taste für die nächste Runde oder 'q' zum Beenden..."
TXT[msg_game_ended]="Spiel beendet. Dein Endguthaben"
TXT[msg_stats_summary]="Deine Bilanz: %s%d Siege%s, %s%d Niederlagen%s, %s%d Unentschieden%s"
TXT[label_high_score]="Höchststand"
TXT[msg_watch_gone]="Und deine Uhr ist weg."
TXT[msg_watch_kept]="Immerhin hast du deine Uhr noch."

# Rules
TXT[rules_title]="S P I E L R E G E L N"
TXT[rules_back]="Zurück zum Spiel (Beliebige Taste)"
