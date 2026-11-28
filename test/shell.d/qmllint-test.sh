#!/bin/bash

set -euo pipefail

# shellcheck source=test/shell.d/base-test.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

qmllint_bin=""
if [[ -x /usr/lib/qt6/bin/qmllint ]]; then
  qmllint_bin="/usr/lib/qt6/bin/qmllint"
elif command -v qmllint >/dev/null 2>&1; then
  qmllint_bin=$(command -v qmllint)
elif command -v qmllint6 >/dev/null 2>&1; then
  qmllint_bin=$(command -v qmllint6)
fi

if [[ -z $qmllint_bin ]]; then
  if [[ -f /etc/os-release ]] && grep -q '^ID=arch$' /etc/os-release; then
    fail "qmllint is installed (expected /usr/lib/qt6/bin/qmllint from qt6-declarative)"
  fi
  skip "qmllint not installed on this host"
  exit 0
fi

qml_list=$(find "$ROOT/shell" -name '*.qml' -type f | sort)
[[ -n $qml_list ]] || fail "shell QML files exist under $ROOT/shell"
mapfile -t qml_files <<<"$qml_list"

# Expose the checkout's shell/ tree under the `qs` import URI so qmllint
# resolves `import qs.Commons` and `import qs.Ui` against this checkout.
import_root=$(mktemp -d)
trap 'rm -rf "$import_root"' EXIT
ln -s "$ROOT/shell" "$import_root/qs"

import_args=(-I "$import_root")
[[ -d /usr/lib/qt6/qml ]] && import_args+=(-I /usr/lib/qt6/qml)

json_out="$import_root/qmllint.json"
err_out="$import_root/qmllint.err"
"$qmllint_bin" --json "$json_out" "${import_args[@]}" "${qml_files[@]}" 2>"$err_out" || true

if [[ ! -s $json_out ]]; then
  fail "qmllint produced JSON report ($(cat "$err_out"))"
fi

# Filter only the two Qt 6.12 / Quickshell .qmltypes metadata false positives
# that cannot be suppressed inline without masking real ImportFailure errors:
#   - shell/shell.qml: Quickshell's ShellRoot qmltypes references PostReloadHook
#   - shell/plugins/bar/widgets/Tray.qml: inline component SectionArea inside Loader
if violations=$(python3 - "$ROOT" "$json_out" "${qml_files[@]}" <<'PY'
import json, os, sys

root = os.path.realpath(sys.argv[1])
data = json.load(open(sys.argv[2]))
expected = {os.path.relpath(os.path.realpath(p), root) for p in sys.argv[3:]}

KNOWN_METADATA_BUGS = {
  ("shell/shell.qml", "import", "PostReloadHook was not found. Did you add all imports and dependencies?"),
  ("shell/plugins/bar/widgets/Tray.qml", "import", "SectionArea was not found. Did you add all imports and dependencies?"),
}

issues = []
reported = set()
for entry in data.get("files", []):
  rel = os.path.relpath(os.path.realpath(entry["filename"]), root)
  reported.add(rel)
  for w in entry.get("warnings", []):
    wid = w.get("id", "")
    msg = w.get("message", "")
    if (rel, wid, msg) in KNOWN_METADATA_BUGS:
      continue
    issues.append(f"{rel}:{w.get('line', 0)}:{w.get('column', 0)}: [{wid}] {msg}")

missing = sorted(expected - reported)
for rel in missing:
  issues.append(f"{rel}:0:0: [missing-report] qmllint omitted file from JSON report")

if issues:
  print("\n".join(issues))
  sys.exit(1)
PY
); then
  pass "all ${#qml_files[@]} shell QML files pass qmllint"
else
  printf '%s\n' "$violations" >&2
  fail "shell QML files pass qmllint"
fi
