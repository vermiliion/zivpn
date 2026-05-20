#!/bin/bash
# =========================================================
# TOTAL UNINSTALLER FOR PREMIUM HYBRID ZIVPN MANAGEMENT SYSTEM
# Location: /root/uninstall.sh
# =========================================================

clear
echo -e "\033[1;31m==================================================\033[0m"
echo -e "\033[1;33m      PROSES UNINSTALL TOTAL PREMIUM ZIVPN SYSTEM \033[0m"
echo -e "\033[1;31m==================================================\033[0m"
echo "➜ Menghapus Cron Job Daemon dari crontab..."

crontab -l 2>/dev/null | grep -v "/usr/bin/cron-zivpn" | crontab -
systemctl stop zivpn >/dev/null 2>&1

echo "➜ Menghapus biner, script menu, dan background daemon..."
rm -f /usr/local/bin/mzivpn
rm -f /usr/bin/m-zivpn
rm -f /usr/bin/cron-zivpn

echo "➜ Membersihkan direktori database..."
rm -rf /etc/limit/zivpn

echo -e "\033[1;92m==================================================\033[0m"
echo -e "\033[1;97m   UNINSTALL BERHASIL! VPS BERSIH DARI SKRIP INI  \033[0m"
echo -e "\033[1;92m==================================================\033[0m"