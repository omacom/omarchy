import json
import os
import shutil
import sys
import tempfile
from datetime import datetime
from pathlib import Path

# Sets root-level string settings in a Sublime settings file, leaving comments,
# formatting and nested objects untouched.
# Usage: set-preferences.py [--backup] <file> <key>=<value>...


def skip_blank(text, i):
    while i < len(text):
        if text[i] in ' \t\r\n':
            i += 1
        elif text.startswith('//', i):
            end = text.find('\n', i)
            i = len(text) if end < 0 else end
        elif text.startswith('/*', i):
            end = text.find('*/', i + 2)
            i = len(text) if end < 0 else end + 2
        else:
            break
    return i


def string_end(text, i):
    i += 1
    while text[i] != '"':
        i += 2 if text[i] == '\\' else 1
    return i + 1


def value_end(text, i):
    depth = 0
    while True:
        if text[i] == '"':
            i = string_end(text, i)
        elif depth and text.startswith(('//', '/*'), i):
            i = skip_blank(text, i)
        else:
            depth += (text[i] in '{[') - (text[i] in '}]')
            i += 1
        if depth == 0 and (i == len(text) or text[i] in ' \t\r\n,}/'):
            return i


def root_members(text):
    i = skip_blank(text, 0)
    if text[i:i + 1] != '{':
        raise ValueError('no settings object')
    body = i + 1
    members = {}
    i = skip_blank(text, body)
    while text[i] != '}':
        key_end = string_end(text, i)
        key = json.loads(text[i:key_end])
        i = skip_blank(text, key_end)
        if text[i] != ':':
            raise ValueError(f'expected ":" after {key}')
        start = skip_blank(text, i + 1)
        end = value_end(text, start)
        members[key] = (i, start, end)
        i = skip_blank(text, end)
        if text[i] == ',':
            i = skip_blank(text, i + 1)
    return body, members


def set_setting(text, key, value):
    body, members = root_members(text)
    if key in members:
        _, start, end = members[key]
        return text[:start] + json.dumps(value) + text[end:]

    indent = '\t'
    if members:
        first = min(colon for colon, _, _ in members.values())
        line = text[text.rfind('\n', 0, first) + 1:first]
        indent = line[:len(line) - len(line.lstrip())] or indent
    member = f'\n{indent}{json.dumps(key)}: {json.dumps(value)},'
    if not members and not text.startswith('\n', body):
        member += '\n'
    return text[:body] + member + text[body:]


backup = sys.argv[1] == '--backup'
args = sys.argv[2:] if backup else sys.argv[1:]
preferences = Path(args[0])
original = preferences.read_text() if preferences.exists() else '{\n}\n'
updated = original

try:
    for setting in args[1:]:
        key, value = setting.split('=', 1)
        updated = set_setting(updated, key, value)
except IndexError:
    sys.exit(f'Cannot update {preferences}: unexpected end of file')
except ValueError as error:
    sys.exit(f'Cannot update {preferences}: {error}')

if updated != original:
    preferences.parent.mkdir(parents=True, exist_ok=True)
    if backup and preferences.exists():
        copy = preferences.with_name(preferences.name + '.bak.' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
        shutil.copy2(preferences, copy)
    if preferences.exists():
        mode = preferences.stat().st_mode & 0o777
    else:
        umask = os.umask(0)
        os.umask(umask)
        mode = 0o666 & ~umask
    with tempfile.NamedTemporaryFile(mode='w', dir=preferences.parent, prefix='.' + preferences.name + '.', delete=False) as tmp:
        tmp.write(updated)
    os.chmod(tmp.name, mode)
    os.replace(tmp.name, preferences)
