#!/usr/bin/env python3
"""lookup_by_isbn.py -- find a book in the catalog by its ISBN.

Reads catalog.txt (see add_book.py for the file format) and prints the
matching title|author|isbn|year line, if any.
"""
import sys

CATALOG_FILE = "catalog.txt"


def lookup_by_isbn(isbn):
    """Return the catalog line matching isbn, or None if not found."""
    try:
        with open(CATALOG_FILE, "r", encoding="utf-8") as f:
            for line in f:
                fields = line.strip().split("|")
                if len(fields) == 4 and fields[2] == isbn:
                    return line.strip()
    except FileNotFoundError:
        print(f"{CATALOG_FILE} not found -- has add_book.py been run yet?")
        sys.exit(1)
    return None


def main():
    if len(sys.argv) != 2:
        print("Usage: lookup_by_isbn.py <isbn>")
        sys.exit(1)
    isbn = sys.argv[1]
    result = lookup_by_isbn(isbn)
    if result:
        print(result)
    else:
        print(f"No book found with ISBN {isbn}")


if __name__ == "__main__":
    main()
