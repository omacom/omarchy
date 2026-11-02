#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
releases="$test_tmp/releases"
export TEST_LOG="$test_tmp/log"
export TEST_RELEASES="$releases"
mkdir -p "$mock_bin" "$releases"

# A stand-in AppImage that extracts upstream's desktop entry and icons the
# way the real runtime does: into squashfs-root under the working directory.
make_appimage() {
  cat >"$1" <<SH
#!/bin/bash
# build $2
[[ \$1 == "--appimage-extract" ]] || exit 1
case \$2 in
t3code.desktop)
  mkdir -p squashfs-root
  printf '%s\n' '[Desktop Entry]' 'Name=T3 Code (Beta)' 'Exec=AppRun %U' 'Terminal=false' 'Type=Application' \
    'Icon=t3code' 'StartupWMClass=t3code' 'X-AppImage-Version=$2' 'MimeType=x-scheme-handler/t3code;' >squashfs-root/t3code.desktop
  ;;
'usr/share/icons/hicolor/*/apps/t3code.png')
  for size in 256x256 512x512; do
    mkdir -p "squashfs-root/usr/share/icons/hicolor/\$size/apps"
    echo "icon \$size" >"squashfs-root/usr/share/icons/hicolor/\$size/apps/t3code.png"
  done
  ;;
*) exit 1 ;;
esac
SH
}

# Serves a release: its AppImage and the updater feed that names it.
publish() {
  local tag=$1 version=$2 feed=$3 file=$4 sha512
  mkdir -p "$releases/download/$tag"
  make_appimage "$releases/download/$tag/$file" "$version"
  sha512=$(openssl dgst -sha512 -binary "$releases/download/$tag/$file" | base64 -w0)
  [[ ${5:-} == "corrupt" ]] && sha512="bm90IHRoZSByaWdodCBjaGVja3N1bQ=="
  printf '%s\n' "version: $version" "files:" "  - url: $file" "    sha512: unused" "path: $file" "sha512: $sha512" \
    "releaseDate: '2026-10-18T00:00:00.000Z'" >"$releases/download/$tag/$feed"
}

publish v0.2.0 0.2.0 latest-linux.yml T3-Code-0.2.0-x86_64.AppImage
publish v0.2.0 0.2.0 latest-linux-arm64.yml T3-Code-0.2.0-arm64.AppImage
publish v0.2.1-nightly.20261018.9 0.2.1-nightly.20261018.9 nightly-linux.yml T3-Code-0.2.1-nightly.20261018.9-x86_64.AppImage
mkdir -p "$releases/latest/download"
cp "$releases/download/v0.2.0/latest-linux.yml" "$releases/download/v0.2.0/latest-linux-arm64.yml" "$releases/latest/download/"
# Newest first, as GitHub lists them: a draft and a preview come before the nightly to install.
jq -n '[
  {tag_name: "v0.2.2-nightly.20261019.1", draft: true},
  {tag_name: "v0.2.1-preview.20261018.10", draft: false},
  {tag_name: "v0.2.1-nightly.20261018.9", draft: false},
  {tag_name: "v0.2.0", draft: false}
]' >"$releases/index.json"

