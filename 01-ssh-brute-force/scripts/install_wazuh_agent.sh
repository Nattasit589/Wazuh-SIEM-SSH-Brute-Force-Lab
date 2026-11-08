#!/bin/bash

# =====================================================================
# Script: install_wazuh_agent.sh
# Description: Installs Wazuh Agent on Ubuntu (Target Machine)
# =====================================================================
# Reproduction helper for a fresh installation, not the original command history.
# Confirm the package version against your manager before running.

set -euo pipefail

WAZUH_SERVER_IP="${WAZUH_SERVER_IP:-192.168.117.132}"
AGENT_NAME="${AGENT_NAME:-ubuntu_webserver2_agt}"
WAZUH_AGENT_VERSION="${WAZUH_AGENT_VERSION:-4.14.0-1}"

echo "[+] Starting Wazuh Agent Installation..."

# 1. Install prerequisites and import the key with root privileges.
sudo apt-get update
sudo apt-get install -y curl gnupg apt-transport-https
curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
sudo chmod 644 /usr/share/keyrings/wazuh.gpg

# 2. Add Wazuh Repository
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

# 3. Pass the manager and agent name to the package deployment scripts.
sudo apt-get update
sudo env WAZUH_MANAGER="$WAZUH_SERVER_IP" WAZUH_AGENT_NAME="$AGENT_NAME" \
    apt-get install -y "wazuh-agent=$WAZUH_AGENT_VERSION"

# 4. Enable, start, and check the local service.
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
sudo systemctl is-active --quiet wazuh-agent

echo "[+] Agent service is running. Verify $AGENT_NAME is Active in the dashboard."
echo "[+] Check status with: sudo systemctl status wazuh-agent"
