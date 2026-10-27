#!/bin/bash

# =====================================================================
# Script: install_wazuh_agent.sh
# Description: Installs Wazuh Agent on Ubuntu (Target Machine)
# =====================================================================
# Note: Replace <WAZUH_SERVER_IP> and <AGENT_NAME> with your actual values.

WAZUH_SERVER_IP="192.168.117.132" # Change this to your SIEM IP
AGENT_NAME="ubuntu_webserver2_agt"

echo "[+] Starting Wazuh Agent Installation..."

# 1. Import GPG Key
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

# 2. Add Wazuh Repository
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list

# 3. Update and Install Agent
sudo apt-get update
sudo apt-get install wazuh-agent -y

# 4. Configure Agent
sudo sed -i "s/MANAGER_IP/$WAZUH_SERVER_IP/g" /var/ossec/etc/ossec.conf
sudo sed -i "s/AGENT_NAME/$AGENT_NAME/g" /var/ossec/etc/ossec.conf

# 5. Enable and Start Service
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

echo "[+] Agent $AGENT_NAME installed and started successfully!"
echo "[+] Check status with: sudo systemctl status wazuh-agent"
