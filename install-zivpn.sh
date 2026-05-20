#!/bin/bash
# =========================================================
# AUTOMATIC SCRIPT SYSTEM INSTALLER FOR PREMIUM ZIVPN V4
# Location: /root/install.sh
# =========================================================

GITHUB_USER="vermiliion"
GITHUB_REPO="zivpn"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/main"

clear
echo -e "\033[1;36m==================================================\033[0m"
echo -e "\033[1;33m       MEMULAI INSTALASI MODULAR SYSTEM PREMIUM   \033[0m"
echo -e "\033[1;36m==================================================\033[0m"

# 1. Update Paket & Install Dependensi Utama
echo "➜ Menginstal JQ dan Python3..."
apt update -y && apt install jq python3 wget -y >/dev/null 2>&1

# 2. Pembuatan Folder Database & Pengunduhan File Konfigurasi Dasar
mkdir -p /etc/zivpn
mkdir -p /etc/limit/zivpn
[ ! -f "/etc/limit/zivpn/database.json" ] && echo "{}" > "/etc/limit/zivpn/database.json"

echo "➜ Mengunduh file konfigurasi utama..."
wget -qO /etc/zivpn/config.json "${BASE_URL}/config.json"

# 3. Download Core Python Engine
echo "➜ Mengunduh Core Python Backend..."
wget -qO /usr/local/bin/mzivpn "${BASE_URL}/zivpn.py"
chmod +x /usr/local/bin/mzivpn

# 4. Download Menu Frontend
echo "➜ Mengunduh Interactive Menu Manager..."
wget -qO /usr/bin/m-zivpn "${BASE_URL}/m-zivpn"
chmod +x /usr/bin/m-zivpn

# 5. Mendaftarkan Background Cron Daemon Pemantau IP Multi-Login
echo "➜ Mengaktifkan Background Cron Auto-Lock Daemon..."
cat << 'EOF' > /usr/bin/cron-zivpn
#!/bin/bash
DB_JSON="/etc/limit/zivpn/database.json"
ZIVPN_LOG="/var/log/syslog"
today=$(date +%Y-%m-%d)
now=$(date +%s)

[ ! -f "$DB_JSON" ] && exit 0

for u in $(jq -r 'keys[]' "$DB_JSON" 2>/dev/null); do
    local exp=$(jq -r --arg u "$u" '.[$u].expired_date' "$DB_JSON")
    local lq=$(jq -r --arg u "$u" '.[$u].limit_quota' "$DB_JSON")
    local uq=$(jq -r --arg u "$u" '.[$u].usage_quota' "$DB_JSON")
    local stat=$(jq -r --arg u "$u" '.[$u].status' "$DB_JSON")
    
    if [[ "$today" > "$exp" || $uq -ge $lq ]]; then
        /usr/local/bin/mzivpn del "$u"
        continue
    fi

    if [[ "$stat" == "ACTIVE" ]]; then
        local RAW_SNAPSHOT="/tmp/zivpn_cron_snap.log"
        tail -n 20000 "$ZIVPN_LOG" > "$RAW_SNAPSHOT" 2>/dev/null
        mapfile -t unique_ips < <(grep -w "$u" "$RAW_SNAPSHOT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v -E "127.0.0.1" | sort -u)
        local live_ip=0
        for ip in "${unique_ips[@]}"; do
            local last_line=$(grep "$ip" "$RAW_SNAPSHOT" | grep -w "$u" | tail -n 1)
            local timestamp_str=$(echo "$last_line" | awk '{print $1, $2, $3}')
            local last_seen=$(date -d "$timestamp_str" +%s 2>/dev/null || echo 0)
            if [[ "$last_seen" -ne 0 && $((now - last_seen)) -le 10 ]]; then ((live_ip++)); fi
        done
        rm -f "$RAW_SNAPSHOT"

        local lip=$(jq -r --arg u "$u" '.[$u].limit_ip' "$DB_JSON")
        if [[ "$live_ip" -gt "$lip" ]]; then
            jq --arg u "$u" '.[$u].status = "LOCKED"' "$DB_JSON" > "${DB_JSON}.tmp" && mv "${DB_JSON}.tmp" "$DB_JSON"
            /usr/local/bin/mzivpn del "$u"
            systemctl restart zivpn >/dev/null 2>&1
        fi
    fi
done
EOF
chmod +x /usr/bin/cron-zivpn

if ! crontab -l 2>/dev/null | grep -q "/usr/bin/cron-zivpn"; then
    (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/cron-zivpn") | crontab -
fi

echo -e "\033[1;92m==================================================\033[0m"
echo -e "\033[1;97m    INSTALASI SELESAI, SYSTEM MODULAR BERJALAN!   \033[0m"
echo -e "\033[1;92m    Akses Menu Utama Kapan Saja: m-zivpn          \033[0m"
echo -e "\033[1;92m==================================================\033[0m"