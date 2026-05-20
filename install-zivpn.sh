#!/bin/bash
# =========================================================
# AUTOMATIC SCRIPT SYSTEM INSTALLER FOR PREMIUM ZIVPN V4
# Location: /root/install-zivpn.sh
# =========================================================

GITHUB_USER="vermiliion"
GITHUB_REPO="zivpn"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main"

clear
echo -e "\033[1;36m==================================================\033[0m"
echo -e "\033[1;33m       MEMULAI INSTALASI MODULAR SYSTEM PREMIUM   \033[0m"
echo -e "\033[1;36m==================================================\033[0m"

# 1. Update Paket & Install Dependensi Utama
echo "➜ Menginstal JQ, OpenSSL, dan Python3..."
apt update -y && apt install jq python3 wget openssl iptables ufw -y >/dev/null 2>&1

# 2. Pembuatan Folder Kerja
mkdir -p /etc/zivpn
mkdir -p /etc/limit/zivpn
[ ! -f "/etc/limit/zivpn/database.json" ] && echo "{}" > "/etc/limit/zivpn/database.json"

# 3. Mengunduh Biner Core Resmi Zahid Islam (AMD64)
echo "➜ Mengunduh Core Binary ZIVPN..."
systemctl stop zivpn 1> /dev/null 2> /dev/null
wget -qO /usr/local/bin/zivpn https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64
chmod +x /usr/local/bin/zivpn

# 4. Membuat Sertifikat SSL Mandiri (Wajib bagi ZIVPN)
echo "➜ Membuat file enkripsi sertifikat SSL..."
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt" 2>/dev/null

# 5. Mengunduh File Konfigurasi Utama Langsung dari GitHub Maseee
echo "➜ Mengunduh file konfigurasi utama dari cloud..."
wget -qO /etc/zivpn/config.json "${BASE_URL}/config.json"

# 6. Download Engine Python & Menu Tampilan Utama Bash
echo "➜ Mengunduh Core Python Backend..."
wget -qO- "${BASE_URL}/zivpn.py" | tr -d '\r' > /usr/local/bin/mzivpn
chmod +x /usr/local/bin/mzivpn

echo "➜ Mengunduh Interactive Menu Manager..."
wget -qO- "${BASE_URL}/m-zivpn" | tr -d '\r' > /usr/bin/m-zivpn
chmod +x /usr/bin/m-zivpn

# 7. Membuat Systemd Service Sesuai Perintah Eksekusi Biner Asli
cat << 'EOF' > /etc/systemd/system/zivpn.service
[Unit]
Description=zivpn VPN Server Premium Modular
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# 8. Pengaturan Buffer Sistem, Firewall, & IPTables Routing UDP Range Port
echo "➜ Mengonfigurasi Network Routing & Firewall..."
sysctl -w net.core.rmem_max=16777216 > /dev/null 2>&1
sysctl -w net.core.wmem_max=16777216 > /dev/null 2>&1

NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -F PREROUTING 2>/dev/null
iptables -t nat -A PREROUTING -i "$NIC" -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp >/dev/null 2>&1
ufw allow 5667/udp >/dev/null 2>&1

# Menjalankan Layanan Core ZIVPN
systemctl daemon-reload
systemctl enable zivpn >/dev/null 2>&1
systemctl restart zivpn >/dev/null 2>&1

echo -e "\033[1;92m==================================================\033[0m"
echo -e "\033[1;97m    INSTALASI SELESAI, SYSTEM MODULAR BERJALAN!   \033[0m"
echo -e "\033[1;92m    Akses Menu Utama Kapan Saja: m-zivpn          \033[0m"
echo -e "\033[1;92m==================================================\033[0m"