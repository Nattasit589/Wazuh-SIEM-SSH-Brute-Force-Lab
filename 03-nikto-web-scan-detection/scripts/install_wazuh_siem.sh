#!/usr/bin/env bash
# =====================================================================
# install_wazuh_siem.sh
# ติดตั้ง Wazuh All-in-One (Manager + Indexer + Dashboard) v4.14
# ใช้กับ: Ubuntu SIEM เท่านั้น (192.168.80.132)
# =====================================================================
set -euo pipefail

# ---------- ตรวจสอบสิทธิ์ root ----------
if [[ "${EUID}" -ne 0 ]]; then
    echo "❌ กรุณารันด้วย sudo: sudo bash $0"
    exit 1
fi

echo "=============================================="
echo " Wazuh All-in-One Installer (v4.14)"
echo "=============================================="
echo "⚠️  คำเตือน: สคริปต์นี้จะติดตั้ง Wazuh Server ทั้งชุด"
echo "   ห้ามรันบน Web Server — ใช้กับเครื่อง SIEM เท่านั้น"
echo ""

read -rp "ดำเนินการต่อหรือไม่? (y/N): " confirm
[[ "${confirm,,}" == "y" ]] || { echo "ยกเลิก"; exit 0; }

# ---------- ตรวจสอบทรัพยากรขั้นต่ำ ----------
echo "[*] ตรวจสอบทรัพยากร..."
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
DISK_GB=$(df -BG / | awk 'NR==2{print $4}' | tr -d 'G')

if [[ "${RAM_MB}" -lt 3800 ]]; then
    echo "⚠️  RAM น้อยกว่า 4 GB (พบ ${RAM_MB} MB) — Wazuh Indexer อาจทำงานไม่เสถียร"
fi
if [[ "${DISK_GB}" -lt 45 ]]; then
    echo "⚠️  Disk ว่างน้อยกว่า 50 GB (พบ ${DISK_GB} GB) — แนะนำเพิ่มก่อนติดตั้ง"
fi
echo ""

# ---------- ติดตั้ง ----------
echo "[*] อัปเดตระบบ..."
apt-get update -y
apt-get install -y curl

echo "[*] ดาวน์โหลดตัวติดตั้ง Wazuh 4.14..."
cd /tmp
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
chmod +x wazuh-install.sh

echo "[*] เริ่มต้นติดตั้ง All-in-One (อาจใช้เวลา 10–20 นาที)..."
bash ./wazuh-install.sh -a

# ---------- แสดงข้อมูลเข้าสู่ระบบ ----------
echo ""
echo "=============================================="
echo " ✅ ติดตั้งเสร็จสิ้น"
echo "=============================================="

if [[ -f wazuh-install-files.tar ]]; then
    mkdir -p /root/wazuh-credentials
    tar -xf wazuh-install-files.tar -C /root/wazuh-credentials
    echo "📁 ไฟล์ credentials ถูกเก็บที่: /root/wazuh-credentials/"
    echo ""
    echo "🔑 ข้อมูลรหัสผ่าน:"
    echo "   ตรวจสอบได้ที่ /root/wazuh-credentials/wazuh-passwords.txt"
fi

IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "192.168.80.132")
echo ""
echo "🌐 เข้า Dashboard ได้ที่: https://${IP}"
echo "   User: admin"
echo "   Password: (ดูจาก output ด้านบนหรือ wazuh-passwords.txt)"
echo ""
echo "🔍 ตรวจสอบสถานะ service:"
echo "   sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard"
