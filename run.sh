#!/bin/bash

DOMAIN=$1      # domain:port
HOSTNAME=$2    # hostname
CONFIG=config.json
if [ ! -f config.json ]; then
cat > config.json <<EOF
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
