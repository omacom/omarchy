#!/usr/bin/python3
"""Local usage index with byte cursors and message previews read on demand."""
import argparse
import fcntl
import hashlib
import json
import os
import re
import sqlite3
import time
from datetime import datetime, timedelta
from functools import lru_cache
from pathlib import Path
from urllib.parse import unquote

HOME = Path.home()
STATE = Path(os.environ.get('OMARCHY_TRACKING_STATE', Path(os.environ.get('XDG_STATE_HOME', HOME / '.local/state')) / 'omarchy/agents/tracking'))


def number(value):
    try:
        return max(0, int(value or 0))
    except (TypeError, ValueError):
        return 0


def stamp(value):
    if isinstance(value, (float, int)):
        return value / 1000 if value > 10_000_000_000 else value
    try:
        return datetime.fromisoformat(str(value).replace('Z', '+00:00')).timestamp()
    except ValueError:
        return 0


@lru_cache(maxsize=1024)
def project(cwd):
    if not cwd or not str(cwd).startswith('/'):
        return '', 'Sem projeto'
    path = Path(cwd)
    for parent in [path, *path.parents]:
        git = parent / '.git'
        if git.is_file():
            try:
                target = (parent / git.read_text().strip().split('gitdir: ', 1)[1]).resolve()
                common = target / 'commondir'
                if common.exists():
                    parent = (target / common.read_text().strip()).resolve().parent
            except (OSError, IndexError):
                pass
            return str(parent), parent.name
        if git.is_dir():
            return str(parent), parent.name
    for root in [HOME / 'Projects', HOME / 'nexunio']:
        try:
            rel = path.relative_to(root)
            if rel.parts:
                return str(root / rel.parts[0]), rel.parts[0]
        except ValueError:
            pass
    if path in [HOME, Path('/tmp'), Path('/')]:
        return '', 'Sem projeto'
    if '.maestri' in path.parts:
        path = Path(*path.parts[:path.parts.index('.maestri')])
    return str(path), path.name


def workspace_names():
    result = {}
    for path in (HOME / '.maestri/workspaces').glob('*/workspace.json'):
        try:
            workspace = json.loads(path.read_text()).get('payload', {})
            pid, _ = project(workspace.get('workingDirectory'))
            if pid:
                result[pid] = str(workspace.get('name') or Path(pid).name)
        except (OSError, ValueError, TypeError):
            continue
    return result


WORKSPACES = workspace_names()
REVISION = hashlib.sha256(json.dumps(WORKSPACES, sort_keys=True).encode()).hexdigest() + ':4'


def event(identity, provider, session, model, cwd, ts, inp, out, read=0, write=0,
          kind='call', caller='', calls=1, status='registrado', duration=None, message=None,
          project_origin='Diretório da sessão'):
    project_id, name = project(cwd)
    return dict(id=f'{provider}:{identity}', provider=provider, session=str(session), model=str(model or 'desconhecido'),
                cwd=str(cwd or ''), project=project_id, projectName=WORKSPACES.get(project_id, name),
                workspace=WORKSPACES.get(project_id, ''), projectOrigin=project_origin if project_id else ('Diretório geral; projeto não identificado' if cwd else 'Diretório não informado pela ferramenta'),
                timestamp=stamp(ts), input=number(inp), output=number(out), cacheRead=number(read), cacheWrite=number(write),
                kind=kind, caller=str(caller or provider), calls=number(calls), status=str(status or 'registrado'),
                duration=duration, _message=message)


def text_content(value):
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        return str(value.get('text') or '') if value.get('type') in ('text', 'input_text', None) else ''
    if isinstance(value, list):
        chunks = [text_content(part) for part in value]
        # Multimodal inputs put the user's text after image path/context blocks.
        meaningful = [s for s in chunks if s.strip() and not re.fullmatch(r'\[Image #\d+\]\s*', s.strip())]
        return meaningful[-1] if meaningful else ''
    return ''


