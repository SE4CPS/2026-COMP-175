#!/usr/bin/env python3
"""Library Admin: Books -- a tiny Python web app for COMP-175 Module 1.

Uses only the standard library (no pip install needed) so it runs the
moment Python 3 is available on the VM:

    python3 app.py

Then browse to http://<server-ip>:8080/ (or http://localhost:8080/ if
you're on the same machine).
"""

from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8080

BOOKS = [
    ("The Pragmatic Programmer", "Hunt & Thomas", "QA76.6 .H85"),
    ("Operating Systems Concepts", "Silberschatz", "QA76.76.O63"),
    ("The Mythical Man-Month", "Brooks", "QA76.6 .B75"),
    ("Clean Code", "Martin", "QA76.6 .M3675"),
    ("Unix Network Programming", "Stevens", "QA76.76.I58 S74"),
]

PAGE_TEMPLATE = """<!DOCTYPE html>
<html>
<head><title>Library Admin: Books</title></head>
<body>
<h1>Library Admin: Sample Books</h1>
<table border="1" cellpadding="6" cellspacing="0">
<tr><th>Title</th><th>Author</th><th>Call Number</th></tr>
{rows}
</table>
</body>
</html>
"""


def render_page():
    rows = "".join(
        "<tr><td>{}</td><td>{}</td><td>{}</td></tr>\n".format(title, author, call)
        for title, author, call in BOOKS
    )
    return PAGE_TEMPLATE.format(rows=rows)


class BooksHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        page = render_page().encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(page)))
        self.end_headers()
        self.wfile.write(page)


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), BooksHandler)
    print(f"Serving Library Admin: Books on port {PORT} ...")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()
