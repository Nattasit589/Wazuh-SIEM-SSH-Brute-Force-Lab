#!/bin/bash
# =====================================================================
# Script: run_nikto_scan.sh
# Description: Executes a Nikto web vulnerability scan against the target
# Run on: Kali Linux (Attacker VM)
# =====================================================================

set -euo pipefail

TARGET_IP="192.168.117.131"
TARGET_PORT="80"

if ! command -v nikto >/dev/null 2>&1; then
    echo "[!] Nikto is required on Kali Linux. Install with: sudo apt install -y nikto" >&2
    exit 1
fi

echo "=========================================================="
echo " Nikto Web Vulnerability Scanning Simulation"
echo " Target: http://${TARGET_IP}:${TARGET_PORT}"
echo "=========================================================="

echo "[+] Initiating Nikto scan..."
# -Tuning 1,2,3 scans for interesting files, misconfigurations, and information disclosure
nikto -h "http://${TARGET_IP}:${TARGET_PORT}" -Tuning 1,2,3

echo ""
echo "[✓] Scan completed."
echo "[*] Check Apache access log on the target: sudo tail -n 50 /var/log/apache2/access.log"
echo "[*] Check Wazuh Dashboard for Rule 31101 (Nikto web scanner detected) and Rule 31106."