cat >"$mock_bin/curl" <<'SH'
#!/bin/bash
url="" output=""
while (($#)); do
  case $1 in
  -o) output=$2; shift ;;
  https://*) url=$1 ;;
  esac
  shift
done
echo "curl:$url" >>"$TEST_LOG"
case $url in
"https://api.github.com/repos/pingdotgg/t3code/releases?per_page=100") source="$TEST_RELEASES/index.json" ;;
https://github.com/pingdotgg/t3code/releases/*) source="$TEST_RELEASES/${url#https://github.com/pingdotgg/t3code/releases/}" ;;
*) exit 22 ;;
esac
[[ -f $source ]] || exit 22
if [[ -n $output ]]; then cp "$source" "$output"; else cat "$source"; fi
SH

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "add:$*" >>"$TEST_LOG"
SH
cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
echo "drop:$*" >>"$TEST_LOG"
SH
cat >"$mock_bin/omarchy-hw-aarch64" <<'SH'
#!/bin/bash
[[ ${TEST_AARCH64:-0} == "1" ]]
SH
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/gtk-update-icon-cache"
cat >"$mock_bin/update-desktop-database" <<'SH'
#!/bin/bash
[[ ${TEST_FAIL_DESKTOP_DATABASE:-0} != "1" ]]
SH
chmod +x "$mock_bin"/*

fresh_home() {
  rm -rf "$test_tmp/home"
  mkdir -p "$test_tmp/home"
  : >"$TEST_LOG"
}

install_app() {
  HOME="$test_tmp/home" T3CODE_HOME="$test_tmp/home/.t3" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-install-t3code-app" "$@" >"$test_tmp/output" 2>&1
}

home="$test_tmp/home"
appimage="$home/.local/share/t3code/T3-Code.AppImage"
desktop="$home/.local/share/applications/t3code.desktop"

fresh_home
install_app stable || fail "a stable install succeeds" "$(cat "$test_tmp/output")"
cmp -s "$appimage" "$releases/download/v0.2.0/T3-Code-0.2.0-x86_64.AppImage" || fail "the stable AppImage is installed"
[[ -x $appimage ]] || fail "the AppImage is executable"
grep -qx 'add:fuse3' "$TEST_LOG" || fail "FUSE is installed for the AppImage runtime"
! grep -q '^drop' "$TEST_LOG" || fail "the packages stay until T3 Code is themed"
pass "a stable install puts the latest stable AppImage in place and leaves the packages to its installer"

grep -qx "Exec=\"$appimage\" %U" "$desktop" || fail "the launcher runs the AppImage" "$(cat "$desktop")"
grep -qx "TryExec=$appimage" "$desktop" || fail "the launcher hides once the AppImage is gone"
grep -qx 'Name=T3 Code' "$desktop" || fail "the launcher is named T3 Code"
grep -qx 'MimeType=x-scheme-handler/t3code;' "$desktop" || fail "the launcher keeps upstream's link handler"
grep -qx 'StartupWMClass=t3code' "$desktop" || fail "the launcher matches the app's windows"
! grep -q '^X-AppImage-Version=' "$desktop" || fail "the launcher drops the pinned AppImage version"
[[ -f $home/.local/share/icons/hicolor/512x512/apps/t3code.png ]] || fail "the app's icons are installed"
pass "the launcher entry and icons come from upstream's entry in the AppImage"

[[ $(readlink "$home/.local/bin/t3") == "$home/.t3/bin/t3" ]] || fail "t3 links to the launcher the app writes"
pass "t3 on PATH links to the app's own launcher"

fresh_home
install_app nightly || fail "a nightly install succeeds" "$(cat "$test_tmp/output")"
cmp -s "$appimage" "$releases/download/v0.2.1-nightly.20261018.9/T3-Code-0.2.1-nightly.20261018.9-x86_64.AppImage" ||
  fail "the newest published nightly is installed, not a draft or a preview"
grep -qx 'Name=T3 Code (Nightly)' "$desktop" || fail "the nightly launcher says so"
pass "a nightly install takes the newest published nightly"

fresh_home
TEST_AARCH64=1 install_app stable || fail "an ARM install succeeds" "$(cat "$test_tmp/output")"
cmp -s "$appimage" "$releases/download/v0.2.0/T3-Code-0.2.0-arm64.AppImage" || fail "ARM machines get the arm64 AppImage"
pass "ARM machines install from the arm64 feed"

# A download that fails its checksum must not replace a working install.
fresh_home
mkdir -p "$(dirname "$appimage")"
echo "previous build" >"$appimage"
chmod +x "$appimage"
publish v0.2.0 0.2.0 latest-linux.yml T3-Code-0.2.0-x86_64.AppImage corrupt
cp "$releases/download/v0.2.0/latest-linux.yml" "$releases/latest/download/"
if install_app stable; then
  fail "a checksum mismatch fails the install"
fi
grep -q 'does not match its release checksum' "$test_tmp/output" || fail "the mismatch is reported"
[[ $(cat "$appimage") == "previous build" ]] || fail "the installed AppImage is kept"
[[ -z $(find "$home/.local/share/t3code" -name '.*download*') ]] || fail "the rejected download is removed"
pass "a download that fails its checksum leaves the existing install alone"
publish v0.2.0 0.2.0 latest-linux.yml T3-Code-0.2.0-x86_64.AppImage
cp "$releases/download/v0.2.0/latest-linux.yml" "$releases/latest/download/"

# The Install menu reads an installed AppImage as a finished
# install, so a setup that stops partway must not leave one behind.
fresh_home
if TEST_FAIL_DESKTOP_DATABASE=1 install_app stable; then
  fail "a failed launcher setup fails the install"
fi
[[ ! -e $appimage ]] || fail "the AppImage only lands once the launcher and t3 link are in place"
[[ -z $(find "$home/.local/share/t3code" -name '.*download*') ]] || fail "the unfinished download is removed"
install_app stable || fail "a retry after an unfinished setup succeeds" "$(cat "$test_tmp/output")"
[[ -x $appimage && -f $desktop ]] || fail "a retry finishes the install"
pass "an install that stops partway leaves no AppImage, so a retry finishes it"

# A desktop launcher expands %-field codes in Exec, so a literal % is doubled there.
percent_home="$test_tmp/home%20name"
mkdir -p "$percent_home"
HOME="$percent_home" T3CODE_HOME="$percent_home/.t3" PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-install-t3code-app" stable >"$test_tmp/output" 2>&1 ||
  fail "an install under a home with % in its path succeeds" "$(cat "$test_tmp/output")"
percent_desktop="$percent_home/.local/share/applications/t3code.desktop"
grep -qxF "Exec=\"$test_tmp/home%%20name/.local/share/t3code/T3-Code.AppImage\" %U" "$percent_desktop" ||
  fail "the launcher escapes % in the AppImage path" "$(cat "$percent_desktop")"
grep -qxF "TryExec=$percent_home/.local/share/t3code/T3-Code.AppImage" "$percent_desktop" ||
  fail "TryExec keeps the literal path"
pass "a % in the home path is escaped in the launcher's Exec"

fresh_home
mkdir -p "$home/.local/bin"
ln -s /usr/bin/t3-nightly "$home/.local/bin/t3"
install_app stable || fail "an install over a package's t3 link succeeds" "$(cat "$test_tmp/output")"
[[ $(readlink "$home/.local/bin/t3") == "$home/.t3/bin/t3" ]] || fail "a link to the package's t3 moves to the app's launcher"
pass "a t3 link to the package's launcher follows the app"

fresh_home
mkdir -p "$home/.local/bin"
echo "#!/bin/sh" >"$home/.local/bin/t3"
install_app stable || fail "an install next to the user's own t3 succeeds" "$(cat "$test_tmp/output")"
[[ ! -L $home/.local/bin/t3 && $(cat "$home/.local/bin/t3") == "#!/bin/sh" ]] || fail "the user's own t3 is left alone"
pass "the user's own t3 is left alone"

if install_app beta; then
  fail "an unknown channel is refused"
fi
pass "only the stable and nightly channels install"