def json_events(path, provider, state=None, start=0):
    state = state if state is not None else {}
    state.setdefault('session', path.stem)
    state.setdefault('cwd', unquote(path.parents[1].name) if provider == 'grok' else '')
    state.setdefault('model', '')
    state.setdefault('caller', provider)
    with path.open('rb') as stream:
        stream.seek(start)
        state['offset'] = start
        while True:
            position = stream.tell()
            line = stream.readline()
            # A writer may still be appending this record. Retry it next time.
            if not line or not line.endswith(b'\n'):
                break
            state['offset'] = stream.tell()
            index = state.get('line', 0)
            state['line'] = index + 1
            try:
                item = json.loads(line)
            except (ValueError, TypeError):
                continue
            payload = item.get('payload') or {}
            if provider == 'codex':
                if item.get('type') == 'session_meta':
                    state['session'] = payload.get('id', state['session'])
                    state['cwd'] = payload.get('cwd', state['cwd'])
                    state['caller'] = payload.get('agent_nickname') or payload.get('originator') or 'Codex'
                elif item.get('type') == 'turn_context':
                    state['cwd'] = payload.get('cwd', state['cwd'])
                    state['model'] = payload.get('model', state['model'])
                elif item.get('type') == 'response_item' and payload.get('role') == 'user' and text_content(payload.get('content')):
                    state['message'] = {'offset': position}
                elif item.get('type') == 'event_msg' and payload.get('type') == 'user_message':
                    state['message'] = {'offset': position}
                elif item.get('type') == 'token_usage_record':
                    state['exact'] = True
                    usage = payload.get('usage') or {}
                    read, write = number(usage.get('cached_input_tokens')), number(usage.get('cache_write_input_tokens'))
                    yield event(payload.get('response_id') or f"{state['session']}:{index}", provider, state['session'],
                                state['model'], state['cwd'], item.get('timestamp'),
                                max(0, number(usage.get('input_tokens')) - read - write), usage.get('output_tokens'), read, write,
                                caller=state['caller'], message=state.get('message'))
                elif item.get('type') == 'event_msg' and payload.get('type') == 'token_count' and not state.get('exact'):
                    info = payload.get('info') or {}
                    total, previous = info.get('total_token_usage'), state.get('previous')
                    if not total or total == previous:
                        continue
                    keys = ['input_tokens', 'output_tokens', 'cached_input_tokens', 'cache_write_input_tokens']
                    usage = {k: max(0, number(total.get(k)) - number((previous or {}).get(k))) for k in keys}
                    if previous and number(total.get('total_tokens')) < number(previous.get('total_tokens')):
                        usage = info.get('last_token_usage') or {}
                    state['previous'] = total
                    read, write = number(usage.get(keys[2])), number(usage.get(keys[3]))
                    yield event(f"{state['session']}:{index}", provider, state['session'], state['model'], state['cwd'], item.get('timestamp'),
                                max(0, number(usage.get(keys[0])) - read - write), usage.get(keys[1]), read, write,
                                caller=state['caller'], message=state.get('message'))
            elif provider == 'claude':
                msg = item.get('message') or {}
                if item.get('type') == 'user' and not item.get('isMeta') and text_content(msg.get('content')):
                    state['message'] = {'offset': position}
                usage = msg.get('usage') or {}
                if item.get('type') != 'assistant' or not usage:
                    continue
                session = item.get('sessionId') or item.get('session_id') or state['session']
                yield event(msg.get('id') or item.get('uuid') or f'{session}:{index}', provider, session,
                            msg.get('model'), item.get('cwd'), item.get('timestamp'), usage.get('input_tokens'),
                            usage.get('output_tokens'), usage.get('cache_read_input_tokens'), usage.get('cache_creation_input_tokens'),
                            caller=item.get('agentId') or item.get('entrypoint') or 'Claude', message=state.get('message'))
            elif provider == 'grok':
                params = item.get('params') or {}
                update = params.get('update') or {}
                if update.get('sessionUpdate') == 'user_message_chunk' and text_content(update.get('content')):
                    state['message'] = {'offset': position}
                usage = update.get('usage') or {}
                if update.get('sessionUpdate') != 'turn_completed' or not usage:
                    continue
                session = params.get('sessionId', path.parent.name)
                identity = update.get('prompt_id') or (params.get('_meta') or {}).get('eventId') or item.get('timestamp')
                for model, bucket in (usage.get('modelUsage') or {'grok': usage}).items():
                    read, write = number(bucket.get('cachedReadTokens')), number(bucket.get('cacheCreationTokens'))
                    yield event(f'{session}:{identity}:{model}', provider, session, model, state['cwd'], item.get('timestamp'),
                                max(0, number(bucket.get('inputTokens')) - read - write), bucket.get('outputTokens'), read, write,
                                kind='turn', calls=bucket.get('modelCalls', 1), caller='Grok', status=update.get('stop_reason'),
                                duration=update.get('elapsed_ms'), message=state.get('message'))


