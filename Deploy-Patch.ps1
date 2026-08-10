# ════════════════════════════════════════════════
# IOT2050 24/7 Stability & Patch Deployment Script
# ════════════════════════════════════════════════
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  🚀 SIMATIC IOT2050 24/7 Stability Patch Deployment" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Get IP Address
$iot_ip = Read-Host "Enter IOT2050 IP Address [Press Enter for 192.168.121.214]"
if ([string]::IsNullOrWhiteSpace($iot_ip)) { $iot_ip = "192.168.121.214" }

$iot_user = "root"

# Get Destination Path
$iot_path = Read-Host "Enter Destination Path on IOT2050 [Press Enter for /opt/pid-tuning-app]"
if ([string]::IsNullOrWhiteSpace($iot_path)) { $iot_path = "/opt/pid-tuning-app" }

Write-Host "`n[1/8] Deploying index.html..." -ForegroundColor Yellow
scp .\public\index.html ${iot_user}@${iot_ip}:${iot_path}/public/

Write-Host "[2/8] Deploying style.css..." -ForegroundColor Yellow
scp .\public\css\style.css ${iot_user}@${iot_ip}:${iot_path}/public/css/

Write-Host "[3/8] Deploying app.js (RAM & Chart Throttled)..." -ForegroundColor Yellow
scp .\public\js\app.js ${iot_user}@${iot_ip}:${iot_path}/public/js/

Write-Host "[4/8] Deploying server.js (Backend)..." -ForegroundColor Yellow
scp .\server.js ${iot_user}@${iot_ip}:${iot_path}/

Write-Host "[5/8] Deploying s7client.js..." -ForegroundColor Yellow
scp .\src\s7client.js ${iot_user}@${iot_ip}:${iot_path}/src/

Write-Host "[6/8] Deploying 24/7 Stability Setup Script..." -ForegroundColor Yellow
scp .\setup-247-stability.sh ${iot_user}@${iot_ip}:${iot_path}/

Write-Host "[7/8] Deploying Self-Healing Watchdog..." -ForegroundColor Yellow
scp .\kiosk-watchdog.sh ${iot_user}@${iot_ip}:${iot_path}/

Write-Host "[8/8] Deploying Systemd Services..." -ForegroundColor Yellow
scp .\pid-app.service ${iot_user}@${iot_ip}:${iot_path}/
scp .\kiosk-watchdog.service ${iot_user}@${iot_ip}:${iot_path}/
scp .\kiosk.service ${iot_user}@${iot_ip}:${iot_path}/

Write-Host "`n✅ All files copied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " 🛠  Executing 24/7 OS Configuration on IOT2050..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

ssh ${iot_user}@${iot_ip} "chmod +x ${iot_path}/setup-247-stability.sh ${iot_path}/kiosk-watchdog.sh && cd ${iot_path} && ./setup-247-stability.sh"

Write-Host "`n🎉 24/7 Deployment Complete! Restarting Node server..." -ForegroundColor Green
ssh ${iot_user}@${iot_ip} "systemctl restart pid-app kiosk-watchdog"

Write-Host "`n👉 You can now reboot the IOT2050 board using: ssh ${iot_user}@${iot_ip} 'reboot'" -ForegroundColor Cyan
Write-Host ""
Pause
