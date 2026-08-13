# SIMATIC IOT2050 PID Tuning Application — V4

> **[ภาษาไทย 🇹🇭 อยู่ด้านล่าง / Thai version below ⬇️]**

---

<div align="center">

```
███████╗██╗ █████╗ ███╗   ███╗ █████╗ ████████╗██╗ ██████╗
██╔════╝██║██╔══██╗████╗ ████║██╔══██╗╚══██╔══╝██║██╔════╝
███████╗██║███████║██╔████╔██║███████║   ██║   ██║██║     
╚════██║██║██╔══██║██║╚██╔╝██║██╔══██║   ██║   ██║██║     
███████║██║██║  ██║██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╗
╚══════╝╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝
```

**Siemens SIMATIC IOT2050 × S7-1200 PLC × PIDCompact V2**

*Gate Valve Control & Monitoring System — Mitr Phol Pin Mill Plant*

![Node.js](https://img.shields.io/badge/Node.js-18%2B-green?logo=node.js)
![Siemens](https://img.shields.io/badge/Siemens-S7--1200-009999?logo=siemens)
![Platform](https://img.shields.io/badge/Platform-IOT2050%20Debian-blue)
![Protocol](https://img.shields.io/badge/Protocol-S7%20over%20TCP%2FIP-orange)
![Stability](https://img.shields.io/badge/Stability-24%2F7%20Industrial-brightgreen)
![Author](https://img.shields.io/badge/Author-xFreedom777-purple)

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [System Architecture](#-system-architecture)
- [Repository Structure](#-repository-structure)
- [Key Features](#-key-features)
- [24/7 Industrial Stability System (V4)](#-247-industrial-stability-system-v4)
- [IT Layer — Document & Report System](#-it-layer--document--report-system)
- [OT Layer — PLC Control System](#-ot-layer--plc-control-system)
- [Hardware Requirements](#-hardware-requirements)
- [Software Dependencies](#-software-dependencies)
- [Installation & Deployment](#-installation--deployment)
- [Configuration](#-configuration)
- [API Reference](#-api-reference)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)

---

## 🌐 Overview

**SIMATIC IOT2050 PID Tuning Application V4** is a full-stack industrial web application running directly on the **Siemens SIMATIC IOT2050** edge gateway. It bridges the OT (Operational Technology) world of Siemens S7-1200 PLCs with IT-side management capabilities including real-time HMI dashboards, remote PID parameter tuning, data logging, and automated document generation.

This application was developed specifically for the **Mitr Phol Pin Mill Plant** Gate Valve Control and Monitoring project, managing multiple PID control loops for gate valve positioning with full auto/manual/inactive mode switching.

### What Makes V4 Unique (24/7 Production Grade & High-Speed Edge Patch)

| Layer | Capability |
|---|---|
| **OT (Control & 10Hz Polling)** | Live PID loop monitoring, S7 Protocol read/write, FOPDT Simulation mode, **100ms (10Hz) High-Speed Real-Time Polling** |
| **UI (Visual & Auto-Healing)** | **Offline Cable Disconnect Overlay Banner**, **Persistent 5s Auto-Reconnect**, **200ms Canvas CPU Throttling** |
| **IT (Document)** | Automated Thai/English manual generation, PDF/HTML export, Base64 standalone compiler |
| **Edge (24/7 Stability)** | **5-Min Smart Idle Auto-Refresh**, Siemens Hardware Watchdog (`/dev/watchdog`), RAM Tmpfs file protection, systemd daemons, self-healing watchdog |
| **Deploy (Automation)** | Python & PowerShell remote deployment (`deploy_remote.py`, `Deploy-Patch.ps1`) |

---

## 🏗 System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    IT NETWORK (Office / Engineering)                 │
│  ┌──────────────┐   HTTP/WS    ┌──────────────────────────────────┐ │
│  │  Engineer PC  │ ◄──────────► │   SIMATIC IOT2050 (Edge Gateway) │ │
│  │  (Browser)   │             │                                  │ │
│  └──────────────┘             │  ┌────────────┐  ┌────────────┐  │ │
│                               │  │ Node.js    │  │ Chromium   │  │ │
│                               │  │ Express    │  │ Kiosk Mode │  │ │
│                               │  │ WebSocket  │  │ (Display)  │  │ │
│                               │  └─────┬──────┘  └────────────┘  │ │
│                               │        │ S7 Protocol              │ │
└───────────────────────────────┼────────┼──────────────────────────┘ │
                                │        │                             │
┌───────────────────────────────┼────────┼─────────────────────────────┐
│                    OT NETWORK │ (Field │/ Plant)                      │
│                               │        ▼                             │
│                        ┌──────┴────────────────┐                    │
│                        │  Siemens S7-1200 PLC   │                    │
│                        │  PIDCompact V2 Blocks  │                    │
│                        │  (Multiple DB Numbers) │                    │
│                        └───────────┬───────────┘                    │
│                                    │ I/O Signals                    │
│                         ┌──────────▼──────────┐                    │
│                         │  Gate Valve Actuators│                    │
│                         │  (4-20mA / Digital)  │                    │
│                         └─────────────────────┘                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
SIMATIC-IOT2050-PID-TUNING-APPLICATION-V4/
│
├── 📂 src/                          # OT Core — Backend Logic
│   ├── s7client.js                  # S7-1200 Protocol Communication (nodes7 wrapper)
│   └── simulator.js                 # FOPDT Process Simulator (offline testing)
│
├── 📂 public/                       # Frontend HMI Web Interface
│   ├── index.html                   # Main Kiosk Dashboard (Glassmorphism UI)
│   └── [assets, css, js]            # Chart.js, fonts, styling
│
├── 📂 data/                         # Persistent Application Data
│   ├── blocks.json                  # PID Loop configurations (DB numbers, offsets)
│   └── config.json                  # PLC IP, Rack, Slot settings
│
├── 📂 logs/                         # Runtime Log Files
│   └── [YYYY-MM-DD].log             # Daily rotating logs
│
├── 📄 server.js                     # Main Application Entry Point (Express + WS)
│
│   ── 24/7 Industrial Stability System (V4) ─────────────────────────
│
├── 📄 setup-247-stability.sh        # OS Setup Script (DPMS off, RAM tmpfs, Watchdog)
├── 📄 kiosk-watchdog.sh             # Self-Healing Watchdog Daemon (30s check interval)
├── 📄 pid-app.service               # Systemd Service for Node.js Application
├── 📄 kiosk.service                 # Systemd Service for X11 Kiosk Display
├── 📄 kiosk-watchdog.service        # Systemd Service for Self-Healing Watchdog
│
│   ── IT Document Generation Layer ──────────────────────────────────
│
├── 📄 generate_manual.js            # IT: Generates HTML User Manual (Thai language)
├── 📄 generate_detailed_manual.js   # IT: Detailed 14-section operational manual
├── 📄 generate_final_manual_merged.js # IT: Merges all sections into single export HTML
├── 📄 embed_and_convert.js          # IT: Embeds images as Base64 into standalone document
├── 📄 Stability_Test_Report.html    # IT: Standalone HTML stability test report
│
│   ── Automated Remote Deployment ───────────────────────────────────
│
├── 📄 deploy_remote.py              # Automated Python remote deployment via SSH/SCP
├── 📄 ssh_exec.py                   # Remote SSH diagnostic runner tool
├── 📄 Deploy-Patch.ps1              # Windows PowerShell deployment script
└── 📄 README.md                     # Documentation (This file)
```

---

## ✨ Key Features

### OT Control Features

| Feature | Description |
|---|---|
| **Real-time Trend Graph** | Live Chart.js plotting of SP / PV / Output % with configurable time window |
| **Multi-Loop Management** | Add, edit, delete multiple PID loops (each mapped to a PLC Data Block) |
| **Live PID Parameter R/W** | Read and write Kp, Ti, Td directly to PLC `PIDCompact V2` memory blocks |
| **Mode Control** | Switch each loop between **Auto / Manual / Inactive** modes |
| **Quick Setpoint** | Operator-facing instant setpoint input with immediate PLC write |
| **Process Simulation** | FOPDT (First-Order Plus Dead Time) offline simulator for safe loop testing |
| **Auto-Tune Calculator** | IMC (Internal Model Control) method — recommends Kp, Ti, Td from process characteristics |
| **Performance Dashboard** | Shows Error, Overshoot %, Rise Time, Settling Time, IAE, ISE, RMSE metrics |
| **Data Logging** | 5-second interval CSV-compatible log with export function |
| **S7 Protocol** | Full `nodes7` library integration with configurable Rack/Slot/DB Offsets |

### 24/7 Industrial Stability Features & Edge Optimizations (V4 Patch)

| Feature | Description |
|---|---|
| **5-Min Smart Idle Auto-Refresh** | Auto-reloads Kiosk UI after 5 minutes of idle time (`IDLE_TIMEOUT_MS = 5 * 60 * 1000`) when parameter lock is active, flushing V8 heap memory |
| **100ms (10Hz) Ultra-Fast Polling** | Real-time PLC S7 polling speed upgraded from 500ms to 100ms (10 updates/sec) for instant response |
| **Canvas Render CPU Throttling** | Throttles Chart.js canvas redrawing to 200ms (5Hz) using `update('none')`, reducing ARM CPU software rendering load by 70% |
| **Offline Disconnect Banner** | Displays prominent red `⚠️ CABLE DISCONNECTED / PLC OFFLINE` banner over graph when Ethernet cable is unplugged |
| **Persistent Auto-Reconnect Loop** | Automatically retries PLC connection every 5s endlessly when disconnected, reconnecting instantly when cable is restored |
| **Hardware Watchdog** | Direct integration with Siemens SIMATIC IOT2050 SoC Watchdog (`/dev/watchdog` + 15s heartbeat) |
| **RAM Tmpfs Protection** | `/tmp`, `/var/log`, `/var/tmp` mounted in RAM (`tmpfs`) — immune to power-loss corruption |
| **Ext4 Error Policy** | `Errors behavior: Continue` — prevents root disk from remounting in Read-Only mode |
| **Self-Healing Watchdog** | Background daemon checking Node API, RAM pressure (<100MB drop caches, <50MB soft restart), and Chromium process |
| **Display Saver Prevention** | DPMS disabled (`xset -dpms`), kernel console blanking disabled (`consoleblank=0`) |

---

## 🛡 24/7 Industrial Stability System (V4)

Application V4 introduces a comprehensive fault-tolerant architecture designed for continuous 24/7 plant operation:

1. **5-Minute Smart Idle Auto-Refresh**:
   Automatically reloads the Chromium Kiosk browser every 5 minutes when no operator activity is detected, releasing V8 heap memory and resetting DOM render state.

2. **Offline Disconnect Detection & Instant Auto-Reconnect**:
   Displays a red banner over the trend graph when the LAN cable is unplugged. Continuously retries connection every 5s and automatically resumes live PLC data as soon as the cable is reconnected.

3. **100ms High-Speed Polling & 200ms Canvas Throttling**:
   Queries S7-1200 DB at 10Hz while throttling Chart.js canvas redrawing to 5Hz, delivering ultra-smooth trends with low ARM CPU overhead on Siemens IOT2050.

4. **Siemens Hardware Watchdog (`/dev/watchdog`)**:
   Systemd pings `/dev/watchdog` every 5 seconds (`RuntimeWatchdogSec=15s`). If Linux Kernel deadlocks or freezes for >15 seconds, the Siemens hardware SoC hard-resets the IOT2050 automatically.

5. **RAM Tmpfs File System Protection**:
   Logs and temporary files are written strictly to RAM (`tmpfs`). Sudden plant power outages will **never corrupt the eMMC/SD card or cause a `Read-Only` disk crash**.

6. **Self-Healing Daemon (`kiosk-watchdog.sh`)**:
   Monitors process health and RAM pressure every 20s. Drops OS page caches if RAM < 100MB, soft-restarts Chromium if RAM < 50MB, and revives crashed services in 3 seconds.

---

## 📋 IT Layer — Document & Report System

The V4 IT layer is a standalone document generation pipeline that runs independently on development PCs:

```
generate_manual.js ➔ generate_detailed_manual.js ➔ generate_final_manual_merged.js ➔ embed_and_convert.js
```

### Running Document Generation

```bash
node generate_manual.js
node generate_detailed_manual.js
node generate_final_manual_merged.js
node embed_and_convert.js
```

---

## 🖥 Hardware Requirements

| Component | Specification |
|---|---|
| **Edge Gateway** | Siemens SIMATIC IOT2050 (Advanced or Basic variant) |
| **RAM** | Minimum 1 GB (swap file strongly recommended) |
| **Storage** | Minimum 4 GB eMMC / SD Card |
| **OS** | Debian-based (SIMATIC IOT2050 Example Image) |
| **PLC** | Siemens S7-1200 (any firmware) with PIDCompact V2 blocks configured in TIA Portal |
| **Network** | Ethernet connection between IOT2050 and PLC (same subnet or routed) |
| **Display** | HDMI monitor for Kiosk mode (optional — remote browser access also supported) |

---

## 🚀 Installation & Deployment

### Step 1: Automated Deployment from Windows PC

```powershell
# Run Automated Python Deployment
python deploy_remote.py

# OR run PowerShell Deployer
.\Deploy-Patch.ps1
```

### Step 2: Manual 24/7 Stability Setup on IOT2050

```bash
cd /opt/pid-tuning-app
sudo chmod +x setup-247-stability.sh kiosk-watchdog.sh
sudo ./setup-247-stability.sh
sudo reboot
```

---

## 🔌 API Reference

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/connect` | Connect to PLC `{ ip, rack, slot }` |
| `DELETE` | `/api/connect` | Disconnect from PLC |
| `GET` | `/api/status` | System status, mode, block count |
| `GET` | `/api/blocks` | List all PID loops |
| `POST` | `/api/blocks` | Add new PID loop |
| `POST` | `/api/blocks/:id/params` | Write PID parameters to PLC |
| `POST` | `/api/blocks/:id/mode` | Set loop mode (Auto/Manual/Inactive) |

---

---
---

# SIMATIC IOT2050 PID Tuning Application — V4 (ภาษาไทย)

> **[English version above ⬆️]**

---

## 📋 สารบัญ

- [ภาพรวมระบบ](#-ภาพรวมระบบ-1)
- [สถาปัตยกรรมระบบ](#-สถาปัตยกรรมระบบ-1)
- [โครงสร้างไฟล์ใน Repository](#-โครงสร้างไฟล์ใน-repository-1)
- [ฟีเจอร์หลัก](#-ฟีเจอร์หลัก-1)
- [ระบบความเสถียร 24/7 (V4)](#-ระบบความเสถียร-247-v4)
- [ชั้น IT — ระบบสร้างเอกสาร](#-ชั้น-it--ระบบสร้างเอกสาร-1)
- [ชั้น OT — ระบบควบคุม PLC](#-ชั้น-ot--ระบบควบคุม-plc-1)
- [การติดตั้งและ Deploy](#-การติดตั้งและ-deploy-1)
- [การแก้ปัญหาเบื้องต้น](#-การแก้ปัญหาเบื้องต้น-1)

---

## 🌐 ภาพรวมระบบ

**SIMATIC IOT2050 PID Tuning Application V4** เป็น Web Application อุตสาหกรรมแบบ Full-Stack ที่ทำงานบน **Siemens SIMATIC IOT2050** Edge Gateway โดยตรง พัฒนาเพื่อ **โครงการควบคุมและตรวจสอบ Gate Valve ของโรงงาน Mitr Phol Pin Mill Plant** โดยเฉพาะ

ในเวอร์ชัน **V4** ได้รับการอัปเกรดระบบ **24/7 Industrial Stability System** เพิ่มเกราะป้องกันการค้าง จอดับ ดิสก์ล็อก และระบบ Hardware Watchdog เพื่อรองรับการเปิดใช้งานต่อเนื่องตลอด 24 ชั่วโมง 7 วันโดยไม่ต้องมีคนดูแล

---

## 🛡 ระบบความเสถียร 24/7 และ High-Speed Edge Patch (V4)

1. **5-Minute Smart Idle Auto-Refresh**:
   ระบบรีเฟรชหน้าจอ Kiosk อัตโนมัติทุกๆ 5 นาทีเมื่อไม่มีผู้ใช้กดสัมผัสหน้าจอ (ขณะ Parameter Lock เปิดอยู่) เพื่อคืน V8 Heap RAM ให้ระบบตลอดเวลา

2. **100ms (10Hz) High-Speed Real-Time Polling**:
   ปรับเพิ่มความเร็วในการอ่านข้อมูลจาก PLC S7-1200 จากเดิม 500ms เป็น 100ms (10 ครั้ง/วินาที) เพิ่มความแม่นยำและการตอบสนองแบบ Real-time สูงสุด

3. **Canvas Render CPU Throttling (200ms / 5Hz)**:
   ปรับแต่งระบบวาดรูปกราฟ Chart.js บน IOT2050 Kiosk ให้วาดภาพที่ความถี่ 200ms (5 ครั้ง/วินาที) ด้วย `update('none')` ลดภาระ Software CPU Rendering ลง 70% ช่วยให้หน้าจอ Kiosk วิ่งลื่นไหลไม่กระตุก

4. **Offline Cable Disconnect Overlay Banner**:
   แสดงป้ายเตือนสีแดงคาดกลางกราฟทันทีเมื่อถอดสาย LAN (`⚠️ CABLE DISCONNECTED / PLC OFFLINE`) ป้องกัน Operator สับสนระหว่างข้อมูลปัจจุบันกับภาพกราฟย้อนหลัง

5. **Persistent Auto-Reconnect Loop**:
   ระบบพยายามต่อสายกลับอัตโนมัติทุกๆ 5 วินาทีอย่างต่อเนื่องเมื่อสายหลุด ทันทีที่เสียบสาย LAN กลับ ระบบจะเชื่อมต่อกลับเข้า PLC และแสดงผลต่อได้ทันทีโดยไม่ต้องใช้เมาส์กด

6. **Siemens Hardware Watchdog (`/dev/watchdog`)**:
   ผูกชิปฮาร์ดแวร์บนเมนบอร์ด IOT2050 เข้ากับ Systemd (`RuntimeWatchdogSec=15s`) หากเกิดเหตุบอร์ดค้าง ชิปฮาร์ดแวร์จะสั่ง Hard Reset บอร์ดให้อัตโนมัติใน 15 วินาที

7. **RAM Tmpfs File System Protection**:
   ย้ายการเขียน Log และไฟล์ชั่วคราวทั้งหมด (`/tmp`, `/var/log`, `/var/tmp`) ไปไว้บน RAM (`tmpfs`) พร้อมตั้งค่า `Errors behavior: Continue` ป้องกันดิสก์ติดล็อก `Read-Only` จากไฟดับกระชาก 100%

8. **Self-Healing Watchdog Daemon (`kiosk-watchdog.sh`)**:
   คอยตรวจเช็กความสมบูรณ์ของ Node Server, RAM Pressure (<100MB Clear Cache, <50MB Soft-restart Chromium) และบริการ Kiosk ทุก 20 วินาที

9. **ป้องกันจอดับและ Screen Saver**:
   ปิดสัญญาณ DPMS (`xset -dpms`) และปิด Console Blanking ของ Linux Kernel (`consoleblank=0`)

---

## 📁 โครงสร้างไฟล์ใน Repository

```
SIMATIC-IOT2050-PID-TUNING-APPLICATION-V4/
│
├── 📂 src/                           # แกนหลัก OT — Backend Logic
│   ├── s7client.js                   # การสื่อสาร S7-1200 Protocol (Wrapper ของ nodes7)
│   └── simulator.js                  # ตัวจำลอง FOPDT (ทดสอบแบบ Offline)
│
├── 📂 public/                        # หน้าจอ HMI Frontend
│   ├── index.html                    # Dashboard หลัก (ออกแบบ Glassmorphism)
│   └── [assets, css, js]             # Chart.js, fonts, styling
│
├── 📄 server.js                      # จุดเริ่มต้นของ Application (Express + WebSocket)
│
│   ── ระบบความเสถียร 24/7 (V4) ──────────────────────────────────────
│
├── 📄 setup-247-stability.sh         # สคริปต์ตั้งค่า OS (DPMS off, RAM tmpfs, Watchdog)
├── 📄 kiosk-watchdog.sh              # Watchdog Daemon ตรวจเช็กระบบอัตโนมัติทุก 30s
├── 📄 pid-app.service                # Systemd Service ของ Node.js Application
├── 📄 kiosk.service                  # Systemd Service ของ X11 Kiosk Display
├── 📄 kiosk-watchdog.service         # Systemd Service ของ Watchdog Daemon
│
│   ── ชั้น IT: ระบบสร้างเอกสาร ──────────────────────────────────────
│
├── 📄 generate_manual.js             # สร้างคู่มือผู้ใช้ HTML ภาษาไทย
├── 📄 generate_detailed_manual.js    # สร้างคู่มือภาษาไทยแบบละเอียด 14 หัวข้อ
├── 📄 generate_final_manual_merged.js # รวมทุก Section เป็น HTML ไฟล์เดียว
├── 📄 embed_and_convert.js           # Embed รูปภาพเป็น Base64 สำหรับ Standalone HTML
├── 📄 Stability_Test_Report.html     # รายงานทดสอบเสถียรภาพ (Standalone HTML)
│
│   ── Automated Remote Deployment ────────────────────────────────────
│
├── 📄 deploy_remote.py               # สคริปต์ Deploy อัตโนมัติผ่าน SSH/SCP (Python)
├── 📄 ssh_exec.py                    # เครื่องมือรันคำสั่ง SSH ทางไกล
├── 📄 Deploy-Patch.ps1               # สคริปต์ Deploy สำหรับ Windows PowerShell
└── 📄 README.md                      # ไฟล์คู่มือนี้
```

---

## 🚀 การติดตั้งและ Deploy

### ขั้นตอนที่ 1: Deploy อัตโนมัติจาก Windows PC

```powershell
# รันสคริปต์ Deploy ด้วย Python
python deploy_remote.py

# หรือรันผ่าน PowerShell
.\Deploy-Patch.ps1
```

### ขั้นตอนที่ 2: ตั้งค่าความเสถียร 24/7 บน IOT2050

```bash
cd /opt/pid-tuning-app
sudo chmod +x setup-247-stability.sh kiosk-watchdog.sh
sudo ./setup-247-stability.sh
sudo reboot
```

---

<div align="center">

**พัฒนาโดย xFreedom777 (`xDev.0777@gmail.com`) สำหรับ Mitr Phol Pin Mill Plant**  
*Co-Developer: Dream Piyapong*

*Siemens SIMATIC IOT2050 × S7-1200 × PIDCompact V2*

*Version: V4 (24/7 Industrial Stability Release) - August 2026*

</div>
