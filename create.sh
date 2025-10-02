#!/bin/bash

# ===========================================
# Deploy Configuration ke Poller
# Script ini akan generate & export config
# ===========================================

CENTREON_URL="https://nms-dev.awetonet.io/centreon/api"
TOKEN="9Wd2RSq3aV+q8Eoz7aWnSCy2o3ccxybN1HcVsZXyQiWpQXqJL9fhnMv6aw1ykS20"
POLLER_NAME="poller_192_168_53_10"
POLLER_IP="192.168.53.10"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "==========================================="
echo "   Deploy Configuration ke Poller"
echo "==========================================="
echo ""

# Metode 1: Menggunakan REST API untuk generate config
echo -e "${BLUE}[Metode 1] REST API - Generate Configuration${NC}"
echo "-------------------------------------------"

# Get poller ID
echo "Mendapatkan Poller ID..."
POLLERS=$(curl -s -k -X GET \
    "${CENTREON_URL}/latest/configuration/monitoring-servers" \
    -H "X-AUTH-TOKEN: ${TOKEN}")

POLLER_ID=$(echo "$POLLERS" | grep -o "\"id\":[0-9]*" | head -1 | cut -d':' -f2)
echo "Poller ID: $POLLER_ID"

if [ -z "$POLLER_ID" ]; then
    echo -e "${RED}✗ Tidak dapat menemukan Poller ID${NC}"
else
    echo ""
    echo "Generating configuration untuk poller ID: $POLLER_ID"
    
    # Alternatif: Direct web request untuk generate config
    GENERATE=$(curl -s -k -X POST \
        "${CENTREON_URL}/latest/configuration/monitoring-servers/generate-and-reload" \
        -H "Content-Type: application/json" \
        -H "X-AUTH-TOKEN: ${TOKEN}" \
        -d '{
            "monitoring_server_ids": ['"${POLLER_ID}"']
        }')
    
    echo "Response: $GENERATE"
    
    if echo "$GENERATE" | grep -qi "success\|done"; then
        echo -e "${GREEN}✓ Configuration berhasil di-generate${NC}"
    else
        echo -e "${YELLOW}⚠ Response tidak jelas, lanjut ke metode berikutnya${NC}"
    fi
fi

echo ""
echo "==========================================="
echo -e "${BLUE}[Metode 2] Manual Steps via Web UI${NC}"
echo "==========================================="
echo ""
echo "Karena API APPLYCFG tidak tersedia, ikuti langkah manual ini:"
echo ""
echo "1. Buka Centreon Web UI:"
echo "   https://nms-dev.awetonet.io/centreon"
echo ""
echo "2. Navigate ke:"
echo "   Configuration > Pollers > Pollers"
echo ""
echo "3. Pilih poller: ${POLLER_NAME}"
echo ""
echo "4. Klik tombol 'Export configuration' (icon gear)"
echo ""
echo "5. Pada dialog export, centang:"
echo "   ☑ Move Export Files"
echo "   ☑ Restart Monitoring Engine"
echo "   ☑ Restart Broker"
echo ""
echo "6. Klik 'Export'"
echo ""
echo "7. Tunggu hingga proses selesai (hijau semua)"
echo ""
echo "==========================================="
echo ""

# Cek status poller via SSH
echo -e "${BLUE}[Verifikasi] Cek Status Services di Poller${NC}"
echo "-------------------------------------------"
echo ""
echo "Menjalankan remote check ke poller..."

# Test SSH connection dan cek services
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@${POLLER_IP} '
    echo "=== Centreon Engine Status ==="
    systemctl status centengine --no-pager | head -5
    echo ""
    echo "=== Centreon Broker Status ==="
    systemctl status cbd --no-pager | head -5
    echo ""
    echo "=== Gorgone Status ==="
    systemctl status gorgoned --no-pager | head -5
    echo ""
    echo "=== Recent Centreon Engine Logs ==="
    tail -10 /var/log/centreon-engine/centengine.log
' 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠ Tidak dapat SSH ke poller${NC}"
    echo "Pastikan:"
    echo "  - SSH key sudah di-setup dari Central ke Poller"
    echo "  - atau gunakan password authentication"
    echo ""
    echo "Manual check via SSH:"
    echo "  ssh root@${POLLER_IP}"
    echo "  systemctl status centengine"
    echo "  systemctl status cbd"
    echo "  systemctl status gorgoned"
else
    echo -e "${GREEN}✓ Berhasil cek status via SSH${NC}"
fi

echo ""
echo "==========================================="
echo -e "${BLUE}[Quick Fix] Restart Services via SSH${NC}"
echo "==========================================="
echo ""
echo "Untuk memastikan poller mulai monitoring, jalankan:"
echo ""
echo "ssh root@${POLLER_IP} << 'EOF'"
echo "systemctl restart gorgoned"
echo "systemctl restart centengine"
echo "systemctl restart cbd"
echo "echo 'Services restarted'"
echo "EOF"
echo ""

read -p "Apakah ingin restart services sekarang? (y/n): " restart_confirm

if [ "$restart_confirm" = "y" ] || [ "$restart_confirm" = "Y" ]; then
    echo ""
    echo "Restarting services..."
    
    ssh -o StrictHostKeyChecking=no root@${POLLER_IP} '
        systemctl restart gorgoned
        sleep 2
        systemctl restart centengine
        sleep 2
        systemctl restart cbd
        echo ""
        echo "Services restarted!"
        echo ""
        systemctl status centengine --no-pager | grep "Active:"
        systemctl status cbd --no-pager | grep "Active:"
        systemctl status gorgoned --no-pager | grep "Active:"
    ' 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Services berhasil di-restart${NC}"
    else
        echo -e "${RED}✗ Gagal restart services via SSH${NC}"
        echo "Lakukan manual restart"
    fi
fi

echo ""
echo "==========================================="
echo -e "${BLUE}[Test] Verifikasi Monitoring${NC}"
echo "==========================================="
echo ""

echo "Test SNMP dari poller ke host..."
ssh -o StrictHostKeyChecking=no root@${POLLER_IP} "snmpwalk -v2c -c public ${POLLER_IP} sysDescr 2>&1 | head -3" 2>/dev/null

echo ""
echo "Cek current monitoring status di Web UI:"
echo "  1. Monitoring > Resources Status"
echo "  2. Filter: host_name:switch-test-01"
echo "  3. Tunggu 2-5 menit untuk data pertama"
echo ""
echo "==========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "==========================================="
echo ""
echo "Data akan mulai muncul dalam 2-5 menit"
echo "Check: Monitoring > Resources Status"
echo ""
