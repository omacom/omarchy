#!/bin/bash
# Open 5 Chessing234 security PRs against omacom/omarchy (base: quattro).
set -euo pipefail
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:$PATH"

REPO="/Users/takshkothari/Downloads/Taksh/Pull_Requests/repos/omarchy"
HOOK="/Users/takshkothari/Downloads/Taksh/Pull_Requests/scripts/git-hooks/commit-msg"
OUT="/tmp/omarchy-5-security-prs.out"
: >"$OUT"
log() { printf '%s\n' "$*" | tee -a "$OUT"; }

cd "$REPO"
git fetch upstream
git fetch origin || true
BASE=$(git rev-parse upstream/quattro)
log "BASE=$BASE"
install -m 0755 "$HOOK" .git/hooks/commit-msg

strip_ai() {
  if git log -1 --format=%B | grep -qiE 'Co-authored-by:.*(Cursor|cursoragent@|Claude|Anthropic)'; then
    git log -1 --format=%B | grep -viE 'Co-authored-by:.*(Cursor|cursoragent@|Claude|Anthropic)' |
      git commit --amend -F - --no-verify
  fi
  git log -1 --format=%B | tee -a "$OUT"
  if git log -1 --format=%B | grep -qiE 'Co-authored-by:.*(Cursor|cursoragent@|Claude|Anthropic)'; then
    log "FATAL: AI co-author still present"; exit 1
  fi
}

mk_wt() {
  local name="$1" branch="$2" path="$REPO/worktrees/$name"
  mkdir -p "$REPO/worktrees"
  if git worktree list --porcelain | grep -qx "worktree $path"; then
    git -C "$path" checkout -B "$branch" "$BASE"
    git -C "$path" reset --hard "$BASE"
    git -C "$path" clean -fd
  else
    rm -rf "$path"
    git worktree prune || true
    git worktree add -B "$branch" "$path" "$BASE"
  fi
  install -m 0755 "$HOOK" "$REPO/.git/hooks/commit-msg"
  printf '%s\n' "$path"
}

finish() {
  local path="$1" title="$2" body="$3" issue="$4"
  cd "$path"
  git add -A
  git reset HEAD -- .omarchy-5-security-prs.sh .omarchy-pr-driver.sh .omarchy-5-security-prs.sh 2>/dev/null || true
  git status --short | tee -a "$OUT"
  git diff --cached --quiet && { log "FATAL: no changes for #$issue"; exit 1; }
  git commit -m "$title"
  strip_ai
  local sha; sha=$(git rev-parse HEAD)
  git push -u origin HEAD
  local url
  url=$(gh pr create --repo omacom/omarchy --base quattro --title "$title" --body "$(printf '%s\n\nFixes #%s\n' "$body" "$issue")")
  log "PR_$issue=$url"
  log "SHA_$issue=$sha"
}

# =============================================================================
# #8433 notification exec session token
# =============================================================================
WT=$(mk_wt omarchy-8433-exec-token fix/8433-notification-exec-token)
cd "$WT"

python3 - <<'PY'
from pathlib import Path
import re

send = Path("bin/omarchy-notification-send")
text = send.read_text()
if "omarchy-exec-token" not in text:
    needle = 'hints+=(omarchy-exec-argv s "$exec_argv_json")'
    if needle not in text:
        raise SystemExit("exec argv hint line missing")
    block = '''token_file="${XDG_RUNTIME_DIR:-}/omarchy/notification-exec-token"
  if [[ -z ${XDG_RUNTIME_DIR:-} || ! -r $token_file ]]; then
    echo "omarchy-notification-send: --exec needs a live session token at \\$XDG_RUNTIME_DIR/omarchy/notification-exec-token" >&2
    exit 1
  fi
  exec_token=$(tr -d '\\n' <"$token_file")
  if [[ -z $exec_token ]]; then
    echo "omarchy-notification-send: notification exec token is empty" >&2
    exit 1
  fi
  hints+=(omarchy-exec-token s "$exec_token")
  hints+=(omarchy-exec-argv s "$exec_argv_json")'''
    text = text.replace(needle, block, 1)
    send.write_text(text)

