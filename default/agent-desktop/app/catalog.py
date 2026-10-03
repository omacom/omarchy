#!/usr/bin/env python3
"""Resolve local desktop ownership without exporting agent ownership handles."""
from contextlib import closing
import base64
import json
import sqlite3
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse

sys.path.insert(0, str(Path(__file__).resolve().parent))
from session_labels import Sessions


def catalog(home, sessions, leases=None):
    path = home / '.local/share/hypr-desktop/leases.json'
    if leases is None:
        leases = json.loads(path.read_text()) if path.exists() else []
    titles = sessions.titles(leases)
    statuses = {}
    database = home / '.t3/userdata/state.sqlite'
    if database.exists():
        with closing(sqlite3.connect(database.as_uri() + '?mode=ro', uri=True)) as connection:
            try:
                for thread, approvals, inputs, plan, state in connection.execute('''
                    SELECT t.thread_id, t.pending_approval_count, t.pending_user_input_count,
                           t.has_actionable_proposed_plan, p.state
                    FROM projection_threads t LEFT JOIN projection_turns p
                    ON p.thread_id=t.thread_id AND p.turn_id=t.latest_turn_id
                    WHERE t.deleted_at IS NULL
                '''):
                    statuses[thread] = ('Waiting for you' if approvals or inputs or plan else
                        {'running': 'Working', 'pending': 'Working', 'completed': 'Finished',
                         'interrupted': 'Stopped', 'error': 'Needs attention'}.get(state, 'Ready'))
            except sqlite3.OperationalError:
                pass

    result = []
    for lease in leases:
        label = titles[lease['desktop']]
        icon = ''
        uri = urlparse(label.get('icon', ''))
        if uri.scheme == 'file':
            path = Path(unquote(uri.path))
            mime = {'.svg': 'image/svg+xml', '.ico': 'image/x-icon', '.png': 'image/png'}.get(path.suffix.lower())
            if mime and path.is_file() and path.stat().st_size <= 1024 * 1024:
                icon = f'data:{mime};base64,' + base64.b64encode(path.read_bytes()).decode()
        result.append({'desktop': lease['desktop'], 'host': lease.get('host'),
                       'generation': lease.get('generation', str(lease['created'])),
                       'title': label['title'], 'icon': icon,
                       'agentStatus': statuses.get(sessions.matches.get(lease['handle']), 'Unknown'),
                       'threadId': sessions.matches.get(lease['handle'])})
    return result


if __name__ == '__main__':
    home = Path.home()
    sessions = {}
    for line in sys.stdin:
        try:
            request = json.loads(line.strip() or '{}')
            leases = request.get('leases')
            if leases is None:
                result = catalog(home, sessions.setdefault('local', Sessions(home)))
            else:
                result = []
                for host in set(lease.get('host', 'local') for lease in leases):
                    group = [lease for lease in leases if lease.get('host', 'local') == host]
                    result.extend(catalog(home, sessions.setdefault(host, Sessions(home)), group))
            print(json.dumps({'desktops': result}), flush=True)
        except Exception as error:
            print(json.dumps({'error': str(error)}), flush=True)
