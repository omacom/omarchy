"""Constrained local history and explicit state publishing, never raw git over HOME."""
import argparse
import difflib
import fcntl
import fnmatch
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tempfile

HOME = Path.home()
DATA = Path(os.environ.get('XDG_DATA_HOME', str(HOME / '.local/share'))) / 'omarchy'
REPO = DATA / 'dots.git'
STATE = Path(os.environ.get('XDG_STATE_HOME', str(HOME / '.local/state'))) / 'omarchy/dots'
MANIFEST = Path(os.environ['OMARCHY_PATH']) / 'default/dots/manifest'
HISTORY = 'refs/heads/history'
BASE = 'refs/omarchy/last-sync'
REMOTE = 'refs/remotes/origin/sync'
PENDING = STATE / 'pending.json'


class Error(Exception):
  pass


def git(*args, data=None, check=True, extra=None):
  # Ignore global hooks, signing, templates, excludes, pager, and inherited
  # worktree/index variables. SSH still uses the user's agent and SSH config.
  env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
  env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1',
       GIT_TERMINAL_PROMPT='0', GIT_AUTHOR_NAME='Omarchy',
       GIT_AUTHOR_EMAIL='omarchy@localhost', GIT_COMMITTER_NAME='Omarchy',
       GIT_COMMITTER_EMAIL='omarchy@localhost')
  env.update(extra or {})
  result = subprocess.run(['git', '--git-dir', str(REPO), '-c', 'core.hooksPath=/dev/null',
              '-c', 'commit.gpgsign=false', '-c', 'core.excludesFile=/dev/null',
              '-c', 'core.attributesFile=/dev/null', '-c', 'core.pager=cat',
              *args], input=data, capture_output=True, env=env)
  if check and result.returncode:
    raise Error(result.stderr.decode(errors='replace').strip() or 'Git operation failed')
  return result


def output(*args, **kwargs):
  return git(*args, **kwargs).stdout.decode().strip()


def ref(name):
  result = git('rev-parse', '--verify', '--end-of-options', name, check=False)
  return result.stdout.decode().strip() if result.returncode == 0 else None


def rules():
  return [line.split(maxsplit=1) for line in MANIFEST.read_text().splitlines()
      if line.strip() and not line.startswith('#')]


def tier(path):
  parts = PurePosixPath(path).parts
  if not parts or path.startswith('/') or any(p in {'.', '..'} for p in parts) or '\n' in path or '\0' in path:
    raise Error('Invalid preference path')
  for kind, pattern in rules():
    # fnmatch's '*' also matches '/', so match components separately.
    patterns = PurePosixPath(pattern).parts
    if len(parts) == len(patterns) and all(fnmatch.fnmatchcase(p, pat) for p, pat in zip(parts, patterns)):
      return kind
  raise Error(f'Outside the preference manifest: {path}')


def safe_path(name):
  tier(name)
  path = HOME
  for component in PurePosixPath(name).parts:
    path = path / component
    if path.is_symlink():
      raise Error(f'Dots is dormant: {path} is a symlink. Keep using your dotfile manager.')
  if path.exists() and not path.is_file():
    raise Error(f'Expected a regular preference file: {path}')
  return path


def check_manager():
  for path in (HOME / '.git', HOME / '.local/share/chezmoi', HOME / '.local/share/yadm/repo.git', HOME / '.config/yadm/repo.git'):
    if path.exists():
      raise Error(f'Dots is dormant: another dotfile manager was found at {path}.')
  for _, pattern in rules():
    # Check literal ancestors even when a symlinked directory is empty.
    current = HOME
    for part in PurePosixPath(pattern).parts:
      if any(c in part for c in '*?['):
        break
      current = current / part
      if current.is_symlink():
        raise Error(f'Dots is dormant: {current} is a symlink. Keep using your dotfile manager.')
    for path in HOME.glob(pattern):
      safe_path(str(path.relative_to(HOME)))


def tree(commit):
  if not commit:
    return {}
  result = {}
  for entry in git('ls-tree', '-rz', '--full-tree', commit).stdout.split(b'\0'):
    if not entry:
      continue
    meta, name = entry.split(b'\t', 1)
    mode, kind, oid = meta.decode().split()
    path = name.decode()
    tier(path)
    if kind != 'blob' or mode not in {'100644', '100755'}:
      raise Error(f'Unsupported preference type: {path}')
    result[path] = [mode, oid]
  return result


