#!/usr/bin/env python3
"""overdue_report.py -- list overdue checkouts, grouped by patron.

Reads checkout.txt: patron|isbn|due_date|returned (returned is "yes"/"no")
Prints one line per overdue item, so cataloging staff know which ISBNs
still need to be chased down.
"""
import sys
from datetime import date

CHECKOUT_FILE = "checkout.txt"


def parse_line(line):
    fields = line.strip().split("|")
    if len(fields) != 4:
        return None
    patron, isbn, due_date, returned = fields
    return {
        "patron": patron,
        "isbn": isbn,
        "due_date": due_date,
        "returned": returned.lower() == "yes",
    }


def overdue_items(today=None):
    today = today or date.today().isoformat()
    overdue = []
    try:
        with open(CHECKOUT_FILE, "r", encoding="utf-8") as f:
            for line in f:
                record = parse_line(line)
                if record and not record["returned"] and record["due_date"] < today:
                    overdue.append(record)
    except FileNotFoundError:
        print(f"{CHECKOUT_FILE} not found in this directory.")
        sys.exit(1)
    return overdue


def main():
    for record in overdue_items():
        print(f"{record['patron']}: ISBN {record['isbn']} was due {record['due_date']}")


if __name__ == "__main__":
    main()
