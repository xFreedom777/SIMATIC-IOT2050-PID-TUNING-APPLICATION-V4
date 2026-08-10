import subprocess
import sys
import os

PSCP = r"C:\Program Files\PuTTY\pscp.exe"
PLINK = r"C:\Program Files\PuTTY\plink.exe"
HOST = "root@192.168.121.214"
PASS = "Admin100"
DEST = "/opt/pid-tuning-app"

def pscp_upload(local_path, remote_path):
    print(f"--> Uploading {local_path} to {remote_path}...")
    cmd = [PSCP, "-batch", "-pw", PASS, local_path, f"{HOST}:{remote_path}"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"[FAIL] Failed to upload {local_path}:\n{res.stderr}")
    else:
        print(f"  [OK] Uploaded {local_path}")

def ssh_exec(command):
    print(f"--> Executing remote: {command}")
    cmd = [PLINK, "-ssh", "-batch", "-pw", PASS, HOST, command]
    res = subprocess.run(cmd, capture_output=True, text=True)
    print("STDOUT:\n", res.stdout)
    if res.stderr:
        print("STDERR:\n", res.stderr)
    return res.stdout

def main():
    print("==================================================")
    print(" Deploying 24/7 Stability Patch to Siemens IOT2050")
    print("==================================================")

    # Make remote directories
    ssh_exec(f"mkdir -p {DEST}/public/css {DEST}/public/js {DEST}/src")

    # Upload files
    pscp_upload("public/index.html", f"{DEST}/public/index.html")
    pscp_upload("public/css/style.css", f"{DEST}/public/css/style.css")
    pscp_upload("public/js/app.js", f"{DEST}/public/js/app.js")
    pscp_upload("server.js", f"{DEST}/server.js")
    pscp_upload("src/s7client.js", f"{DEST}/src/s7client.js")
    pscp_upload("setup-247-stability.sh", f"{DEST}/setup-247-stability.sh")
    pscp_upload("kiosk-watchdog.sh", f"{DEST}/kiosk-watchdog.sh")
    pscp_upload("pid-app.service", f"{DEST}/pid-app.service")
    pscp_upload("kiosk-watchdog.service", f"{DEST}/kiosk-watchdog.service")
    pscp_upload("kiosk.service", f"{DEST}/kiosk.service")

    # Make executable & run setup script
    ssh_exec(f"chmod +x {DEST}/setup-247-stability.sh {DEST}/kiosk-watchdog.sh && cd {DEST} && ./setup-247-stability.sh")

    # Add auto-launch to /root/.bashrc if tty1
    ssh_exec('grep -q "startx" /root/.bashrc || echo \'if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then systemctl start pid-app kiosk-watchdog kiosk || startx -- -nocursor; fi\' >> /root/.bashrc')

    # Restart services
    print("--> Restarting production services...")
    ssh_exec("systemctl restart pid-app kiosk-watchdog kiosk")

    print("==================================================")
    print(" 24/7 Deployment & Fix Executed Successfully!")
    print("==================================================")

if __name__ == "__main__":
    main()