def scan(shared=False):
  check_manager()
  files = {}
  for kind, pattern in rules():
    if shared and kind != 'shared':
      continue
    for path in sorted(HOME.glob(pattern)):
      name = str(path.relative_to(HOME))
      safe_path(name)
      files[name] = ['100755' if path.stat().st_mode & 0o111 else '100644',
             output('hash-object', '-w', '--stdin', data=path.read_bytes())]
  return files


def write_tree(files):
  with tempfile.TemporaryDirectory(dir=STATE) as work:
    index = {'GIT_INDEX_FILE': str(Path(work) / 'index')}
    git('read-tree', '--empty', extra=index)
    entries = b''.join(f'{mode} {oid}\t{name}\0'.encode() for name, (mode, oid) in sorted(files.items()))
    git('update-index', '-z', '--index-info', data=entries, extra=index)
    return output('write-tree', extra=index)


def commit(files, parent, label):
  args = ['commit-tree', write_tree(files)]
  if parent:
    args += ['-p', parent]
  return output(*args, data=(label + '\n').encode())


def snapshot(label):
  files = scan()
  previous = ref(HISTORY)
  if previous and tree(previous) == files:
    return previous
  oid = commit(files, previous, label)
  git('update-ref', HISTORY, oid)
  return oid


def require_repo():
  if not REPO.is_dir():
    raise Error('Choose Setup > Preferences first, or run: omarchy dots setup')
  check_manager()


def require_idle():
  if PENDING.exists():
    raise Error('A preference update is pending. Use Resolve Conflicts, Continue, or Cancel Pending Update.')


def confirm(question, yes=False):
  if not yes and subprocess.run(['gum', 'confirm', question]).returncode:
    raise Error('Cancelled. No preferences changed.')


def choose(header, choices):
  result = subprocess.run(['gum', 'choose', '--header', header, *choices], stdout=subprocess.PIPE, text=True)
  if result.returncode:
    raise Error('Cancelled.')
  return result.stdout.strip()


def atomic_json(path, data):
  fd, temporary = tempfile.mkstemp(dir=path.parent)
  try:
    with os.fdopen(fd, 'w') as out:
      json.dump(data, out)
      out.flush()
      os.fsync(out.fileno())
    os.replace(temporary, path)
  finally:
    Path(temporary).unlink(missing_ok=True)


def setup(args):
  check_manager()
  if not REPO.exists():
    DATA.mkdir(parents=True, exist_ok=True)
    git('init', '--bare', '--initial-branch=history', '--template=', str(REPO))
    REPO.chmod(0o700)
  snapshot('Start preference history')
  url = args.repo
  if not url and sys.stdin.isatty():
    choice = choose('Preferences: keep local history or share between computers?', ['Local history only', 'Create a private GitHub repository', 'Use an existing private Git repository'])
    if choice.startswith('Create'):
      result = subprocess.run(['gum', 'input', '--prompt', 'Repository name> ', '--value', 'omarchy-preferences'], stdout=subprocess.PIPE, text=True)
      if result.returncode:
        raise Error('Cancelled. Local history is ready.')
      name = result.stdout.strip()
      if not re.fullmatch(r'[A-Za-z0-9_.-]+', name) or name.startswith('-'):
        raise Error('Use a simple repository name with letters, numbers, dots, underscores, or hyphens.')
      subprocess.run(['gh', 'repo', 'create', name, '--private'], check=True)
      metadata = json.loads(subprocess.check_output(['gh', 'repo', 'view', name, '--json', 'sshUrl,isPrivate'], text=True))
      if not metadata['isPrivate']:
        raise Error('The repository must be private.')
      url = metadata['sshUrl']
    if choice.startswith('Use'):
      result = subprocess.run(['gum', 'input', '--header', 'Use a private repository. Preference files can contain personal information.', '--prompt', 'SSH Git URL> '], stdout=subprocess.PIPE, text=True)
      if result.returncode:
        raise Error('Cancelled. Local history is ready.')
      url = result.stdout.strip()
  if url:
    require_idle()
    if url.startswith('-') or '\n' in url or not (url.startswith('/') or re.fullmatch(r'(ssh://)?[\w.@-]+[:/][^\s]+', url)):
      raise Error('Use an SSH Git URL, such as git@github.com:you/private-preferences.git, or an absolute local repository path.')
    old = output('config', '--get', 'remote.origin.url', check=False)
    if old and old != url:
      raise Error('A different shared repository is already configured; keep this history and use a separate profile rather than silently changing its origin.')
    github = re.fullmatch(r'(?:git@github\.com:|ssh://git@github\.com/)([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+?)(?:\.git)?', url)
    if github:
      result = subprocess.run(['gh', 'api', 'repos/' + github[1], '--jq', '.private'], capture_output=True, text=True)
      if result.returncode or result.stdout.strip() != 'true':
        raise Error('Could not verify a private GitHub repository. Sign in with gh auth login and choose a private repository.')
    git('ls-remote', '--heads', '--', url)
    git('config', 'remote.origin.url', url)
    git('config', 'remote.origin.fetch', '+refs/heads/sync:refs/remotes/origin/sync')
  print('Preference history is ready. Use System > Preferences to save, review, publish, or apply settings.')
  if url:
    print('On another computer, use the same repository, then Apply Settings. Only the audited shared files travel.')


