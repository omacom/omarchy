#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
bin_dir=$fixture/bin
mkdir -p "$bin_dir"

for name in omarchy omarchy-restart-shell omarchy-restart-audio omarchy-theme-set zz-unique-cmd; do
  printf '#!/bin/bash\n' >"$bin_dir/$name"
  chmod +x "$bin_dir/$name"
done

source "$ROOT/default/bash/completions"

spec=$(complete -p -I)
[[ $spec == *"-F _omarchy_command_complete"* && $spec != *"-X"* ]] ||
  fail "initial-word completion offers typed omarchy binaries" "$spec"
pass "initial-word completion offers typed omarchy binaries"

complete_initial() {
  local PATH=$bin_dir
  COMP_WORDS=("$1")
  COMP_CWORD=0
  COMP_LINE=$1
  COMP_POINT=${#COMP_LINE}
  COMPREPLY=()
  _omarchy_command_complete
}

complete_initial "omarchy-restart-s"
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "omarchy-restart-shell" ]] ||
  fail "omarchy-restart-shell completes from its prefix" "got: ${COMPREPLY[*]-}"
pass "omarchy-restart-shell completes from its prefix"

complete_initial "omarchy-r"
actual=$(printf '%s\n' "${COMPREPLY[@]}" | sort)
expected=$'omarchy-restart-audio\nomarchy-restart-shell'
[[ $actual == "$expected" ]] ||
  fail "a hyphenated prefix lists matching omarchy binaries" "expected:
$expected
actual:
$actual"
pass "a hyphenated prefix lists matching omarchy binaries"

complete_initial "oma"
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "omarchy" ]] ||
  fail "a short prefix stays on the omarchy dispatcher" "got: ${COMPREPLY[*]-}"
pass "a short prefix stays on the omarchy dispatcher"

complete_initial "zz-unique"
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "zz-unique-cmd" ]] ||
  fail "other commands still complete" "got: ${COMPREPLY[*]-}"
pass "other commands still complete"

complete_dispatcher() {
  local PATH=$bin_dir:/usr/bin
  COMP_WORDS=(omarchy restart sh)
  COMP_CWORD=2
  COMP_LINE="omarchy restart sh"
  COMP_POINT=${#COMP_LINE}
  COMPREPLY=()
  _omarchy_complete
}

complete_dispatcher
(( ${#COMPREPLY[@]} == 1 )) && [[ ${COMPREPLY[0]} == "shell" ]] ||
  fail "omarchy restart shell still completes" "got: ${COMPREPLY[*]-}"
pass "omarchy restart shell still completes"

complete_empty() {
  local PATH=$bin_dir
  COMP_WORDS=()
  COMP_CWORD=-1
  COMP_LINE=""
  COMP_POINT=0
  COMPREPLY=()
  _omarchy_command_complete
}

complete_empty
seen_omarchy=0
for candidate in "${COMPREPLY[@]}"; do
  [[ $candidate == "omarchy-restart-shell" ]] && fail "an empty prompt hides omarchy-* binaries"
  [[ $candidate == "omarchy" ]] && seen_omarchy=1
done
(( seen_omarchy == 1 )) || fail "an empty prompt still lists the omarchy dispatcher"
pass "an empty prompt skips the missing word and hides omarchy-* binaries"

require_command python3

work_dir=$fixture/work
mkdir -p "$work_dir/Projects" "$work_dir/space directory" "$work_dir/ls" "$fixture/home/Docs" "$fixture/absroot/onlydir"
ln -s Projects "$work_dir/LinkDest"
printf '#!/bin/bash\n' >"$bin_dir/ls"
printf '#!/bin/bash\n' >"$bin_dir/ZzUnique"
chmod +x "$bin_dir/ls" "$bin_dir/ZzUnique"
# The dispatcher completer resolves its bin directory with these.
ln -s /usr/bin/dirname /usr/bin/readlink "$bin_dir/"

if ! insert_out=$(
  python3 - "$ROOT" "$fixture" 2>&1 <<'PY'
import os, select, subprocess, sys, time
import pty as pty_mod

root, fixture = sys.argv[1], sys.argv[2]
rc_path = fixture + "/rc"
with open(rc_path, "w") as rc:
    rc.write(f'''
export HOME="{fixture}/home"
export PATH="{fixture}/bin"
cd "{fixture}/work"
bind -f "{root}/default/bash/inputrc"
bind "set completion-query-items 10000"
source "{root}/default/bash/completions"
dump_line() {{ printf '\\n__LINE__%s__END__\\n' "$READLINE_LINE"; }}
bind -x '"\\C-t": dump_line'
PS1='READY$ '
set +m
''')

def complete(keys):
    master, slave = pty_mod.openpty()
    proc = subprocess.Popen(
        ["bash", "--noprofile", "--rcfile", rc_path, "-i"],
        stdin=slave, stdout=slave, stderr=slave,
        close_fds=True, start_new_session=True,
    )
    os.close(slave)
    try:
        buf = b""
        deadline = time.time() + 3
        while time.time() < deadline and b"READY$" not in buf:
            ready, _, _ = select.select([master], [], [], 0.05)
            if master in ready:
                chunk = os.read(master, 8192)
                if not chunk:
                    break
                buf += chunk
        os.write(master, keys + b"\t\x14")
        out = b""
        deadline = time.time() + 3
        while time.time() < deadline and b"__END__" not in out:
            ready, _, _ = select.select([master], [], [], 0.05)
            if master in ready:
                chunk = os.read(master, 16384)
                if not chunk:
                    break
                out += chunk
    finally:
        proc.kill()
        proc.wait(timeout=2)
        os.close(master)
    text = out.decode("utf-8", "replace").replace("\r", "")
    if "bad array subscript" in text:
        return None, "bad array subscript"
    if "__LINE__" not in text or "__END__" not in text:
        return None, "completion did not report the line"
    line = text.split("__LINE__", 1)[1].split("__END__", 1)[0]
    return line, ""

checks = [
    ("empty prompt", b"", ""),
    ("whitespace prompt", b"   ", "   "),
    ("directory", b"./pro", "./Projects/"),
    ("symlinked directory", b"./Link", "./LinkDest/"),
    ("spaced directory", b"./space", "./space\\ directory/"),
    ("single-quoted path", b"'./space", "'./space directory'/"),
    ("double-quoted path", b'"./space', '"./space directory"/'),
    ("tilde path", b"~/Do", "~/Docs/"),
    ("absolute path", f"{fixture}/absroot/onl".encode(), f"{fixture}/absroot/onlydir/"),
    ("command matching a directory", b"ls", "ls "),
    ("short omarchy prefix", b"oma", "omarchy "),
    ("case-insensitive omarchy prefix", b"OMA", "omarchy "),
    ("other command", b"zzu", "ZzUnique "),
    ("hyphenated omarchy command", b"omarchy-restart-s", "omarchy-restart-shell "),
    ("dispatcher", b"omarchy restart sh", "omarchy restart shell "),
]
failed = []
for name, keys, expected in checks:
    line, err = complete(keys)
    if err or line != expected:
        failed.append(f"{name}: expected {expected!r}, got {line!r} ({err})")
if failed:
    print("\n".join(failed))
    sys.exit(1)
PY
); then
  fail "tab inserts the same text as builtin command completion" "$insert_out"
fi
pass "tab inserts the same text as builtin command completion"