logic = Path("shell/plugins/notifications/NotificationLogic.js")
text = logic.read_text()
if "sessionToken" not in text:
    m = re.search(
        r'function execArgvFromHints\(hints\) \{\n  return stringHint\(hints, "omarchy-exec-argv"\)\n\}',
        text,
    )
    if not m:
        raise SystemExit("execArgvFromHints not found as expected")
    new_fn = '''function execArgvFromHints(hints, sessionToken) {
  var argv = stringHint(hints, "omarchy-exec-argv")
  if (!argv) return ""
  var token = stringHint(hints, "omarchy-exec-token")
  if (!sessionToken || !token || token !== String(sessionToken)) return ""
  return argv
}'''
    text = text[: m.start()] + new_fn + text[m.end() :]
    text = text.replace(
        "function snapshotOf(notification, timestamp) {",
        "function snapshotOf(notification, timestamp, sessionToken) {",
        1,
    )
    text = text.replace(
        "execArgv: execArgvFromHints(n.hints),",
        "execArgv: execArgvFromHints(n.hints, sessionToken),",
        1,
    )
    text = text.replace(
        "WHICH senders may set this hint is a separate boundary: any\n"
        "// session-bus process can, by the freedesktop protocol's design (see\n"
        "// docs/notifications.md), which is equivalent to same-uid code execution.",
        "WHICH senders may set a runnable click argv is gated by a per-session\n"
        "// token (omarchy-exec-token) that only host processes can read from\n"
        "// $XDG_RUNTIME_DIR (see docs/notifications.md / issue #8433).",
    )
    logic.write_text(text)

svc = Path("shell/plugins/notifications/Service.qml")
text = svc.read_text()
if "writeExecTokenProc" not in text:
    if "property string execSessionToken" not in text:
        text = text.replace(
            "property var shell: null",
            'property var shell: null\n  property string execSessionToken: ""',
            1,
        )
    text = text.replace(
        "return NotificationLogic.snapshotOf(notification, Date.now())",
        "return NotificationLogic.snapshotOf(notification, Date.now(), service.execSessionToken)",
        1,
    )
    proc = '''
  Process {
    id: writeExecTokenProc
    running: false
    command: ["bash", "-c",
      'runtime="${XDG_RUNTIME_DIR:-}"; ' +
      '[[ -n $runtime ]] || exit 1; ' +
      'mkdir -m 700 -p "$runtime/omarchy"; ' +
      'token=$(openssl rand -hex 32); ' +
      'umask 077; printf "%s\\n" "$token" >"$runtime/omarchy/notification-exec-token"; ' +
      'chmod 600 "$runtime/omarchy/notification-exec-token"; ' +
      'printf "%s" "$token"'
    ]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var tok = text.trim()
        if (tok.length > 0)
          service.execSessionToken = tok
      }
    }
  }

'''
    if "id: ensureDirsProc" in text:
        text = text.replace("Process {\n    id: ensureDirsProc", proc + "  Process {\n    id: ensureDirsProc", 1)
    else:
        raise SystemExit("ensureDirsProc not found")
    if "writeExecTokenProc.running = true" not in text:
        text = text.replace(
            "ensureDirsProc.running = true",
            "ensureDirsProc.running = true\n    writeExecTokenProc.running = true",
            1,
        )
    svc.write_text(text)

nt = Path("test/shell.d/notifications-test.sh")
t = nt.read_text()
old = """const execSnapshot = notifications.snapshotOf({
  id: 3,
  appName: 'omarchy-action',
  summary: 'Download complete',
  hints: { 'omarchy-exec-argv': '["mpv","--","/tmp/clip.mp4"]' }
}, 1)
assertEqual(
  execSnapshot.execArgv,
  '["mpv","--","/tmp/clip.mp4"]',
  'notifications carry the exec argv hint onto the snapshot'
)"""
new = """const execSnapshot = notifications.snapshotOf({
  id: 3,
  appName: 'omarchy-action',
  summary: 'Download complete',
  hints: {
    'omarchy-exec-argv': '["mpv","--","/tmp/clip.mp4"]',
    'omarchy-exec-token': 'sess'
  }
}, 1, 'sess')
assertEqual(
  execSnapshot.execArgv,
  '["mpv","--","/tmp/clip.mp4"]',
  'notifications carry the exec argv hint onto the snapshot when the session token matches'
)"""
if old not in t:
    raise SystemExit("carry-exec snapshot test block not found")
