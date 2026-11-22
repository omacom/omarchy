#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

WORKDIR=$(mktemp -d)
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

downloads="$WORKDIR/downloads"
mkdir -p "$WORKDIR/bin" "$WORKDIR/notifications" "$downloads" "$WORKDIR/outbox"
printf 'mine' >"$downloads/unrelated.txt"

# Stands in for the daemon handing over whatever is waiting in the inbox. A
# decoy is whatever else drops into the downloads directory while Taildrop is
# still blocking on the next delivery.
cat >"$WORKDIR/bin/tailscale" <<SH
#!/bin/bash
target="\${*: -1}"
[[ -n \${DECOY:-} ]] && printf 'iso' >"$downloads/\$DECOY"
mv "$WORKDIR/outbox/"* "\$target/"
SH

cat >"$WORKDIR/bin/busctl" <<SH
#!/bin/bash
printf '%s\0' "\$@" >"\$(mktemp "$WORKDIR/notifications/call.XXXXXXXX")"
SH

chmod +x "$WORKDIR/bin/"*

receive() {
  local expected="$1"
  shift

  rm -f "$WORKDIR/notifications/"*
  OMARCHY_PATH="$ROOT" PATH="$WORKDIR/bin:$ROOT/bin:$PATH" "$@" "$ROOT/bin/omarchy-tailscale-receive" --once "$downloads"

  for _ in {1..50}; do
    (($(find "$WORKDIR/notifications" -type f | wc -l) >= expected)) && break
    sleep 0.1
  done
}

printf 'png' >"$WORKDIR/outbox/photo.png"
printf 'png' >"$WORKDIR/outbox/Vacation Photo.PNG"
printf 'pdf' >"$WORKDIR/outbox/notes with space.pdf"
receive 3 env

notification_files=("$WORKDIR/notifications/"*)
(( ${#notification_files[@]} == 3 )) || fail "taildrop receive announces each delivery once"

[[ -f $downloads/photo.png && -f "$downloads/Vacation Photo.PNG" && -f "$downloads/notes with space.pdf" ]] ||
  fail "taildrop receive saves incoming files" "$(ls "$downloads")"
pass "taildrop receive saves incoming files"

assert_notification() {
  local path=$1 name=${1##*/} file i key open_json='' open_index=-1 image_index=-1 urgency_found=false glyph='' image=''
  local headline=${2:-Received $name} body=${3:-Saved to $downloads}
  local -a args

  for file in "$WORKDIR/notifications/"*; do
    mapfile -d '' -t args <"$file"
    [[ ${args[11]} == "$headline" ]] || continue
    [[ ${args[10]} == '' && ${args[12]} == "$body" ]] ||
      fail "taildrop receive keeps the app icon empty and reports the save location" "$name: ${args[12]}"

    for ((i = 15; i < 15 + 3 * ${args[14]}; i += 3)); do
      key=${args[i]}
      case $key in
      urgency)
        urgency_found=true
        [[ ${args[i + 2]} == 2 ]] || fail "taildrop receive keeps critical urgency" "$name"
        ;;
      omarchy-glyph) glyph=${args[i + 2]} ;;
      image-path) image=${args[i + 2]}; image_index=$((i + 2)) ;;
      omarchy-exec-argv) open_json=${args[i + 2]}; open_index=$((i + 2)) ;;
      esac
    done

    $urgency_found || fail "taildrop receive sets an urgency" "$name"
    case ${name,,} in
    *.png)
      [[ $image == "$path" && $glyph == 󰒊 ]] || fail "taildrop receive previews images over the send glyph" "$name: image=$image glyph=$glyph"
      ;;
    *)
      [[ -z $image && $glyph == 󰒊 ]] || fail "taildrop receive gives other files the send glyph" "$name: image=$image glyph=$glyph"
      ;;
    esac
    [[ -n $open_json ]] && jq -e --arg path "$path" '. == ["xdg-open", $path]' <<<"$open_json" >/dev/null ||
      fail "taildrop receive keeps the literal click-to-open argv" "$name: $open_json"
    for ((i = 0; i < ${#args[@]}; i++)); do
      if [[ ${args[i]} == *"$path"* ]] && (( i != open_index && i != image_index )); then
        fail "taildrop receive exposes the file path only in the open argv and preview" "$name: ${args[i]}"
      fi
    done
    return 0
  done

  fail "taildrop receive announces the expected file" "$name"
}

assert_notification "$downloads/photo.png"
assert_notification "$downloads/Vacation Photo.PNG"
assert_notification "$downloads/notes with space.pdf"
pass "taildrop receive previews images over the send glyph and gives other files the glyph"
pass "taildrop receive keeps critical urgency and literal click-to-open paths"

[[ -f $downloads/unrelated.txt ]] || fail "taildrop receive leaves unrelated downloads alone"
pass "taildrop receive leaves the rest of the downloads directory alone"

# A second delivery of the same name, alongside a download that arrives while
# Taildrop is waiting.
printf 'png' >"$WORKDIR/outbox/photo.png"
receive 1 env DECOY=browser-download.iso

notification_files=("$WORKDIR/notifications/"*)

[[ -f $downloads/photo-1.png ]] || fail "taildrop receive keeps both files on a name clash" "$(ls "$downloads")"
(( ${#notification_files[@]} == 1 )) || fail "taildrop receive announces the collision once"
assert_notification "$downloads/photo-1.png"
pass "taildrop receive keeps both files on a name clash"

[[ -f $downloads/browser-download.iso ]] || fail "taildrop receive keeps the concurrent download"
pass "taildrop receive ignores downloads that arrive while it waits"

[[ -z $(ls -A "$downloads/.omarchy-taildrop") ]] ||
  fail "taildrop receive empties its staging directory" "$(ls -A "$downloads/.omarchy-taildrop")"
pass "taildrop receive empties its staging directory"

# Keep upstream's localized title and save location.
printf 'da\n' >"$WORKDIR/language"
printf 'png' >"$WORKDIR/outbox/Translated Image.png"
receive 1 env OMARCHY_LANGUAGE_FILE="$WORKDIR/language"
assert_notification "$downloads/Translated Image.png" "Modtaget Translated Image.png" "Gemt til $downloads"
pass "taildrop receive preserves localized notifications"

# A save location under HOME reads as ~, not the expanded path.
printf 'png' >"$WORKDIR/outbox/home.png"
receive 1 env HOME="$WORKDIR"
assert_notification "$downloads/home.png" "Received home.png" "Saved to ~/downloads"
pass "taildrop receive shortens a save location under HOME"
