#!/usr/bin/env bash
# =====================================================================
# attack_nikto.sh
# รัน Nikto เพื่อสแกนช่องโหว่เว็บไซต์ (ใช้กับ Kali Linux: 192.168.80.130)
# รองรับการใช้งานทั้ง Nikto รอบที่ 1 และรอบที่ 2
#
# การใช้งาน:
#   bash attack_nikto.sh [IP_WEB_SERVER]
#   bash attack_nikto.sh 192.168.80.129
# =====================================================================
set -euo pipefail

TARGET="${1:-192.168.80.129}"

# ---------- ตรวจสอบ argument ----------
if [[ -z "${TARGET}" ]]; then
    echo "❌ ไม่ได้ระบุ IP เป้าหมาย"
    echo "   การใช้งาน: bash $0 <IP_WEB_SERVER>"
    echo "   ตัวอย่าง:   bash $0 192.168.80.129"
    exit 1
fi

# ---------- ตรวจสอบว่า nikto ติดตั้งแล้ว ----------
if ! command -v nikto >/dev/null 2>&1; then
    echo "❌ ไม่พบ nikto — กำลังติดตั้ง..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y
        sudo apt-get install -y nikto
    else
        echo "❌ ไม่สามารถติดตั้งอัตโนมัติได้ — โปรดติดตั้ง nikto ก่อน"
        exit 1
    fi
fi

# ---------- ตรวจสอบว่าเข้าถึงเป้าหมายได้ ----------
echo "[*] ทดสอบเชื่อมต่อ http://${TARGET} ..."
if ! curl -s -o /dev/null -m 5 -w "%{http_code}" "http://${TARGET}" | grep -qE '^[23]'; then
    echo "⚠️  ไม่สามารถเข้าถึง http://${TARGET} ได้ (หรือไม่ตอบสนอง)"
    read -rp "ดำเนินการต่อหรือไม่? (y/N): " confirm
    [[ "${confirm,,}" == "y" ]] || exit 1
fi

echo ""
echo "=============================================="
echo " Nikto Web Scan — Target: http://${TARGET}"
echo "=============================================="
echo "⏳ การสแกนอาจใช้เวลา 1–5 นาที"
echo ""

# ---------- รัน Nikto ----------
# -h              : host
# -nointeractive  : ไม่ถามซ้ำ
nikto -h "http://${TARGET}" -nointeractive

echo ""
echo "=============================================="
echo " ✅ การสแกนเสร็จสิ้น"
echo "=============================================="
echo " 📊 ขั้นตอนถัดไป:"
echo "   1. ไปที่ Wazuh Dashboard > Threat Hunting"
echo "   2. Filter: agent.name:\"ubuntu-server\""
echo "   3. เปรียบเทียบ Total Event ก่อน/หลัง"
