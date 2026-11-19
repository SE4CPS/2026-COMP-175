# Team 4 -- RBAC Progress Log (Toan)

Status as of 2026-11-19. Solo so far -- see "Team status" below.

Screenshots referenced below are in `screenshots/`, named
`YYYY-MM-DD_<step>.png` in the order the work happened.

## Important: baseline mismatch, not yet reconciled

The work in this log was done **before** I had read
`project/part-2/Hospital-VM/setup.sh` and `Hospital-VM/README.md`
closely. That script defines the actual shared baseline every team's
VM is supposed to start from:

- Data path: `/srv/clinical-data` (flat files, `patients.csv` +
  `.patients.csv.bak`, `root:root`, `755`/`644`, world-readable on
  purpose -- that's the problem this team is meant to fix).
- Accounts: `guest1`, `nurse1`, `physician1`, `patient1` (note:
  `physician1`, not `doc1`; only one patient account; `patient1` has
  a real password, `Patient123!`, set by `chpasswd`).
- Groups: `guests`, `nurses`, `physicians`, `patients` (no
  `careteam`).
- There is also `/opt/hospital-vm/legacy-notify.sh`, world-readable
  (`644`), containing a hardcoded credential in a comment
  (`patient1 / Patient123!`). This looks like a planted finding --
  likely relevant to Team 3 (Attacker) and worth flagging/handling
  as part of this team's hardening, not just removing quietly.

What I actually built below uses a **different, self-designed**
layout: `/srv/clinical` (not `/srv/clinical-data`), a `clinicadmin`
owner account, a `careteam` group, and `doc1` + two patient accounts
(`patient1`, `patient2`) instead of `physician1` + one patient. It is
a correct and tested RBAC design in isolation, but it does **not**
sit on top of the real `Hospital-VM/setup.sh` baseline, so it is not
yet the deliverable other teams (1, 2, 3, 5) can target.

**Next session, before anything else:** decide whether to (a) re-run
`Hospital-VM/setup.sh` on the VM and re-apply the same ACL approach
to its actual paths/accounts, or (b) keep this layout and get it
explicitly agreed with the class setup. Option (a) is almost
certainly correct -- the point of the shared seed script is that
every team's VM matches. Treat everything below as a validated
design/rehearsal, not the final state.

## What's actually done (tested, working)

### Step 1 -- inventory + baseline hardening (2026-11-12)
- `screenshots/2026-11-12_step1-inventory.png`: OS version, `id`,
  network config, listening services (`ss -tlnp`), `ufw` status
  (inactive at the time), `sshd` active, `acl` package present.
- `screenshots/2026-11-12_step1-ufw-hardening.png`: set `ufw` default
  deny incoming / allow outgoing, allowed SSH only from
  `192.168.56.0/24`, enabled `ufw`. Confirmed with `ufw status
  verbose`.

### Steps 2-3 -- groups, owner account, test users (2026-11-18)
- `screenshots/2026-11-18_step2-groups-clinicadmin.png`: created
  groups `guests`, `patients`, `nurses`, `physicians`, `careteam`;
  created the `clinicadmin` system account (no login shell, owns the
  data instead of logging in).
- `screenshots/2026-11-18_step3-test-users.png`: created test users
  `guest1`, `nurse1`, `doc1`, `patient1`, `patient2` and put each in
  the right group(s) (`nurse1`/`doc1` also share `careteam`).
  Confirmed with `id` for all five.

### Step 4 -- directory layout + ACLs (2026-11-19)
Design (my own layout, see baseline-mismatch note above):

| Path | guest | own patient | other patient | nurse | physician |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `public/` | read | read | read | read | read |
| `records/patientN/` | none | read | none | read | read+write |
| `audit/` | none | none | none | none | `clinicadmin` only |

- `screenshots/2026-11-19_step4-acl-install.png`: installed the
  `acl` package (already present).
- `screenshots/2026-11-19_step4-dirs-and-acl-cmds.png`: created
  `/srv/clinical/{public,records,audit}` and the two patient
  subdirectories (`records/patient1`, `records/patient2`, mode
  `2770`, setgid to `physicians`); a typo in the first `setfacl` loop
  (`patients$n` instead of `patient$n`) left it hanging.
- `screenshots/2026-11-19_step4-typo-fix-getfacl-1.png`: fixed the
  typo, re-ran the loop successfully.
- `screenshots/2026-11-19_step4-getfacl-permission-denied.png`: first
  `getfacl -R` as my own (non-privileged) account -- correctly
  denied entry into `records/` and `audit/`, confirming the lockout
  works even for inspection.
- `screenshots/2026-11-19_step4-getfacl-patient-dirs-confirmed.png`:
  `sudo getfacl -R` showing the real ACLs on both patient
  directories -- `user:patientN:r-x`, `group:nurses:r-x`,
  `group::rwx` (physicians, via primary group), setgid flag, and
  matching default ACLs so new files inherit the same rules. Matches
  the matrix above.

### Step 4b -- dummy records (2026-11-19)
- `screenshots/2026-11-19_step4b-dummy-records-final-state.png`:
  created one file per area (`public/info.txt`,
  `records/patient1/record.txt`, `records/patient2/record.txt`,
  `audit/audit.log`) as the `clinicadmin` account so ownership was
  correct from creation; `chmod 0660` on the two record files and
  `0600` on the audit log. Final `ls -lR` confirms: `clinicadmin`
  owns everything, record files are group `physicians`, audit dir
  and file are `clinicadmin`-only (`700`/`600`), public file is
  world-readable (`644`).

## Not done yet

- **Step 5**: the per-persona test script (`guest1`/`patient1`/
  `patient2`/`nurse1`/`doc1` each tried against each path with
  `sudo -u ... test -r/-w`, expecting PASS on every line). Written
  and ready to run, not yet executed/captured -- paused for an exam.
- Reconciling this layout against the real `Hospital-VM/setup.sh`
  baseline (see above) -- this has to happen before Step 5 is
  meaningful for the class-wide target.
- The actual deliverable for this team: the Kali-side dashboard.

## Kali dashboard -- undecided, two directions in mind

Not built yet. Two options under consideration for how the
dashboard presents the per-persona PASS/FAIL test results:

- **Flask web app.** Favored by the rest of the group/class, and
  probably easier for other teams to read or extend if they need to.
- **ASCII/terminal-style interface.** My own preference, running
  straight in the Kali terminal -- no web server, no browser
  dependency, closer to the rest of this course's CLI-first tooling.

No commitment either way yet -- this is just marking the two ideas
before they get forgotten. Whichever it is, it will read the same
`test -r`/`test -w` PASS/FAIL checks from Step 5 (or the actual
baseline-paths version of them) over SSH from Kali to the Ubuntu VM.

## Team status

Members listed in the team README: Toan, Kaung, Shomario. As of this
log, this is solo work -- no commits or setup from the other two.
Proceeding alone rather than waiting; if that needs to be raised with
the professor, that's a conversation for the other two to have, not
something resolved by this log.
