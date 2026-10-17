#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export CAPTURE="$tmp/capture" REVIEW_CWD="$tmp/cwd" MARKER="$tmp/external-diff-ran"
mkdir -p "$tmp/bin" "$tmp/repo/subdir"
export PATH="$tmp/bin:$PATH"
cat > "$tmp/bin/omarchy-agent" <<'MOCK'
#!/bin/bash
printf '%s\0' "$@" > "$CAPTURE"
pwd -P > "$REVIEW_CWD"
MOCK
cat > "$tmp/bin/external-diff" <<'MOCK'
#!/bin/bash
 touch "$MARKER"
 exit 1
MOCK
chmod +x "$tmp/bin/"*
run() { bash "$ROOT/bin/omarchy-agent-review" "$@"; }
cd "$tmp/repo"
git init -q
git config user.name test
git config user.email test@example.invalid
printf 'initial\n' > tracked
printf 'tracked diff=fixture\n' > .gitattributes
git config diff.fixture.textconv external-diff
git add tracked .gitattributes
git commit -qm initial
printf 'staged-change\n' >> tracked
git add tracked
printf 'unstaged-change\n' >> tracked
printf 'untracked-secret\n' > untracked
git config diff.external external-diff
cd subdir
run --inline --staged
python3 - <<'PY'
import os
args=open(os.environ['CAPTURE'],'rb').read().split(b'\0')
assert args[:2] == [b'--inline',b'--prompt']
assert b'+staged-change' in args[2]
assert b'+unstaged-change' not in args[2]
assert b'untracked-secret' not in args[2]
assert open(os.environ['REVIEW_CWD']).read().strip()==os.path.realpath('..')
assert not os.path.exists(os.environ['MARKER'])
PY
pass 'staged review uses repository root and excludes unstaged and untracked content'
git config --unset diff.external
run
python3 - <<'PY'
import os
args=open(os.environ['CAPTURE'],'rb').read().split(b'\0')
assert b'+unstaged-change' in args[1]
assert b'+staged-change' not in args[1]
assert not os.path.exists(os.environ['MARKER'])
PY
pass 'default review selects unstaged changes without executing a text converter'
cd ..
git add tracked
rm -f "$CAPTURE"
run >/dev/null
[[ ! -e $CAPTURE ]] || fail 'empty diff launched agent'
python3 -c 'import sys;sys.stdout.write("x"*66000)' >> tracked
if run 2>/dev/null; then fail 'reject oversized diff'; fi
[[ ! -e $CAPTURE ]] || fail 'oversized diff launched agent'
cd "$tmp"
if run 2>/dev/null; then fail 'reject non-repository'; fi
pass 'empty, oversized and unavailable diffs never launch an agent'