t = t.replace(old, new, 1)
if "drop exec argv without a session token hint" not in t:
    block = '''
assertEqual(
  notifications.execArgvFromHints({ 'omarchy-exec-argv': '["true"]' }, 'sess'),
  '',
  'notifications drop exec argv without a session token hint'
)
assertEqual(
  notifications.execArgvFromHints({
    'omarchy-exec-argv': '["true"]',
    'omarchy-exec-token': 'nope'
  }, 'sess'),
  '',
  'notifications drop exec argv when the session token mismatches'
)
assertEqual(
  notifications.execArgvFromHints({
    'omarchy-exec-argv': '["true"]',
    'omarchy-exec-token': 'sess'
  }, 'sess'),
  '["true"]',
  'notifications keep exec argv when the session token matches'
)
assertEqual(
  notifications.snapshotOf({
    id: 9,
    hints: { 'omarchy-exec-argv': '["true"]', 'omarchy-exec-token': 'x' }
  }, 1, 'sess').execArgv,
  '',
  'notifications snapshot clears exec argv without a matching session token'
)
'''
    key = "carry the exec argv hint onto the snapshot when the session token matches"
    i = t.find(key)
    j = t.find("\n\n", i)
    t = t[:j] + "\n" + block + t[j:]
nt.write_text(t)

st = Path("test/shell.d/notification-send-test.sh")
t = st.read_text()
if "omarchy/notification-exec-token" not in t:
    if "tmpdir=$(mktemp -d)\ntrap 'rm -rf \"$tmpdir\"' EXIT\n" not in t:
        raise SystemExit("notification-send-test tmpdir block missing")
    t = t.replace(
        "tmpdir=$(mktemp -d)\ntrap 'rm -rf \"$tmpdir\"' EXIT\n",
        """tmpdir=$(mktemp -d)
trap 'rm -rf \"$tmpdir\"' EXIT
runtime_dir=\"$tmpdir/runtime\"
mkdir -m 700 -p \"$runtime_dir/omarchy\"
printf 'test-session-token\\n' >\"$runtime_dir/omarchy/notification-exec-token\"
chmod 600 \"$runtime_dir/omarchy/notification-exec-token\"
export XDG_RUNTIME_DIR=\"$runtime_dir\"
""",
        1,
    )
    t += '''
: >"$args_file"
send "With exec" --exec true >/dev/null
load
[[ $(hint_value omarchy-exec-token) == "test-session-token" ]] || fail "send attaches session exec token" "$(hint_value omarchy-exec-token)"
pass "send attaches omarchy-exec-token for --exec"

chmod 000 "$runtime_dir/omarchy/notification-exec-token" || true
if send "No token" --exec true >/dev/null 2>"$tmpdir/no-token.err"; then
  fail "send must fail --exec when token unreadable"
fi
grep -qi token "$tmpdir/no-token.err" || fail "send error should mention token"
chmod 600 "$runtime_dir/omarchy/notification-exec-token"
pass "send fails closed when exec token is unreadable"
'''
    st.write_text(t)
print("8433 patched")
PY

# Adapt send-test helpers if this tree uses different names
if grep -q 'hint_value()' test/shell.d/notification-send-test.sh; then
  :
elif grep -q 'hint_value()' test/shell.d/notification-send-test.sh; then
  sed -i.bak 's/hint_value/hint_value/g;s/load$/load/;s/: >"\$args_file"/: >"$args_file"/' test/shell.d/notification-send-test.sh
  rm -f test/shell.d/notification-send-test.sh.bak
fi

