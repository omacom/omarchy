#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TEST_DIR=$(mktemp -d)
cleanup() {
  if [[ -f $TEST_DIR/hyprpicker.pid ]]; then
    kill "$(cat "$TEST_DIR/hyprpicker.pid")" 2>/dev/null || true
  fi
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

export TEST_DIR
mkdir -p "$TEST_DIR/bin"

cat > "$TEST_DIR/bin/hyprpicker" <<'SH'
#!/bin/bash
echo "$$" > "$TEST_DIR/hyprpicker.pid"
exec sleep 60
SH

cat > "$TEST_DIR/bin/slurp" <<'SH'
#!/bin/bash
printf '0,0 100x100\n'
SH

cat > "$TEST_DIR/bin/grim" <<'SH'
#!/bin/bash
printf 'stub screenshot'
SH

cat > "$TEST_DIR/bin/tesseract" <<'SH'
#!/bin/bash
cat >/dev/null
cat "$TEST_DIR/ocr"
SH

cat > "$TEST_DIR/bin/wl-copy" <<'SH'
#!/bin/bash
printf '%s\n' "$#" > "$TEST_DIR/argc"
printf '%s\n' "$@" > "$TEST_DIR/args"
cat > "$TEST_DIR/copied"
SH

cat > "$TEST_DIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$TEST_DIR/bin/"*
printf '%s\n' '--type' 'text/plain;charset=utf-8' > "$TEST_DIR/expected-args"

for fixture in email json; do
  if [[ $fixture == "email" ]]; then
    printf 'From: sender@example.com\nTo: recipient@example.com\nSubject: OCR\n\nHello' > "$TEST_DIR/ocr"
  else
    printf '{"message": "Hello", "count": 2}' > "$TEST_DIR/ocr"
  fi

  PATH="$TEST_DIR/bin:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-capture-text"

  [[ $(cat "$TEST_DIR/argc") == "2" ]] || fail "$fixture OCR passes exactly two clipboard arguments"
  cmp -s "$TEST_DIR/expected-args" "$TEST_DIR/args" || fail "$fixture OCR requests UTF-8 plain text"
  cmp -s "$TEST_DIR/ocr" "$TEST_DIR/copied" || fail "$fixture OCR copies unchanged text"
  pass "$fixture OCR copies unchanged text as UTF-8 plain text"
done
