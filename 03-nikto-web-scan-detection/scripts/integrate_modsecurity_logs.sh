#!/usr/bin/env bash
# =====================================================================
# integrate_modsecurity_logs.sh
# เพิ่ม <localfile> ชี้ไปที่ Apache error.log (ModSecurity) และ access.log ใน ossec.conf
# ใช้ log_format = syslog สำหรับ error.log (ตามเอกสาร WAF Lab with SIEM)
# ใช้กับ: Ubuntu Web Server (192.168.80.129)
# =====================================================================
set -euo pipefail

# ---------- ตรวจสอบสิทธิ์ root ----------
if [[ "${EUID}" -ne 0 ]]; then
    echo "❌ กรุณารันด้วย sudo: sudo bash $0"
    exit 1
fi

OSSEC_CONF="/var/ossec/etc/ossec.conf"
ERROR_LOG="/var/log/apache2/error.log"
ACCESS_LOG="/var/log/apache2/access.log"

echo "=============================================="
echo " Integrate ModSecurity & Apache Logs into Wazuh"
echo " Configuration: ${OSSEC_CONF}"
echo "=============================================="

# ---------- ตรวจสอบไฟล์ที่จำเป็น ----------
if [[ ! -f "${OSSEC_CONF}" ]]; then
    echo "❌ ไม่พบ ${OSSEC_CONF} — Wazuh Agent ติดตั้งแล้วหรือยัง?"
    exit 1
fi

# ---------- Backup ossec.conf ----------
BACKUP="${OSSEC_CONF}.bak.$(date +%Y%m%d%H%M%S)"
echo "[*] Backup ${OSSEC_CONF} → ${BACKUP}"
cp "${OSSEC_CONF}" "${BACKUP}"

# ---------- ตรวจสอบและเพิ่ม Apache access.log ----------
if grep -qF "<location>${ACCESS_LOG}</location>" "${OSSEC_CONF}"; then
    echo "⚠️  มี <localfile> สำหรับ ${ACCESS_LOG} อยู่แล้ว — ข้ามการเพิ่ม"
else
    echo "[*] เพิ่ม <localfile> สำหรับ ${ACCESS_LOG} (log_format=apache)..."
    python3 - "${OSSEC_CONF}" "${ACCESS_LOG}" "apache" <<'PYEOF'
import sys
conf_path, log_path, log_fmt = sys.argv[1], sys.argv[2], sys.argv[3]
with open(conf_path, "r") as f:
    content = f.read()

block = f"""
  <localfile>
    <log_format>{log_fmt}</log_format>
    <location>{log_path}</location>
  </localfile>
"""

idx = content.rfind("</ossec_config>")
if idx == -1:
    print("❌ ไม่พบ </ossec_config>", file=sys.stderr)
    sys.exit(1)

with open(conf_path, "w") as f:
    f.write(content[:idx] + block + content[idx:])
print("   ✅ แทรก access.log สำเร็จ")
PYEOF
fi

# ---------- ตรวจสอบและเพิ่ม Apache error.log (ModSecurity) ----------
if grep -qF "<location>${ERROR_LOG}</location>" "${OSSEC_CONF}"; then
    echo "⚠️  มี <localfile> สำหรับ ${ERROR_LOG} อยู่แล้ว — ข้ามการเพิ่ม"
else
    echo "[*] เพิ่ม <localfile> สำหรับ ${ERROR_LOG} (log_format=syslog)..."
    python3 - "${OSSEC_CONF}" "${ERROR_LOG}" "syslog" <<'PYEOF'
import sys
conf_path, log_path, log_fmt = sys.argv[1], sys.argv[2], sys.argv[3]
with open(conf_path, "r") as f:
    content = f.read()

block = f"""
  <localfile>
    <log_format>{log_fmt}</log_format>
    <location>{log_path}</location>
  </localfile>
"""

idx = content.rfind("</ossec_config>")
if idx == -1:
    print("❌ ไม่พบ </ossec_config>", file=sys.stderr)
    sys.exit(1)

with open(conf_path, "w") as f:
    f.write(content[:idx] + block + content[idx:])
print("   ✅ แทรก error.log (syslog) สำเร็จ")
PYEOF
fi

# ---------- รีสตาร์ท Agent ----------
echo "[*] รีสตาร์ท Wazuh Agent..."
systemctl restart wazuh-agent
sleep 3

echo ""
echo "[*] ตรวจสอบสถานะ Agent:"
systemctl --no-pager --full status wazuh-agent | head -10 || true

echo ""
echo "[*] ตรวจสอบ log ล่าสุด (10 บรรทัด):"
tail -n 10 /var/ossec/logs/ossec.log || true

echo ""
echo "=============================================="
echo " ✅ เชื่อมต่อ Log เข้า Wazuh เสร็จสิ้น"
echo "=============================================="
echo " ⚠️  หากต้องการย้อนกลับ:"
echo "    sudo cp ${BACKUP} ${OSSEC_CONF}"
echo "    sudo systemctl restart wazuh-agent"
