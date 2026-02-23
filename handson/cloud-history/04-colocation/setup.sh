#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-04"

echo "============================================================"
echo " クラウドの考古学 第4回 ハンズオン"
echo " IPMI/BMCの概念とサーバのリモート管理を体感する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq python3 procps iproute2 net-tools > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: BMCシミュレータ — OSとは独立した管理チャネル"
echo "============================================================"
echo ""

cat > "${WORKDIR}/bmc_simulator.py" << 'PYEOF'
import socket
import json
import threading
import time
import random

class HardwareSensors:
    def __init__(self):
        self.power_state = "on"
        self.cpu_temp = 45.0
        self.inlet_temp = 22.0
        self.fan1_rpm = 3200
        self.fan2_rpm = 3150
        self.psu1_watts = 280
        self.psu2_watts = 275
        self.disk_health = {"sda": "OK", "sdb": "OK", "sdc": "OK", "sdd": "OK"}
        self.uptime_seconds = 0
        self.boot_count = 1

    def update(self):
        if self.power_state == "on":
            self.uptime_seconds += 1
            self.cpu_temp = 45.0 + random.uniform(-3, 8)
            self.inlet_temp = 22.0 + random.uniform(-1, 2)
            self.fan1_rpm = 3200 + random.randint(-100, 100)
            self.fan2_rpm = 3150 + random.randint(-100, 100)
            self.psu1_watts = 280 + random.randint(-20, 20)
            self.psu2_watts = 275 + random.randint(-20, 20)

    def to_dict(self):
        return {
            "power_state": self.power_state,
            "cpu_temp_celsius": round(self.cpu_temp, 1),
            "inlet_temp_celsius": round(self.inlet_temp, 1),
            "fan1_rpm": self.fan1_rpm,
            "fan2_rpm": self.fan2_rpm,
            "psu1_watts": self.psu1_watts,
            "psu2_watts": self.psu2_watts,
            "disk_health": self.disk_health,
            "uptime_seconds": self.uptime_seconds,
            "boot_count": self.boot_count,
        }

sensors = HardwareSensors()

def sensor_update_loop():
    while True:
        sensors.update()
        time.sleep(1)

def handle_command(command):
    cmd = command.get("action", "")
    if cmd == "sensor_reading":
        return {"status": "ok", "sensors": sensors.to_dict()}
    elif cmd == "power_status":
        return {"status": "ok", "power": sensors.power_state}
    elif cmd == "power_off":
        sensors.power_state = "off"
        sensors.cpu_temp = 0
        sensors.fan1_rpm = 0
        sensors.fan2_rpm = 0
        return {"status": "ok", "message": "Server powered off"}
    elif cmd == "power_on":
        sensors.power_state = "on"
        sensors.cpu_temp = 35.0
        sensors.fan1_rpm = 3200
        sensors.fan2_rpm = 3150
        sensors.boot_count += 1
        return {"status": "ok", "message": f"Server powered on (boot #{sensors.boot_count})"}
    elif cmd == "power_cycle":
        sensors.power_state = "off"
        time.sleep(1)
        sensors.power_state = "on"
        sensors.boot_count += 1
        return {"status": "ok", "message": f"Server power cycled (boot #{sensors.boot_count})"}
    elif cmd == "sel_list":
        events = [
            {"id": 1, "time": "2002-10-15 03:22:11", "sensor": "PSU1",
             "event": "Power Supply AC Lost"},
            {"id": 2, "time": "2002-10-15 03:22:11", "sensor": "UPS",
             "event": "UPS Switchover - Battery Mode"},
            {"id": 3, "time": "2002-10-15 03:22:45", "sensor": "PSU1",
             "event": "Power Supply AC Restored"},
            {"id": 4, "time": "2002-11-03 14:05:33", "sensor": "CPU1 Temp",
             "event": "Upper Critical - Going High - Reading 82 > Threshold 80"},
            {"id": 5, "time": "2002-11-03 14:06:01", "sensor": "Fan1",
             "event": "Fan Speed Increased to Maximum"},
        ]
        return {"status": "ok", "events": events}
    elif cmd == "simulate_disk_failure":
        sensors.disk_health["sdc"] = "FAILING - S.M.A.R.T. Predictive Failure"
        return {"status": "ok", "message": "Disk sdc marked as failing",
                "alert": "WARNING: Disk sdc S.M.A.R.T. threshold exceeded"}
    else:
        return {"status": "error", "message": f"Unknown command: {cmd}"}

