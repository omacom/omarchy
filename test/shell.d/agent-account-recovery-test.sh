#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

test_tmp=$(mktemp -d)
login_pid=""
trap '[[ -n $login_pid ]] && kill "$login_pid" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/home/.claude" "$test_tmp/bin" "$test_tmp/runtime"
export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/state"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
export OMARCHY_PATH="$ROOT"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
unset CLAUDE_CONFIG_DIR CODEX_HOME GROK_HOME

STATE="$ROOT/bin/omarchy-agent-account-state" python3 - <<'PY'
import importlib.machinery, importlib.util, json, os, subprocess, sys
from pathlib import Path

loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)

def signed_in(home, uuid, email):
  (home / ".claude.json").write_text(json.dumps({"oauthAccount": {"accountUuid": uuid, "emailAddress": email}}))
  (home / ".credentials.json").write_text(json.dumps({"claudeAiOauth": {"accessToken": "test-token", "subscriptionType": "max"}}))

(Path.home() / ".claude.json").write_text(json.dumps({"oauthAccount": {"accountUuid": "main", "emailAddress": "main@example.com"}}))

# A completed login whose parent disappeared is recovered with its label.
pending = state.begin("claude", "Interrupted", 999999999)
signed_in(pending, "interrupted", "interrupted@example.com")
state.refresh("claude")
account = state.find(state.load("claude"), "interrupted")
assert account and account["email"] == "interrupted@example.com"
assert not pending.exists()
assert not (Path(account["home"]) / state.LOGIN_RECEIPT).exists()
assert state.recover("claude") == [], "recovery is idempotent"

# A still-running add must keep ownership, even after credentials arrive.
pending = state.begin("claude", "Live", os.getpid())
signed_in(pending, "live", "live@example.com")
assert state.recover("claude") == []
assert pending.exists()
assert state.find(state.load("claude"), "live") is None
import shutil
shutil.rmtree(pending)

# Identity can be written before the credentials. Do not prematurely add it.
pending = state.begin("claude", "Incomplete")
(pending / ".claude.json").write_text(json.dumps({"oauthAccount": {"accountUuid": "incomplete"}}))
assert state.recover("claude") == []
assert pending.exists()
try:
  state.register("claude", "Incomplete", pending)
except state.AccountError:
  pass
else:
  raise AssertionError("identity without credentials must not register")
assert not pending.exists()

# A storage error preserves a completed login; a later refresh retries it.
pending = state.begin("claude", "Storage failure")
signed_in(pending, "storage", "storage@example.com")
original_save = state.save
def broken_save(provider, registry):
  raise OSError("disk full")
state.save = broken_save
try:
  state.register("claude", "Storage failure", pending)
except OSError:
  pass
else:
  raise AssertionError("expected a registry write failure")
assert pending.exists() and (pending / ".credentials.json").exists()
assert (pending / state.LOGIN_RECEIPT).exists()
state.save = original_save
state.refresh("claude")
assert state.find(state.load("claude"), "storage-failure")["email"] == "storage@example.com"

# Ctrl-C rolls a moved login back so the add command can cancel it.
pending = state.begin("claude", "Cancelled")
signed_in(pending, "cancelled", "cancelled@example.com")
def interrupted_save(provider, registry):
  raise KeyboardInterrupt()
state.save = interrupted_save
try:
  state.register("claude", "Cancelled", pending)
except KeyboardInterrupt:
  pass
else:
  raise AssertionError("expected interruption")
state.save = original_save
assert pending.exists()
assert not (state.accounts_root() / "claude" / "cancelled").exists()
shutil.rmtree(pending)
assert state.recover("claude") == []

# Abrupt process death cannot run rollback. Kill a subprocess at the write
# boundary to leave the moved home exactly as it would be after a crash.
def crash_register(label, uuid):
  pending = state.begin("claude", label)
  signed_in(pending, uuid, uuid + "@example.com")
  code = """
import importlib.machinery, importlib.util, os, sys
loader = importlib.machinery.SourceFileLoader("state", os.environ["STATE"])
spec = importlib.util.spec_from_loader(loader.name, loader)
state = importlib.util.module_from_spec(spec)
loader.exec_module(state)
def crash(provider, registry):
  os._exit(77)
state.save = crash
state.register("claude", sys.argv[1], state.Path(sys.argv[2]))
"""
  result = subprocess.run([sys.executable, "-c", code, label, str(pending)])
  assert result.returncode == 77
  assert not pending.exists()
  return state.accounts_root() / "claude" / state.slug(label)

home = crash_register("Moved", "moved")
state.refresh("claude")
assert state.find(state.load("claude"), "moved")["email"] == "moved@example.com"
assert state.recover("claude") == []

# A retry may have already added the same login under another home.
home = crash_register("Conflict", "conflict")
pending = state.begin("claude", "Conflict")
signed_in(pending, "conflict", "conflict@example.com")
entry = state.register("claude", "Conflict", pending)
assert entry["id"] == "conflict-2"
assert state.recover("claude") == []
assert not home.exists()
assert state.find(state.load("claude"), "conflict-2") is not None

