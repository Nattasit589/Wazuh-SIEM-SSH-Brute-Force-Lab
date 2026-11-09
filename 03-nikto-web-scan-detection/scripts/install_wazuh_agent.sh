#!/usr/bin/env bash
# =====================================================================
# install_wazuh_agent.sh
# ติดตั้ง Wazuh Agent + Apache2 บน Ubuntu Web Server
# ใช้กับ: Ubuntu Web Server (192.168.80.129)
#
# การใช้งาน:
#   sudo bash install_wazuh_agent.sh
#   หรือระบุค่า:
#   sudo WAZUH_MANAGER_IP=192.168.80.132 WAZUH_AGENT_NAME=ubuntu-server \
#        bash install_wazuh_agent.sh
# =====================================================================
set -euo pipefail

# ---------- ตรวจสอบสิทธิ์ root ----------
if [[ "${EUID}" -ne 0 ]]; then
    echo "❌ กรุณารันด้วย sudo: sudo bash $0"
    exit 1
fi

WAZUH_MANAGER_IP="${WAZUH_MANAGER_IP:-192.168.80.132}"
AGENT_NAME="${WAZUH_AGENT_NAME:-ubuntu-server}"

echo "=============================================="
echo " Wazuh Agent Installer"
echo " Manager IP : ${WAZUH_MANAGER_IP}"
echo " Agent Name : ${AGENT_NAME}"
echo "=============================================="

# ---------- ทดสอบเชื่อมต่อ Manager ----------
echo "[*] ทดสอบเชื่อมต่อไปยัง Manager (Port 1514)..."
if ! timeout 5 bash -c "cat < /dev/null > /dev/tcp/${WAZUH_MANAGER_IP}/1514" 2>/dev/null; then
    echo "⚠️  ไม่สามารถเชื่อมต่อ ${WAZUH_MANAGER_IP}:1514 ได้"
    read -rp "ดำเนินการต่อหรือไม่? (y/N): " confirm
    [[ "${confirm,,}" == "y" ]] || exit 1
fi

# ---------- ติดตั้ง Apache2 ----------
echo "[*] ติดตั้ง Apache2..."
apt-get update -y
apt-get install -y apache2 curl gpg
systemctl enable apache2
systemctl restart apache2

# ---------- เพิ่ม Repository ของ Wazuh ----------
echo "[*] เพิ่ม GPG Key และ Repository ของ Wazuh..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH \
    | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg --yes

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
    | tee /etc/apt/sources.list.d/wazuh.list > /dev/null

apt-get update -y

# ---------- ติดตั้ง Agent ----------
echo "[*] ติดตั้ง Wazuh Agent..."
WAZUH_MANAGER="${WAZUH_MANAGER_IP}" \
WAZUH_AGENT_NAME="${AGENT_NAME}" \
apt-get install -y wazuh-agent

# ---------- เริ่มต้น Agent ----------
echo "[*] เริ่มต้น Agent..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

sleep 3
systemctl --no-pager --full status wazuh-agent | head -20

# ---------- สรุป ----------
echo ""
echo "=============================================="
echo " ✅ ติดตั้งเสร็จสิ้น"
echo "=============================================="
echo " ตรวจสอบสถานะ: sudo systemctl status wazuh-agent"
echo " ดู log:      sudo tail -f /var/ossec/logs/ossec.log"
echo " ใน Dashboard ควรเห็น agent '${AGENT_NAME}' สถานะ Active"
echo ""
echo " ทดสอบ Apache: curl -I http://localhost"
