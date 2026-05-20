#!/usr/bin/env python3
# =========================================================
# PREMIUM ZIVPN CORE HYBRID ENGINE (FIXED LOGIC)
# Location: /usr/local/bin/mzivpn
# =========================================================

import json, sys, os, tempfile

CONF = "/etc/zivpn/config.json"
DB_JSON = "/etc/limit/zivpn/database.json"

def load_json(path):
    try:
        with open(path, "r") as f: 
            return json.loads(f.read().replace('\r\n', '\n').replace('\r', '\n'))
    except: 
        return {}

def save_json(path, data):
    # Pastikan folder tujuan sudah ada
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
    
    # Ambil semua user yang berstatus ACTIVE
    active_users = [u for u, d in db.items() if d.get("status") == "ACTIVE"]
    
    # Perbaikan Logika: Konversi nama user biasa menjadi format objek struktur ZIVPN [{"user": "nama"}]
    zivpn_auth_list = [{"user": u} for u in active_users]
    
    # Pastikan struktur luar config.json tetap terjaga
    if "auth" not in cfg or not isinstance(cfg["auth"], dict):
        cfg["auth"] = {"type": "text"}
    
    cfg["auth"]["type"] = "text"
    cfg["auth"]["config"] = zivpn_auth_list
    
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
                "limit_quota": 53687091200, 
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
        for k in db.keys(): 
            print(k)
            
    elif cmd == "sync":
        sync()

if __name__ == "__main__": 
    main()