# A committed account with a leftover receipt can be renamed safely.
entry = state.find(state.load("claude"), "moved")
home = state.Path(entry["home"])
state.write_receipt(home, {"entry": entry})
state.rename("claude", "moved", "Renamed moved")
assert state.recover("claude") == []
assert not (home / state.LOGIN_RECEIPT).exists()
assert state.find(state.load("claude"), "renamed-moved") is not None

# Recheck under the lock: a home removed while recovery waits stays removed.
home = crash_register("Removed", "removed")
original_enter = state.Locked.__enter__
def removed_while_waiting(lock):
  shutil.rmtree(home)
  state.Locked.__enter__ = original_enter
  return original_enter(lock)
state.Locked.__enter__ = removed_while_waiting
assert state.recover("claude") == []
assert state.find(state.load("claude"), "removed") is None

# A failed candidate must not stop the next completed login from recovering.
pending = state.begin("claude", "Fail one")
signed_in(pending, "fail-one", "fail-one@example.com")
other = state.begin("claude", "Other")
signed_in(other, "other", "other@example.com")
def fail_one(provider, registry):
  if state.find(registry, "fail-one"):
    raise OSError("disk full")
  original_save(provider, registry)
state.save = fail_one
recovered = state.recover("claude")
assert [a["id"] for a in recovered] == ["other"]
assert pending.exists()
state.save = original_save
state.refresh("claude")
assert state.find(state.load("claude"), "fail-one") is not None

# Recovery uses the same duplicate check as an ordinary add.
pending = state.begin("claude", "Duplicate")
signed_in(pending, "interrupted", "interrupted@example.com")
assert state.recover("claude") == []
assert not pending.exists()

# Leave a completed login for the real add command to recover below.
pending = state.begin("claude", "Retry")
signed_in(pending, "retry", "retry@example.com")
PY
pass "refresh recovers interrupted sign-ins and failed writes without taking over live logins"

cat >"$test_tmp/bin/omarchy-agent-usage-update" <<'SH'
#!/bin/bash
SH
cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
SH
cat >"$test_tmp/bin/claude" <<'SH'
#!/bin/bash
echo "unexpected browser login" >&2
exit 99
SH
chmod +x "$test_tmp/bin"/*

output=$(omarchy-agent-account-add --events claude Retry </dev/null)
[[ $output == "@@omarchy done Added Retry (retry@example.com)." ]] || fail "retry adds the saved sign-in without another browser login" "$output"
pass "retry adds the saved sign-in without another browser login"

# Kill the actual add process after the CLI saves credentials, while the
# CLI itself is still alive. Recovery waits until that child also exits.
cat >"$test_tmp/bin/claude" <<'SH'
#!/bin/bash
printf '{"oauthAccount":{"accountUuid":"killed","emailAddress":"killed@example.com"}}' >"$CLAUDE_CONFIG_DIR/.claude.json"
printf '{"claudeAiOauth":{"accessToken":"test-token"}}' >"$CLAUDE_CONFIG_DIR/.credentials.json"
echo $$ >"$OMARCHY_TEST_LOGIN_PID"
exec sleep 30
SH
OMARCHY_TEST_LOGIN_PID="$test_tmp/login.pid" omarchy-agent-account-add --events claude Killed </dev/null >"$test_tmp/killed-output" 2>&1 &
adding=$!
for _ in {1..50}; do
  [[ -s $test_tmp/login.pid ]] && break
  sleep 0.05
done
[[ -s $test_tmp/login.pid ]] || fail "the login reached credential save"
login_pid=$(cat "$test_tmp/login.pid")
kill -KILL "$adding"
wait "$adding" 2>/dev/null || true
[[ $(omarchy-agent-account-state recover claude) == "[]" ]] || fail "recovery waits for the surviving CLI"
kill "$login_pid"
for _ in {1..50}; do
  kill -0 "$login_pid" 2>/dev/null || break
  sleep 0.05
done
login_pid=""
omarchy-agent-account-state refresh
[[ $(omarchy-agent-account-list claude --json | jq -r '.[0].accounts[] | select(.id == "killed") | .email') == "killed@example.com" ]] || fail "refresh recovers a completed login after the add process is killed"
pass "refresh recovers a completed login after the add process is killed"

# A browser helper that cannot be created must stop before launching login.
cat >"$test_tmp/bin/claude" <<'SH'
#!/bin/bash
echo "unexpected browser login" >&2
exit 99
SH
export XDG_RUNTIME_DIR="$test_tmp/missing"
if output=$(omarchy-agent-account-add --events claude Browser </dev/null 2>&1); then
  fail "a private browser setup failure stops the add"
fi
[[ $output == *"@@omarchy error"* && $output != *"unexpected browser login"* ]] || fail "private browser setup fails visibly before login" "$output"
pass "private browser setup fails visibly before login"
