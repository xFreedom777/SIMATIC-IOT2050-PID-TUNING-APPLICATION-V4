import subprocess
import sys

def run_ssh(cmd):
    plink = r"C:\Program Files\PuTTY\plink.exe"
    full_cmd = [plink, "-ssh", "-batch", "-pw", "Admin100", "root@192.168.121.214", cmd]
    res = subprocess.run(full_cmd, capture_output=True, text=False)
    stdout = res.stdout.decode('utf-8', errors='replace')
    stderr = res.stderr.decode('utf-8', errors='replace')
    print("STDOUT:\n", stdout)
    if stderr:
        print("STDERR:\n", stderr)
    return stdout

if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else "mount; uptime"
    run_ssh(command)
