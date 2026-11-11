import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from werkzeug.security import generate_password_hash

import app as team5


class DashboardTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        hashes = root / 'hashes.json'
        hashes.write_text(json.dumps({name: generate_password_hash('test-password', method='pbkdf2:sha256')
                                      for name in ('guest1', 'operator')}))
        env = {'TEAM5_SESSION_SECRET': 'test-only-secret', 'TEAM5_PASSWORD_HASHES': str(hashes),
               'TEAM5_UBUNTU_HOST': '10.0.0.40', 'TEAM5_KEY_DIR': str(root),
               'TEAM5_KNOWN_HOSTS': str(root / 'known_hosts')}
        self.env_patch = patch.dict(os.environ, env)
        self.env_patch.start()
        self.addCleanup(self.env_patch.stop)
        self.app = team5.create_app()
        self.app.testing = True
        self.client = self.app.test_client()

    def login(self, persona='guest1'):
        response = self.client.post('/login', data={'persona': persona, 'password': 'test-password'})
        self.assertEqual(response.status_code, 302)
        with self.client.session_transaction() as session:
            return session['csrf']

    def test_action_link_opens_dashboard_without_running_command(self):
        self.login()
        with patch('app.subprocess.run') as run:
            response = self.client.get('/action?action=restart', follow_redirects=True)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.request.path, '/')
        self.assertEqual([item.status_code for item in response.history], [302])
        self.assertIn(b'guest1', response.data)
        run.assert_not_called()

    def test_real_ssh_failure_is_shown(self):
        csrf = self.login()
        failure = subprocess.CompletedProcess([], 1, '', 'Permission denied (publickey).')
        with patch('app.subprocess.run', return_value=failure) as run:
            response = self.client.post('/action', data={'csrf': csrf, 'action': 'list'})
        self.assertIn(b'Permission denied (publickey).', response.data)
        self.assertIn(b'EXIT 1', response.data)
        args = run.call_args.args[0]
        self.assertEqual(args[-2:], ['guest1@10.0.0.40', 'list'])

    def test_bad_filename_cannot_reach_ssh(self):
        csrf = self.login()
        with patch('app.subprocess.run') as run:
            response = self.client.post('/action', data={'csrf': csrf, 'action': 'read',
                                                         'filename': '../../etc/shadow'})
        self.assertEqual(response.status_code, 400)
        run.assert_not_called()

    def test_post_requires_persona_and_csrf(self):
        response = self.client.post('/action', data={'action': 'list'})
        self.assertEqual(response.status_code, 403)
        csrf = self.login()
        response = self.client.post('/action', data={'csrf': csrf + 'wrong', 'action': 'list'})
        self.assertEqual(response.status_code, 403)

    def test_record_success_is_actual_subprocess_output(self):
        csrf = self.login()
        success = subprocess.CompletedProcess([], 0, 'mrn,name\nER-1001,Jordan Ellis\n', '')
        with patch('app.subprocess.run', return_value=success) as run:
            response = self.client.post('/action', data={'csrf': csrf, 'action': 'read',
                                                         'filename': 'patients.csv'})
        self.assertIn(b'ER-1001,Jordan Ellis', response.data)
        self.assertEqual(run.call_args.args[0][-1], 'read patients.csv')

    def test_persona_cannot_manage_app(self):
        csrf = self.login()
        with patch('app.subprocess.run') as run:
            response = self.client.post('/action', data={'csrf': csrf, 'action': 'restart'})
        self.assertEqual(response.status_code, 403)
        run.assert_not_called()

    def test_operator_cannot_read_records(self):
        csrf = self.login('operator')
        with patch('app.subprocess.run') as run:
            response = self.client.post('/action', data={'csrf': csrf, 'action': 'read', 'filename': 'patients.csv'})
        self.assertEqual(response.status_code, 403)
        run.assert_not_called()


if __name__ == '__main__':
    unittest.main()