HOST = '127.0.0.1'
PORT = 6230

update_thread = threading.Thread(target=sensor_update_loop, daemon=True)
update_thread.start()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"BMCシミュレータ起動: {HOST}:{PORT}")

    s.settimeout(120)
    try:
        while True:
            conn, addr = s.accept()
            with conn:
                data = conn.recv(4096)
                if data:
                    command = json.loads(data.decode('utf-8'))
                    response = handle_command(command)
                    conn.sendall(json.dumps(response).encode('utf-8'))
    except socket.timeout:
        pass
PYEOF

cat > "${WORKDIR}/bmc_client.py" << 'PYEOF'
import socket
import json
import sys

HOST = '127.0.0.1'
PORT = 6230

def send_command(action):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(json.dumps({"action": action}).encode('utf-8'))
        data = s.recv(4096)
        return json.loads(data.decode('utf-8'))

def print_sensors(data):
    s = data["sensors"]
    print(f"  電源状態       : {s['power_state']}")
    print(f"  CPU温度        : {s['cpu_temp_celsius']}°C")
    print(f"  吸気温度       : {s['inlet_temp_celsius']}°C")
    print(f"  Fan1 回転数    : {s['fan1_rpm']} RPM")
    print(f"  Fan2 回転数    : {s['fan2_rpm']} RPM")
    print(f"  PSU1 消費電力  : {s['psu1_watts']}W")
    print(f"  PSU2 消費電力  : {s['psu2_watts']}W")
    print(f"  ディスク状態   :")
    for disk, status in s['disk_health'].items():
        marker = "!!" if status != "OK" else "  "
        print(f"    {marker} {disk}: {status}")
    print(f"  稼働時間       : {s['uptime_seconds']}秒")
    print(f"  起動回数       : {s['boot_count']}回")

if len(sys.argv) < 2:
    print("使い方: python3 bmc_client.py <command>")
    print("  sensor  - センサー値を表示")
    print("  power   - 電源状態を表示")
    print("  off     - 電源オフ")
    print("  on      - 電源オン")
    print("  cycle   - 電源サイクル（再起動）")
    print("  sel     - システムイベントログ表示")
    print("  fail    - ディスク障害をシミュレート")
    sys.exit(1)

cmd = sys.argv[1]
commands = {
    "sensor": "sensor_reading",
    "power": "power_status",
    "off": "power_off",
    "on": "power_on",
    "cycle": "power_cycle",
    "sel": "sel_list",
    "fail": "simulate_disk_failure",
}

if cmd not in commands:
    print(f"不明なコマンド: {cmd}")
    sys.exit(1)

result = send_command(commands[cmd])

if cmd == "sensor":
    print("--- センサーレポート ---")
    print_sensors(result)
elif cmd == "sel":
    print("--- システムイベントログ ---")
    for event in result.get("events", []):
        print(f"  [{event['id']}] {event['time']} | {event['sensor']}: {event['event']}")
elif cmd == "power":
    print(f"電源状態: {result.get('power', 'unknown')}")
else:
    print(result.get("message", json.dumps(result)))
    if "alert" in result:
        print(f"\n*** ALERT: {result['alert']} ***")
PYEOF

echo "bmc_simulator.py と bmc_client.py を作成しました"
echo ""
echo "--- 演習1実行 ---"
echo ""

python3 "${WORKDIR}/bmc_simulator.py" &
BMC_PID=$!
sleep 2

echo "センサー値を確認（ipmitool sensor list 相当）:"
python3 "${WORKDIR}/bmc_client.py" sensor
echo ""

echo "電源状態を確認（ipmitool chassis power status 相当）:"
python3 "${WORKDIR}/bmc_client.py" power
echo ""

