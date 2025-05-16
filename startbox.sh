#!/bin/bash

# Determine the real user (non-root) and their home directory
if [[ "$EUID" -eq 0 && -n "$SUDO_USER" ]]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi

USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Prompt for platform (htb or offsec)
read -p "Are you working on HTB or OffSec? (htb/offsec): " PLATFORM
PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')

if [[ "$PLATFORM" != "htb" && "$PLATFORM" != "offsec" ]]; then
    echo "❌ Invalid platform. Please enter 'htb' or 'offsec'."
    exit 1
fi

# Prompt for box name and sanitize it
read -p "Enter the box name: " BOXNAME
SANITIZED_BOXNAME=$(echo "$BOXNAME" | tr -cd '[:alnum:]_-')

if [[ -z "$SANITIZED_BOXNAME" ]]; then
    echo "❌ Invalid box name. Use alphanumeric, dash, or underscore."
    exit 1
fi

if [[ "$SANITIZED_BOXNAME" != "$BOXNAME" ]]; then
    echo "⚠️ Invalid characters removed. Using sanitized name: $SANITIZED_BOXNAME"
fi

# Set directory paths
BASE_DIR="$USER_HOME/$PLATFORM"
DEST_DIR="$BASE_DIR/$SANITIZED_BOXNAME"

# Create directories with proper permissions
if [[ "$EUID" -eq 0 ]]; then
    mkdir -p "$DEST_DIR" || { echo "❌ Failed to create directory: $DEST_DIR"; exit 1; }
    chown "$REAL_USER":"$REAL_USER" "$BASE_DIR" "$DEST_DIR"
    chmod 755 "$BASE_DIR" "$DEST_DIR"
else
    mkdir -p "$DEST_DIR" || { echo "❌ Failed to create directory: $DEST_DIR"; exit 1; }
fi

# Prompt for IP and basic validation
read -p "Enter the box IP address: " IP

if ! [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid IP address format."
    exit 1
fi

# Write IP to file with correct ownership and permissions
echo "$IP" > "$DEST_DIR/ip.txt"

if [[ "$EUID" -eq 0 ]]; then
    chown "$REAL_USER":"$REAL_USER" "$DEST_DIR/ip.txt"
fi
chmod 644 "$DEST_DIR/ip.txt"

# Write environment variables to real user's home for banner to source
echo "MACHINE_NAME=$SANITIZED_BOXNAME" > "$USER_HOME/.currentboxinfo"
echo "MACHINE_IP=$IP" >> "$USER_HOME/.currentboxinfo"

chown "$REAL_USER":"$REAL_USER" "$USER_HOME/.currentboxinfo"
chmod 600 "$USER_HOME/.currentboxinfo"

# Final output
echo "✅ Created directory: $DEST_DIR"
echo "✅ Saved IP to: $DEST_DIR/ip.txt"
echo "✅ Saved current box info to: $USER_HOME/.currentboxinfo"
echo "HAPPY HACKING!!"
