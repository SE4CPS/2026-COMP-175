# Module 2: Command-Line & Permissions -- Practice Files

Real files for the university-library scenario used throughout Module 2's
slides (`jdoe`, the `library` group, `catalog.txt`, `patrons.txt`, and so
on) so you have something real to `ls`, `cat`, `chmod`, and `grep` against
instead of typing commands against files that don't exist.

## Getting the files onto your Ubuntu VM

```
sudo apt-get update
sudo apt-get install -y git
cd ~
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/modules/module-2
```

## What's here

| File               | Used in                                    |
|--------------------|---------------------------------------------|
| `catalog.txt`      | Owner/Group/Other, `ls -l`, `chmod` practice |
| `overdue.txt`      | `ls -l` in Practice                          |
| `checkout.txt`     | Making & Removing Files, Reading a File      |
| `notes.txt`        | Practice: Organize Today's Notes             |
| `patrons.txt`      | Searching Text: grep, Practice: Find a Patron|
| `backup.sh`        | Practice: Lock Down backup.sh (`chmod 700`)  |
| `overdue-2024.txt` | Practice: Archive Old Records (`mv`)         |
| `archive/`         | Destination for the archive task and backups |
| `.passwords/passwords.txt` | Hidden-file discovery: `ls -a`, `find` |
| `passwords/passwords.txt`  | Same file, visible folder -- compare permissions on each |

Nothing here has been `chmod`'d yet -- that's the point of Module 2's
own permissions practice slides. Run `git pull` from
`2026-COMP-175/` any time to pick up updates to these files.

**All credentials in `passwords/` and `.passwords/` are fake**, made up
for permissions practice -- they are not real accounts.
