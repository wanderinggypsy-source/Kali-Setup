#!/bin/bash

set -e

# --- Colors & Effects ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Helper: slow print for dramatic hacker effect ---
slow_print() {
  local text="$1"
  local delay=${2:-0.03}
  while IFS= read -r -n1 char; do
    printf "%s" "$char"
    sleep $delay
  done <<< "$text"
  echo
}

# --- ASCII Hacker Intro ---
clear
cat << "EOF"
   __  __           _        __   __
  |  \/  | ___   __| | ___   \ \ / /__  _   _
  | |\/| |/ _ \ / _` |/ _ \   \ V / _ \| | | |
  | |  | | (_) | (_| |  __/    | | (_) | |_| |
  |_|  |_|\___/ \__,_|\___|    |_|\___/ \__,_|

  █▀█ █░█ █▀▀ █░░ █▀▀ █▀█   █▀█ █▀█ █▀█ █▄░█ █▀█ █▄█
  █▀▄ █▄█ █▄█ █▄▄ █▄█ █▀▄   █▀▄ █▄█ █▄█ █░▀█ █▄█ ░█░

           ─── H4CK3R SETUP 1993 ───
EOF

sleep 1

echo -e "${CYAN}Initializing scripts vault...${RESET}"
mkdir -p "$HOME/scripts" "$HOME/.config/argos"
touch "$HOME/.currentboxinfo"
sleep 0.6

slow_print "${YELLOW}Injecting base scripts into the system...${RESET}"

curl -s -o "$HOME/scripts/startbox.sh" "https://raw.githubusercontent.com/wanderinggypsy-source/Kali-Setup/main/startbox.sh"
chmod +x "$HOME/scripts"/*.sh
echo -e "${GREEN}[OK]${RESET} Scripts downloaded and executable."

sleep 0.5

echo -e "${CYAN}Updating system repositories... hold tight!${RESET}"
sudo apt update -qq

echo -e "${CYAN}Deploying core dependencies...${RESET}"
sudo apt install -y git gnome-shell-extension-prefs gnome-shell-extensions unzip wget >/dev/null
echo -e "${GREEN}[OK]${RESET} Core dependencies locked and loaded."

sleep 0.5

echo -e "${CYAN}Cloning Argos extension... the eyes of the terminal.${RESET}"
if [ ! -d "$HOME/argos" ]; then
    git clone -q https://github.com/p-e-w/argos.git "$HOME/argos"
    echo -e "${GREEN}[OK]${RESET} Argos infiltrated."
else
    echo -e "${YELLOW}[WARN]${RESET} Argos already deployed."
fi

mkdir -p ~/.local/share/gnome-shell/extensions/
cp -r "$HOME/argos/argos@pew.worldwidemann.com" ~/.local/share/gnome-shell/extensions/
gnome-extensions enable argos@pew.worldwidemann.com
echo -e "${GREEN}[OK]${RESET} Argos extension active."

sleep 0.5

echo -e "${CYAN}Constructing VPN IP watcher script...${RESET}"
cat << 'EOF' > "$HOME/.config/argos/vpn-ip.5s.sh"
#!/bin/bash

TUN0_IP=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
TUN1_IP=$(ip -4 addr show tun1 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [[ -n "$TUN0_IP" ]]; then
    if [[ -n "$TUN1_IP" ]]; then
        echo "VPN: $TUN0_IP $TUN1_IP"
    else
        echo "VPN: $TUN0_IP"
    fi
else
    echo "VPN: No active VPN"
fi
EOF
chmod +x "$HOME/.config/argos/vpn-ip.5s.sh"
echo -e "${GREEN}[OK]${RESET} VPN watcher live."

sleep 0.5

echo -e "${CYAN}Building machine info widgets for Argos...${RESET}"
cat << 'EOF' > "$HOME/.config/argos/box-name.10s.sh"
#!/bin/bash

BOX_FILE="$HOME/.currentboxinfo"

if [[ -f "$BOX_FILE" ]]; then
    source "$BOX_FILE"
    MACHINE_NAME=${MACHINE_NAME:-"(no machine)"}
    echo "💻 $MACHINE_NAME"
else
    echo "💻 (no file)"
fi
EOF

cat << 'EOF' > "$HOME/.config/argos/box-ip.10s.sh"
#!/bin/bash

BOX_FILE="$HOME/.currentboxinfo"

if [[ -f "$BOX_FILE" ]]; then
    source "$BOX_FILE"
    MACHINE_IP=${MACHINE_IP:-"(no IP)"}
    echo "🌐 $MACHINE_IP"
else
    echo "🌐 (no file)"
fi
EOF

chmod +x "$HOME/.config/argos"/box-*.10s.sh
echo -e "${GREEN}[OK]${RESET} Machine widgets assembled."

sleep 0.5

echo -e "${CYAN}Activating Dash to Dock extension...${RESET}"

if ! gnome-extensions info dash-to-dock@micxgx.gmail.com >/dev/null 2>&1; then
    echo -e "${YELLOW}Not found — installing...${RESET}"
    if ! gnome-extensions install dash-to-dock@micxgx.gmail.com; then
        echo -e "${YELLOW}Manual installation initiated...${RESET}"
        wget -q -O dash-to-dock.zip https://extensions.gnome.org/extension-data/dash-to-dockmicxgx.gmail.com.v77.shell-extension.zip
        mkdir -p ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
        unzip -oq dash-to-dock.zip -d ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
        rm dash-to-dock.zip
    fi
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    echo -e "${GREEN}[OK]${RESET} Dash to Dock ready."
else
    echo -e "${GREEN}[OK]${RESET} Dash to Dock already installed."
fi

echo
slow_print "${BOLD}${CYAN}█ Setup complete. Time to jack back in! █${RESET}" 0.05
echo -e "${YELLOW}If you're on Xorg, hit ${BOLD}Alt+F2${RESET}${YELLOW}, then type ${BOLD}r${RESET}${YELLOW} and press Enter to restart GNOME Shell."
echo -e "${YELLOW}If you're on Wayland, just log out and log back in.${RESET}"
echo

exit 0
