#!/bin/bash
set -e

# -------------------------
# CONFIG
# -------------------------
BASE="$HOME/Desktop/onion-site"
TEMPLATES="$BASE/templates"
APP="$BASE/app.py"
HS="$HOME/tor-hidden_service"
TORRC="$HOME/torrc"
PORT=8080

# -------------------------
# STOP OLD PROCESSES
# -------------------------
echo "Stopping old Flask and Tor processes..."
sudo pkill -9 tor || true
pkill -f app.py || true

# -------------------------
# CREATE DIRECTORIES
# -------------------------
mkdir -p "$BASE"
mkdir -p "$TEMPLATES"
mkdir -p "$HS"

# Give Tor proper permissions
chmod 700 "$HS"

# -------------------------
# WRITE SAMPLE HTML
# -------------------------
cat > "$TEMPLATES/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Onion Site</title>
</head>
<body>
<h1>Welcome to your Onion Site!</h1>
<p>Edit this HTML anytime, changes will be live.</p>
</body>
</html>
EOF

# -------------------------
# WRITE FLASK APP
# -------------------------
cat > "$APP" <<'EOF'
from flask import Flask, render_template
import os
import threading
import time

app = Flask(__name__, template_folder="templates")

@app.route("/")
def index():
    return render_template("index.html")

if __name__ == "__main__":
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler

    class ReloadHandler(FileSystemEventHandler):
        def __init__(self, restart_func):
            self.restart_func = restart_func
        def on_modified(self, event):
            if event.src_path.endswith(".html"):
                print("HTML changed! Restarting server...")
                self.restart_func()

    def run_app():
        app.run(host="127.0.0.1", port=8080, debug=False, use_reloader=False)

    server_thread = threading.Thread(target=run_app)
    server_thread.daemon = True
    server_thread.start()

    def restart_flask():
        os._exit(3)  # Force restart script

    observer = Observer()
    observer.schedule(ReloadHandler(restart_flask), path="templates", recursive=True)
    observer.start()

    while True:
        time.sleep(1)
EOF

# -------------------------
# WRITE TORRC
# -------------------------
cat > "$TORRC" <<EOF
SocksPort 9050
HiddenServiceDir $HS
HiddenServicePort 80 127.0.0.1:$PORT
EOF

# -------------------------
# START FLASK
# -------------------------
echo "Starting Flask in background..."
nohup python3 "$APP" >/dev/null 2>&1 &

# -------------------------
# START TOR
# -------------------------
echo "Starting Tor..."
tor -f "$TORRC" >/dev/null 2>&1 &

# -------------------------
# WAIT FOR ONION ADDRESS
# -------------------------
echo "Waiting for Onion address..."
while [ ! -f "$HS/hostname" ]; do
    sleep 1
done

ONION=$(cat "$HS/hostname")
echo "Your Onion address is: $ONION"
echo "Site is running in background. Edit HTML anytime, changes will auto-update."
