#!/bin/bash
# ═════════════════════════════════════════════════════════════════
# Siemens SIMATIC IOT2050 — 24/7 Kiosk Stability Setup Script
# ═════════════════════════════════════════════════════════════════
set -e

echo "==========================================================="
echo " 🛠  Configuring Siemens IOT2050 24/7 Stability Parameters"
echo "==========================================================="

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo ./setup-247-stability.sh)"
  exit 1
fi

APP_DIR="/opt/pid-tuning-app"
USER_HOME="/root"

# 1. Disable System Idle & Lid Sleep Actions in logind.conf
echo "--> [1/6] Disabling logind sleep & idle actions..."
mkdir -p /etc/systemd/logind.conf.d/
cat << 'EOF' > /etc/systemd/logind.conf.d/247-stability.conf
[Login]
IdleAction=ignore
HandleLidSwitch=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandlePowerKey=ignore
EOF
systemctl restart systemd-logind || true

# 2. Disable Kernel Console Blanking
echo "--> [2/6] Disabling Linux kernel console blanking..."
if [ -f /sys/module/kernel/parameters/consoleblank ]; then
  echo 0 > /sys/module/kernel/parameters/consoleblank 2>/dev/null || true
fi
if grep -q "consoleblank" /etc/sysctl.conf; then
  sed -i 's/consoleblank=.*/consoleblank=0/' /etc/sysctl.conf
else
  echo "kernel.consoleblank = 0" >> /etc/sysctl.conf
fi

# 3. Limit Systemd Journal Logs to 100MB (Prevents Disk Exhaustion)
echo "--> [3/6] Configuring Journald log limits (Max 100MB)..."
mkdir -p /etc/systemd/journald.conf.d/
cat << 'EOF' > /etc/systemd/journald.conf.d/limit-size.conf
[Journal]
SystemMaxUse=100M
SystemKeepFree=200M
MaxRetentionSec=1month
EOF
systemctl restart systemd-journald || true

# 4. Generate Production ~/.xinitrc with GPU-disabled & DPMS-off flags
echo "--> [4/6] Installing X11 Kiosk launcher (~/.xinitrc)..."
cat << 'EOF' > "${USER_HOME}/.xinitrc"
#!/bin/bash
# ── Siemens IOT2050 24/7 Kiosk Launcher ──

# Disable Display Power Management (DPMS) & Screen Savers
xset -dpms
xset s off
xset s noblank
xset s 0 0
setterm -blank 0 -powerdown 0 2>/dev/null || true

# Fix mouse cursor styling
xsetroot -cursor_name left_ptr &

# Clear previous Chromium crash locks & restore profiles
rm -rf ~/.config/chromium/Singleton*
rm -rf ~/.config/chromium/Default/WebData*
find ~/.config/chromium -name "Preferences" -exec sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' {} + 2>/dev/null || true
find ~/.config/chromium -name "Preferences" -exec sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' {} + 2>/dev/null || true

# Continuous Kiosk Loop with GPU-disabled flags (prevents ARM driver freeze)
while true; do
  chromium \
    --no-sandbox \
    --disable-dev-shm-usage \
    --no-first-run \
    --password-store=basic \
    --kiosk \
    --start-fullscreen \
    --start-maximized \
    --window-size=1920,1080 \
    --window-position=0,0 \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-gpu \
    --disable-software-rasterizer \
    --disk-cache-size=1 \
    --media-cache-size=1 \
    --js-flags="--max-old-space-size=256" \
    --autoplay-policy=no-user-gesture-required \
    --force-device-scale-factor=1.0 \
    http://localhost:3000/splash.html
  
  sleep 2
done
EOF
chmod +x "${USER_HOME}/.xinitrc"

# 5. Install Watchdog script
echo "--> [5/6] Installing Self-Healing Watchdog script..."
chmod +x "${APP_DIR}/kiosk-watchdog.sh" 2>/dev/null || true

# 6. Install & Enable Systemd Services
echo "--> [6/6] Registering production Systemd services..."
cp "${APP_DIR}/pid-app.service" /etc/systemd/system/ 2>/dev/null || true
cp "${APP_DIR}/kiosk-watchdog.service" /etc/systemd/system/ 2>/dev/null || true
cp "${APP_DIR}/kiosk.service" /etc/systemd/system/ 2>/dev/null || true

systemctl daemon-reload
systemctl enable pid-app.service || true
systemctl enable kiosk-watchdog.service || true
systemctl enable kiosk.service || true

echo "==========================================================="
echo " ✅ 24/7 Stability Parameters configured successfully!"
echo " 👉 Reboot IOT2050 to start 24/7 mode: reboot"
echo "==========================================================="