def fetch():
  if not output('config', '--get', 'remote.origin.url', check=False):
    raise Error('No shared repository. Choose Setup > Preferences or run omarchy dots setup --repo <ssh-url>.')
  heads = output('ls-remote', '--heads', 'origin', 'refs/heads/sync')
  if not heads:
    return None
  git('fetch', '--quiet', '--no-tags', 'origin', '+refs/heads/sync:' + REMOTE)
  remote = ref(REMOTE)
  files = tree(remote)
  if any(tier(name) != 'shared' for name in files):
    raise Error('The remote contains machine-local preferences; nothing has been applied.')
  return remote


def data(entry):
  return git('cat-file', 'blob', entry[1]).stdout if entry else b''


def show_changes(before, after):
  count = 0
  for name in sorted(before.keys() | after.keys()):
    if before.get(name) == after.get(name):
      continue
    count += 1
    print(('Delete ' if name not in after else 'Add ' if name not in before else 'Change ') + name)
    left, right = data(before.get(name)), data(after.get(name))
    try:
      print(''.join(difflib.unified_diff(left.decode().splitlines(True), right.decode().splitlines(True), fromfile='this machine/' + name, tofile='proposed/' + name)), end='')
    except UnicodeDecodeError:
      print('  Binary contents differ')
  if not count:
    print('No preference changes.')


def push(args):
  require_idle()
  remote = fetch()
  if remote != ref(BASE):
    raise Error('Shared settings changed. Apply Settings (omarchy dots pull) before publishing.')
  current = scan(shared=True)
  before = tree(remote)
  show_changes(before, current)
  if current == before:
    return
  confirm('Publish these preferences to your shared repository?', args.yes)
  snapshot('Before publishing preferences')
  oid = commit(current, remote, 'Published from ' + os.uname().nodename)
  # A temporary ref is never a history parent: only current shared state leaves.
  git('update-ref', 'refs/omarchy/publish', oid)
  git('push', '--quiet', 'origin', 'refs/omarchy/publish:refs/heads/sync')
  git('update-ref', BASE, oid)
  git('update-ref', REMOTE, oid)
  print('Published. Other computers can now Apply Settings.')


def merge_files(base, ours, theirs):
  proposed, conflicts = {}, []
  for name in sorted(base.keys() | ours.keys() | theirs.keys()):
    b, o, t = base.get(name), ours.get(name), theirs.get(name)
    if o == t or t == b:
      merged = o
    elif o == b:
      merged = t
    elif b and o and t and b[0] == o[0] == t[0] and all(b'\0' not in data(e) for e in (b, o, t)):
      with tempfile.TemporaryDirectory(dir=STATE) as work:
        paths = [Path(work) / side for side in ('ours', 'base', 'theirs')]
        for path, entry in zip(paths, (o, b, t)):
          path.write_bytes(data(entry))
        result = git('merge-file', '-p', *map(str, paths), check=False)
        if result.returncode == 0:
          merged = [o[0], output('hash-object', '-w', '--stdin', data=result.stdout)]
        else:
          conflicts.append(name)
          merged = o
    else:
      conflicts.append(name)
      merged = o
    if merged:
      proposed[name] = merged
  return proposed, conflicts


