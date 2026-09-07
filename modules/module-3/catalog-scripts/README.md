# Cataloging Scripts

Small Python scripts for the University Library's cataloging team, used by
Lab 2's `git clone` / `find` / `grep` practice. Nothing here needs any
external packages -- plain Python 3 standard library only.

## Getting the files onto your Ubuntu VM

```
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/SE4CPS/2026-COMP-175.git
cd 2026-COMP-175/modules/module-3/catalog-scripts
```

## What's here

| File                 | What it does                                      |
|----------------------|----------------------------------------------------|
| `add_book.py`        | Appends a book (title, author, ISBN, year) to `catalog.txt` |
| `lookup_by_isbn.py`  | Looks up a book in `catalog.txt` by its ISBN        |
| `overdue_report.py`  | Lists overdue checkouts from `checkout.txt`, by ISBN |

None of these create their own `catalog.txt`/`checkout.txt` -- they're meant
to be run against the files a real cataloging workflow would already have.
They're here mainly so Lab 2 has real `.py` files to `find` and `grep`
(e.g. `grep -ri "isbn" *.py`) instead of searching against nothing.
