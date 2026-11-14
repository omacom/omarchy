#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq

copied_url=$(bash -c '
  source "$1"
  wl-copy() { cat; }
  omarchy-notification-send() { :; }
  copy_url "$2"
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" 'https://example.test/path?q=one&name=two')

[[ $copied_url == "https://example.test/path?q=one&name=two" ]] ||
  fail "copy-url native host writes the complete URL" "$copied_url"
pass "copy-url native host writes the complete URL"

native_reply=$(bash -c '
  source "$1"
  reply_copied true
' bash "$ROOT/bin/omarchy-chromium-copy-url-host" | od -An -v -tx1 | tr -d ' \n')

[[ $native_reply == "0f0000007b22636f70696564223a747275657d" ]] ||
  fail "copy-url native host returns a framed success response" "$native_reply"
pass "copy-url native host returns a framed success response"

# Exercise both real entrypoints: a complete JSON prefix of an incomplete
# frame must never copy a URL or start a detached downloader.
python3 - "$ROOT" <<'PY'
import json, os, pathlib, struct, subprocess, sys, tempfile
root = pathlib.Path(sys.argv[1])
with tempfile.TemporaryDirectory() as scratch:
  log = pathlib.Path(scratch) / "actions"
  env = dict(os.environ, OMARCHY_PATH=str(root), ACTION_LOG=str(log), NATIVE_TEST_PATH=os.environ["PATH"])
  script = '''source "$1"
PATH=$NATIVE_TEST_PATH
wl-copy() { cat >"$ACTION_LOG"; }
omarchy-notification-send() { :; }
setsid() { printf '%s\\n' "$*" >"$ACTION_LOG"; }
main'''
  payload = json.dumps({"url": "https://example.test/日本語"}, ensure_ascii=False).encode() + b"\n"
  invalid = [b"\x01\x00", struct.pack("<I", 0), struct.pack("<I", 1048577),
             struct.pack("<I", len(payload) + 1) + payload]
  for value in [123, True, ["https://example.test"], {"url": "https://example.test"}]:
    body = json.dumps({"url": value}).encode()
    invalid.append(struct.pack("<I", len(body)) + body)
  for name in ["copy-url", "ytdlp"]:
    command = ["bash", "-c", script, "bash", str(root / "bin" / f"omarchy-chromium-{name}-host")]
    for frame in invalid:
      log.unlink(missing_ok=True)
      result = subprocess.run(command, input=frame, env=env, capture_output=True, timeout=5)
      assert result.returncode == 0, result.stderr
      assert not log.exists(), (name, frame, log.read_text())
    result = subprocess.run(command, input=struct.pack("<I", len(payload)) + payload, env=env, capture_output=True, timeout=5)
    assert result.returncode == 0 and log.exists(), (name, result.stderr)
    assert "https://example.test/日本語" in log.read_text()
    log.unlink()
print("ok - both native hosts reject oversized, truncated and non-string requests and accept complete UTF-8 frames")
PY
