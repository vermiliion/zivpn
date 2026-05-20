#!/bin/bash
# =========================================================
# AUTOMATIC SCRIPT SYSTEM UNINSTALLER FOR PREMIUM ZIVPN V4
# Location: /root/uninstall-zivpn.sh
# =========================================================

clear
echo -e "\033[1;31m==================================================\033[0m"
echo -e "\033[1;33m       PROSES UNINSTALL TOTAL PREMIUM ZIVPN SYSTEM \033[0m"
echo -e "\033[1;31m==================================================\033[0m"

# 1. Menghentikan dan Menghapus Systemd Service
echo "➜ Menghentikan dan mencabut zivpn.service..."
systemctl stop zivpn 2>/dev/null
systemctl disable zivpn 2>/dev/null
rm -f /etc/systemd/system/zivpn.service
systemctl daemon-reload

# 2. Menghapus Cron Job Daemon Pemantau IP & Quota
echo "➜ Menghapus Background Cron Auto-Lock Daemon..."
crontab -l 2>/dev/null | grep -v "/usr/bin/cron-zivpn" | crontab -
rm -f /usr/bin/cron-zivpn

# 3. Menghapus Biner Core, Script Menu, dan Engine Python
echo "➜ Menghapus biner utama, backend engine, dan script menu..."
rm -f /usr/local/bin/zivpn
rm -f /usr/local/bin/mzivpn
rm -f /usr/bin/m-zivpn

# 4. Membersihkan Direktori Konfigurasi & Database
echo "➜ Membersihkan seluruh direktori database dan sertifikat SSL..."
rm -rf /etc/zivpn
rm -rf /etc/limit/zivpn

# 5. Membersihkan Aturan Routing IPTables & Firewall
echo "➜ Mengembalikan pengaturan network routing & firewall..."
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -D PREROUTING -i "$NIC" -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null
ufw delete allow 6000:19999/udp >/dev/null 2>&1
ufw delete allow 5667/udp >/dev/null 2>&1

echo -e "\033[1;92m==================================================\033[0m"
echo -e "\033[1;97m   UNINSTALL BERHASIL! VPS BERSIH DARI SKRIP INI  \033[0m"
echo -e "\033[1;92m==================================================\033[0m"
