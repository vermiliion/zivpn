#!/usr/bin/env python3
# =========================================================
# PREMIUM ZIVPN BACKEND ENGINE - ZAHID ISLAM SYNCHRONIZER
# Location: /usr/local/bin/mzivpn
# =========================================================

import json
import sys
import os
import tempfile

CONF = "/etc/zivpn/config.json"
DB_JSON = "/etc/limit/zivpn/database.json"

def load_json(path):
    try:
        with open(path, "r") as f:
            # Otomatis bersihkan enter Windows (\r) saat membaca database
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
    
    # Ambil daftar nama user yang statusnya masih ACTIVE
    active_users = [u for u, d in db.items() if d.get("status") == "ACTIVE"]
    
    # Jika database kosong, berikan default user "zi" agar biner tidak crash
    if not active_users:
        active_users = ["zi"]
        
    # Amankan struktur luar config.json asli Zahid Islam
    auth = cfg.setdefault("auth", {})
    auth["mode"] = "passwords"
    auth["config"] = active_users
    
    save_json(CONF, cfg)

def main():
    if len(sys.argv) < 2:
        sys.exit(1)
        
    cmd = sys.argv[1].strip()
    db = load_json(DB_JSON)
    
    if cmd == "add" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u not in db:
            db[u] = {
                "limit_ip": 2,
                "limit_quota": 10737418240, # Default 10 GB
                "usage_quota": 0,
                "expired_date": "2030-01-01",
                "status": "ACTIVE"
            }
        else:
            db[u]["status"] = "ACTIVE"
        save_json(DB_JSON, db)
        sync()
        
    elif cmd == "del" and len(sys.argv) >= 3:
        u = sys.argv[2].strip()
        if u in db:
            del db[u]
        save_json(DB_JSON, db)
        sync()
        
    elif cmd == "list":
        # Menampilkan daftar untuk kebutuhan menu Bash
        for k in db.keys():
            print(k)
            
    elif cmd == "sync":
        sync()

if __name__ == "__main__":
    main()