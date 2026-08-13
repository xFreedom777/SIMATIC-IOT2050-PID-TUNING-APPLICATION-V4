import paramiko
import os
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')

HOST = '192.168.121.214'
USER = 'root'
PASS = 'Admin100'
DEST = '/opt/pid-tuning-app'

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
print("Connecting...")
ssh.connect(HOST, username=USER, password=PASS, timeout=10)

def run_cmd(cmd):
    print(f"--> {cmd}")
    stdin, stdout, stderr = ssh.exec_command(cmd)
    out = stdout.read().decode('utf-8')
    err = stderr.read().decode('utf-8')
    if err.strip():
        print("[STDERR]", err.strip())
    return out

print("Creating directories...")
run_cmd(f"mkdir -p {DEST}/public/css {DEST}/public/js {DEST}/src")

sftp = ssh.open_sftp()

files_to_upload = [
    ("public/index.html", f"{DEST}/public/index.html"),
    ("public/css/style.css", f"{DEST}/public/css/style.css"),
    ("public/js/app.js", f"{DEST}/public/js/app.js"),
    ("server.js", f"{DEST}/server.js"),
    ("src/s7client.js", f"{DEST}/src/s7client.js"),
    ("setup-247-stability.sh", f"{DEST}/setup-247-stability.sh"),
    ("kiosk-watchdog.sh", f"{DEST}/kiosk-watchdog.sh"),
    ("pid-app.service", f"{DEST}/pid-app.service"),
    ("kiosk-watchdog.service", f"{DEST}/kiosk-watchdog.service"),
    ("kiosk.service", f"{DEST}/kiosk.service")
]

for local_path, remote_path in files_to_upload:
    print(f"Uploading {local_path} to {remote_path}...")
    if os.path.exists(local_path):
        sftp.put(local_path, remote_path)
    else:
        print(f"WARNING: {local_path} not found locally!")

sftp.close()

print("Executing setup script...")
# Install nodejs if it's missing (pid-app.service needs node)
run_cmd("which node || apt-get install -y nodejs npm")

out = run_cmd(f"chmod +x {DEST}/setup-247-stability.sh {DEST}/kiosk-watchdog.sh && cd {DEST} && ./setup-247-stability.sh")
print(out)

# Add auto-launch to bashrc
run_cmd('grep -q "startx" /root/.bashrc || echo \'if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then systemctl start pid-app kiosk-watchdog kiosk || startx -- -nocursor; fi\' >> /root/.bashrc')

print("Restarting services...")
run_cmd("systemctl daemon-reload")
run_cmd("systemctl restart pid-app kiosk-watchdog kiosk")
run_cmd("systemctl enable pid-app kiosk-watchdog kiosk")

ssh.close()
print("Deployment Complete.")