echo "システムイベントログ（ipmitool sel list 相当）:"
python3 "${WORKDIR}/bmc_client.py" sel

echo ""
echo "→ BMCはOSとは独立して動作する管理チャネル"
echo "  サーバの電源がオフでもBMCは生きている"

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: 深夜のディスク障害シナリオ"
echo "============================================================"
echo ""

echo "=== シナリオ: 深夜3時、監視アラート発報 ==="
echo ""

echo "ディスク障害を発生させる..."
python3 "${WORKDIR}/bmc_client.py" fail
echo ""

echo "--- リモートから状況確認 ---"
echo ""
python3 "${WORKDIR}/bmc_client.py" sensor

echo ""
echo "→ ディスク1本のS.M.A.R.T.障害。RAID構成ならデグレード状態で継続可能"
echo "  即座のデータセンター駆けつけは不要。明朝の交換で対応可能と判断"
echo "  IPMIがあれば「行くべきか否か」をリモートで判断できる"

kill ${BMC_PID} 2>/dev/null || true
wait ${BMC_PID} 2>/dev/null || true

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: 電力冗長化のシミュレーション"
echo "============================================================"
echo ""

cat > "${WORKDIR}/power_redundancy.py" << 'PYEOF'
import random

class PowerSource:
    def __init__(self, name, reliability=0.999):
        self.name = name
        self.reliability = reliability
        self.is_up = True

    def tick(self):
        if self.is_up:
            if random.random() > self.reliability:
                self.is_up = False
                return f"  !! {self.name} が停止"
        else:
            if random.random() < 0.1:
                self.is_up = True
                return f"  >> {self.name} が復旧"
        return None

def simulate(name, sources, required_active, hours=8760):
    downtime_hours = 0
    events = []

    for hour in range(hours):
        for source in sources:
            event = source.tick()
            if event:
                events.append((hour, event))

        active = sum(1 for s in sources if s.is_up)
        if active < required_active:
            downtime_hours += 1

    uptime_pct = ((hours - downtime_hours) / hours) * 100
    print(f"\n{'='*50}")
    print(f"構成: {name}")
    print(f"電源数: {len(sources)}, 最低必要数: {required_active}")
    print(f"シミュレーション: {hours}時間（1年間）")
    print(f"ダウンタイム: {downtime_hours}時間")
    print(f"稼働率: {uptime_pct:.3f}%")
    if events[:3]:
        print(f"イベント例:")
        for hour, event in events[:3]:
            print(f"  [{hour}h]{event}")
    return uptime_pct

random.seed(42)
print("電力冗長化設計のシミュレーション")
print("（各電源の個別信頼性: 99.9%）")

simulate("N（冗長なし）- Tier I相当",
         [PowerSource("PSU-A", 0.999)],
         required_active=1)

simulate("N+1 - Tier II/III相当",
         [PowerSource("PSU-A", 0.999), PowerSource("PSU-B", 0.999)],
         required_active=1)

simulate("2N - Tier IV相当",
         [PowerSource("A-1", 0.999), PowerSource("A-2", 0.999),
          PowerSource("B-1", 0.999), PowerSource("B-2", 0.999)],
         required_active=2)
PYEOF

python3 "${WORKDIR}/power_redundancy.py"

echo ""
echo "→ 冗長化の段階によってダウンタイムが桁違いに変わる"
echo "  Tier I（N構成）とTier IV（2N構成）の差はコストの差でもある"

# ============================================================
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo "============================================================"
echo ""
echo "このハンズオンで体感したこと:"
echo ""
echo "1. BMC/IPMIはOSとは独立した管理チャネルであり"
echo "   リモートからのハードウェア監視・制御を可能にする"
echo "2. リモート管理は「データセンターに行くべきか」の判断を可能にし"
echo "   運用者の負担を大幅に軽減する"
echo "3. 電力冗長化設計（N/N+1/2N）はコストと信頼性のトレードオフであり"
echo "   Uptime Instituteのティア分類に直結する"
echo ""
echo "作業ファイルは ${WORKDIR} にあります"
