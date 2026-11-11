#!/usr/bin/env python3
"""Team 5 Flask dashboard. Every result comes from a real subprocess."""
import json
import os
import re
import secrets
import subprocess
from pathlib import Path

from flask import Flask, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash

PERSONAS = ('guest1', 'nurse1', 'physician1', 'patient1')
WEB_USERS = PERSONAS + ('operator',)
FILE_NAME = re.compile(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,79}\Z')
BASE = Path(__file__).resolve().parent


def create_app():
    app = Flask(__name__)
    app.secret_key = os.environ['TEAM5_SESSION_SECRET']
    app.config['MAX_CONTENT_LENGTH'] = 8192
    hashes = json.loads(Path(os.environ['TEAM5_PASSWORD_HASHES']).read_text())
    host = os.environ['TEAM5_UBUNTU_HOST']
    keys = Path(os.environ['TEAM5_KEY_DIR'])
    known_hosts = Path(os.environ['TEAM5_KNOWN_HOSTS'])

    def run(args, timeout=8):
        try:
            result = subprocess.run(args, text=True, capture_output=True, timeout=timeout, check=False)
            return {'code': result.returncode, 'stdout': result.stdout[:32768], 'stderr': result.stderr[:8192]}
        except (OSError, subprocess.TimeoutExpired) as exc:
            return {'code': -1, 'stdout': '', 'stderr': f'{type(exc).__name__}: {exc}'}

    def remote(persona, command):
        # SSH account keys are forced to run gateway.py. No command can write clinical data.
        return run(['ssh', '-F', '/dev/null', '-T', '-i', str(keys / f'{persona}_ed25519'), '-o', 'BatchMode=yes',
                    '-o', 'IdentitiesOnly=yes', '-o', 'ConnectTimeout=4',
                    '-o', 'StrictHostKeyChecking=yes', '-o', f'UserKnownHostsFile={known_hosts}',
                    f'{persona}@{host}', command])

    @app.get('/')
    def index():
        return render_template('index.html', persona=session.get('persona'), result=None,
                               csrf=session.setdefault('csrf', secrets.token_urlsafe(24)))

    @app.post('/login')
    def login():
        persona = request.form.get('persona', '')
        password = request.form.get('password', '')
        if persona not in WEB_USERS or not check_password_hash(hashes.get(persona, 'invalid'), password):
            return render_template('index.html', persona=None,
                                   result={'code': 1, 'stderr': 'Login failed', 'stdout': ''},
                                   csrf=session.setdefault('csrf', secrets.token_urlsafe(24))), 401
        else:
            session.clear()
            session['persona'] = persona
            session['csrf'] = secrets.token_urlsafe(24)
        return redirect(url_for('index'))

    @app.post('/logout')
    def logout():
        if not session.get('csrf') or request.form.get('csrf') != session.get('csrf'):
            return 'Invalid form token', 403
        session.clear()
        return redirect(url_for('index'))

    @app.get('/action')
    def action_home():
        # Opening or refreshing a result URL must never run a command.
        return redirect(url_for('index'))

    @app.post('/action')
    def action():
        if not session.get('csrf') or request.form.get('csrf') != session.get('csrf'):
            return 'Invalid form token', 403
        persona = session.get('persona')
        if persona not in WEB_USERS:
            return redirect(url_for('index'))
        name = request.form.get('action', '')
        if name in ('identity', 'list', 'read') and persona not in PERSONAS:
            return 'Persona action requires a persona login', 403
        if name in ('deploy', 'restart') and persona != 'operator':
            return 'App management requires the Team 5 operator login', 403
        if name == 'identity':
            result = remote(persona, 'identity')
        elif name == 'list':
            result = remote(persona, 'list')
        elif name == 'read':
            filename = request.form.get('filename', '')
            if not FILE_NAME.fullmatch(filename) or filename.startswith('.'):
                return 'Invalid filename', 400
            result = remote(persona, f'read {filename}')
        elif name == 'deploy':
            result = run(['/usr/bin/bash', str(BASE / 'deploy.sh')], timeout=30)
        elif name == 'restart':
            result = run(['systemd-run', '--user', '--on-active=3s',
                          f'--unit=team5-web-restart-{secrets.token_hex(4)}',
                          '/usr/bin/systemctl', '--user', 'restart', 'team5-web.service'])
        else:
            return 'Unknown action', 400
        result['action'] = name
        return render_template('index.html', persona=persona, result=result, csrf=session['csrf'])

    return app


if __name__ == '__main__':
    create_app().run(host=os.environ.get('TEAM5_BIND', '127.0.0.1'), port=int(os.environ.get('TEAM5_PORT', '5000')))
