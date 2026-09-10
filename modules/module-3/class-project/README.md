# Module 3 Class Project: Stand Up the Library File Share

This is **Phase 3** of the Module 3 practice lab. Phases 1 and 2 walked you
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

Every line should read `PASS`. Fix anything that says `FAIL` and run it again.

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
