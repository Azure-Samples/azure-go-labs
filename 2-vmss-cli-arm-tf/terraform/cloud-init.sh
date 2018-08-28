#!/bin/bash

sudo tee -a /etc/systemd/system/hello-echo.service >/dev/null <<'EOF'
[Unit]
Description=hello-echo

[Service]
Type=simple
Restart=always
RestartSec=5s
Environment=HTTP_PLATFORM_PORT=80
ExecStart=/home/azureuser/hello-echo

[Install]
WantedBy=multi-user.target
EOF

cd "/home/azureuser/"

curl -OL https://github.com/aaronmsft/hello-echo/releases/download/test/hello-echo

chmod +x hello-echo

sudo systemctl enable hello-echo

sudo systemctl start hello-echo

echo 'cloud-init complete!' > /home/azureuser/cloud-init-complete.txt
