#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
racing_pids=()

cleanup() {
  if [[ -n ${race_state:-} && -d $race_state ]]; then
    touch "$race_state/release-first" "$race_state/release-second"
  fi

  for pid in "${racing_pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  rm -rf "$tmp"
}
trap cleanup EXIT

home="$tmp/home"
cache_home="$tmp/cache home"
user_themes="$home/.config/omarchy/themes"
omarchy_path="$tmp/omarchy"
stub_bin="$tmp/bin"
secret_dir="$home/private images"
secret_marker="H1-4113381-private-preview"

mkdir -p "$user_themes" "$omarchy_path/themes" "$stub_bin" "$secret_dir"
printf '%s\n' "$secret_marker" >"$secret_dir/private photo.png"
chmod 700 "$secret_dir"
chmod 600 "$secret_dir/private photo.png"

# This is the report's input: a repository-controlled preview points outside
# the theme at an unrelated private image owned by the same user.
mkdir -p "$user_themes/escaped-preview"
ln -s "$secret_dir/private photo.png" "$user_themes/escaped-preview/preview.png"

# The background fallback must apply the same boundary when a repository makes
# the whole backgrounds component a symlink.
mkdir -p "$user_themes/escaped-background"
ln -s "$secret_dir" "$user_themes/escaped-background/backgrounds"

# Internal symlinks remain useful for themes that keep their preview with their
# other artwork, including paths containing spaces.
mkdir -p "$user_themes/internal-preview/assets with spaces"
printf 'internal-preview\n' >"$user_themes/internal-preview/assets with spaces/source image.png"
ln -s "assets with spaces/source image.png" "$user_themes/internal-preview/preview.png"

# A top-level theme entry may itself be a symlink. Resolve that entry as the
# theme root, then keep its regular and internally linked media working.
linked_theme="$tmp/linked theme source"
mkdir -p "$linked_theme"
printf 'linked-theme\n' >"$linked_theme/preview.jpg"
ln -s "$linked_theme" "$user_themes/linked-theme"

mkdir -p "$user_themes/video-preview"
printf 'video-preview\n' >"$user_themes/video-preview/preview.mp4"

cat >"$stub_bin/omarchy-menu-images" <<'EOF'
#!/bin/bash

