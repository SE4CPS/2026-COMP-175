# Module 3 Class Project: Stand Up the Library File Share

This is **Phase 4** of the Module 3 practice lab. Phases 1, 2 and 3 walked you
through the pieces on the slides; here you build the whole thing on your own
Ubuntu VM, deploy the real files from this repo, and hand in an audit that
proves it works.

Everything you need is a command Module 3 already taught: `mkdir`,
`groupadd`, `usermod`, `chgrp`, `chmod`, `ls`, `stat`, `df`, `id`, `groups`,
`ln`.

## 0. Get the repo onto your VM

```
sudo apt-get update
sudo apt-get install -y git
cd ~
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/modules/module-3
```

Run `git pull` from `~/2026-COMP-175` any time to pick up updates.

## What you just cloned (module-3 folder)

Every file below is real and already written. You do not edit them &mdash;
you *deploy* them and prove they run.

| File | What it is | Run it with | What you should see |
|---|---|---|---|
| `catalog-scripts/add_book.py` | Appends one book (`title\|author\|isbn\|year`) to `catalog.txt` in the current directory. Creates nothing; the file must already exist. | `python3 add_book.py "Title" "Author" 9780321919168 2016` | `Added 'Title' (ISBN 9780321919168) to catalog.txt`, and one new line in `catalog.txt` |
| `catalog-scripts/lookup_by_isbn.py` | Reads `catalog.txt` and prints the line whose ISBN (3rd field) matches. | `python3 lookup_by_isbn.py 9780321919168` | the matching `title\|author\|isbn\|year` line, or `No book found with ISBN ...` |
| `catalog-scripts/overdue_report.py` | Reads `checkout.txt` (`patron\|isbn\|due_date\|returned`) and prints every item not returned whose due date is in the past. | `python3 overdue_report.py` | one `patron: ISBN ... was due YYYY-MM-DD` line per overdue item (nothing if none, or a "not found" note if `checkout.txt` is missing) |
| `catalog-scripts/README.md` | Notes on the three scripts and their file formats. | `cat catalog-scripts/README.md` | the table above, in more detail |
| `dotfiles/.bashrc` | A login-banner block: on every new interactive shell it prints your identity, your groups, the root filesystem type, and free space on `/` and `/srv`. Built only from `id`, `groups`, `mount`, `df`. | append to `~/.bashrc`, then `source ~/.bashrc` (see step 4) | a boxed banner with your `id`, your `groups`, `Root filesystem type: ext4`, and a `df -h` table |
| `class-project/verify.sh` | The self-check for this project. Inspects `/srv/library` and its three role folders, the deployed scripts, your `libstaff` membership, and the banner in `~/.bashrc`. | `bash verify.sh` | one `PASS`/`FAIL` line per check, a count, and a final verdict (see step 6) |
| `class-project/README.md` | This file. | `cat class-project/README.md` | these instructions |

## 1. Build `/srv/library` (the shared collection)

Recreate the Phase 1 + Phase 2 end state:

1. `sudo mkdir -p /srv/library`
2. `sudo groupadd libstaff` (skip if it already exists), then
   `sudo usermod -aG libstaff $USER` and start a fresh login so `id` lists it.
3. `sudo chgrp libstaff /srv/library`
4. `sudo chmod 3770 /srv/library` &mdash; `770` for owner+group, `2000`
   setgid so new files inherit `libstaff`, `1000` sticky so staff can add
   files but only delete their own.
5. Confirm: `stat -c '%A %G' /srv/library` should print `drwxrws--T libstaff`.

## 2. Create the three role folders

```
sudo mkdir /srv/library/{cataloging,circulation,archives}
sudo chgrp -R libstaff /srv/library
sudo chmod 3770 /srv/library/cataloging /srv/library/circulation /srv/library/archives
```

Each should also read `drwxrws--T libstaff`.

## 3. Deploy the cataloging scripts

Copy the scripts from this repo into the `cataloging` folder and make them
group-usable:

```
cp catalog-scripts/*.py /srv/library/cataloging/
sudo chgrp libstaff /srv/library/cataloging/*.py
chmod 750 /srv/library/cataloging/*.py
```

Then prove they run: create a `catalog.txt` in that folder and add a book.

```
cd /srv/library/cataloging
touch catalog.txt
python3 add_book.py "The Practice of System and Network Administration" "Limoncelli" "9780321919168" 2016
python3 lookup_by_isbn.py 9780321919168
```

## 4. Install the admin welcome banner

```
cat ~/2026-COMP-175/modules/module-3/dotfiles/.bashrc >> ~/.bashrc
source ~/.bashrc
```

Open a new shell. You should see the identity / filesystem / disk banner.
Read the file first &mdash; you are expected to explain every line of it.

## 5. Break something, then diagnose it

Pick one and do it for real, then write two or three sentences on how you
found and fixed it:

- `sudo chmod 700 /srv/library/circulation` &mdash; now a teammate gets
  "Permission denied". What does `ls -ld` show, and what fixes it?
- Rename `catalog.txt`, then check a symlink you made to it. Why is it red?
- `ln /srv/library/cataloging/catalog.txt ~/catalog-hardlink.txt`, then
  delete the original. Does the hardlink still open? Explain with `ls -li`.

## 6. Run the self-check and fix what fails

```
bash ~/2026-COMP-175/modules/module-3/class-project/verify.sh
```

`verify.sh` prints **one line per check**: `PASS` if that piece of the
build is correct, or `FAIL` with the expected vs. actual value so you know
what to fix. It ends with a count and a verdict, and its exit code is `0`
only when every check passed.

**A finished build looks exactly like this** (16 checks, all green):

```
=== Module 3 class project: verify ===

PASS  /srv/library exists
PASS  /srv/library is drwxrws--T libstaff
PASS  /srv/library/cataloging exists
PASS  /srv/library/cataloging is drwxrws--T libstaff
PASS  /srv/library/circulation exists
PASS  /srv/library/circulation is drwxrws--T libstaff
PASS  /srv/library/archives exists
PASS  /srv/library/archives is drwxrws--T libstaff
PASS  /srv/library/cataloging/add_book.py deployed
PASS  add_book.py group is libstaff
PASS  /srv/library/cataloging/lookup_by_isbn.py deployed
PASS  lookup_by_isbn.py group is libstaff
PASS  /srv/library/cataloging/overdue_report.py deployed
PASS  overdue_report.py group is libstaff
PASS  your login is in the libstaff group
PASS  welcome banner is in ~/.bashrc

-------------------------------------------------------------
16 passed, 0 failed
All checks passed.
```

A `FAIL` looks like this &mdash; the fix is always in the two lines under it:

```
FAIL  /srv/library is drwxrws--T libstaff
        expected: drwxrws--T libstaff
        got:      drwxrwx--- root
```

That one means the group is still `root` and setgid + sticky are not set:
`sudo chgrp libstaff /srv/library && sudo chmod 3770 /srv/library`. Fix
each `FAIL`, run `verify.sh` again, and stop when the last line reads
`All checks passed.`

## What to submit (Canvas)

Submit **one text file or PDF** containing:

1. The full output of `ls -lR /srv/library`.
2. The full output of `verify.sh` (all `PASS`).
3. Your identity/disk banner (paste it, or a screenshot of a fresh login).
4. Your 2-3 sentence write-up from Task 5.
5. One sentence per permission string in your `ls -lR` explaining what it
   grants and to whom.

**Groups:** you may work together on approach, but each person builds and
submits their own VM. **AI policy:** allowed, but state which parts used AI
and which you did yourself.
