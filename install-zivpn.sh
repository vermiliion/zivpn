#!/bin/bash
# =========================================================
# AUTOMATIC SCRIPT SYSTEM INSTALLER FOR PREMIUM ZIVPN V4 HYBRID
# Location: install-zivpn.sh (Simpan & upload ke GitHub maseee)
# =========================================================

# Menghubungkan otomatis ke repositori GitHub milik maseee
GITHUB_USER="vermiliion"
GITHUB_REPO="zivpn"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main"

clear
echo -e "\033[1;36m==================================================\033[0m"
echo -e "\033[1;33m    MEMULAI INSTALASI MODULAR SYSTEM V4 HYBRID    \033[0m"
echo -e "\033[1;36m==================================================\033[0m"

# 1. Update Paket & Install Dependensi Utama
echo "➜ Menginstal JQ, OpenSSL, Python3, BC, dan Net-Tools..."
apt update -y && apt install jq python3 wget openssl iptables ufw bc net-tools -y >/dev/null 2>&1

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

# 5. Mengunduh File Konfigurasi & Script Pendukung Langsung Dari GitHub Maseee
echo "➜ Mengunduh file konfigurasi utama (config.json)..."
wget -qO /etc/zivpn/config.json "${BASE_URL}/config.json"

echo "➜ Mengunduh Engine Backend Python (zivpn.py)..."
wget -qO /usr/local/bin/mzivpn "${BASE_URL}/zivpn.py"
chmod +x /usr/local/bin/mzivpn

echo "➜ Mengunduh Script Menu Interactive (m-zivpn)..."
wget -qO /usr/bin/m-zivpn "${BASE_URL}/m-zivpn"
chmod +x /usr/bin/m-zivpn

# 6. Membuat Script Auto-Lock & Auto-Clean Daemon (Cron Daemon Pemantau)
echo "➜ Membuat Background Cron Daemon Pemantau..."
cat << 'EOC' > /usr/bin/cron-zivpn
#!/bin/bash
/usr/local/bin/mzivpn sync >/dev/null 2>&1
EOC
chmod +x /usr/bin/cron-zivpn

# Mendaftarkan ke Crontab untuk berjalan otomatis setiap 5 menit
crontab -l 2>/dev/null | grep -v "/usr/bin/cron-zivpn" | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/cron-zivpn") | crontab -

# 7. Membuat Systemd Service Sesuai Perintah Eksekusi Biner Asli
echo "➜ Membuat Systemd Service daemon..."
cat << 'EOS' > /etc/systemd/system/zivpn.service
[Unit]
Description=zivpn VPN Server Premium Modular Hybrid V4
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
EOS

# 8. Pengaturan Buffer Sistem, Firewall, & IPTables Routing UDP Range Port
echo "➜ Mengonfigurasi Network Routing & Firewall..."
sysctl -w net.core.rmem_max=16777216 > /dev/null 2>&1
sysctl -w net.core.wmem_max=16777216 > /dev/null 2>&1

NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -F PREROUTING 2>/dev/null
iptables -t nat -A PREROUTING -i "$NIC" -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp >/dev/null 2>&1
ufw allow 5667/udp >/dev/null 2>&1

# Menjalankan Layanan Core ZIVPN & Pemicu Sinkronisasi Awal
systemctl daemon-reload
systemctl enable zivpn >/dev/null 2>&1
systemctl restart zivpn >/dev/null 2>&1
/usr/local/bin/mzivpn sync >/dev/null 2>&1
hash -r

echo -e "\033[1;92m==================================================\033[0m"
echo -e "\033[1;97m    INSTALASI BERHASIL DIUNDUH DARI GITHUB!       \033[0m"
echo -e "\033[1;92m    Akses Menu Utama Kapan Saja: m-zivpn          \033[0m"
echo -e "\033[1;92m==================================================\033[0m"
sed -i 's/\r$//' /usr/bin/m-zivpn
sed -i 's/\r$//' /usr/local/bin/mzivpn