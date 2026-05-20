#!/usr/bin/env python3
# =========================================================
# PREMIUM ZIVPN BACKEND ENGINE - HYBRID CORE V4
# Location: /usr/local/bin/mzivpn
# =========================================================

import json
import sys
import os
import tempfile
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

def sync():
    cfg = load_json(CONF)
    db = load_json(DB_JSON)
    today = datetime.now().strftime("%Y-%m-%d")
    
    active_users = []
    changed = False
    
    for u, d in db.items():
        # Auto lock jika melewati tanggal kadaluarsa
        if d.get("expired_date") and d.get("expired_date") < today and d.get("status") == "ACTIVE":
            d["status"] = "EXPIRED"
            changed = True
        
        # Auto lock jika kuota habis
        if d.get("limit_quota", 0) > 0 and d.get("usage_quota", 0) >= d.get("limit_quota", 0) and d.get("status") == "ACTIVE":
            d["status"] = "QUOTA_EXHAUSTED"
            changed = True
            
        if d.get("status") == "ACTIVE":
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
    
    if cmd == "add" and len(sys.argv) >= 4:
        u = sys.argv[2].strip()
        days = int(sys.argv[3].strip())
        exp_date = (today_dt + timedelta(days=days)).strftime("%Y-%m-%d")
        
        db[u] = {
            "limit_ip": 2,
            "limit_quota": 10737418240, # Default 10 GB
            "usage_quota": 0,
            "expired_date": exp_date,
            "status": "ACTIVE"
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
            # Jika sudah expired/lock, perpanjang dari hari ini. Jika masih aktif, akumulasikan.
            if db[u]["status"] != "ACTIVE":
                base_dt = today_dt
            else:
                try:
                    base_dt = datetime.strptime(db[u]["expired_date"], "%Y-%m-%d")
                except:
                    base_dt = today_dt
            
            db[u]["expired_date"] = (base_dt + timedelta(days=days)).strftime("%Y-%m-%d")
            db[u]["status"] = "ACTIVE"
            db[u]["usage_quota"] = 0 # Reset kuota saat diperpanjang
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "lock" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u in db:
            db[u]["status"] = "LOCKED"
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "unlock" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u in db:
            db[u]["status"] = "ACTIVE"
            save_json(DB_JSON, db)
            sync()
            
    elif cmd == "ch_ip" and len(sys.argv) >= 4:
        u = sys.argv[2].strip()
        limit = int(sys.argv[3].strip())
        if u in db:
            db[u]["limit_ip"] = limit
            save_json(DB_JSON, db)
            
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
        print(f"BERHASIL: {len(to_delete)} akun expired dibersihkan.")
        
    elif cmd == "sync":
        sync()

if __name__ == "__main__":
    main()
