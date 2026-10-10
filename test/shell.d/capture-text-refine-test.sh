#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# capture-text-refine contract tests: the helper is the seam between the stock
# tesseract pass and an optional refine service, so its pass-through and
# rejection behavior is what keeps a broken endpoint from degrading the
# keybind. The endpoint is stubbed (real HTTP server on a scratch port); the
# helper runs unmodified.

require_command curl
require_command python3

TMPDIR=$(mktemp -d)
trap cleanup EXIT
SERVER_PID=""
cleanup() {
  [[ -n $SERVER_PID ]] && kill "$SERVER_PID" 2>/dev/null || true
  rm -rf "$TMPDIR"
}

# Redirect background-server output and clean up on exit (conventions doc).
LOG="$TMPDIR/server-log"

start_server() {
  local mode="$1" port_file="$TMPDIR/port"
  rm -f "$port_file"   # a stale port file from the previous stub would win the readiness race

  (
    python3 - "$mode" "$port_file" <<'PY' >>"$LOG" 2>&1
import json, sys, time
from http.server import BaseHTTPRequestHandler, HTTPServer

mode, port_file = sys.argv[1], sys.argv[2]

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(n)
        try:
            parsed = json.loads(body)
        except Exception:
            parsed = {}
        if mode == "clean-json":
            out = json.dumps({"text": parsed.get("text", "").replace("teh", "the")}).encode()
            self.send_response(200)
        elif mode == "clean-raw":
            out = parsed.get("text", "").replace("teh", "the").encode()
            self.send_response(200)
            # Documented raw contract: a plain text answer, not JSON.
            self.send_header("Content-Type", "text/plain")
        elif mode == "error-json":
            out = json.dumps({"text": "Service unavailable"}).encode()
            self.send_response(503)
        elif mode == "bool":
            out = json.dumps({"text": True}).encode()
            self.send_response(200)
        elif mode == "redirect":
            # Nonempty HTML body: the old helper (pre-status-gate) printed it
            # verbatim, so this stub must actually serve it to catch that.
            out = b"<html><body>301 Moved</body></html>"
            self.send_response(302)
            self.send_header("Location", "http://example.invalid/new")
        elif mode == "hang":
            time.sleep(30)
            out = b"{}"
            self.send_response(200)
        elif mode == "auth":
            # Record the exact Authorization header; only the right one refines.
            auth = self.headers.get("Authorization", "")
            out = (json.dumps({"text": "AUTH=" + auth}).encode()
                   if auth == "Bearer test-key-123" else b"{}")
            self.send_response(200 if auth == "Bearer test-key-123" else 401)
        else:
            out = b"{}"
            self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(out)

    def log_message(self, *args):
        pass

srv = HTTPServer(("127.0.0.1", 0), Handler)
with open(port_file, "w") as f:
    f.write(str(srv.server_address[1]))
srv.serve_forever()
PY
  ) &
  SERVER_PID=$!

  local attempt
  for attempt in $(seq 1 50); do
    [[ -s $port_file ]] && break
    sleep 0.1
  done
  [[ -s $port_file ]] || fail "stub refine server started"
}

stop_server() {
  kill "$SERVER_PID" 2>/dev/null || true
  wait "$SERVER_PID" 2>/dev/null || true
  SERVER_PID=""
}

run_helper() {
  # env assignments come from the caller; text arrives on stdin
  PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-capture-text-refine"
}

# ── unset URL: silent no-op pass-through ─────────────────────
out=$(printf 'teh raw' | run_helper)
[[ -z $out ]] || fail "unset OMARCHY_OCR_REFINE_URL keeps the raw text (got $out)"
pass "unset OMARCHY_OCR_REFINE_URL is a silent no-op"

