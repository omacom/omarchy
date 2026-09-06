import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('tracking', Path(__file__).parents[1] / 'bin/tracking.py')
t = importlib.util.module_from_spec(spec)
spec.loader.exec_module(t)


class TrackingTests(unittest.TestCase):
    def test_codex_repeated_counters_cache_and_delta(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / 'session.jsonl'
            def counter(total):
                return dict(type='event_msg', timestamp='2026-09-06T10:00:00Z', payload=dict(type='token_count', info=dict(total_token_usage=total)))
            first = dict(input_tokens=100, output_tokens=10, cached_input_tokens=60, total_tokens=110)
            second = dict(input_tokens=220, output_tokens=30, cached_input_tokens=130, total_tokens=250)
            p.write_text('\n'.join(map(json.dumps, [dict(type='session_meta', payload=dict(id='a', cwd='/home/test/Projects/example')),
                                                       counter(first), counter(first), counter(second)])) + "\n")
            rows = list(t.json_events(p, 'codex'))
            self.assertEqual(len(rows), 2)
            self.assertEqual(sum(sum(r[k] for k in ['input', 'output', 'cacheRead', 'cacheWrite']) for r in rows), 250)
            self.assertEqual(rows[1]['cacheRead'], 70)

    def test_grok_turn_is_not_labeled_single_call(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / '%2Fhome%2Ftest%2FProjects%2Fexample' / 's' / 'updates.jsonl'
            p.parent.mkdir(parents=True)
            p.write_text(json.dumps(dict(timestamp=1788690000, params=dict(sessionId='s', update=dict(sessionUpdate='turn_completed', prompt_id='p', usage=dict(modelUsage={'grok': dict(inputTokens=100, outputTokens=20, cachedReadTokens=80, modelCalls=4)}))))) + "\n")
            row = list(t.json_events(p, 'grok'))[0]
            self.assertEqual((row['kind'], row['calls'], row['input'], row['cacheRead']), ('turn', 4, 20, 80))
            self.assertEqual(row['cwd'], '/home/test/Projects/example')

    def test_worktree_resolves_to_shared_project(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, work = Path(tmp) / 'repo', Path(tmp) / 'copy'
            meta = root / '.git/worktrees/copy'
            meta.mkdir(parents=True)
            work.mkdir()
            (work / '.git').write_text('gitdir: ' + str(meta))
            (meta / 'commondir').write_text('../..')
            self.assertEqual(t.project(str(work / 'src'))[0], str(root))
            self.assertEqual(t.project('')[1], 'Sem projeto')

    def test_filters_pagination_and_router_not_double_counted(self):
        import sqlite3
        from types import SimpleNamespace
        db = sqlite3.connect(':memory:')
        db.execute('CREATE TABLE events(id TEXT,source TEXT,provider TEXT,project TEXT,model TEXT,timestamp REAL,tokens INTEGER,calls INTEGER,data TEXT)')
        for provider in ['codex', '9router']:
            for i in range(105):
                row = t.event(str(i), provider, 's', 'm', '/p', 1788690000, 10, 0)
                db.execute('INSERT INTO events VALUES (?,?,?,?,?,?,?,?,?)', (row['id'], '', provider, '/p', 'm', row['timestamp'], 10, 1, json.dumps(row)))
        args = SimpleNamespace(period='total', provider='all', project='*', search='', offset=100, limit=100)
        snap = t.snapshot(db, args, [], {})
        self.assertEqual((snap['tokens'], snap['records'], len(snap['rows'])), (1050, 105, 5))
        args.search = 'missing'
        self.assertEqual(t.snapshot(db, args, [], {})['records'], 0)


class IncrementalTests(unittest.TestCase):
    def test_append_partial_record_and_rewrite(self):
        import sqlite3
        from unittest.mock import patch
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / 's.jsonl'
            meta = dict(type='session_meta', payload=dict(id='s', cwd='/home/test/Projects/example'))
            prompt = dict(type='response_item', payload=dict(role='user', content=[dict(type='input_text', text='Corrigir a tela de vendas')]))
            def usage(identity, amount):
                return dict(type='token_usage_record', timestamp='2026-09-06T10:00:00Z', payload=dict(response_id=identity, usage=dict(input_tokens=amount, output_tokens=5)))
            lines = lambda rows: ''.join(json.dumps(row) + '\n' for row in rows)
            p.write_text(lines([meta, prompt, usage('r1', 100)]))
            db = sqlite3.connect(':memory:')
            t.init_db(db)
            with patch.object(t, 'sources', return_value=[(p, 'codex', t.json_events)]):
                self.assertFalse(t.scan(db)[0])
                first_size = p.stat().st_size
                complete = lines([usage('r2', 200)])
                with p.open('a') as out: out.write(complete[:-4])
                t.scan(db)
                self.assertEqual(db.execute('SELECT count(*) FROM events').fetchone()[0], 1)
                with p.open('a') as out: out.write(complete[-4:])
                stats = t.scan(db)[2]
                self.assertEqual(stats['jsonBytesRead'], len(complete.encode()))
                self.assertEqual(db.execute('SELECT sum(tokens) FROM events').fetchone()[0], 310)
                self.assertEqual(t.scan(db)[2]['jsonBytesRead'], 0)
                detail = t.details(db, 'codex:r2')
                self.assertEqual(detail['preview'], 'Corrigir a tela de vendas')
                self.assertNotIn('Corrigir a tela', db.execute('SELECT data FROM events LIMIT 1').fetchone()[0])
                p.write_text(lines([meta, usage('r3', 20)]))
                t.scan(db)
                self.assertEqual(db.execute('SELECT count(*),sum(tokens) FROM events').fetchone(), (1, 25))

    def test_exact_codex_record_suppresses_quota_duplicate(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / 's.jsonl'
            usage = dict(input_tokens=100, cached_input_tokens=70, output_tokens=5, total_tokens=105)
            p.write_text(''.join(json.dumps(row)+'\n' for row in [
                dict(type='token_usage_record', timestamp='2026-09-06T10:00:00Z', payload=dict(response_id='r', usage=usage)),
                dict(type='event_msg', timestamp='2026-09-06T10:00:00Z', payload=dict(type='token_count', info=dict(total_token_usage=usage)))
            ]))
            rows = list(t.json_events(p,'codex'))
            self.assertEqual(len(rows),1)
            self.assertEqual((rows[0]['input'], rows[0]['cacheRead'], rows[0]['output']), (30,70,5))

    def test_project_requires_declared_directory(self):
        self.assertEqual(t.declared_directory('Current working directory: /home/test/Projects/example\nShell: bash'), '/home/test/Projects/example')
        self.assertEqual(t.declared_directory('Please look at /home/test/Projects/example'), '')


if __name__ == '__main__':
    unittest.main()
