#!/usr/bin/env python3
"""
COMP-175 Project Part 2 — Team 4: Clinical Data & Access Control Dashboard
Hosts a 5-button Flask web dashboard on Kali that executes REAL Linux commands
against the Ubuntu Hospital-VM over SSH via subprocess.run().
"""
import os
import subprocess
from datetime import datetime
from flask import Flask, render_template_string, request

app = Flask(__name__)

# Default target Ubuntu VM IP (supports HOSPITAL_HOST, HOSPITAL_VM_IP, WSL local IP, or 10.0.0.40 in class)
DEFAULT_TARGET_IP = (
    os.environ.get("HOSPITAL_HOST")
    or os.environ.get("HOSPITAL_VM_IP")
    or "172.29.165.237"
)
DEFAULT_SSH_USER = os.environ.get("HOSPITAL_SSH_USER", "sricha28")
SSH_KEY_PATH = os.path.expanduser("~/.ssh/id_ed25519")

ACTIONS = {
    "check_rbac": {
        "title": "1. Audit Live RBAC Matrix & ACLs",
        "desc": "Runs ls -la, getfacl, and real sudo -u persona read/write tests (physician1, nurse1, patient1, guest1).",
        "remote_cmd": "sudo /opt/hospital-vm/check-rbac.sh"
    },
    "enforce_rbac": {
        "title": "2. Enforce Hardened RBAC Rules",
        "desc": "Executes chmod/chgrp/setfacl via /opt/hospital-vm/enforce-rbac.sh to lock down /srv/clinical-data and verify.",
        "remote_cmd": "sudo /opt/hospital-vm/enforce-rbac.sh && echo '' && sudo /opt/hospital-vm/check-rbac.sh"
    },
    "view_logs": {
        "title": "3. Live Clinical Activity & inotify Logs",
        "desc": "Tails real-time persona access attempts (/var/log/clinical-activity.log) and file events (/var/log/clinical-inotify.log).",
        "remote_cmd": "echo '=== /var/log/clinical-activity.log (Last 15 Events) ===' && tail -n 15 /var/log/clinical-activity.log && echo '' && echo '=== /var/log/clinical-inotify.log (Last 15 File Events) ===' && sudo tail -n 15 /var/log/clinical-inotify.log"
    },
    "integrity_check": {
        "title": "4. Clinical Data Integrity & Corruption Scan",
        "desc": "Inspects /srv/clinical-data/patients.csv for CORRUPTED rows, checks active SSH sessions, and computes SHA-256 hashes.",
        "remote_cmd": "echo '=== Current /srv/clinical-data/patients.csv ===' && sudo cat /srv/clinical-data/patients.csv && echo '' && echo '=== SHA-256 Checksums ===' && sudo sha256sum /srv/clinical-data/patients.csv /srv/clinical-data/patient1-chart.csv /srv/clinical-data/README.md && echo '' && echo '=== Corruption Check ===' && (sudo grep -n 'CORRUPTED' /srv/clinical-data/patients.csv && echo 'WARNING: CORRUPTED ROW DETECTED!' || echo 'OK: No corrupted rows detected.')"
    },
    "restore_clean": {
        "title": "5. Repair Corrupted Records & Re-Lock RBAC",
        "desc": "Restores clean patients.csv from Hospital-VM/sample-data/patients.csv and immediately re-applies Team 4 RBAC rules.",
        "remote_cmd": "sudo cp ~/2026-COMP-175/project/part-2/Hospital-VM/sample-data/patients.csv /srv/clinical-data/patients.csv && sudo /opt/hospital-vm/enforce-rbac.sh && echo '' && echo '=== Restored /srv/clinical-data/patients.csv ===' && sudo cat /srv/clinical-data/patients.csv"
    }
}

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Team 4 — Clinical Data & Access Control Dashboard</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 24px; }
    .container { max-width: 1100px; margin: 0 auto; }
    header { background: #1e293b; border: 1px solid #334155; border-radius: 10px; padding: 20px 24px; margin-bottom: 20px; }
    h1 { margin: 0 0 6px 0; font-size: 24px; color: #38bdf8; }
    .sub { color: #94a3b8; font-size: 14px; margin: 0; }
    .target-bar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-top: 14px; background: #0f172a; padding: 10px 14px; border-radius: 8px; border: 1px solid #334155; }
    .target-bar label { font-size: 13px; color: #cbd5e1; font-weight: 600; }
    .target-bar input { background: #1e293b; color: #f8fafc; border: 1px solid #475569; border-radius: 6px; padding: 6px 10px; font-family: monospace; }
    .hint { font-size: 12px; color: #64748b; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(310px, 1fr)); gap: 14px; margin-bottom: 22px; }
    .card { background: #1e293b; border: 1px solid #334155; border-radius: 10px; padding: 16px; display: flex; flex-direction: column; justify-content: space-between; }
    .card h3 { margin: 0 0 8px 0; font-size: 16px; color: #f1f5f9; }
    .card p { margin: 0 0 14px 0; font-size: 13px; color: #94a3b8; line-height: 1.4; }
    button { background: #0284c7; color: white; border: none; border-radius: 6px; padding: 10px 14px; font-size: 14px; font-weight: 600; cursor: pointer; width: 100%; transition: background 0.15s; }
    button:hover { background: #0369a1; }
    .status-box { background: #020617; border: 1px solid #334155; border-radius: 10px; padding: 18px; }
    .status-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; border-bottom: 1px solid #1e293b; padding-bottom: 10px; }
    .badge-ok { background: #065f46; color: #6ee7b7; padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 700; }
    .badge-err { background: #7f1d1d; color: #fca5a5; padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 700; }
    pre { margin: 0; font-family: 'Consolas', 'Courier New', monospace; font-size: 13px; color: #e2e8f0; white-space: pre-wrap; word-break: break-word; line-height: 1.45; }
    .cmd-line { color: #38bdf8; font-family: monospace; font-size: 12px; margin-bottom: 10px; }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>Team 4: Clinical Data & Access Control — Live Admin Dashboard</h1>
      <p class="sub">Members: Toan, Kaung, Shomario | Executes REAL Linux commands over SSH via Python subprocess</p>
      <form method="POST" action="/">
        <div class="target-bar">
          <label>Ubuntu Hospital-VM IP:</label>
          <input type="text" name="target_ip" value="{{ target_ip }}">
          <label>SSH User:</label>
          <input type="text" name="ssh_user" value="{{ ssh_user }}">
          <span class="hint">(Phase 1 WSL: 172.29.165.237 | Phase 2 Switch: 10.0.0.40 / clindata-ubuntu)</span>
        </div>
        <div class="grid" style="margin-top: 16px;">
          {% for key, item in actions.items() %}
          <div class="card">
            <div>
              <h3>{{ item.title }}</h3>
              <p>{{ item.desc }}</p>
            </div>
            <button type="submit" name="action" value="{{ key }}">Run Command</button>
          </div>
          {% endfor %}
        </div>
      </form>
    </header>

    <div class="status-box">
      <div class="status-header">
        <strong>Live Subprocess Terminal Output {% if timestamp %}({{ timestamp }}){% endif %}</strong>
        {% if returncode is not none %}
          {% if returncode == 0 %}
            <span class="badge-ok">EXIT CODE: 0 (SUCCESS)</span>
          {% else %}
            <span class="badge-err">EXIT CODE: {{ returncode }} (COMMAND FAILED)</span>
          {% endif %}
        {% endif %}
      </div>
      {% if executed_cmd %}
        <div class="cmd-line">$ {{ executed_cmd }}</div>
      {% endif %}
      <pre>{{ output }}</pre>
    </div>
  </div>
</body>
</html>
"""

@app.route("/", methods=["GET", "POST"])
@app.route("/action", methods=["GET", "POST"])
def index():
    target_ip = request.form.get("target_ip", DEFAULT_TARGET_IP).strip()
    ssh_user = request.form.get("ssh_user", DEFAULT_SSH_USER).strip()
    action_key = request.form.get("action")

    output = "Click any of the 5 buttons above to execute a real Linux command against Hospital-VM."
    executed_cmd = None
    returncode = None
    timestamp = None

    if request.method == "POST" and action_key in ACTIONS:
        remote_cmd = ACTIONS[action_key]["remote_cmd"]
        ssh_cmd = [
            "ssh",
            "-i", SSH_KEY_PATH,
            "-o", "BatchMode=yes",
            "-o", "StrictHostKeyChecking=accept-new",
            "-o", "ConnectTimeout=5",
            f"{ssh_user}@{target_ip}",
            remote_cmd
        ]
        executed_cmd = " ".join(ssh_cmd)
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        try:
            res = subprocess.run(ssh_cmd, capture_output=True, text=True, timeout=15)
            returncode = res.returncode
            combined = ""
            if res.stdout:
                combined += res.stdout
            if res.stderr:
                combined += ("\n--- STDERR ---\n" + res.stderr)
            output = combined.strip() if combined.strip() else "(Command completed with no output)"
        except Exception as exc:
            returncode = -1
            output = f"Subprocess execution error: {exc}"

    return render_template_string(
        HTML_TEMPLATE,
        actions=ACTIONS,
        target_ip=target_ip,
        ssh_user=ssh_user,
        output=output,
        executed_cmd=executed_cmd,
        returncode=returncode,
        timestamp=timestamp
    )

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
