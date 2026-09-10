#!/usr/bin/env bash
# verify.sh -- self-check for the Module 3 class project.
#
# Checks that /srv/library was built the way the project brief asks:
# the shared collection dir and its three role folders each read
# drwxrws--T with group libstaff, the cataloging scripts are deployed,
# and the admin welcome banner is installed in ~/.bashrc.
#
# Run:  bash verify.sh
# Exit code is 0 only if every check passes.

pass=0
fail=0

check() {
    # check "<description>" "<actual>" "<expected>"
    local desc="$1" actual="$2" expected="$3"
    if [ "$actual" = "$expected" ]; then
        printf 'PASS  %s\n' "$desc"
        pass=$((pass + 1))
    else
        printf 'FAIL  %s\n        expected: %s\n        got:      %s\n' \
            "$desc" "$expected" "$actual"
        fail=$((fail + 1))
    fi
}

exists() {
    # exists "<description>" "<path>"
    if [ -e "$2" ]; then
        printf 'PASS  %s\n' "$1"
        pass=$((pass + 1))
    else
        printf 'FAIL  %s (missing: %s)\n' "$1" "$2"
        fail=$((fail + 1))
    fi
}

echo "=== Module 3 class project: verify ==="
echo

# --- 1. the shared collection dir ---------------------------------------
exists "/srv/library exists" /srv/library
if [ -d /srv/library ]; then
    got="$(stat -c '%A %G' /srv/library 2>/dev/null)"
    check "/srv/library is drwxrws--T libstaff" "$got" "drwxrws--T libstaff"
fi

# --- 2. the three role folders ---------------------------------------
for role in cataloging circulation archives; do
    d="/srv/library/$role"
    exists "$d exists" "$d"
    if [ -d "$d" ]; then
        got="$(stat -c '%A %G' "$d" 2>/dev/null)"
        check "$d is drwxrws--T libstaff" "$got" "drwxrws--T libstaff"
    fi
done

# --- 3. cataloging scripts deployed --------------------------------------
for f in add_book.py lookup_by_isbn.py overdue_report.py; do
    p="/srv/library/cataloging/$f"
    exists "$p deployed" "$p"
    if [ -f "$p" ]; then
        got="$(stat -c '%G' "$p" 2>/dev/null)"
        check "$f group is libstaff" "$got" "libstaff"
    fi
done

# --- 4. you are actually in the group ---------------------------------
if id -nG 2>/dev/null | tr ' ' '\n' | grep -qx libstaff; then
    printf 'PASS  your login is in the libstaff group\n'
    pass=$((pass + 1))
else
    printf 'FAIL  your login is NOT in libstaff (usermod, then re-login)\n'
    fail=$((fail + 1))
fi

# --- 5. admin welcome banner installed --------------------------------
if grep -q 'welcome_banner' "$HOME/.bashrc" 2>/dev/null; then
    printf 'PASS  welcome banner is in ~/.bashrc\n'
    pass=$((pass + 1))
else
    printf 'FAIL  welcome banner not found in ~/.bashrc\n'
    fail=$((fail + 1))
fi

echo
echo "-------------------------------------------------------------"
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && echo "All checks passed." || echo "Fix the FAILs above and run again."
[ "$fail" -eq 0 ]