def pull(args):
  require_idle()
  remote = fetch()
  if not remote:
    raise Error('Nothing has been published yet. Publish from the computer whose preferences you want to share.')
  before = scan(shared=True)
  proposed, conflicts = merge_files(tree(ref(BASE)), before, tree(remote))
  show_changes(before, proposed)
  for name in conflicts:
    print('Conflict: ' + name)
  if args.dry_run:
    return
  confirm('Apply these shared settings? A local recovery snapshot will be kept.', args.yes)
  previous = snapshot('Before applying shared preferences')
  pending = {'operation': 'pull', 'remote': remote, 'before': before, 'after': proposed,
       'snapshot': previous, 'conflicts': conflicts, 'phase': 'review'}
  git('update-ref', 'refs/omarchy/pending', commit(proposed, None, 'Pending preference update'))
  atomic_json(PENDING, pending)
  if conflicts:
    print('Nothing applied. Choose System > Preferences > Resolve Conflicts, then Continue Update.')
    return
  apply_pending()


def load_pending():
  if not PENDING.exists():
    raise Error('There is no pending preference update.')
  pending = json.loads(PENDING.read_text())
  for key in ('before', 'after'):
    for name, entry in pending[key].items():
      safe_path(name)
      if entry[0] not in {'100644', '100755'} or not re.fullmatch(r'[0-9a-f]{40,64}', entry[1]):
        raise Error('Invalid pending preference update.')
  return pending


def write_file(name, entry):
  path = safe_path(name)
  if entry is None:
    path.unlink(missing_ok=True)
    return
  path.parent.mkdir(parents=True, exist_ok=True)
  fd, temporary = tempfile.mkstemp(prefix='.omarchy-dots-', dir=path.parent)
  try:
    with os.fdopen(fd, 'wb') as out:
      out.write(data(entry))
      out.flush()
      os.fsync(out.fileno())
      # Preference files are private even when an incoming commit is 644.
      os.fchmod(out.fileno(), 0o700 if entry[0] == '100755' else 0o600)
    os.replace(temporary, path)
  finally:
    Path(temporary).unlink(missing_ok=True)


def apply_pending():
  pending = load_pending()
  if pending['conflicts']:
    raise Error('Resolve these files first: ' + ', '.join(pending['conflicts']))
  current = scan()
  paths = pending['before'].keys() | pending['after'].keys()
  for name in paths:
    expected = [pending['before'].get(name)]
    if pending['phase'] == 'applying':
      expected.append(pending['after'].get(name))
    if current.get(name) not in expected:
      raise Error(f'{name} changed while this update was pending. Cancel and pull again; your new edit has not been overwritten.')
  pending['phase'] = 'applying'
  atomic_json(PENDING, pending)
  for name in sorted(paths):
    if pending['before'].get(name) != pending['after'].get(name):
      write_file(name, pending['after'].get(name))
  snapshot('After ' + pending['operation'])
  if pending['operation'] == 'pull':
    git('update-ref', BASE, pending['remote'])
  PENDING.unlink()
  git('update-ref', '-d', 'refs/omarchy/pending')
  print('Preferences applied. Recovery snapshot: ' + pending['snapshot'][:12])
  print('Log out and back in to apply desktop settings. System > Preferences > Restore a File can undo individual changes.')


def resolve(args):
  pending = load_pending()
  conflicts = pending['conflicts']
  if not conflicts:
    print('All conflicts are resolved. Choose Continue Update.')
    return
  name = args.file or choose('Resolve which preference?', conflicts)
  if name not in conflicts:
    raise Error('That file is not an unresolved conflict.')
  ours, theirs = pending['before'].get(name), tree(pending['remote']).get(name)
  show_changes({name: ours} if ours else {}, {name: theirs} if theirs else {})
  side = args.take or choose('Choose the version to keep for ' + name, ['This machine', 'Shared version'])
  entry = ours if side in {'ours', 'This machine'} else theirs
  if entry:
    pending['after'][name] = entry
  else:
    pending['after'].pop(name, None)
  pending['conflicts'].remove(name)
  git('update-ref', 'refs/omarchy/pending', commit(pending['after'], None, 'Pending preference resolution'))
  atomic_json(PENDING, pending)
  print('Resolution saved. ' + ('More conflicts remain.' if pending['conflicts'] else 'Choose Continue Update to apply.'))


def abort(args):
  pending = load_pending()
  if pending['phase'] == 'applying':
    confirm('Undo the partially applied update using its recovery snapshot?', args.yes)
    # Do not discard changes made after interruption.
    current = scan()
    for name in pending['before'].keys() | pending['after'].keys():
      if current.get(name) not in [pending['before'].get(name), pending['after'].get(name)]:
        raise Error(f'{name} changed after interruption; save that edit before cancelling.')
    for name in pending['before'].keys() | pending['after'].keys():
      if pending['before'].get(name) != pending['after'].get(name):
        write_file(name, pending['before'].get(name))
  PENDING.unlink()
  git('update-ref', '-d', 'refs/omarchy/pending')
  print('Pending update cancelled. Your local preferences are kept.')