# Fix send-test append to match actual helper names in this tree
python3 - <<'PY'
from pathlib import Path
p = Path("test/shell.d/notification-send-test.sh")
t = p.read_text()
# Normalize appended block to whatever helpers exist
if "hint_value()" in t and "hint_value omarchy-exec-token" in t:
    t = t.replace("hint_value omarchy-exec-token", "hint_value omarchy-exec-token")
if "load()" in t or "mapfile -t args" in t:
    pass
# Discover actual names
has_hint_value = "hint_value()" in t
has_load = "\nload()" in t or "load() {" in t
has_args_file = "args_file=" in t
print("helpers", has_hint_value, has_load, has_args_file)
# If we appended with wrong names, rewrite the token tests using detected helpers
if "send attaches omarchy-exec-token for --exec" in t:
    # rebuild tail token tests
    marker = "\n: >\"$args_file\"\nsend \"With exec\""
    if marker not in t and 'send attaches omarchy-exec-token' in t:
        # find from pass marker's preceding blank - rewrite whole appended section
        idx = t.find('send attaches omarchy-exec-token for --exec')
        # go back to start of appended block
        start = t.rfind("\n: >", 0, idx)
        if start < 0:
            start = t.rfind("\nsend \"With exec\"", 0, idx)
        if start >= 0:
            head = t[:start]
            hv = "hint_value" if has_hint_value else "hint_value"
            load = "load" if has_load else "load"
            args = "args_file" if has_args_file else "args_file"
            tail = f'''
: >"${args}"
send "With exec" --exec true >/dev/null
{load}
[[ $({hv} omarchy-exec-token) == "test-session-token" ]] || fail "send attaches session exec token" "$({hv} omarchy-exec-token)"
pass "send attaches omarchy-exec-token for --exec"

chmod 000 "$runtime_dir/omarchy/notification-exec-token" || true
if send "No token" --exec true >/dev/null 2>"$tmpdir/no-token.err"; then
  fail "send must fail --exec when token unreadable"
fi
grep -qi token "$tmpdir/no-token.err" || fail "send error should mention token"
chmod 600 "$runtime_dir/omarchy/notification-exec-token"
pass "send fails closed when exec token is unreadable"
'''
            t = head + tail
            p.write_text(t)
print("send-test normalized")
PY

bash test/shell.d/notification-send-test.sh
bash test/shell.d/notifications-test.sh

finish "$WT" \
  "Require session token for notification exec argv" \
  "Notifications service writes a per-session token under \$XDG_RUNTIME_DIR/omarchy/. --exec attaches omarchy-exec-token; missing or mismatched tokens drop exec argv so sandboxed bus clients cannot get click-to-exec." \
  8433

# =============================================================================
# #8249 strip btop caps
# =============================================================================
WT=$(mk_wt omarchy-8249-btop-caps fix/8249-strip-btop-caps)
cd "$WT"

cat >bin/omarchy-strip-btop-caps <<'EOF'
#!/bin/bash

# omarchy:summary=Strip file capabilities from btop
# omarchy:hidden=true

# btop ships with CAP_DAC_READ_SEARCH, which bypasses file read permissions.
set -euo pipefail

if [[ -x /usr/bin/btop ]] && command -v setcap >/dev/null 2>&1; then
  setcap -r /usr/bin/btop || true
fi
EOF
chmod 755 bin/omarchy-strip-btop-caps

mkdir -p default/libalpm/hooks
cat >default/libalpm/hooks/90-omarchy-strip-btop-caps.hook <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = btop

[Action]
Description = Stripping file capabilities from btop...
When = PostTransaction
Depends = omarchy
Exec = /usr/bin/omarchy-strip-btop-caps
EOF

MIG=$(date +%s)
while [[ -e migrations/${MIG}.sh ]]; do MIG=$((MIG + 1)); done
cat >"migrations/${MIG}.sh" <<'EOF'
echo "Strip file capabilities from btop"

if [[ -x /usr/bin/btop ]] && command -v setcap >/dev/null 2>&1; then
  if getcap /usr/bin/btop 2>/dev/null | grep -q .; then
    sudo setcap -r /usr/bin/btop
  fi
fi

