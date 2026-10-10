#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command node

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Refresh the real registry, run the real per-account collectors, then feed
# their records to the reset model. Only provider network calls are stubbed.
python3 - "$ROOT" "$test_tmp" <<'PY'
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import sys
from unittest.mock import patch

root, temporary = map(Path, sys.argv[1:])
os.environ.update(HOME=str(temporary / "home"), XDG_STATE_HOME=str(temporary / "state"))

def load(name):
  loader = importlib.machinery.SourceFileLoader(name, str(root / "bin" / name))
  spec = importlib.util.spec_from_loader(loader.name, loader)
  module = importlib.util.module_from_spec(spec)
  loader.exec_module(module)
  return module

registry = load("omarchy-agent-account-state")
collectors = {provider: load("omarchy-agent-usage-" + provider) for provider in ["codex", "claude"]}
limits = [{"label": "weekly", "resetsAt": "2030-01-01T00:10:00Z"}]
collectors["codex"].fetch_codex_rpc = lambda *args: dict(limits=limits, tierLabel="", usageStatusText="", authHelpText="")
collectors["claude"].oauth_login = lambda *args: ("", 0, 0, "")
collectors["claude"].collect_limits = lambda *args: dict(limits=limits, live=False, fetchedAtMs=0, usageStatusText="", authHelpText="")

traces = []
for provider, collector in collectors.items():
  home = registry.primary_home(provider)
  home.mkdir(parents=True, exist_ok=True)
  path = registry.claude_account_file(home) if provider == "claude" else home / "auth.json"
  def credentials(identity):
    return {"oauthAccount": {"accountUuid": identity}} if provider == "claude" else {"tokens": {"account_id": identity}}
  path.write_text(json.dumps(credentials("original")))
  data = registry.empty_registry(provider)
  data["accounts"] = [registry.primary_entry(provider), {"id": "other", "label": "Other", "home": str(temporary / provider), "accountId": ""}]
  registry.save(provider, data)
  def record():
    registry.refresh(provider)
    accounts = collector.registered_accounts()["accounts"]
    if provider == "claude":
      values = [collector.account_limits(a, True) for a in accounts]
    else:
      values = [collector.account_limits(a) for a in accounts]
    return dict(id=provider, name=provider, accountRegistryStatus="available", accounts=values)
  original = record()
  for failure in ["permission", "truncated", "invalid-shape", "invalid-account-shape"]:
    path.write_text(json.dumps(credentials("original")))
    registry.refresh(provider)
    read_text = Path.read_text
    def unreadable(current, *args, **kwargs):
      if current == path:
        raise PermissionError("simulated temporary identity read failure")
      return read_text(current, *args, **kwargs)
    if failure == "permission":
      with patch.object(Path, "read_text", unreadable):
        unavailable = record()
    else:
      if failure == "truncated": path.write_text('{')
      elif failure == "invalid-shape": path.write_text('[]')
      else: path.write_text(json.dumps({"oauthAccount" if provider == "claude" else "tokens": []}))
      unavailable = record()
    traces.append(dict(provider=provider, failure=failure, original=original, unavailable=unavailable))
  path.write_text(json.dumps(credentials("replacement")))
  replacement = record()
  path.write_text('{}')
  cleared = record()
  path.write_text(json.dumps(credentials("original")))
  registry.refresh(provider)
  path.unlink()
  missing = record()
  traces.append(dict(provider=provider, original=original, replacement=replacement, cleared=cleared, missing=missing))
(temporary / "traces.json").write_text(json.dumps(traces))
PY

export OMARCHY_IDENTITY_TRACES="$test_tmp/traces.json"
run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/agents/LimitResetModel.js')
const traces = JSON.parse(fs.readFileSync(process.env.OMARCHY_IDENTITY_TRACES, 'utf8'))
const now = Date.parse('2030-01-01T00:00:00Z')
const due = Date.parse('2030-01-01T00:11:00Z')
const enabled = () => true
for (const trace of traces) {
  const pending = model.schedule({}, [trace.original], now, true, enabled)
  assertEqual(Object.keys(pending).length, 1, `${trace.provider} queues the original subscription deadline`)
  if (trace.failure) {
    const next = model.schedule(pending, [trace.unavailable], due, true, enabled)
    assertEqual(trace.unavailable.accounts[0].accountId, 'original', `${trace.provider} ${trace.failure} retains the last known identity`)
    const result = model.announce(next, due, true, enabled)
    assertEqual(result.notifications.length, 1, `${trace.provider} ${trace.failure} still announces a reset due during the read failure`)
    assertEqual(model.announce(result.pending, due, true, enabled).notifications.length, 0, `${trace.provider} ${trace.failure} announces only once`)
  } else {
    for (const state of ['replacement', 'cleared', 'missing']) {
      const next = model.schedule(pending, [trace[state]], due, true, enabled)
      assertEqual(model.announce(next, due, true, enabled).notifications.length, 0, `${trace.provider} ${state} retires the original subscription deadline`)
    }
  }
}
JS