def restore(args):
  require_idle()
  revision = args.at
  if not revision:
    lines = output('log', '-30', '--format=%h %s', HISTORY).splitlines()
    revision = choose('Restore from which local snapshot?', lines).split()[0]
  oid = ref(revision + '^{commit}')
  if not oid:
    raise Error('Unknown local snapshot.')
  # A user-supplied ref must belong to local history, not arbitrary fetched data.
  if git('merge-base', '--is-ancestor', oid, HISTORY, check=False).returncode:
    raise Error('Choose a snapshot from local preference history.')
  old, current = tree(oid), scan()
  name = args.file or choose('Restore which preference?', sorted(old.keys() | current.keys()))
  if name.startswith(str(HOME) + '/'):
    name = str(Path(name).relative_to(HOME))
  safe_path(name)
  if name not in old and name not in current:
    raise Error('That file is not in this preference history.')
  before = {name: current[name]} if name in current else {}
  after = {name: old[name]} if name in old else {}
  show_changes(before, after)
  if args.dry_run:
    return
  confirm('Restore this file? Its current version will be kept in local history.', args.yes)
  previous = snapshot('Before restoring ' + name)
  atomic_json(PENDING, {'operation': 'restore', 'before': before, 'after': after,
            'snapshot': previous, 'conflicts': [], 'phase': 'review'})
  apply_pending()


def main():
  parser = argparse.ArgumentParser(description='Local preference history and explicit cross-machine sharing.')
  sub = parser.add_subparsers(dest='action', required=True)
  setup_parser = sub.add_parser('setup', help='Set up local history and optional sharing')
  setup_parser.add_argument('--repo', help='Private SSH Git repository (or local bare repository)')
  snap = sub.add_parser('snapshot', help='Save preferences locally')
  snap.add_argument('label', nargs='?', default='Saved preferences')
  sub.add_parser('log', help='Show local preference history')
  diff = sub.add_parser('diff', help='Review unsaved preference edits')
  diff.add_argument('ref', nargs='?', default='HEAD')
  sub.add_parser('status', help='Show history, shared repository, and pending conflicts')
  for action in ('push', 'pull', 'restore', 'abort'):
    cmd = sub.add_parser(action)
    cmd.add_argument('--yes', action='store_true', help='Skip confirmation')
    if action in ('pull', 'restore'):
      cmd.add_argument('--dry-run', action='store_true', help='Preview without changing preferences')
    if action == 'restore':
      cmd.add_argument('file', nargs='?')
      cmd.add_argument('--at', help='Local history revision')
  resolution = sub.add_parser('resolve', help='Choose a side for a pending conflict')
  resolution.add_argument('file', nargs='?')
  resolution.add_argument('--take', choices=['ours', 'theirs'])
  sub.add_parser('continue', help='Apply a resolved or interrupted update')
  args = parser.parse_args()
  os.umask(0o077)
  STATE.mkdir(parents=True, exist_ok=True)
  with (STATE / 'lock').open('w') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    if args.action == 'setup':
      setup(args)
      return
    require_repo()
    if args.action == 'snapshot':
      require_idle()
      print('Saved local snapshot: ' + snapshot(args.label)[:12])
    elif args.action == 'log':
      print(output('log', '-30', '--format=%h %ad %s', '--date=short', HISTORY))
    elif args.action == 'diff':
      oid = ref(args.ref + '^{commit}')
      if not oid:
        raise Error('Unknown local snapshot.')
      show_changes(tree(oid), scan())
    elif args.action == 'status':
      print('History: ' + (ref(HISTORY) or 'empty'))
      print('Sharing: ' + (output('config', '--get', 'remote.origin.url', check=False) or 'local only'))
      print('Published/applied: ' + (ref(BASE) or 'never'))
      if PENDING.exists():
        pending = load_pending()
        print('Pending: ' + pending['phase'])
        print('Conflicts: ' + (', '.join(pending['conflicts']) or 'none; ready to continue'))
      else:
        print('No pending update.')
    elif args.action == 'continue':
      apply_pending()
    else:
      {'push': push, 'pull': pull, 'restore': restore, 'resolve': resolve, 'abort': abort}[args.action](args)


if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    sys.exit(130)
  except (Error, OSError, ValueError, subprocess.SubprocessError) as error:
    print('omarchy-dots: ' + str(error), file=sys.stderr)
    sys.exit(1)
