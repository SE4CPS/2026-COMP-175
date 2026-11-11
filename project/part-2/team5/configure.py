#!/usr/bin/env python3
"""Create local-only Flask secret and persona demo passwords on Kali."""
import json
import secrets
from pathlib import Path
from werkzeug.security import generate_password_hash

base = Path(__file__).resolve().parent
passwords = {name: secrets.token_urlsafe(10) for name in ('guest1', 'nurse1', 'physician1', 'patient1', 'operator')}
hash_file = base / 'persona-hashes.json'
hash_file.write_text(json.dumps({name: generate_password_hash(password, method='pbkdf2:sha256') for name, password in passwords.items()}, indent=2) + '\n')
hash_file.chmod(0o600)
secret_file = base / 'session-secret.txt'
secret_file.write_text(secrets.token_urlsafe(48) + '\n')
secret_file.chmod(0o600)
password_file = base / 'demo-passwords-private.txt'
password_file.write_text('Demo passwords (keep private):\n' + ''.join(f'  {name}: {password}\n' for name, password in passwords.items()))
password_file.chmod(0o600)
print(f'Demo passwords saved privately to: {password_file}')
print(f'Hashes: {hash_file}')
print(f'Session secret: {secret_file}')