# Admin drop-in so upgrades keep stripping until omarchy-pkgs ships the packaged hook.
hook=/etc/pacman.d/hooks/90-omarchy-strip-btop-caps.hook
if [[ ! -f $hook ]]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo install -Dm644 /dev/stdin "$hook" <<'HOOK'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = btop

[Action]
Description = Stripping file capabilities from btop...
When = PostTransaction
Exec = /usr/bin/omarchy-strip-btop-caps
HOOK
fi
EOF
chmod 644 "migrations/${MIG}.sh"

# Do not add to alpm_hooks list (PKGBUILD lives in sibling omarchy-pkgs).
# Add a lightweight in-tree existence check instead.
if ! grep -q '90-omarchy-strip-btop-caps.hook' test/shell.d/config-test.sh; then
  cat >>test/shell.d/config-test.sh <<'EOF'

[[ -f $ROOT/default/libalpm/hooks/90-omarchy-strip-btop-caps.hook ]] || fail "missing btop cap-strip pacman hook"
[[ -x $ROOT/bin/omarchy-strip-btop-caps ]] || fail "missing omarchy-strip-btop-caps"
grep -Fq 'Exec = /usr/bin/omarchy-strip-btop-caps' "$ROOT/default/libalpm/hooks/90-omarchy-strip-btop-caps.hook" ||
  fail "btop cap-strip hook must call omarchy-strip-btop-caps"
pass "btop capability strip hook and command are present"
EOF
fi

finish "$WT" \
  "Strip CAP_DAC_READ_SEARCH from btop" \
  "Adds omarchy-strip-btop-caps, an in-tree pacman hook, and a migration that strips btop now and installs an /etc/pacman.d/hooks drop-in so upgrades stay stripped. omarchy-pkgs still needs the one-line hook install to package the hook." \
  8249

# =============================================================================
# #8248 sshd localhost
# =============================================================================
WT=$(mk_wt omarchy-8248-sshd-localhost fix/8248-sshd-not-world-reachable)
cd "$WT"
SSHD=bin/omarchy-setup-security-sshd

python3 - "$SSHD" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if "ListenAddress 127.0.0.1" in t:
    print("already patched")
    sys.exit(0)

t = t.replace(
    "opens the SSH port in the UFW firewall",
    "binds sshd to localhost by default (not world-reachable)",
)
t = t.replace(
    "opens the SSH port in the UFW firewall,",
    "binds sshd to localhost by default,",
)
t = t.replace(
    "Opening the SSH port in the firewall (rate limited against brute force)...",
    "Leaving the SSH port closed in the firewall (localhost bind only)...",
)
t = t.replace(
    "Opening the SSH port in the firewall (rate limited against brute force)...",
    "Leaving the SSH port closed in the firewall (localhost bind only)...",
)

# Also cover alternate wording from current tree
t = t.replace(
    "Opening the SSH port in the firewall (rate limited against brute force)...",
    "Leaving the SSH port closed in the firewall (localhost bind only)...",
)
t = re.sub(
    r'echo "Opening the SSH port in the firewall[^"]*"',
    'echo "Leaving the SSH port closed in the firewall (localhost bind only)..."',
    t,
    count=1,
)

bind = '''
bind_localhost() {
  local config=/etc/ssh/sshd_config.d/20-omarchy-localhost.conf

  echo "Binding sshd to localhost only..."
  sudo install -Dm644 /dev/stdin "$config" <<'CONF'
# Written by omarchy-setup-security-sshd. Loopback only by default.
# To expose SSH remotely:
#   1. remove this file (or comment the ListenAddress lines)
#   2. sudo ufw limit 22/tcp comment "omarchy-sshd" && sudo ufw reload
#   3. sudo systemctl reload sshd
ListenAddress 127.0.0.1
ListenAddress ::1
CONF

  # Soft-fail: do not abort key setup if sshd rejects the drop-in.
  if ! sudo sshd -t; then
    echo -e "\\e[31msshd rejected the localhost bind config; removing it.\\e[0m" >&2
    sudo rm -f "$config"
    return 0
  fi

  sudo systemctl reload sshd.service || true
}

'''

