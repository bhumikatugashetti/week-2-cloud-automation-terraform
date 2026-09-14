#!/bin/bash
set -eux

dnf install -y nginx

cat > /etc/nginx/conf.d/yuva.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;

    location = /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    location / {
        proxy_pass http://${internal_alb_dns};
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

rm -f /etc/nginx/conf.d/default.conf || true
nginx -t
systemctl enable --now nginx
