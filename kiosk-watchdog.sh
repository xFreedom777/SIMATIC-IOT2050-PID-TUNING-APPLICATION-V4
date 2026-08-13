#!/bin/bash
# ═════════════════════════════════════════════════════════════════
# Siemens IOT2050 — Self-Healing Watchdog Daemon
# ═════════════════════════════════════════════════════════════════

LOG_FILE="/var/log/kiosk-watchdog.log"
exec >> "$LOG_FILE" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🛡 Watchdog Daemon Started"

while true; do
  # 1. Check Node Backend Health
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/status || echo "000")
  if [ "$HTTP_CODE" != "200" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Node Backend unreachable (HTTP $HTTP_CODE). Restarting pid-app service..."
    systemctl restart pid-app.service || true
    sleep 5
  fi

  # 2. Check Chromium Display Process
  if ! pgrep -x "chromium" > /dev/null && ! pgrep -f "chromium-bsu" > /dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Chromium Kiosk process dead. Restarting kiosk service..."
    systemctl restart kiosk.service || true
    sleep 5
  fi

  # 3. Check System RAM Pressure
  FREE_RAM_MB=$(free -m | awk '/^Mem:/{print $4}')
  if [ "$FREE_RAM_MB" -lt 100 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Low RAM detected (${FREE_RAM_MB}MB free). Clearing PageCaches..."
    sync && echo 3 > /proc/sys/vm/drop_caches || true
    
    if [ "$FREE_RAM_MB" -lt 50 ]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🚨 Critical RAM pressure! Soft-restarting Kiosk Display..."
      pkill -f "chromium" || true
      sleep 2
      systemctl restart kiosk.service || true
      sleep 10
    fi
  fi

  # 4. Off-Peak Soft Refresh (Every day at 03:00 AM)
  CURRENT_TIME=$(date '+%H:%M')
  if [ "$CURRENT_TIME" == "03:00" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🌙 Daily Maintenance: Cleaning V8 Heap Cache..."
    pkill -f "chromium" || true
    sleep 2
    systemctl restart kiosk.service || true
    sleep 60
  fi

  sleep 20
done
