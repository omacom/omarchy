import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
from datetime import datetime

backup = sys.argv[1] == '--backup'
args = sys.argv[2:] if backup else sys.argv[1:]
preferences = Path(args[0])
original = preferences.read_text() if preferences.exists() else '{}\n'
updated = original

for setting in args[1:]:
    key, value = setting.split('=', 1)
    pattern = rf'(?<!\\)("{re.escape(key)}"[ \t]*:[ \t]*)"(?:\\.|[^"\\])*"'
    lines = updated.splitlines(keepends=True)
    found = False
    for index, line in enumerate(lines):
        if line.lstrip().startswith('//'):
            continue
        lines[index], count = re.subn(pattern, lambda match: match[1] + json.dumps(value), line, count=1)
        if count:
            found = True
            break
    if found:
        updated = ''.join(lines)
    else:
        if any(re.search(rf'(?<!\\)"{re.escape(key)}"[ \t]*:', line)
               for line in lines if not line.lstrip().startswith('//')):
            sys.exit(f'Cannot update {key} in {preferences}')
        updated, count = re.subn(r'(?m)^([ \t]*)\{', lambda match: match[0] + '\n  ' + json.dumps(key) + ': ' + json.dumps(value) + ',', updated, count=1)
        if count == 0:
            sys.exit(f'Cannot find settings object in {preferences}')

if updated != original:
    if backup and preferences.exists():
        copy = preferences.with_name(preferences.name + '.bak.' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
        shutil.copy2(preferences, copy)
    with tempfile.NamedTemporaryFile(mode='w', dir=preferences.parent, prefix='.Preferences.sublime-settings.', delete=False) as tmp:
        tmp.write(updated)
    os.replace(tmp.name, preferences)