def read_db(path):
    connection = sqlite3.connect(path.as_uri() + '?mode=ro', uri=True, timeout=2)
    connection.row_factory = sqlite3.Row
    return connection


def declared_directory(value):
    match = re.search(r'working directory:\s*`?(/[^\n`]+)', value or '', re.IGNORECASE)
    return match.group(1).strip() if match else ''


def db_events(path, provider):
    with read_db(path) as db:
        if provider == 'hermes':
            query = '''SELECT u.*, s.cwd, s.source, s.profile_name,
                CASE WHEN s.cwd IS NULL OR s.cwd='' THEN
                  substr(p.prompt, instr(lower(p.prompt),'working directory:'), 350) ELSE '' END AS environment
                FROM session_model_usage u JOIN sessions s ON s.id=u.session_id
                LEFT JOIN system_prompts p ON p.hash=s.system_prompt_hash'''
            for row in db.execute(query):
                key = hashlib.sha256(json.dumps([row[k] for k in ['session_id', 'model', 'billing_provider', 'billing_base_url', 'billing_mode', 'task']]).encode()).hexdigest()
                cwd = row['cwd'] or declared_directory(row['environment'])
                yield event(f'{path.parent}:{key}', provider, row['session_id'], row['model'], cwd, row['last_seen'],
                            row['input_tokens'], row['output_tokens'] + row['reasoning_tokens'], row['cache_read_tokens'],
                            row['cache_write_tokens'], kind='session', calls=row['api_call_count'],
                            caller='Hermes / ' + str(row['profile_name'] or row['source'] or path.parent.name),
                            project_origin='Diretório da sessão' if row['cwd'] else 'Diretório inicial declarado pela ferramenta')
        elif provider == 'opencode':
            for row in db.execute('SELECT m.id, m.session_id, m.time_created, m.data, s.directory FROM message m JOIN session s ON s.id=m.session_id'):
                data = json.loads(row['data'])
                usage = data.get('tokens') or {}
                if data.get('role') != 'assistant' or not usage or not (data.get('time') or {}).get('completed'):
                    continue
                cache = usage.get('cache') or {}
                yield event(row['id'], provider, row['session_id'], data.get('modelID'), row['directory'], row['time_created'],
                            usage.get('input'), number(usage.get('output')) + number(usage.get('reasoning')),
                            cache.get('read'), cache.get('write'), caller='OpenCode / ' + str(data.get('agent') or 'agente'),
                            status=data.get('finish'), duration=data['time']['completed'] - data['time']['created'],
                            message={'parent': data.get('parentID')})
        elif provider == '9router':
            for row in db.execute('SELECT id,timestamp,provider,model,promptTokens,completionTokens,status,meta FROM usageHistory'):
                meta = json.loads(row['meta'] or '{}')
                if not isinstance(meta, dict):
                    meta = {}
                yield event(row['id'], provider, meta.get('sessionId', ''), row['model'], meta.get('cwd', ''),
                            row['timestamp'], row['promptTokens'], row['completionTokens'],
                            caller=meta.get('caller') or '9Router / ' + str(row['provider'] or ''), status=row['status'])


def sources():
    for provider, root, pattern in [('codex', HOME / '.codex/sessions', '*.jsonl'),
                                    ('codex', HOME / '.codex/archived_sessions', '*.jsonl'),
                                    ('claude', HOME / '.claude/projects', '*.jsonl'),
                                    ('grok', HOME / '.grok/sessions', 'updates.jsonl')]:
        for path in root.rglob(pattern):
            yield path, provider, json_events
    for path in [HOME / '.hermes/state.db', *(HOME / '.hermes/profiles').glob('*/state.db')]:
        if path.exists():
            yield path, 'hermes', db_events
    for provider, path in [('opencode', HOME / '.local/share/opencode/opencode.db'), ('9router', HOME / '.9router/db/data.sqlite')]:
        if path.exists():
            yield path, provider, db_events


