import importlib.util
import sqlite3
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('desktop_catalog', Path(__file__).parents[1] / 'catalog.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class StatusTest(unittest.TestCase):
    def test_attention_takes_priority_over_turn_state(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / '.t3/userdata').mkdir(parents=True)
            connection = sqlite3.connect(home / '.t3/userdata/state.sqlite')
            connection.executescript('''
                CREATE TABLE projection_threads(thread_id, pending_approval_count, pending_user_input_count,
                    has_actionable_proposed_plan, latest_turn_id, deleted_at);
                CREATE TABLE projection_turns(thread_id, turn_id, state);
                INSERT INTO projection_threads VALUES ('thread', 0, 0, 0, 'turn', NULL);
                INSERT INTO projection_turns VALUES ('thread', 'turn', 'running');
            ''')
            connection.commit()
            class Sessions:
                matches = {'handle': 'thread'}
                def titles(self, leases): return {1: {'title': 'Test agent', 'icon': ''}}
            leases = [{'desktop': 1, 'host': 'remote', 'handle': 'handle', 'created': 0, 'owner': 'Test'}]
            status = lambda: module.catalog(home, Sessions(), leases)[0]['agentStatus']
            self.assertEqual(status(), 'Working')
            connection.execute('UPDATE projection_threads SET pending_approval_count=1'); connection.commit()
            self.assertEqual(status(), 'Waiting for you')
            connection.execute('UPDATE projection_threads SET pending_approval_count=0')
            connection.execute("UPDATE projection_turns SET state='completed'"); connection.commit()
            self.assertEqual(status(), 'Finished')
            connection.close()

if __name__ == '__main__': unittest.main()
