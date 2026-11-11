#!/usr/bin/env python3
"""Read-only SSH forced command. Install root-owned on the clinical Ubuntu VM."""
import json
import os
import pwd
import re
import sys
from pathlib import Path

ROOT = Path('/srv/clinical-data')
ALLOWED_NAME = re.compile(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,79}\Z')


def main():
    command = os.environ.get('SSH_ORIGINAL_COMMAND', '').split(' ', 1)
    action = command[0]
    if action == 'identity' and len(command) == 1:
        print(json.dumps({'user': pwd.getpwuid(os.geteuid()).pw_name, 'uid': os.geteuid()}))
        return 0
    if action == 'list' and len(command) == 1:
        # Enumeration itself must obey the persona's directory permissions.
        names = sorted(p.name for p in ROOT.iterdir() if p.is_file() and not p.is_symlink() and not p.name.startswith('.'))
        print(json.dumps(names))
        return 0
    if action == 'read' and len(command) == 2 and ALLOWED_NAME.fullmatch(command[1]):
        name = command[1]
        if name.startswith('.'):
            raise PermissionError('hidden files are excluded')
        parent_fd = os.open(ROOT, os.O_RDONLY | os.O_DIRECTORY)
        try:
            fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW, dir_fd=parent_fd)
            with os.fdopen(fd, 'r', encoding='utf-8', errors='replace') as f:
                print(f.read(32768), end='')
        finally:
            os.close(parent_fd)
        return 0
    print('Denied: unsupported read-only command', file=sys.stderr)
    return 2


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, UnicodeError) as exc:
        print(f'{type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(1)
