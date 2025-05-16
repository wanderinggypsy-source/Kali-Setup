#!/bin/bash

# ANSI color codes
RED="\e[31m"
RESET="\e[0m"

# Try to load machine info from ~/.currentboxinfo first
if [[ -f "$HOME/.currentboxinfo" ]]; then
    source "$HOME/.currentboxinfo"
    MACHINE_NAME=${MACHINE_NAME:-"(no machine set)"}
    MACHINE_IP=${MACHINE_IP:-"(no IP set)"}
else
    if [[ -f "$HOME/.currentbox" ]]; then
        BOX_DIR=$(<"$HOME/.currentbox")
        MACHINE_NAME=$(basename "$BOX_DIR")
        if [[ -f "$BOX_DIR/ip.txt" ]]; then
            MACHINE_IP=$(<"$BOX_DIR/ip.txt")
        else
            MACHINE_IP="(IP file missing)"
        fi
    else
        MACHINE_NAME="(no active machine)"
        MACHINE_IP="(no IP)"
    fi
fi

cat << "EOF"
█     █░▓█████  ███▄    █ ▓█████▄  ██▓  ▄████  ▒█████
▓█░ █ ░█░▓█   ▀  ██ ▀█   █ ▒██▀ ██▌▓██▒ ██▒ ▀█▒▒██▒  ██▒
▒█░ █ ░█ ▒███   ▓██  ▀█ ██▒░██   █▌▒██▒▒██░▄▄▄░▒██░  ██▒
░█░ █ ░█ ▒▓█  ▄ ▓██▒  ▐▌██▒░▓█▄   ▌░██░░▓█  ██▓▒██   ██░
░░██▒██▓ ░▒████▒▒██░   ▓██░░▒████▓ ░██░░▒▓███▀▒░ ████▓▒░
 ░ ▓░▒ ▒  ░░ ▒░ ░░ ▒░   ▒ ▒  ▒▒▓  ▒ ░▓   ░▒   ▒ ░ ▒░▒░▒░
   ▒ ░ ░   ░ ░  ░░ ░░   ░ ▒░ ░ ▒  ▒  ▒ ░  ░   ░   ░ ▒ ▒░
   ░   ░     ░      ░   ░ ░  ░ ░  ░  ▒ ░░ ░   ░ ░ ░ ░ ▒
     ░       ░  ░         ░    ░     ░        ░     ░ ░
                              ░
──────────────────────────────────────────────────────
   WELCOME TO: THE HACKER LAB
──────────────────────────────────────────────────────
EOF

# Print WARNING in red
echo -e "${RED}WARNING: UNAUTHORISED RESULT IN SPANKINGS${RESET}"
echo "──────────────────────────────────────────────────────"

# Print machine info with machine name in red
echo -e "Current Machine: ${RED}$MACHINE_NAME${RESET}"
echo -e "Current IP for Machine: ${RED}$MACHINE_IP${RESET}"
echo

# VPN IP detection
TUN0_IP=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
TUN1_IP=$(ip -4 addr show tun1 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [[ -n "$TUN0_IP" ]]; then
    if [[ -n "$TUN1_IP" ]]; then
        echo -e "Kali IP: ${RED}$TUN0_IP $TUN1_IP${RESET}"
    else
        echo -e "Kali IP: ${RED}$TUN0_IP${RESET}"
    fi
else
    echo -e "Kali IP: ${RED}No active VPN${RESET}"
fi
