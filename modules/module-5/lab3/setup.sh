#!/usr/bin/env bash
# COMP-175 Lab 3 setup: builds the registrar server scenario on the UBUNTU VM.
#
#   sudo bash setup.sh        (safe to re-run; re-running RESETS the lab files)
#
# Creates 3 accounts, 2 groups, the /srv/registrar tree, two helper scripts and
# the packages the lab needs. Lab-only accounts: run it on the VM, never on a
# machine you care about.
set -euo pipefail

fail() { echo "ERROR: $*" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || fail "run with sudo:  sudo bash $0"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT=/srv/registrar
[ -d "$HERE/files" ] || fail "files/ folder not found next to setup.sh (git pull?)"

if [ -z "${LAB_PASSWORD:-}" ]; then
  read -rsp "Choose a lab password for the 3 accounts (8+ chars): " LAB_PASSWORD
  echo
fi
[ "${#LAB_PASSWORD}" -ge 8 ] || fail "password must be at least 8 characters"

echo "== 1/5 Packages (acl, inotify-tools, openssh-server)"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq acl inotify-tools openssh-server >/dev/null

echo "== 2/5 Groups and accounts"
for g in registrars auditors; do
  getent group "$g" >/dev/null || groupadd "$g"
done
add_user() {
  local u=$1 g=$2
  id "$u" >/dev/null 2>&1 || useradd -m -s /bin/bash "$u"
  usermod -aG "$g" "$u"
  echo "$u:$LAB_PASSWORD" | chpasswd
}
add_user mreyes registrars   # registrar clerk
add_user jokafor registrars  # registrar lead (the SSH login in Q9 and Q10)
add_user tnguyen auditors    # auditor, no access to grades at first

echo "== 3/5 Folders and files under $ROOT"
rm -rf "$ROOT"
install -d -o root -g root -m 755 "$ROOT"

# grades.csv: owner jokafor, group registrars, mode 640, no ACL
cat > "$ROOT/grades.csv" <<'EOF'
student_id,course,grade
1001,COMP-175,A
1002,COMP-175,B+
1003,DATA-013,A-
1004,COMP-051,B
1005,DATA-013,A
EOF
chown jokafor:registrars "$ROOT/grades.csv"
chmod 640 "$ROOT/grades.csv"
setfacl -b "$ROOT/grades.csv"

# archive/: three files older than 180 days (one in a subfolder), three newer
mkdir -p "$ROOT/archive/2024"
mk() {  # mk <path> <bytes> <days old>
  head -c "$2" /dev/zero | tr '\0' 'x' > "$ROOT/archive/$1"
  touch -d "$3 days ago" "$ROOT/archive/$1"
}
mk 2024/spring-roster.csv 4096 400
mk 2024/fall-roster.csv 2048 250
mk holds-2025.txt 8192 200
mk summer-2025.csv 1024 100
mk enrollment-aug.csv 3072 30
mk notes.txt 512 2
chown -R root:root "$ROOT/archive"

# reports/: mreyes's working folder with one file to link and delete in Q3
install -d -o mreyes -g registrars -m 775 "$ROOT/reports"
printf 'Term summary: 5 grades filed.\n' > "$ROOT/reports/summary.txt"
chown mreyes:registrars "$ROOT/reports/summary.txt"

# shared/ and dropbox/ start with plain modes; Q4 hardens them
install -d -o root -g registrars -m 770 "$ROOT/shared"
install -d -o root -g root -m 777 "$ROOT/dropbox"

# public/: the page you tunnel to in Q10
install -d -o root -g root -m 755 "$ROOT/public"
install -o root -g root -m 644 "$HERE/files/public/index.html" "$ROOT/public/index.html"

echo "== 4/5 Helper scripts"
install -o root -g root -m 755 "$HERE/files/backup-grades.sh" /usr/local/bin/backup-grades.sh
install -d -o root -g root -m 755 /opt/registrar
install -o root -g root -m 755 "$HERE/files/report-job.sh" /opt/registrar/report-job.sh

echo "== 5/5 SSH server"
systemctl enable --now ssh >/dev/null 2>&1 || echo "   (could not start ssh here; on your VM run: sudo systemctl enable --now ssh)"

echo
echo "SETUP OK"
echo "  accounts : 3 lab accounts (find them: getent group registrars auditors)"
echo "  tree     : $ROOT"
echo "  scripts  : /usr/local/bin/backup-grades.sh   /opt/registrar/report-job.sh"
echo "  Ubuntu IP: $(hostname -I | awk '{print $1}')"
