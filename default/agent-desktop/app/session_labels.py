#!/usr/bin/env python3
"""Read-only T3 conversation ownership and session labels."""
import datetime
import json
from pathlib import Path
import re
import sqlite3


def is_claim_response(value, lease, depth=0):
    if depth > 10:
        return False
    if isinstance(value, str):
        try:
            decoder = json.JSONDecoder()
            offset = 0
            while offset < len(value):
                while offset < len(value) and value[offset].isspace():
                    offset += 1
                if offset == len(value):
                    break
                item, offset = decoder.raw_decode(value, offset)
                if is_claim_response(item, lease, depth + 1):
                    return True
            return False
        except (ValueError, RecursionError):
            return False
    if isinstance(value, list):
        return any(is_claim_response(item, lease, depth + 1) for item in value)
    if not isinstance(value, dict) or value.get('isError'):
        return False
    claim = value.get('structuredContent', {})
    if (isinstance(claim, dict) and claim.get('handle') == lease['handle']
            and claim.get('desktop') == lease['desktop'] and isinstance(claim.get('show'), str)):
        return True
    return any(is_claim_response(item, lease, depth + 1) for key, item in value.items()
               if key in ('output', 'content', 'text', 'payload', 'message'))


def native_claim_response(payload, lease, claim_calls):
    if payload.get('call_id') not in claim_calls:
        return False
    output = payload.get('output')
    if not isinstance(output, str):
        return False
    output = re.sub(r'^Wall time: [0-9.]+ seconds\nOutput:\n', '', output)
    try:
        value = json.loads(output)
    except ValueError:
        return False
    return is_claim_response({'structuredContent': value}, lease)


class Sessions:
    def __init__(self, home):
        self.home = Path(home)
        self.matches = {}
        self.claim_cache = {}

    def titles(self, leases):
        self.matches = {}
        overrides_file = self.home / '.local/share/agent-desktop-labels/titles.json'
        overrides = json.loads(overrides_file.read_text()) if overrides_file.exists() else {}
        db = self.home / '.t3/userdata/state.sqlite'
        if not db.is_file():
            return {lease['desktop']: overrides.get(lease['handle'],
                    {'title': lease['owner'], 'icon': ''}) for lease in leases}
        with sqlite3.connect(db.as_uri() + '?mode=ro', uri=True) as connection:
            rows = connection.execute('''
                SELECT t.thread_id, t.title, p.workspace_root, p.favicon_path,
                       r.resume_cursor_json
                FROM projection_threads t
                JOIN projection_projects p USING (project_id)
                JOIN provider_session_runtime r USING (thread_id)
                WHERE t.deleted_at IS NULL
            ''').fetchall()
        by_provider = {}
        for thread, title, root, favicon, cursor in rows:
            cursor = json.loads(cursor or 'null') or {}
            for provider_id in (cursor.get('threadId'), cursor.get('resume')):
                if provider_id:
                    by_provider.setdefault(provider_id, set()).add(thread)

        paths = list((self.home / '.codex/sessions').glob('**/rollout-*.jsonl'))
        paths += list((self.home / '.claude/projects').glob('*/*.jsonl'))
        candidates_by_handle = {}
        live_paths = set()
        for path in paths:
            providers = [key for key in by_provider if key in path.name]
            if not providers:
                continue
            stat = path.stat()
            candidates = [lease for lease in leases if stat.st_mtime * 1000 >= lease['created']]
            if not candidates:
                continue
            live_paths.add(path)
            signature = (stat.st_mtime_ns, stat.st_size, tuple(sorted(lease['handle'] for lease in candidates)))
            cached = self.claim_cache.get(path)
            if not cached or cached[0] != signature:
                found = set()
                claim_calls = set()
                with path.open() as stream:
                    for line in stream:
                        if '"function_call"' in line:
                            try:
                                call = json.loads(line).get('payload', {})
                                if (call.get('type') == 'function_call' and call.get('name') == 'claim'
                                        and re.fullmatch(r'mcp__hypr[-_]desktop(?:[-_][a-z0-9]+)*', call.get('namespace', ''))):
                                    claim_calls.add(call.get('call_id'))
                            except ValueError:
                                pass
                        for lease in candidates:
                            if lease['handle'] not in line:
                                continue
                            try:
                                record = json.loads(line)
                                stamp = datetime.datetime.fromisoformat(
                                    record['timestamp'].replace('Z', '+00:00')).timestamp() * 1000
                            except (ValueError, KeyError):
                                continue
                            payload = record.get('payload', {})
                            tool_output = payload.get('type') in ('function_call_output', 'custom_tool_call_output')
                            tool_output |= any(item.get('type') == 'tool_result' for item in
                                               record.get('message', {}).get('content', [])
                                               if isinstance(item, dict))
                            # Yielded tool results can arrive minutes after allocation.
                            if (tool_output and -1000 <= stamp - lease['created'] <= 300000
                                    and (is_claim_response(record, lease) or native_claim_response(payload, lease, claim_calls))):
                                found.add(lease['handle'])
                self.claim_cache[path] = (signature, found)
            for handle in self.claim_cache[path][1]:
                for provider in providers:
                    candidates_by_handle.setdefault(handle, set()).update(by_provider[provider])
        self.claim_cache = {path: value for path, value in self.claim_cache.items() if path in live_paths}
        self.matches = {handle: next(iter(threads)) for handle, threads in candidates_by_handle.items() if len(threads) == 1}

        by_thread = {row[0]: row for row in rows}
        result = {}
        for lease in leases:
            if lease['handle'] in overrides:
                result[lease['desktop']] = overrides[lease['handle']]
                continue
            row = by_thread.get(self.matches.get(lease['handle']))
            if row:
                _, title, root, favicon, _ = row
                candidates = [Path(root) / 'favicon.svg', Path(root) / 'favicon.ico']
                if favicon:
                    path = Path(favicon)
                    candidates.insert(0, path if path.is_absolute() else Path(root) / path)
                icon = next((path.resolve().as_uri() for path in candidates if path.is_file()), '')
                result[lease['desktop']] = {'title': title, 'icon': icon}
            else:
                result[lease['desktop']] = {'title': lease['owner'], 'icon': ''}
        return result
