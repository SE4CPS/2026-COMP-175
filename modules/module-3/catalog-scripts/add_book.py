#!/usr/bin/env python3
"""add_book.py -- append a book record to the library catalog.

Each record is one line in catalog.txt: title|author|isbn|year
The ISBN is the unique key the rest of the cataloging scripts key off of.
"""
import sys

CATALOG_FILE = "catalog.txt"


def add_book(title, author, isbn, year):
    """Append a new book to the catalog, keyed by its ISBN."""
    with open(CATALOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"{title}|{author}|{isbn}|{year}\n")
    print(f"Added '{title}' (ISBN {isbn}) to {CATALOG_FILE}")


def main():
    if len(sys.argv) != 5:
        print("Usage: add_book.py <title> <author> <isbn> <year>")
        sys.exit(1)
    title, author, isbn, year = sys.argv[1:5]
    add_book(title, author, isbn, year)


if __name__ == "__main__":
    main()
