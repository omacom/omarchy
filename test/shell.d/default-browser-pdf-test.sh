#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/data/applications" "$test_tmp/system/applications" "$test_tmp/flatpak/exports/share/applications"

export HOME="$test_tmp/home"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_DATA_DIRS="$test_tmp/system:$test_tmp/flatpak/exports/share"
export OMARCHY_TEST_PDF_HANDLER_FILE="$test_tmp/pdf-handler"
export OMARCHY_TEST_XDG_MIME_LOG="$test_tmp/xdg-mime"

cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
case $1 in
query) [[ -f $OMARCHY_TEST_PDF_HANDLER_FILE ]] && cat "$OMARCHY_TEST_PDF_HANDLER_FILE" ;;
default) printf 'default %s %s\n' "$2" "$3" >>"$OMARCHY_TEST_XDG_MIME_LOG" ;;
esac
SH

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
SH

printf '#!/bin/bash\nexit 1\n' >"$mock_bin/omarchy-cmd-missing"
printf '#!/bin/bash\n' >"$mock_bin/omarchy-notification-send"
printf '#!/bin/bash\necho translated\n' >"$mock_bin/omarchy-i18n"
printf '#!/bin/bash\n' >"$mock_bin/omarchy-launch-floating-terminal-with-presentation"
chmod +x "$mock_bin"/*

export PATH="$mock_bin:$ROOT/bin:$PATH"

set_zen_as_browser() {
  : >"$OMARCHY_TEST_XDG_MIME_LOG"
  omarchy-default-browser zen
}

pdf_handed_to_zen() {
  grep -Fxq 'default zen.desktop application/pdf' "$OMARCHY_TEST_XDG_MIME_LOG" ||
    fail "$1" "xdg-mime calls: $(cat "$OMARCHY_TEST_XDG_MIME_LOG")"
}

# With no PDF handler set, the browser takes the type, as it did when nothing
# else could open a PDF.
rm -f "$OMARCHY_TEST_PDF_HANDLER_FILE"
set_zen_as_browser
pdf_handed_to_zen "a missing PDF handler is handed to the new browser"

# A browser that owned PDFs only because nothing else could, here a flatpak
# LibreWolf, loses the type to the new browser.
cat >"$test_tmp/flatpak/exports/share/applications/librewolf.desktop" <<'EOF'
[Desktop Entry]
Exec=librewolf %U
MimeType=application/pdf;x-scheme-handler/http;x-scheme-handler/https;
EOF
printf 'librewolf.desktop\n' >"$OMARCHY_TEST_PDF_HANDLER_FILE"
set_zen_as_browser
pdf_handed_to_zen "a PDF handler that is a browser is replaced"

# An installed viewer is the real PDF default and stays.
cat >"$test_tmp/system/applications/org.gnome.Evince.desktop" <<'EOF'
[Desktop Entry]
Exec=evince %U
MimeType=application/pdf;
EOF
printf 'org.gnome.Evince.desktop\n' >"$OMARCHY_TEST_PDF_HANDLER_FILE"
set_zen_as_browser
[[ ! -s $OMARCHY_TEST_XDG_MIME_LOG ]] ||
  fail "an installed PDF viewer keeps the type" "xdg-mime calls: $(cat "$OMARCHY_TEST_XDG_MIME_LOG")"
pass "an installed PDF viewer keeps the type"

# A viewer in an applications subdirectory is found by its desktop ID, where
# kde-viewer.desktop names applications/kde/viewer.desktop, and stays.
mkdir -p "$test_tmp/system/applications/kde"
cat >"$test_tmp/system/applications/kde/viewer.desktop" <<'EOF'
[Desktop Entry]
Exec=viewer %U
MimeType=application/pdf;
EOF
printf 'kde-viewer.desktop\n' >"$OMARCHY_TEST_PDF_HANDLER_FILE"
set_zen_as_browser
[[ ! -s $OMARCHY_TEST_XDG_MIME_LOG ]] ||
  fail "a PDF viewer in an applications subdirectory keeps the type" "xdg-mime calls: $(cat "$OMARCHY_TEST_XDG_MIME_LOG")"
pass "a PDF viewer in an applications subdirectory keeps the type"

# A handler named in mimeapps.list whose entry is gone no longer holds the type.
printf 'gone.desktop\n' >"$OMARCHY_TEST_PDF_HANDLER_FILE"
set_zen_as_browser
pdf_handed_to_zen "a PDF handler without an installed entry is replaced"

pass "setting the browser claims application/pdf unless a viewer keeps it"