preview_dir=${!#}
exec "$ROOT/bin/omarchy-menu-images" --cache-only "$preview_dir"
EOF

cat >"$stub_bin/vipsthumbnail" <<'EOF'
#!/bin/bash

image=$1
shift
while (( $# > 0 )); do
  if [[ $1 == "--path" ]]; then
    output=${2%%\[*}
    break
  fi
  shift
done
cat -- "$image" >"$output"
EOF

cat >"$stub_bin/ffmpegthumbnailer" <<'EOF'
#!/bin/bash

while (( $# > 0 )); do
  case $1 in
    -i) image=$2; shift 2 ;;
    -o) output=$2; shift 2 ;;
    *) shift ;;
  esac
done
cat -- "$image" >"$output"
EOF
chmod +x "$stub_bin/omarchy-menu-images" "$stub_bin/vipsthumbnail" "$stub_bin/ffmpegthumbnailer"

# Recreate an existing cache from a vulnerable release. The fixed invocation
# must make its leaf directory private before reading or writing it.
mkdir -p "$cache_home/omarchy/theme-selector/previews" "$cache_home/omarchy/image-selector"
chmod 755 "$cache_home/omarchy/theme-selector" "$cache_home/omarchy/theme-selector/previews" \
  "$cache_home/omarchy/image-selector"
printf 'old-cache\n' >"$cache_home/omarchy/image-selector/old-thumbnail.jpg"
chmod 644 "$cache_home/omarchy/image-selector/old-thumbnail.jpg"

HOME="$home" XDG_CACHE_HOME="$cache_home" OMARCHY_PATH="$omarchy_path" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-theme-switcher"

theme_cache="$cache_home/omarchy/theme-selector"
preview_cache="$theme_cache/previews"
image_cache="$cache_home/omarchy/image-selector"

grep -RFl -- "$secret_marker" "$image_cache" >/dev/null ||
  fail "the fixture reaches the reported derived-image cache"
[[ $(readlink -f -- "$preview_cache/escaped-preview.png") == "$secret_dir/private photo.png" ]] ||
  fail "the reported external preview fixture remains represented"
[[ $(readlink -f -- "$preview_cache/escaped-background.png") == "$secret_dir/private photo.png" ]] ||
  fail "the reported backgrounds fixture remains represented"
[[ $(readlink -f -- "$preview_cache/internal-preview.png") == \
  "$user_themes/internal-preview/assets with spaces/source image.png" ]] ||
  fail "an internal preview symlink remains available"
[[ $(readlink -f -- "$preview_cache/linked-theme.jpg") == "$linked_theme/preview.jpg" ]] ||
  fail "a top-level theme symlink remains available"
[[ $(readlink -f -- "$preview_cache/video-preview.mp4") == "$user_themes/video-preview/preview.mp4" ]] ||
  fail "a regular video preview remains available"
pass "theme preview behavior remains unchanged"

[[ $(stat -c '%a' "$theme_cache") == 700 ]] || fail "the theme preview cache is private"
[[ $(stat -c '%a' "$image_cache") == 700 ]] || fail "the image thumbnail cache is private"

while IFS= read -r -d '' file; do
  [[ $(stat -c '%a' "$file") == 600 ]] || fail "new thumbnail cache files are private: $file"
done < <(find "$image_cache" -type f ! -name old-thumbnail.jpg -print0)
while IFS= read -r -d '' file; do
  [[ $(stat -c '%a' "$file") == 600 ]] || fail "theme cache metadata is private: $file"
done < <(find "$theme_cache" -type f -print0)
pass "theme and thumbnail caches restrict new and existing artifacts"

# Exercise the generic writer directly under the ordinary umask. The theme
# switcher now has its own restrictive umask, which must not be allowed to mask
# a regression when another caller opens the generic image selector.
direct_cache_home="$tmp/direct cache"
direct_images="$tmp/direct images"
mkdir -p "$direct_cache_home/omarchy/image-selector" "$direct_images"
chmod 755 "$direct_cache_home/omarchy/image-selector"
printf 'direct-image\n' >"$direct_images/direct image.png"
(
  umask 022
  PATH="$stub_bin:$PATH" XDG_CACHE_HOME="$direct_cache_home" \
    "$ROOT/bin/omarchy-menu-images" --cache-only "$direct_images"
)
direct_cache="$direct_cache_home/omarchy/image-selector"
[[ $(stat -c '%a' "$direct_cache") == 700 ]] || fail "the generic image menu repairs its cache mode"
while IFS= read -r -d '' file; do
  [[ $(stat -c '%a' "$file") == 600 ]] || fail "the generic image menu creates private cache files: $file"
done < <(find "$direct_cache" -type f -print0)
pass "the generic image menu enforces privacy independently"

# The shell plugin also prepares video thumbnails on demand and is a separate
# writer to the same cache. It must repair the directory mode and create its
# own artifacts privately even when the menu process did not run first.
plugin_media="$tmp/plugin media"
mkdir -p "$plugin_media"
printf 'plugin-video\n' >"$plugin_media/sample video.mp4"
chmod 755 "$image_cache"
plugin_rows=$(
  umask 022
  PATH="$stub_bin:$PATH" XDG_CACHE_HOME="$cache_home" \
    "$ROOT/shell/plugins/image-picker/list.sh" "$plugin_media"
)
plugin_thumbnail=${plugin_rows#*$'\t'}

[[ $(stat -c '%a' "$image_cache") == 700 ]] || fail "the shell image picker repairs its cache mode"
[[ -f $plugin_thumbnail && $(stat -c '%a' "$plugin_thumbnail") == 600 ]] ||
  fail "the shell image picker creates private video thumbnails"
pass "every image selector cache writer preserves the privacy boundary"

# A failed cache initialization must still remove the shell writer's pending
# work file. The trap needs to be armed before the cache can fail.
failed_tmp="$tmp/failed tmp"
failed_cache_home="$tmp/cache blocker"
mkdir -p "$failed_tmp"
printf 'not a directory\n' >"$failed_cache_home"
if TMPDIR="$failed_tmp" XDG_CACHE_HOME="$failed_cache_home" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$plugin_media" >/dev/null 2>&1; then
  fail "the shell image picker accepted an unusable cache path"
fi
[[ -z $(find "$failed_tmp" -mindepth 1 -print -quit) ]] ||
  fail "a failed cache initialization left pending work behind"
pass "cache initialization failure cleans up pending work"

# Rebuilding previews is intentionally lock-free. A second switcher may remove
# the disposable previews directory after the first one creates it, so cache
# hardening must be anchored at the stable parent instead of adding a check on
# that racy child.
race_home="$tmp/race home"
race_cache_home="$tmp/race cache"
race_state="$tmp/race state"
race_bin="$tmp/race bin"
race_preview="$race_cache_home/omarchy/theme-selector/previews"
mkdir -p "$race_home/.config/omarchy/themes" "$race_home/.local/state/omarchy/current" \
  "$race_state" "$race_bin"
cp -a "$user_themes/." "$race_home/.config/omarchy/themes/"
printf 'internal-preview\n' >"$race_home/.local/state/omarchy/current/theme.name"

cat >"$race_bin/mkdir" <<'EOF'
#!/bin/bash

/usr/bin/mkdir "$@" || exit
if [[ ${RACE_ROLE:-} == first ]]; then
  for path in "$@"; do
    if [[ $path == "$RACE_PREVIEW" && ! -e $RACE_STATE/first-created ]]; then
      /usr/bin/touch "$RACE_STATE/first-created"
      while [[ ! -e $RACE_STATE/release-first ]]; do
        /usr/bin/sleep 0.01
      done
      break
    fi
  done
fi
EOF

cat >"$race_bin/rm" <<'EOF'
#!/bin/bash

/usr/bin/rm "$@" || exit
if [[ ${RACE_ROLE:-} == second ]]; then
  for path in "$@"; do
    if [[ $path == "$RACE_PREVIEW" && ! -e $RACE_STATE/second-removed ]]; then
      /usr/bin/touch "$RACE_STATE/second-removed"
      while [[ ! -e $RACE_STATE/release-second ]]; do
        /usr/bin/sleep 0.01
      done
      break
    fi
  done
fi
EOF
chmod +x "$race_bin/mkdir" "$race_bin/rm"

run_racing_switcher() {
  local role="$1" status_file="$2"
  (
    set +e
    timeout -k 1 10 env HOME="$race_home" XDG_CACHE_HOME="$race_cache_home" \
      OMARCHY_PATH="$omarchy_path" PATH="$race_bin:$stub_bin:$PATH" RACE_ROLE="$role" \
      RACE_PREVIEW="$race_preview" RACE_STATE="$race_state" \
      "$ROOT/bin/omarchy-theme-switcher" >/dev/null 2>&1
    printf '%s\n' "$?" >"$status_file"
  ) &
  racing_pid=$!
  racing_pids+=("$racing_pid")
}

wait_for_race_event() {
  local event="$1"
  for ((attempt = 0; attempt < 500; attempt++)); do
    [[ -e $race_state/$event ]] && return
    sleep 0.01
  done
  fail "timed out waiting for concurrent preview rebuild: $event"
}

run_racing_switcher first "$race_state/first-status"
first_pid=$racing_pid
wait_for_race_event first-created
run_racing_switcher second "$race_state/second-status"
second_pid=$racing_pid
wait_for_race_event second-removed
touch "$race_state/release-first"
wait "$first_pid"
touch "$race_state/release-second"
wait "$second_pid"

[[ $(<"$race_state/first-status") == 0 && $(<"$race_state/second-status") == 0 ]] ||
  fail "a concurrent theme preview rebuild aborted a switcher"
pass "concurrent theme preview rebuilds remain available"