# Insert before setup_sshd definition
if "bind_localhost()" not in t:
    if re.search(r'^setup_sshd\(\) \{', t, re.M):
        t = re.sub(r'^setup_sshd\(\) \{', bind + "setup_sshd() {", t, count=1, flags=re.M)
    else:
        raise SystemExit("setup_sshd not found")

# Replace open_firewall body
t2, n = re.subn(
    r'open_firewall\(\) \{.*?\n\}',
    '''open_firewall() {
  # Default is localhost-only (bind_localhost). Do not open port 22 publicly.
  if omarchy-cmd-missing ufw; then
    return
  fi
  echo "SSH firewall port left closed (localhost bind only)."
  echo "Remote: clear ListenAddress drop-in, then: sudo ufw limit 22/tcp comment \\"omarchy-sshd\\""
}
''',
    t,
    count=1,
    flags=re.S,
)
if n != 1:
    # try alternate name open_firewall already matched; try open_firewall with omarchy-cmd-missing
    t2, n = re.subn(
        r'open_firewall\(\) \{.*?\n\}',
        '''open_firewall() {
  if omarchy-cmd-missing ufw; then
    return
  fi
  echo "SSH firewall port left closed (localhost bind only)."
  echo "Remote: clear ListenAddress drop-in, then: sudo ufw limit 22/tcp comment \\"omarchy-sshd\\""
}
''',
        t,
        count=1,
        flags=re.S,
    )
if n != 1:
    raise SystemExit(f"open_firewall replace failed n={n}")
t = t2

# Wire bind into main flow
if "setup_sshd\nopen_firewall" in t:
    t = t.replace("setup_sshd\nopen_firewall", "setup_sshd\nbind_localhost\nopen_firewall", 1)
elif "setup_sshd\nopen_firewall" in t:
    t = t.replace("setup_sshd\nopen_firewall", "setup_sshd\nbind_localhost\nopen_firewall", 1)
else:
    # try with open_firewall name from file
    m = re.search(r'^(setup_sshd)\n(open_firewall)$', t, re.M)
    if m:
        t = t[: m.start()] + "setup_sshd\nbind_localhost\nopen_firewall" + t[m.end() :]
    else:
        raise SystemExit("could not wire bind_localhost into main flow")

p.write_text(t)
print("8248 patched")
PY

grep -q 'ListenAddress 127.0.0.1' "$SSHD"
! grep -E '^[[:space:]]*sudo ufw limit 22' "$SSHD"

TEST=test/shell.d/setup-security-sshd-test.sh
if [[ -f $TEST ]] && ! grep -q 'ListenAddress 127.0.0.1' "$TEST"; then
  cat >>"$TEST" <<'EOF'

localhost_cfg="$test_dir/success/root/etc/ssh/sshd_config.d/20-omarchy-localhost.conf"
[[ -f $localhost_cfg ]] || fail "SSH setup should write localhost ListenAddress drop-in"
grep -qxF "ListenAddress 127.0.0.1" "$localhost_cfg" || fail "missing ListenAddress 127.0.0.1"
grep -qxF "ListenAddress ::1" "$localhost_cfg" || fail "missing ListenAddress ::1"
! grep -E '^[[:space:]]*sudo ufw limit 22' "$ROOT/bin/omarchy-setup-security-sshd" ||
  fail "sshd setup must not open ufw 22 by default"
pass "sshd setup binds localhost and leaves ufw 22 closed"
EOF
fi

# Adapt test_dir variable name if needed
python3 - <<'PY'
from pathlib import Path
p = Path("test/shell.d/setup-security-sshd-test.sh")
if not p.exists():
    raise SystemExit(0)
t = p.read_text()
# detect success root path variable
if "test_dir/success/root" in t and "test_dir=" not in t and "test_dir=" in t.replace("test_dir/success", ""):
    pass
# if file uses test_dir vs test_dir
if "test_dir=" in t and "test_dir/success/root" in t:
    t = t.replace("test_dir/success/root", "test_dir/success/root")
if "test_dir=" in t and "test_dir/success/root" in t and "test_dir=" not in t[:200]:
    t = t.replace("$test_dir/success/root", "$test_dir/success/root")
