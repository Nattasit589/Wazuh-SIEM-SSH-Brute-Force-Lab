#!/usr/bin/env bash
# =====================================================================
# install_modsecurity.sh
# ติดตั้ง ModSecurity (WAF) บน Apache2 + เปลี่ยน SecRuleEngine เป็น On
# ใช้กับ: Ubuntu Web Server (192.168.80.129)
# =====================================================================
set -euo pipefail

# ---------- ตรวจสอบสิทธิ์ root ----------
if [[ "${EUID}" -ne 0 ]]; then
    echo "❌ กรุณารันด้วย sudo: sudo bash $0"
    exit 1
fi

echo "=============================================="
echo " ModSecurity Installer (WAF for Apache2)"
echo "=============================================="

# ---------- ตรวจสอบว่า Apache ติดตั้งแล้ว ----------
if ! dpkg -l | grep -q apache2; then
    echo "❌ ไม่พบ Apache2 — กรุณาติดตั้งก่อน (apt install apache2 -y)"
    exit 1
fi

# ---------- ติดตั้ง ModSecurity ----------
echo "[*] ติดตั้ง libapache2-mod-security2..."
apt-get update -y
apt-get install -y libapache2-mod-security2

# ---------- เปิดใช้งานโมดูล ----------
echo "[*] เปิดใช้งานโมดูล security2..."
a2enmod security2

# ---------- คัดลอกไฟล์คอนฟิก ----------
CONF=/etc/modsecurity/modsecurity.conf
if [[ ! -f "${CONF}" ]]; then
    echo "[*] คัดลอก modsecurity.conf-recommended → modsecurity.conf..."
    cp /etc/modsecurity/modsecurity.conf-recommended "${CONF}"
else
    echo "[*] พบไฟล์ ${CONF} อยู่แล้ว — backup"
    cp "${CONF}" "${CONF}.bak.$(date +%Y%m%d%H%M%S)"
fi

# ---------- เปลี่ยน SecRuleEngine → On ----------
echo "[*] เปลี่ยน SecRuleEngine เป็น On (โหมดบล็อก)..."
if grep -q '^SecRuleEngine DetectionOnly' "${CONF}"; then
    sed -i 's/^SecRuleEngine DetectionOnly/SecRuleEngine On/' "${CONF}"
    echo "   ✅ แก้ไขแล้ว"
else
    echo "   ⚠️  ไม่พบบรรทัด 'SecRuleEngine DetectionOnly' — โปรดตรวจสอบด้วยตนเอง"
fi

# ---------- รีสตาร์ท Apache ----------
echo "[*] รีสตาร์ท Apache2..."
if ! apache2ctl configtest 2>/dev/null; then
    echo "❌ Apache config มีปัญหา — ยกเลิกการรีสตาร์ท"
    apache2ctl configtest
    exit 1
fi
systemctl restart apache2

# ---------- ตรวจสอบ ----------
echo ""
echo "[*] ตรวจสอบโมดูล:"
apache2ctl -M | grep security2 || echo "⚠️  ไม่พบ security2_module"

echo ""
echo "[*] ตรวจสอบ SecRuleEngine:"
grep '^SecRuleEngine' "${CONF}" || echo "⚠️  ไม่พบบรรทัด SecRuleEngine"

echo ""
echo "=============================================="
echo " ✅ ติดตั้ง ModSecurity เสร็จสิ้น"
echo "=============================================="
echo " ⚠️  อย่าลืมเชื่อมต่อ Log เข้า Wazuh ด้วยสคริปต์:"
echo "    sudo bash integrate_modsecurity_logs.sh"