# ── empty stdin with URL set: silent no-op ───────────────────
out=$(printf '' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:1/x" run_helper)
[[ -z $out ]] || fail "empty stdin yields no refined text (got $out)"
pass "empty stdin yields no refined text"

# ── live endpoint, JSON contract: refinement applied ─────────
start_server "clean-json"
port=$(cat "$TMPDIR/port")
out=$(printf 'teh screenshot text' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" run_helper)
[[ $out == "the screenshot text" ]] || fail "JSON contract answer replaces the raw text (got $out)"
pass "JSON contract answer replaces the raw text"

# ── live endpoint, raw text answer (documented contract) ─────
stop_server
start_server "clean-raw"
port=$(cat "$TMPDIR/port")
out=$(printf 'teh raw body answer' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" run_helper)
[[ $out == "the raw body answer" ]] || fail "raw text answer replaces the raw text (got $out)"
pass "raw text answer replaces the raw text"

# ── HTTP 503 error body: rejected, raw text kept ─────────────
stop_server
start_server "error-json"
port=$(cat "$TMPDIR/port")
out=$(printf 'teh raw' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" run_helper)
[[ -z $out ]] || fail "an HTTP error body never becomes refined text (got $out)"
pass "HTTP error body is rejected, raw text kept"

# ── redirect: rejected, raw text kept ────────────────────────
stop_server
start_server "redirect"
port=$(cat "$TMPDIR/port")
out=$(printf 'teh raw' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" run_helper)
[[ -z $out ]] || fail "a redirect page never becomes refined text (got $out)"
pass "redirect answer is rejected, raw text kept"

# ── non-string answer: rejected ──────────────────────────────
stop_server
start_server "bool"
port=$(cat "$TMPDIR/port")
out=$(printf 'teh raw' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" run_helper)
[[ -z $out ]] || fail "a non-string text answer never becomes refined text (got $out)"
pass "non-string text answer is rejected"

# ── bearer key: sent verbatim, wrong/missing key rejected ────
stop_server
start_server "auth"
port=$(cat "$TMPDIR/port")
out=$(printf 'teh authed' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" \
  OMARCHY_OCR_REFINE_KEY="test-key-123" run_helper)
[[ $out == "AUTH=Bearer test-key-123" ]] ||
  fail "the Authorization header must arrive exactly as Bearer <key> (got $out)"
pass "bearer key is sent verbatim (Authorization: Bearer <key>)"

out=$(printf 'teh wrong' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" \
  OMARCHY_OCR_REFINE_KEY="wrong-key" run_helper)
[[ -z $out ]] || fail "a wrong key (401) must degrade to raw text (got $out)"
pass "401 on wrong key degrades to raw text"

out=$(printf 'teh nokey' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" run_helper)
[[ -z $out ]] || fail "a missing key (401) must degrade to raw text (got $out)"
pass "401 on missing key degrades to raw text"

stop_server

# ── timeout: a hung endpoint cannot hang the keypress ────────
start_server "hang"
port=$(cat "$TMPDIR/port")
t0=$SECONDS
out=$(printf 'teh hung' | OMARCHY_OCR_REFINE_URL="http://127.0.0.1:$port/x" \
  OMARCHY_OCR_REFINE_TIMEOUT="2" run_helper)
rc=$?
elapsed=$(( SECONDS - t0 ))
[[ $rc == 0 && -z $out ]] || fail "a hung endpoint degrades silently (rc $rc, out $out)"
(( elapsed <= 10 )) || fail "timeout bounds the wait (took ${elapsed}s)"
pass "hung endpoint times out and degrades silently"

stop_server

# ── capture-text composition: text via stdin, never argv ─────
grep -F 'omarchy-capture-text-refine' "$ROOT/bin/omarchy-capture-text" >/dev/null &&
  ! grep -F 'omarchy-capture-text-refine "$' "$ROOT/bin/omarchy-capture-text" >/dev/null ||
  fail "capture-text pipes the screenshot text into the helper (never as an argument)"
pass "capture-text pipes the screenshot text into the helper (never as an argument)"

grep -F 'wl-copy 9>&- >/dev/null 2>&1' "$ROOT/bin/omarchy-capture-text" >/dev/null ||
  fail "capture-text detaches wl-copy so pipe-waiting callers never hang"
pass "capture-text detaches wl-copy"

exit 0