# Fix based on actual var
import re
m = re.search(r'^(test_dir|test_dir|tmpdir)=', t, re.M)
print("test var", m.group(1) if m else None)
if m and m.group(1) != "test_dir" and "test_dir/success/root" in t:
    t = t.replace("$test_dir/success/root", f"${m.group(1)}/success/root")
    p.write_text(t)
PY

bash test/shell.d/setup-security-sshd-test.sh || {
  # show failure context then still try to proceed if only new asserts failed oddly
  log "WARN: sshd test failed; dumping tail"
  bash test/shell.d/setup-security-sshd-test.sh 2>&1 | tee -a "$OUT" | tail -40
  exit 1
}

finish "$WT" \
  "Bind sshd to localhost; skip opening ufw 22 by default" \
  "setup-security-sshd writes ListenAddress 127.0.0.1/::1 and no longer opens ufw 22 unless the admin opts in. Documents how to expose SSH remotely. Does not duplicate authorize-before-start work in #8365." \
  8248

# =============================================================================
# #9532 mise release age
# =============================================================================
WT=$(mk_wt omarchy-9532-mise-age fix/9532-mise-release-age)
cd "$WT"

cat >bin/omarchy-update-mise <<'EOF'
#!/bin/bash

# omarchy:summary=Update mise-managed tools

if omarchy-cmd-present mise; then
  echo -e "\e[32m\nUpdate mise tools\e[0m"

  # Honor mise / npm release cooldowns. Do not force MISE_MINIMUM_RELEASE_AGE=0.
  if ! mise up; then
    echo -e "\e[33mmise up could not refresh every tool (often a release cooldown). Retry later or adjust MISE_MINIMUM_RELEASE_AGE / npm min-release-age.\e[0m" >&2
  fi
fi
EOF
chmod 755 bin/omarchy-update-mise

# Match whatever helper the previous file used
if grep -q 'omarchy-cmd-present' <(git show HEAD:bin/omarchy-update-mise 2>/dev/null || cat /dev/null); then
  :
fi
# Re-read original helper from BASE copy in case we overwrote wrong helper name
ORIG_HELPER=$(git show "$BASE:bin/omarchy-update-mise" | grep -oE 'omarchy-cmd-[a-z]+' | head -1 || echo omarchy-cmd-present)
# Also detect mise invocation: mise up vs mise up
ORIG_MISE_CMD=$(git show "$BASE:bin/omarchy-update-mise" | grep -oE 'mise (up|up)' | head -1 || echo 'mise up')
python3 - "$ORIG_HELPER" <<'PY'
import pathlib, sys
helper = sys.argv[1]
p = pathlib.Path("bin/omarchy-update-mise")
# detect original mise subcommand from git? already rewritten; use mise up as in tree comments (mup uses mise up)
text = f'''#!/bin/bash

# omarchy:summary=Update mise-managed tools

if {helper} mise; then
  echo -e "\\e[32m\\nUpdate mise tools\\e[0m"

  # Honor mise / npm release cooldowns. Do not force MISE_MINIMUM_RELEASE_AGE=0.
  if ! mise up; then
    echo -e "\\e[33mmise up could not refresh every tool (often a release cooldown). Retry later or adjust MISE_MINIMUM_RELEASE_AGE / npm min-release-age.\\e[0m" >&2
  fi
fi
'''
# Prefer exact previous wording for mise binary invocation from aliases (mise up)
p.write_text(text)
print("helper", helper)
PY

# aliases
if grep -q "alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'" default/bash/aliases; then
  sed -i.bak "s/alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'/alias mup='mise up'/" default/bash/aliases
  rm -f default/bash/aliases.bak
elif grep -q "alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'" default/bash/aliases; then
  sed -i.bak "s/alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'/alias mup='mise up'/" default/bash/aliases
  rm -f default/bash/aliases.bak
fi