def init_db(db):
    db.execute('CREATE TABLE IF NOT EXISTS files(path TEXT PRIMARY KEY,signature TEXT)')
    db.execute('CREATE TABLE IF NOT EXISTS cursors(path TEXT PRIMARY KEY,state TEXT,offset INTEGER,inode INTEGER)')
    db.execute('CREATE TABLE IF NOT EXISTS events(id TEXT PRIMARY KEY,source TEXT,provider TEXT,project TEXT,model TEXT,timestamp REAL,tokens INTEGER,calls INTEGER,data TEXT)')
    db.execute('CREATE INDEX IF NOT EXISTS events_time ON events(timestamp DESC)')
    db.execute('CREATE INDEX IF NOT EXISTS events_source ON events(source)')
    db.commit()


def scan(db):
    errors, counts = [], {}
    metrics = dict(jsonBytesRead=0, changedFiles=0)
    for path, provider, parser in sources():
        counts[provider] = counts.get(provider, 0) + 1
        try:
            stat = path.stat()
            wal = Path(str(path) + '-wal')
            walstat = wal.stat() if wal.exists() else None
            signature = f'{REVISION}:{stat.st_size}:{stat.st_mtime_ns}:{walstat.st_size if walstat else 0}:{walstat.st_mtime_ns if walstat else 0}'
            old = db.execute("SELECT f.signature,coalesce(c.state,'{}'),coalesce(c.offset,0),coalesce(c.inode,0) FROM files f LEFT JOIN cursors c ON c.path=f.path WHERE f.path=?", (str(path),)).fetchone()
            if old and old[0] == signature:
                continue
            metrics['changedFiles'] += 1
            incremental = (parser is json_events and old and old[0].startswith(REVISION + ':')
                           and stat.st_ino == old[3] and stat.st_size > old[2])
            state = json.loads(old[1]) if incremental else {}
            start = old[2] if incremental else 0
            entries = {}
            rows = parser(path, provider, state, start) if parser is json_events else parser(path, provider)
            for row in rows:
                if row['timestamp'] and sum(row[k] for k in ['input', 'output', 'cacheRead', 'cacheWrite']) > 0:
                    entries[row['id']] = row
            if parser is json_events:
                metrics['jsonBytesRead'] += max(0, stat.st_size - start)
            with db:
                if not incremental:
                    db.execute('DELETE FROM events WHERE source=?', (str(path),))
                db.executemany('INSERT OR REPLACE INTO events VALUES (?,?,?,?,?,?,?,?,?)',
                               [(r['id'], str(path), provider, r['project'], r['model'], r['timestamp'],
                                 sum(r[k] for k in ['input', 'output', 'cacheRead', 'cacheWrite']), r['calls'], json.dumps(r)) for r in entries.values()])
                db.execute('INSERT OR REPLACE INTO files(path,signature) VALUES (?,?)', (str(path), signature))
                db.execute('INSERT OR REPLACE INTO cursors VALUES (?,?,?,?)',
                           (str(path), json.dumps(state), state.get('offset', 0), stat.st_ino))
        except (OSError, ValueError, sqlite3.Error, KeyError, TypeError) as error:
            errors.append(f'{provider}: {type(error).__name__} em {path.name}')
    return errors, counts, metrics


