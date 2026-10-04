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


def without_comments(content):
    tokens = re.compile(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/')

    def keep_strings(match):
        token = match[0]
        if token.startswith('"'):
            return token
        return ''.join('\n' if char == '\n' else ' ' for char in token)

    return tokens.sub(keep_strings, content)

for setting in args[1:]:
    key, value = setting.split('=', 1)
    active = without_comments(updated)
    pattern = rf'(?<!\\)("{re.escape(key)}"[ \t]*:[ \t]*)"(?:\\.|[^"\\])*"'
    match = re.search(pattern, active)
    if match:
        updated = updated[:match.start()] + match[1] + json.dumps(value) + updated[match.end():]
    else:
        if re.search(rf'(?<!\\)"{re.escape(key)}"[ \t]*:', active):
            sys.exit(f'Cannot update {key} in {preferences}')
        opening = re.search(r'(?m)^([ \t]*)\{', active)
        count = bool(opening)
        if opening:
            offset = opening.end()
            updated = updated[:offset] + '\n  ' + json.dumps(key) + ': ' + json.dumps(value) + ',' + updated[offset:]
        if count == 0:
            sys.exit(f'Cannot find settings object in {preferences}')

if updated != original:
    if backup and preferences.exists():
        copy = preferences.with_name(preferences.name + '.bak.' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
        shutil.copy2(preferences, copy)
    with tempfile.NamedTemporaryFile(mode='w', dir=preferences.parent, prefix='.Preferences.sublime-settings.', delete=False) as tmp:
        tmp.write(updated)
    os.replace(tmp.name, preferences)