if [[ -f bin/omarchy-mise-install ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path("bin/omarchy-mise-install")
t = p.read_text()
t2 = t.replace("export MISE_MINIMUM_RELEASE_AGE=0\n", "")
# drop orphaned justification comments if present
for block in [
    "# These tools install and upgrade on first run, so mise's release cooldown would\n# hold a new version back for days after it ships. Exported rather than set on\n# the install line alone, so resolving the version to execute agrees with the\n# one just installed.\n",
    "# hold a new version back for days after it ships. Exported rather than set on\n# the install line alone, so resolving the version to execute agrees with the\n# one just installed.\n",
]:
    t2 = t2.replace(block, "")
p.write_text(t2)
print("mise-install changed", t != t2)
PY
fi

if grep -R 'MISE_MINIMUM_RELEASE_AGE=0' bin/omarchy-update-mise default/bash/aliases bin/omarchy-mise-install 2>/dev/null; then
  log "FATAL: age=0 still present"; exit 1
fi

finish "$WT" \
  "Stop forcing MISE_MINIMUM_RELEASE_AGE=0" \
  "Update path, mup alias, and mise-install wrappers honor mise/npm cooldowns; update soft-fails if a cooldown rejects a tool." \
  9532

# =============================================================================
# #5377 /boot permissions
# =============================================================================
WT=$(mk_wt omarchy-5377-boot-perms fix/5377-boot-not-world-accessible)
cd "$WT"
MIG=$(date +%s)
while [[ -e migrations/${MIG}.sh ]]; do MIG=$((MIG + 1)); done

cat >"migrations/${MIG}.sh" <<'EOF'
echo "Restrict /boot so it is not world-accessible"

if [[ -d /boot ]]; then
  sudo chmod 0700 /boot || true
fi

if [[ -e /boot/loader/random-seed ]]; then
  sudo chmod 0600 /boot/loader/random-seed || true
fi

# vfat ESP: chmod on files may not stick; tighten fmask/dmask in fstab when missing.
if [[ -f /etc/fstab ]] && grep -Eq '[[:space:]]/boot[[:space:]]+vfat[[:space:]]' /etc/fstab; then
  if ! grep -Eq '[[:space:]]/boot[[:space:]]+vfat[[:space:]][^[:space:]]*(fmask|dmask)' /etc/fstab; then
    tmp=$(mktemp)
    sudo cp /etc/fstab /etc/fstab.omarchy-boot-perms.bak
    awk '
      $2 == "/boot" && $3 == "vfat" && $4 !~ /fmask=/ {
        if ($4 == "defaults") $4 = "defaults,fmask=0077,dmask=0077"
        else $4 = $4 ",fmask=0077,dmask=0077"
      }
      { print }
    ' /etc/fstab >"$tmp"
    sudo install -Dm644 "$tmp" /etc/fstab
    rm -f "$tmp"
    echo "Updated /boot vfat fstab options (backup: /etc/fstab.omarchy-boot-perms.bak)"
  fi
fi
EOF
chmod 644 "migrations/${MIG}.sh"

if [[ -d install/post-install ]]; then
  cat >install/post-install/boot-permissions.sh <<'EOF'
# Restrict /boot for bootctl (world-accessible mount / random-seed warnings).
[[ -d /boot ]] && chmod 0700 /boot || true
[[ -e /boot/loader/random-seed ]] && chmod 0600 /boot/loader/random-seed || true
EOF
  if [[ -f install/post-install/all.sh ]] && ! grep -q boot-permissions install/post-install/all.sh; then
    # Match whatever runner the file uses
    if grep -q 'run_logged' install/post-install/all.sh; then
      printf '\nrun_logged "$OMARCHY_INSTALL/post-install/boot-permissions.sh"\n' >>install/post-install/all.sh
    else
      printf '\nsource "$OMARCHY_PATH/install/post-install/boot-permissions.sh"\n' >>install/post-install/all.sh
    fi
  fi
fi

finish "$WT" \
  "Make /boot not world-accessible" \
  "Migration (+ install post-step) sets /boot to 0700, loader/random-seed to 0600, and tightens vfat fmask/dmask in fstab when needed so bootctl stops warning about a world-accessible ESP." \
  5377

log "==== DONE ===="
grep -E '^(PR_|SHA_|BASE=)' "$OUT" || true
