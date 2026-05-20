#!/usr/bin/env python3
# =========================================================
# PREMIUM ZIVPN BACKEND ENGINE - HYBRID CORE V4
# Location: /usr/local/bin/mzivpn (Simpan & upload ke GitHub)
# =========================================================

import json
import sys
import os
import tempfile
import subprocess
from datetime import datetime, timedelta

CONF = "/etc/zivpn/config.json"
DB_JSON = "/etc/limit/zivpn/database.json"

def load_json(path):
    try:
        with open(path, "r") as f:
            return json.loads(f.read().replace('\r\n', '\n').replace('\r', '\n'))
    except:
        return {}

def save_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=os.path.dirname(path))
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(data, f, indent=2)
        os.replace(tmp_path, path)
    except:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)

def get_active_ip_count(username):
    try:
        cmd = "netstat -anp | grep :5667 | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort -u | wc -l"
        res = subprocess.check_output(cmd, shell=True).decode().strip()
        return int(res) if res else 0
    except:
        return 0

def format_bytes(bytes_val):
    if bytes_val >= 1073741824:
        return f"{bytes_val/1073741824:.2f} GB"
    elif bytes_val >= 1048576:
        return f"{bytes_val/1048576:.2f} MB"
    return f"{bytes_val} Bytes"

def sync():
    cfg = load_json(CONF)
    db = load_json(DB_JSON)
    now = datetime.now()
    today_str = now.strftime("%Y-%m-%d")
    
    active_users = []
    changed = False
    
    for u, d in db.items():
        status = d.get("status", "ACTIVE")
        
        # Auto-Unlock Akun Terkunci jika Hukuman 2 Jam Habis
        if status == "LOCKED" and d.get("lock_until"):
            try:
                unban_time = datetime.strptime(d["lock_until"], "%Y-%m-%d %H:%M:%S")
                if now >= unban_time:
                    d["status"] = "ACTIVE"
                    d["lock_until"] = ""
                    status = "ACTIVE"
                    changed = True
            except:
                pass

        # Cek Expired Date
        if d.get("expired_date") and d.get("expired_date") < today_str and status == "ACTIVE":
            d["status"] = "EXPIRED"
            status = "EXPIRED"
            changed = True
        
        # Cek Kuota Data Habis
        if d.get("limit_quota", 0) > 0 and d.get("usage_quota", 0) >= d.get("limit_quota", 0) and status == "ACTIVE":
            d["status"] = "QUOTA_EXHAUSTED"
            status = "QUOTA_EXHAUSTED"
            changed = True
            
        # Proteksi Pelanggaran Limit IP (Auto Banned 2 Jam)
        if status == "ACTIVE":
            current_login = get_active_ip_count(u)
            limit_ip = d.get("limit_ip", 2)
            if current_login > limit_ip:
                d["status"] = "LOCKED"
                d["lock_until"] = (now + timedelta(hours=2)).strftime("%Y-%m-%d %H:%M:%S")
                status = "LOCKED"
                changed = True
                
        if status == "ACTIVE":
            active_users.append(u)
            
    if changed:
        save_json(DB_JSON, db)
        
    if not active_users:
        active_users = ["zi"]
        
    auth = cfg.setdefault("auth", {})
    auth["mode"] = "passwords"
    auth["config"] = active_users
    
    save_json(CONF, cfg)

def main():
    if len(sys.argv) < 2:
        sys.exit(1)
        
    cmd = sys.argv[1].strip()
    db = load_json(DB_JSON)
    today_dt = datetime.now()
    
    if cmd == "add" and len(sys.argv) >= 6:
        u = sys.argv[2].strip()
        days = int(sys.argv[3].strip())
        limit_ip = int(sys.argv[4].strip())
        quota_gb = int(sys.argv[5].strip())
        
        exp_date = (today_dt + timedelta(days=days)).strftime("%Y-%m-%d")
        
        db[u] = {
            "limit_ip": limit_ip,
            "limit_quota": quota_gb * 1024 * 1024 * 1024,
            "usage_quota": 0,
            "expired_date": exp_date,
            "status": "ACTIVE",
            "lock_until": ""
        }
        save_json(DB_JSON, db)
        sync()
        
    elif cmd == "del" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u in db:
            del db[u]
        save_json(DB_JSON, db)
        sync()
        
    elif cmd == "renew" and len(sys.argv) >= 4:
        u = sys.argv[2].strip()
        days = int(sys.argv[3].strip())
        if u in db:
            if db[u]["status"] not in ["ACTIVE", "LOCKED"]:
                base_dt = today_dt
            else:
                try:
                    base_dt = datetime.strptime(db[u]["expired_date"], "%Y-%m-%d")
                except:
                    base_dt = today_dt
            db[u]["expired_date"] = (base_dt + timedelta(days=days)).strftime("%Y-%m-%d")
            db[u]["status"] = "ACTIVE"
            db[u]["lock_until"] = ""
            db[u]["usage_quota"] = 0
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "lock" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u in db:
            db[u]["status"] = "LOCKED"
            db[u]["lock_until"] = (today_dt + timedelta(hours=2)).strftime("%Y-%m-%d %H:%M:%S")
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "unlock" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u in db:
            db[u]["status"] = "ACTIVE"
            db[u]["lock_until"] = ""
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "ch_ip" and len(sys.argv) >= 4:
        u = sys.argv[2].strip()
        limit = int(sys.argv[3].strip())
        if u in db:
            db[u]["limit_ip"] = limit
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "ch_quota" and len(sys.argv) >= 4:
        u = sys.argv[2].strip()
        gb = int(sys.argv[3].strip())
        if u in db:
            db[u]["limit_quota"] = gb * 1024 * 1024 * 1024
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "clean_exp":
        today = today_dt.strftime("%Y-%m-%d")
        to_delete = [u for u, d in db.items() if d.get("expired_date", "") < today or d.get("status") in ["EXPIRED", "QUOTA_EXHAUSTED"]]
        for u in to_delete:
            del db[u]
        save_json(DB_JSON, db)
        sync()
        print(f"BERHASIL: {len(to_delete)} akun mati dibersihkan.")
        
    elif cmd == "list":
        if not db:
            print("Database member kosong.")
            return
        print("==========================================================================")
        print(f"{'Username':<15} {'Status':<16} {'Expired':<12} {'Limit IP':<8} {'Kuota'}")
        print("==========================================================================")
        for u, d in db.items():
            uq = format_bytes(d.get("usage_quota", 0))
            lq = format_bytes(d.get("limit_quota", 0))
            print(f"{u:<15} {d.get('status'):<16} {d.get('expired_date'):<12} {d.get('limit_ip'):<8} {uq}/{lq}")
        print("==========================================================================")

    elif cmd == "sync":
        sync()

if __name__ == "__main__":
    main()