class Previews:
    def __init__(self):
        self.connections = {}
        self.cache = {}

    def close(self):
        for db in self.connections.values():
            db.close()

    def connection(self, source):
        if source not in self.connections:
            self.connections[source] = read_db(Path(source))
        return self.connections[source]

    def read(self, source, row, limit=180):
        ref = row.get('_message') or {}
        key = (source, json.dumps(ref, sort_keys=True), row['session'] if row['provider'] == 'hermes' else '', row['timestamp'] if row['provider'] == 'hermes' else 0)
        if key not in self.cache:
            text = ''
            try:
                if 'offset' in ref:
                    with open(source, 'rb') as stream:
                        stream.seek(ref['offset'])
                        item = json.loads(stream.readline())
                    if row['provider'] == 'codex':
                        payload = item.get('payload') or {}
                        text = text_content(payload.get('message')) or text_content(payload.get('content'))
                    elif row['provider'] == 'claude':
                        text = text_content((item.get('message') or {}).get('content'))
                    else:
                        text = text_content((item.get('params') or {}).get('update', {}).get('content'))
                elif row['provider'] == 'hermes':
                    found = self.connection(source).execute('''SELECT substr(content,1,2400) FROM messages
                        WHERE session_id=? AND role='user' AND timestamp<=? ORDER BY timestamp DESC LIMIT 1''',
                        (row['session'], row['timestamp'])).fetchone()
                    if found:
                        text = found[0] or ''
                elif row['provider'] == 'opencode' and ref.get('parent'):
                    db = self.connection(source)
                    chunks = []
                    for found in db.execute('SELECT data FROM part WHERE message_id=? ORDER BY id', (ref['parent'],)):
                        chunks.append(text_content(json.loads(found[0])))
                    text = ' '.join(chunks)
            except (OSError, ValueError, sqlite3.Error, TypeError):
                text = ''
            text = re.sub(r'^\s*(?:\[Image #\d+\]\s*)+', '', text)
            self.cache[key] = re.sub(r'\s+', ' ', text).strip()[:2400]
        value = self.cache[key]
        return value[:limit] + ('…' if len(value) > limit else '')

    def display(self, source, row, limit=180):
        out = {k: v for k, v in row.items() if not k.startswith('_')}
        out['preview'] = self.read(source, row, limit)
        out['previewLabel'] = 'Último pedido da sessão' if row['kind'] == 'session' else 'Mensagem do usuário'
        return out


def snapshot(db, args, errors, counts, metrics=None):
    since = 0
    if args.period != 'total':
        days = {'day': 0, 'week': 6, 'month': 29}[args.period]
        since = (datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=days)).timestamp()
    clauses, params = ['timestamp>=?'], [since]
    if args.provider == 'all':
        clauses.append("provider != '9router'")
    else:
        clauses.append('provider=?')
        params.append(args.provider)
    if args.search:
        clauses.append('(instr(lower(data), lower(?)) > 0)')
        params.append(args.search)
    where = ' AND '.join(clauses)
    projects = []
    for pid, total, calls, last in db.execute(f'SELECT project,sum(tokens),sum(calls),max(timestamp) FROM events WHERE {where} GROUP BY project ORDER BY sum(tokens) DESC', params):
        projects.append(dict(id=pid, name=WORKSPACES.get(pid, Path(pid).name) if pid else 'Sem projeto', tokens=total, calls=calls, lastSeen=last))
    if args.project != '*':
        where += ' AND project=?'
        params.append(args.project)
    total, calls, records = db.execute(f'SELECT coalesce(sum(tokens),0),coalesce(sum(calls),0),count(*) FROM events WHERE {where}', params).fetchone()
    limit = getattr(args, 'limit', 25)
    previews = Previews()
    try:
        rows = [previews.display(source, json.loads(data)) for source, data in db.execute(
            f'SELECT source,data FROM events WHERE {where} ORDER BY timestamp DESC,id DESC LIMIT ? OFFSET ?', [*params, limit, args.offset])]
    finally:
        previews.close()
    return dict(updatedAt=time.time(), projects=projects, rows=rows, tokens=total, calls=calls, records=records,
                offset=args.offset, pageSize=limit, errors=errors, sources=counts, scan=metrics or {})


def details(db, identity):
    found = db.execute('SELECT source,data FROM events WHERE id=?', (identity,)).fetchone()
    if not found:
        return dict(error='Registro não encontrado')
    previews = Previews()
    try:
        return previews.display(found[0], json.loads(found[1]), 1200)
    finally:
        previews.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--period', choices=['day', 'week', 'month', 'total'], default='week')
    parser.add_argument('--provider', default='all')
    parser.add_argument('--project', default='*')
    parser.add_argument('--search', default='')
    parser.add_argument('--offset', type=int, default=0)
    parser.add_argument('--limit', type=int, choices=[25, 50, 100], default=25)
    parser.add_argument('--detail')
    args = parser.parse_args()
    os.umask(0o077)
    STATE.mkdir(parents=True, exist_ok=True)
    if args.detail:
        with read_db(STATE / 'ledger.sqlite') as db:
            print(json.dumps(details(db, args.detail), ensure_ascii=False))
        return
    with (STATE / 'lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        with sqlite3.connect(STATE / 'ledger.sqlite') as db:
            init_db(db)
            errors, counts, metrics = scan(db)
            print(json.dumps(snapshot(db, args, errors, counts, metrics), ensure_ascii=False))


if __name__ == '__main__':
    main()
