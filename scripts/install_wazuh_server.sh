#!/bin/bash

# =====================================================================
# Script: install_wazuh_server.sh
# Description: Downloads and installs Wazuh All-in-One (Manager, Indexer, Dashboard)
# =====================================================================

echo "[+] Starting Wazuh Server Installation..."

# 1. Download the Wazuh installation script
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh

# 2. Run the installation script (-a for all-in-one, -i for ignoring hardware check)
sudo bash ./wazuh-install.sh -a -i

echo "[+] Installation Complete!"
echo "[!] IMPORTANT: Save the admin password displayed above."
echo "[!] To open the firewall, run: sudo ufw allow 443/tcp"
