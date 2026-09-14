#!/bin/bash
set -eux

mkdir -p /opt/yuva-app

cat > /opt/yuva-app/app.py <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import socket
import json

class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self.send_json(200, {"status": "healthy", "tier": "application"})
            return

        self.send_json(200, {
            "message": "Hello from the Yuva Week 2 application tier",
            "hostname": socket.gethostname(),
            "service": "python-application-server"
        })

    def log_message(self, fmt, *args):
        print("%s - - [%s] %s" % (self.address_string(), self.log_date_time_string(), fmt % args))

HTTPServer(("0.0.0.0", 5000), Handler).serve_forever()
PY

cat > /etc/systemd/system/yuva-app.service <<'SERVICE'
[Unit]
Description=Yuva Week 2 Python Application Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/yuva-app/app.py
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now yuva-app
