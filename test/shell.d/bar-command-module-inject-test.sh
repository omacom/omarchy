#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Custom command modules derive moduleName and settings from their layout entry
# as readonly bindings. ModuleSlot.injectProps used to assign those same names
# unconditionally whenever `"moduleName" in target`, which throws:
#   TypeError: Cannot assign to read-only property "moduleName"
# on every load / shell.json reload. The module still rendered because it never
# needed the injection; the assignment was pure log noise that also aborted
# before the settings write. Command slots skip those writes.

bar_qml="$ROOT/shell/plugins/bar/Bar.qml"
[[ -f $bar_qml ]] || fail "bar QML is present"

ROOT="$ROOT" python3 - "$bar_qml" <<'PY' || fail "command module injectProps tolerates readonly moduleName/settings"
import re
import sys
from pathlib import Path

bar_path = Path(sys.argv[1])
bar = bar_path.read_text()

custom_start = bar.find("component CustomCommandModule:")
if custom_start < 0:
    print("CustomCommandModule is not defined on the bar", file=sys.stderr)
    sys.exit(1)
print("ok - CustomCommandModule is defined on the bar")

# Body through the component's closing brace (indent of two spaces).
custom_end = bar.find("\n  }\n", custom_start)
custom_body = bar[custom_start:custom_end + 4]

if not re.search(r"readonly property string moduleName:\s*root\.entryId\(entry\)", custom_body):
    print("CustomCommandModule must derive readonly moduleName from its entry", file=sys.stderr)
    sys.exit(1)
print("ok - CustomCommandModule derives readonly moduleName from its entry")

if not re.search(r"readonly property var settings:\s*root\.entrySettings\(entry\)", custom_body):
    print("CustomCommandModule must derive readonly settings from its entry", file=sys.stderr)
    sys.exit(1)
print("ok - CustomCommandModule derives readonly settings from its entry")

slot_start = bar.find("component ModuleSlot:")
if slot_start < 0:
    print("ModuleSlot is not defined on the bar", file=sys.stderr)
    sys.exit(1)
print("ok - ModuleSlot is defined on the bar")

slot_body = bar[slot_start:custom_start]
inject = re.search(r"function injectProps\(\)\s*\{([\s\S]*?)\n    \}", slot_body)
if not inject:
    print("ModuleSlot does not define injectProps", file=sys.stderr)
    sys.exit(1)
print("ok - ModuleSlot defines injectProps")
body = inject.group(1)

# `in` is true for readonly props, so the writes have to be skipped on the slots
# that host CustomCommandModule rather than attempted there.
guard = re.search(r"if\s*\(\s*!commandCustom\s*\)\s*\{([\s\S]*?)\n      \}", body)
if not guard:
    print("injectProps must skip moduleName/settings writes on command slots", file=sys.stderr)
    sys.exit(1)
guarded = guard.group(1)
unguarded = body[:guard.start()] + body[guard.end():]

for prop, value in (("moduleName", "moduleName"), ("settings", "moduleSettings")):
    if not re.search(rf'if\s*\(\s*"{prop}"\s+in\s+target\s*\)\s*target\.{prop}\s*=\s*{value}\b', guarded):
        print(f"injectProps must still inject {prop} into writable modules", file=sys.stderr)
        sys.exit(1)
    if re.search(rf"target\.{prop}\s*=", unguarded):
        print(f"injectProps must not write {prop} outside the command-slot guard", file=sys.stderr)
        sys.exit(1)
print("ok - injectProps skips readonly moduleName/settings on command slots only")

# Every module that declares bar still gets it, command modules included.
if not re.search(r'if\s*\(\s*"bar"\s+in\s+target\s*\)\s*target\.bar\s*=', unguarded):
    print("injectProps must still offer bar to every module that declares it", file=sys.stderr)
    sys.exit(1)
print("ok - injectProps still offers bar outside the guard")
PY

pass "command module injectProps tolerates readonly moduleName/settings"
