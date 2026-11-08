#!/bin/bash
# =====================================================================
# Script: setup_webserver.sh
# Description: Installs Apache2 web server and configures Wazuh Agent to collect access logs
# =====================================================================

set -euo pipefail

echo "[+] Updating package index and installing Apache2..."
sudo apt update
sudo apt install -y apache2

echo "[+] Starting and enabling Apache2 service..."
sudo systemctl enable --now apache2
sudo systemctl status apache2 --no-pager

OSSEC_CONF="/var/ossec/etc/ossec.conf"
ACCESS_LOG="/var/log/apache2/access.log"

if [ -f "$OSSEC_CONF" ]; then
    echo "[+] Checking if Apache access log is configured in Wazuh agent..."
    if grep -q "$ACCESS_LOG" "$OSSEC_CONF"; then
        echo "[*] Apache access log is already configured in $OSSEC_CONF"
    else
        echo "[+] Adding Apache access log block to $OSSEC_CONF..."
        sudo sed -i '/<\/ossec_config>/i \
  <localfile>\
    <log_format>apache<\/log_format>\
    <location>/var/log/apache2/access.log<\/location>\
  <\/localfile>' "$OSSEC_CONF"
        
        echo "[+] Restarting Wazuh Agent to apply log collection..."
        sudo systemctl restart wazuh-agent
    fi
else
    echo "[!] Wazuh Agent config ($OSSEC_CONF) not found. Please install the agent first."
fi

echo "[✓] Web server setup and log forwarding configuration complete."

