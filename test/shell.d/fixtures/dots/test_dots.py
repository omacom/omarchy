import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(os.environ['ROOT'])


class DotsTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.root = Path(self.tmp.name)
    self.remote = self.root / 'remote.git'
    subprocess.run(['git', 'init', '--bare', '--quiet', str(self.remote)], check=True)
    for host in ('a', 'b'):
      home = self.root / host
      home.mkdir()
      (home / '.bashrc').write_text('color=blue\nsize=10\n')
      (home / '.config/hypr').mkdir(parents=True)
      (home / '.config/hypr/monitors.lua').write_text('monitor=' + host + '\n')
      self.run_dots(host, 'setup', '--repo', str(self.remote))

  def env(self, host):
    home = self.root / host
    env = os.environ.copy()
    env.update(HOME=str(home), XDG_CONFIG_HOME=str(home / '.config'),
         XDG_DATA_HOME=str(home / '.local/share'), XDG_STATE_HOME=str(home / '.local/state'),
         OMARCHY_PATH=str(ROOT), GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
    return env

  def run_dots(self, host, *args, ok=True):
    result = subprocess.run(['bash', str(ROOT / 'bin/omarchy-dots'), *args], env=self.env(host), capture_output=True, text=True)
    if ok:
      self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
    else:
      self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
    return result

  def file(self, host, name='.bashrc'):
    return self.root / host / name

  def seed(self):
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')

  def test_roundtrip_keeps_hardware_local(self):
    self.seed()
    self.file('a').write_text('color=red\nsize=10\n')
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.assertEqual(self.file('b').read_text(), self.file('a').read_text())
    self.assertEqual(self.file('b', '.config/hypr/monitors.lua').read_text(), 'monitor=b\n')

  def test_deletion_propagates(self):
    self.seed()
    self.file('a').unlink()
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.assertFalse(self.file('b').exists())

  def test_dry_run_preserves_files_and_no_pending_update(self):
    self.seed()
    self.file('a').write_text('changed\n')
    self.run_dots('a', 'push', '--yes')
    old = self.file('b').read_bytes()
    self.run_dots('b', 'pull', '--dry-run')
    self.assertEqual(self.file('b').read_bytes(), old)
    self.assertFalse(self.file('b', '.local/state/omarchy/dots/pending.json').exists())

  def test_independent_edits_merge(self):
    content = 'color=blue\n' + 'unchanged\n' * 8 + 'size=10\n'
    self.file('a').write_text(content)
    self.file('b').write_text(content)
    self.seed()
    self.file('a').write_text(content.replace('blue', 'red'))
    self.file('b').write_text(content.replace('10', '20'))
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.assertEqual(self.file('b').read_text(), content.replace('blue', 'red').replace('10', '20'))
    self.assertFalse(self.file('b', '.local/state/omarchy/dots/pending.json').exists())

  def test_conflicts_persist_until_explicit_resolution(self):
    self.seed()
    self.file('a').write_text('remote\n')
    self.file('b').write_text('local\n')
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.assertEqual(self.file('b').read_text(), 'local\n')
    self.assertTrue(self.file('b', '.local/state/omarchy/dots/pending.json').exists())
    self.run_dots('b', 'continue', ok=False)
    self.run_dots('b', 'resolve', '.bashrc', '--take', 'theirs')
    self.run_dots('b', 'continue')
    self.assertEqual(self.file('b').read_text(), 'remote\n')
    log = self.run_dots('b', 'log').stdout
    recovery = next(line.split()[0] for line in log.splitlines() if 'Before applying' in line)
    self.run_dots('b', 'restore', '.bashrc', '--at', recovery, '--yes')
    self.assertEqual(self.file('b').read_text(), 'local\n')

  def test_edit_during_conflict_is_not_overwritten(self):
    self.seed()
    self.file('a').write_text('remote\n')
    self.file('b').write_text('local\n')
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.run_dots('b', 'resolve', '.bashrc', '--take', 'theirs')
    self.file('b').write_text('new local work\n')
    self.run_dots('b', 'continue', ok=False)
    self.run_dots('b', 'abort')
    self.assertEqual(self.file('b').read_text(), 'new local work\n')

  def test_stale_publish_is_refused(self):
    self.seed()
    self.file('a').write_text('remote\n')
    self.run_dots('a', 'push', '--yes')
    self.file('b').write_text('stale\n')
    self.run_dots('b', 'push', '--yes', ok=False)

  def test_symlink_manager_is_left_alone(self):
    self.file('b').unlink()
    self.file('b').symlink_to(self.file('a'))
    self.run_dots('b', 'pull', '--yes', ok=False)
    self.assertTrue(self.file('b').is_symlink())

  def test_global_hooks_signing_and_inherited_git_env_cannot_break_snapshot(self):
    self.file('a', '.gitconfig').write_text('[commit]\n gpgSign=true\n[core]\n hooksPath=/nonexistent-hooks\n')
    env = self.env('a')
    env.update(GIT_DIR='/nonexistent', GIT_WORK_TREE='/', GIT_INDEX_FILE='/nonexistent/index')
    result = subprocess.run(['bash', str(ROOT / 'bin/omarchy-dots'), 'snapshot'], env=env, capture_output=True)
    self.assertEqual(result.returncode, 0, result.stderr)

  def test_remote_cannot_apply_unlisted_or_machine_local_paths(self):
    self.seed()
    stage = self.root / 'attacker'
    subprocess.run(['git', 'clone', '--quiet', '--branch', 'sync', str(self.remote), str(stage)], check=True)
    (stage / '.ssh').mkdir()
    (stage / '.ssh/authorized_keys').write_text('unwanted')
    subprocess.run(['git', '-C', str(stage), 'add', '.'], check=True)
    subprocess.run(['git', '-C', str(stage), '-c', 'user.name=test', '-c', 'user.email=test@test', 'commit', '--quiet', '-m', 'bad'], check=True)
    subprocess.run(['git', '-C', str(stage), 'push', '--quiet'], check=True)
    self.run_dots('b', 'pull', '--yes', ok=False)
    self.assertFalse(self.file('b', '.ssh/authorized_keys').exists())

  def test_local_history_never_enters_published_history(self):
    self.file('a').write_text('old private token\n')
    self.run_dots('a', 'snapshot')
    self.file('a').write_text('clean\n')
    self.run_dots('a', 'push', '--yes')
    history = subprocess.check_output(['git', '--git-dir', str(self.remote), 'log', '-p', 'sync'])
    self.assertNotIn(b'old private token', history)

  def test_modify_delete_conflict_can_choose_deletion(self):
    self.seed()
    self.file('a').unlink()
    self.file('b').write_text('keep me?\n')
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.assertTrue(self.file('b').exists())
    self.run_dots('b', 'resolve', '.bashrc', '--take', 'theirs')
    self.run_dots('b', 'continue')
    self.assertFalse(self.file('b').exists())

  def test_interrupted_application_can_continue_or_undo(self):
    self.seed()
    self.file('a').write_text('remote\n')
    self.file('b').write_text('local\n')
    self.run_dots('a', 'push', '--yes')
    self.run_dots('b', 'pull', '--yes')
    self.run_dots('b', 'resolve', '.bashrc', '--take', 'theirs')
    path = self.file('b', '.local/state/omarchy/dots/pending.json')
    pending = json.loads(path.read_text())
    pending['phase'] = 'applying'
    path.write_text(json.dumps(pending))
    self.file('b').write_text('remote\n')
    self.run_dots('b', 'abort', '--yes')
    self.assertEqual(self.file('b').read_text(), 'local\n')
    self.run_dots('b', 'pull', '--yes')
    self.run_dots('b', 'resolve', '.bashrc', '--take', 'theirs')
    pending = json.loads(path.read_text())
    pending['phase'] = 'applying'
    path.write_text(json.dumps(pending))
    self.file('b').write_text('remote\n')
    self.run_dots('b', 'continue')
    self.assertEqual(self.file('b').read_text(), 'remote\n')
    self.assertFalse(path.exists())


unittest.main()
