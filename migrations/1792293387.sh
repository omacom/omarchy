echo "Enable shared transcode settings for selections in Files"

python3 <<'PY'
from pathlib import Path
import shutil

extension = Path.home() / '.local/share/nautilus-python/extensions/transcode.py'
if extension.is_file() and not extension.is_symlink():
  original = extension.read_text()
  before = '''        if len(paths) == 1:
            cmd = shlex.join([binary, paths[0]])
        else:
            cmd = "; ".join(
                f"echo {shlex.quote(f'Transcoding {path}')} && "
                f"{shlex.join([binary, path])} || true"
                for path in paths
            )'''
  after = '''        args = [binary, "--batch", "--", *paths] if len(paths) > 1 else [binary, "--", *paths]
        cmd = shlex.join(args)'''
  # Patch only the shipped launch loop; preserve other customizations and
  # leave a separately maintained launcher or an intentionally removed file alone.
  if original.count(before) == 1:
    backup = extension.with_name('transcode.py.bak.1792293387')
    if not backup.exists():
      shutil.copy2(extension, backup)
    extension.write_text(original.replace(before, after, 1))
    print('Restart Files to load shared transcode settings.')
PY
