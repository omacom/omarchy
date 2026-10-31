#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/project dir" "$test_tmp/notes"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
printf '{"class":"%s","title":"%s"}\n' "$ACTIVE_CLASS" "$ACTIVE_TITLE"
SH

# Two Files windows, one of them on its second tab, as Nautilus publishes them.
cat >"$stub_bin/busctl" <<SH
#!/bin/bash
printf '%s\n' '{"type":"a{sas}","data":{"/org/gnome/Nautilus/window/1":["file://$test_tmp/notes","recent:///"],"/org/gnome/Nautilus/window/2":["file://$test_tmp/project%20dir"]}}'
SH
chmod +x "$stub_bin/hyprctl" "$stub_bin/busctl"

nautilus_cwd() {
  ACTIVE_CLASS="$1" ACTIVE_TITLE="$2" HOME="$test_tmp" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-cmd-nautilus-cwd"
}

folder=$(nautilus_cwd org.gnome.Nautilus "project dir")
[[ $folder == "$test_tmp/project dir" ]] || fail "the focused Files window's folder is found by its title" "got: $folder"
pass "the focused Files window's folder is found by its title, with its URI decoded"

folder=$(nautilus_cwd org.gnome.Nautilus "notes")
[[ $folder == "$test_tmp/notes" ]] || fail "a folder open in another tab is matched too" "got: $folder"
pass "a folder open in another tab is matched too"

if folder=$(nautilus_cwd org.gnome.Nautilus "Recent"); then
  fail "a non-folder location gives no folder" "got: $folder"
fi
pass "a non-folder location gives no folder"

if folder=$(nautilus_cwd foot "notes"); then
  fail "a window other than Files gives no folder" "got: $folder"
fi
pass "a window other than Files gives no folder, so the editor opens as before"
