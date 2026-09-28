# COMP-175 Project Part 1 -- Hospital VM Security Assessment

Setup data for the individual, 4-week Project Part 1 assignment (see Canvas / the course deck for the
full assignment). This is a fictional scenario: no real patient data, and no file here names an actual
medical condition, diagnosis, or allergy -- only generic record IDs, room numbers, and billing amounts.

## What's here

- `setup.sh` -- run on the **`hospital-records` (Ubuntu)** VM as a sudo-capable user
  (`sudo bash setup.sh`). Creates the `contractor` account, the `/srv/hospital-records/` data
  directory, a backup script under `/opt/hospital/`, and a few other pieces left behind by a previous
  IT contractor. Re-running it resets the scenario.
- `cleanup.sh` -- reverses `setup.sh`, if you need to start over.
- `keys/contractor_id_ed25519` / `.pub` -- an SSH keypair the contractor left behind. This is a
  **real, working keypair checked into this repo on purpose** -- part of the assignment is deciding
  what that means and what you'd do about it.
- `files/` -- copies of the sample data files `setup.sh` installs, for reference.

## Using it

1. On `hospital-records`, clone this repo and run `setup.sh` as instructed in the assignment.
2. Read the script before you run it. Note anything that looks unusual.
3. Once setup finishes, **snapshot the VM** (name it `post-clone-vulnerable`) before you do any of your
   own hardening work -- you'll need that snapshot later in the assignment.
4. Follow the rest of the assignment (Canvas / the course deck) from there.

## Rules of engagement

Only test against your own two VMs (`hospital-records` and your own Kali workstation). Never point any
tool at a real IP address, a classmate's VM, or anything on the public internet. The private key in
`keys/` is for this lab only -- never reuse it, and never commit a real credential to a public repo the
way this one deliberately does as a teaching example.
