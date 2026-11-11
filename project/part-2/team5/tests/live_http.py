"""Kali-only live check. Reads local demo password, prints no secrets."""
import http.cookiejar
import html
import re
import urllib.parse
import urllib.request
import urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = 'http://127.0.0.1:5000'
password_text = (ROOT / 'demo-passwords-private.txt').read_text()
def password_for(name):
    return re.search(rf'^  {name}: (\S+)$', password_text, re.M).group(1)


opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))


def post(path, values):
    data = urllib.parse.urlencode(values).encode()
    with opener.open(urllib.request.Request(BASE + path, data=data), timeout=20) as response:
        return response.read().decode()


post('/login', {'persona': 'guest1', 'password': password_for('guest1')})
with opener.open(BASE, timeout=8) as response:
    page = response.read().decode()
csrf = re.search(r'name="csrf" value="([^"]+)"', page).group(1)
for action, extra in [('identity', {}), ('list', {}), ('read', {'filename': 'patients.csv'}),
                      ('read', {'filename': 'restricted.txt'})]:
    page = post('/action', {'csrf': csrf, 'action': action, **extra})
    status = re.search(r'EXIT (-?\d+)', page).group(1)
    chunks = [html.unescape(x) for x in re.findall(r'<pre>(.*?)</pre>', page, re.S)]
    print(f'=== {action}: exit {status} ===')
    for chunk in chunks:
        print(chunk[:600].strip())
try:
    post('/action', {'csrf': csrf, 'action': 'restart'})
    raise AssertionError('Persona was allowed to restart the app')
except urllib.error.HTTPError as exc:
    assert exc.code == 403
    print('=== guest restart: HTTP 403 ===')
post('/logout', {'csrf': csrf})
post('/login', {'persona': 'operator', 'password': password_for('operator')})
with opener.open(BASE, timeout=8) as response:
    page = response.read().decode()
csrf = re.search(r'name="csrf" value="([^"]+)"', page).group(1)
for action in ('deploy', 'restart'):
    page = post('/action', {'csrf': csrf, 'action': action})
    status = re.search(r'EXIT (-?\d+)', page).group(1)
    chunks = [html.unescape(x) for x in re.findall(r'<pre>(.*?)</pre>', page, re.S)]
    print(f'=== operator {action}: exit {status} ===')
    for chunk in chunks:
        print(chunk[:600].strip())
