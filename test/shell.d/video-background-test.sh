#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const utilQml = fs.readFileSync(path.join(root, 'shell/Commons/Util.qml'), 'utf8')
const mediaQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')
const videoQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundVideo.qml'), 'utf8')
const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const lockQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')
const themeSwitcher = fs.readFileSync(path.join(root, 'bin/omarchy-theme-switcher'), 'utf8')
const quattroUpgrade = fs.readFileSync(path.join(root, 'bin/omarchy-upgrade-to-quattro'), 'utf8')
const multimediaMigration = fs.readFileSync(path.join(root, 'migrations/1786609204.sh'), 'utf8')
const barTextColor = fs.readFileSync(path.join(root, 'bin/omarchy-bar-text-color'), 'utf8')
const menuImages = fs.readFileSync(path.join(root, 'bin/omarchy-menu-images'), 'utf8')
const lockView = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')
const lockService = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const batteryService = fs.readFileSync(path.join(root, 'shell/plugins/services/battery/Service.qml'), 'utf8')
const themeSet = fs.readFileSync(path.join(root, 'bin/omarchy-theme-set'), 'utf8')
const directImageList = fs.readFileSync(path.join(root, 'shell/plugins/image-picker/list.sh'), 'utf8')

assert(
  /function isVideoPath\(path\)[\s\S]*\.test\(String\(path \|\| ""\)\)/.test(utilQml) &&
    !utilQml.includes('split(/[?#]/)'),
  'shared media helper identifies video paths without truncating valid local names'
)
assert(
  videoQml.includes('loops: MediaPlayer.Infinite') &&
    videoQml.includes('autoPlay: root.playbackEnabled') &&
    videoQml.includes('fillMode: VideoOutput.PreserveAspectCrop') &&
    /imageUrl: path && !Util\.isVideoPath\(path\) \? Util\.fileUrl\(path\) \+ \(version \? "\?v=" \+ version : ""\) : ""/.test(mediaQml) &&
    /videoUrl: path && Util\.isVideoPath\(path\) \? Util\.fileUrl\(path\) : ""/.test(mediaQml),
  'background media plays aspect-cropped videos on a loop, and hands each loader only its own kind of file'
)
assert(
  videoQml.includes('MediaPlayer.LoadedMedia') &&
    videoQml.includes('primePauseTimer') &&
    videoQml.includes('mediaGeneration') &&
    videoQml.includes('videoSink') &&
    videoQml.includes('onVideoFrameChanged') &&
    videoQml.includes('MediaPlayer.BufferedMedia') &&
    videoQml.includes('mediaStatus !== MediaPlayer.BufferedMedia') &&
    videoQml.includes('interval: 1000') &&
    videoQml.includes('interval: 50') &&
    videoQml.includes('frameReceived') &&
    videoQml.includes('output.clearOutput()') &&
    !videoQml.includes('KeepLastFrame') &&
    /onPlaybackEnabledChanged:[\s\S]*?if \(playbackEnabled\) player\.play\(\)[\s\S]*?else player\.pause\(\)/.test(videoQml) &&
    videoQml.includes('primingGeneration') &&
    videoQml.includes('player.play()') &&
    videoQml.includes('player.pause()'),
  'paused video sources are primed to display their first frame'
)
assert(
  !/^\s*import QtMultimedia/m.test(mediaQml) &&
    mediaQml.includes('source: "BackgroundVideo.qml"'),
  'the still-image path never imports QtMultimedia, so image-only sessions do not map it'
)
assert(
  !/^\s*Video\s*\{/m.test(videoQml) &&
    /property bool audioEnabled: false/.test(videoQml) &&
    /property bool audioEnabled: false/.test(mediaQml) &&
    /active: root\.audioEnabled && player\.hasAudio/.test(videoQml) &&
    /audioOutput: audioLoader\.item/.test(videoQml) &&
    /muted: root\.priming \|\| !root\.playbackEnabled/.test(videoQml) &&
    /property: "audioEnabled"\s*\n\s*value: root\.audioEnabled/.test(mediaQml) &&
    /firstScreen: Quickshell\.screens\.length > 0\s*\n\s*&& String\(Quickshell\.screens\[0\]\.name/.test(backgroundQml) &&
    backgroundQml.includes('audioEnabled: panel.firstScreen') &&
    !lockQml.includes('audioEnabled'),
  'a sound track plays from the first monitor only, a silent file builds no audio output, and the lock stays quiet'
)
assert(
  /property: "mediaSource"[\s\S]*?when: videoLoader\.item !== null && Util\.isVideoPath\(root\.path\)\s*\n\s*restoreMode: Binding\.RestoreNone/.test(mediaQml) &&
    !videoQml.includes('Component.onDestruction'),
  'a player on its way out keeps its source, so nothing is left loading for its destructor to cancel'
)
assert(
  !mediaQml.includes('mipmap'),
  'the shared image path leaves mipmapping off, as the desktop background had it'
)
assert(
  /instant \|\| !displayedBackground \|\| isVideo\(path\) \|\| isVideo\(displayedBackground\)[\s\S]*displayedBackground = finalPath/.test(backgroundQml),
  'video switches bypass the image-only reveal stack and use the durable background path'
)
assert(backgroundQml.includes('BackgroundMedia {') && lockQml.includes('BackgroundMedia {'), 'desktop and lock screen share video-capable media rendering')
assert(
  lockQml.includes('source: wallpaper.video ? null : wallpaper') &&
    lockQml.includes('visible: !wallpaper.video') &&
    lockQml.includes('visible: wallpaper.video'),
  'lock screen bypasses its image effect for video output'
)
assert(
  /sessionObscured:\s*lockActive \|\| screensaverActive/.test(backgroundQml) &&
    backgroundQml.includes('playbackEnabled: !root.sessionObscured && !root.powerSaverActive && !panel.fullscreenHere') &&
    backgroundQml.includes('omarchy.lock') &&
    backgroundQml.includes('omarchy.idle') &&
    backgroundQml.includes('omarchy.battery'),
  'desktop playback stops while covered or on battery power-saver'
)
assert(
  backgroundQml.includes('Hyprland.monitorFor(modelData)') &&
    /fullscreenHere: visibleWorkspace \? visibleWorkspace\.hasFullscreen : false/.test(backgroundQml) &&
    !backgroundQml.includes('ToplevelManager.activeToplevel'),
  'a fullscreen window pauses only the output it covers, wherever focus is'
)
assert(
  /if \(displayedBackground === finalPath\) displayedReloads \+= 1/.test(backgroundQml) &&
    backgroundQml.includes('reloads: root.displayedReloads') &&
    /active: root\.path !== "" && root\.video && !root\.reloading/.test(mediaQml) &&
    /onReloadsChanged: \{[\s\S]*?reloading = true/.test(mediaQml),
  'a theme switch that keeps the video path still reopens the replaced file'
)
assert(
  barTextColor.includes('magick "$background_path[0]"'),
  'bar colour sampling reads one frame instead of decoding a whole video'
)
assert(
  menuImages.includes('pending_video_file') && /video_jobs=\$\(\( \$\(nproc\) \/ 4 \)\)/.test(menuImages),
  'video thumbnails fan out narrower than single-threaded vips jobs'
)
assert(
  themeSwitcher.includes('fast_signature="v2"'),
  'the theme preview cache rebuilds after preview discovery learned about video'
)
assert(
  /lazy_thumbnails == true && \$cache_only != true \]\] && ! is_video_path/.test(menuImages),
  'a video never stands in as its own lazy thumbnail, so the fan out cap always applies'
)
assert(
  /thumbnail_command=\(timeout -k \d+ \d+ ffmpegthumbnailer/.test(menuImages),
  'a stalled video cannot hold the picker shut, because its generator is time bounded'
)
assert(
  directImageList.includes('generate_video_thumbnail') &&
    /timeout -k \d+ \d+ ffmpegthumbnailer/.test(directImageList) &&
    /if \[\[ ! -f \$thumbnail \]\] && ! is_video_path/.test(directImageList),
  'a direct picker scan generates bounded video thumbnails without content-hashing the media'
)
assert(
  themeSet.includes('choose_staged_theme_background') &&
    themeSet.includes('background_transition_uses_snapshots') &&
    themeSet.includes('BACKGROUND_TRANSITION_SNAPSHOTS=false') &&
    /if \[\[ \$BACKGROUND_TRANSITION_SNAPSHOTS == "true" \]\]/.test(themeSet) &&
    /if \[\[ -z \$CHOSEN_THEME_BACKGROUND \|\| ! -f \$CHOSEN_THEME_BACKGROUND \]\]/.test(themeSet),
  'theme changes disable both transition snapshots whenever either side is a video'
)
assert(
  /function onScreensChanged\(\) \{[\s\S]*?root\.displaysBlank = false/.test(lockService),
  'a display coming back gives up the blank state instead of freezing a visible wallpaper'
)
assert(
  lockService.includes('function screenBlank(screenName)') &&
    lockService.includes('function applyMonitorDpms(text)') &&
    lockService.includes('command: ["hyprctl", "monitors", "-j"]') &&
    lockService.includes('running: root.locked && root.videoBackground') &&
    /displaysBlank: root\.screenBlank\(lockSurface\.screen/.test(lockService) &&
    /function runWake\(\) \{[\s\S]*?root\.monitorDpmsKnown = false/.test(lockService) &&
    /function runBlank\(\) \{[\s\S]*?root\.monitorDpmsKnown = false/.test(lockService),
  'a locked video wallpaper follows what each panel actually did, not only what the lock asked for'
)
assert(
  lockView.includes('playbackEnabled: root.loadBackground && !root.displaysBlank') &&
    lockView.includes('&& !root.powerSaverActive') &&
    /displaysBlank: root\.screenBlank\(/.test(lockService) &&
    /powerSaverActive: root\.powerSaverActive/.test(lockService) &&
    /function runBlank\(\) \{\s*\n\s*root\.displaysBlank = true/.test(lockService) &&
    /function runWake\(\) \{\s*\n\s*root\.displaysBlank = false/.test(lockService),
  'the lock screen stops playback once displays go dark or power-saver is active'
)
assert(
  batteryService.includes('property string activePowerProfile') &&
    batteryService.includes('UPower.onBattery && activePowerProfile === "power-saver"') &&
    batteryService.includes('["powerprofilesctl", "get"]') &&
    batteryService.includes('interval: 2000'),
  'the battery service tracks the active power-saver profile'
)
assert(
  themeSwitcher.includes("-iname '*.mp4'") &&
    themeSwitcher.includes('mp4 m4v mov webm mkv avi') &&
    themeSwitcher.includes('preview.mp4'),
  'theme switcher previews video-only themes, named preview files included'
)
assert(quattroUpgrade.includes("-iname '*.mp4'"), 'Quattro upgrade can seed a video-only theme background')
assert(
  multimediaMigration.includes('omarchy-pkg-add qt6-multimedia qt6-multimedia-ffmpeg'),
  'existing Quattro installations receive video playback dependencies'
)
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/backgrounds" "$test_tmp/generator-cache" "$test_tmp/direct-cache"
printf 'not a real video\n' >"$test_tmp/backgrounds/sample.mp4"

cat >"$test_tmp/bin/ffmpegthumbnailer" <<'SH'
#!/bin/bash
while (( $# > 0 )); do
  case "$1" in
    -i) input=$2; shift 2 ;;
    -o) output=$2; shift 2 ;;
    *) shift ;;
  esac
done
printf 'thumbnail for %s\n' "$input" >"$output"
SH
chmod +x "$test_tmp/bin/ffmpegthumbnailer"

cat >"$test_tmp/bin/md5sum" <<'SH'
#!/bin/bash
if (( $# > 0 )); then
  printf 'unexpected file hash: %s\n' "$*" >>"$MD5_FILE_CALLS"
fi
exec /usr/bin/md5sum "$@"
SH
chmod +x "$test_tmp/bin/md5sum"

md5_file_calls="$test_tmp/md5-file-calls"
PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$test_tmp/generator-cache" MD5_FILE_CALLS="$md5_file_calls" \
  "$ROOT/bin/omarchy-menu-images" --prepare-only "$test_tmp/backgrounds"

generator_thumbnail=$(find "$test_tmp/generator-cache/omarchy/image-selector" -maxdepth 1 -type f -name '*.jpg' -print -quit)
[[ -s $generator_thumbnail ]] || fail "menu image generator creates a video thumbnail"

generator_row=$(XDG_CACHE_HOME="$test_tmp/generator-cache" "$ROOT/shell/plugins/image-picker/list.sh" "$test_tmp/backgrounds")
IFS=$'\t' read -r generator_row_path generator_row_thumbnail <<<"$generator_row"
[[ $generator_row_path == "$test_tmp/backgrounds/sample.mp4" && $generator_row_thumbnail == "$generator_thumbnail" ]] || \
  fail "direct picker consumes the menu image generator thumbnail" "$generator_row"

row=$(PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$test_tmp/direct-cache" MD5_FILE_CALLS="$md5_file_calls" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$test_tmp/backgrounds")

IFS=$'\t' read -r row_path row_thumbnail <<<"$row"
[[ $row_path == "$test_tmp/backgrounds/sample.mp4" && $row_thumbnail == *.jpg && -s $row_thumbnail ]] || \
  fail "image picker lists videos with their cached thumbnail" "$row"
[[ ! -s $md5_file_calls ]] || fail "direct video scans avoid hashing the complete media file" "$(<"$md5_file_calls")"

failed_backgrounds="$test_tmp/failed-backgrounds"
failed_cache="$test_tmp/failed-cache"
mkdir -p "$failed_backgrounds" "$failed_cache"
printf 'broken video\n' >"$failed_backgrounds/broken.mp4"
cat >"$test_tmp/bin/ffmpegthumbnailer" <<'SH'
#!/bin/bash
exit 1
SH

cached_row=$(PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$test_tmp/direct-cache" MD5_FILE_CALLS="$md5_file_calls" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$test_tmp/backgrounds")
[[ $cached_row == "$row" ]] || fail "direct picker reuses its cached video thumbnail" "$cached_row"

failed_rows=$(PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$failed_cache" MD5_FILE_CALLS="$md5_file_calls" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$failed_backgrounds")
[[ -z $failed_rows ]] || fail "direct picker omits a video whose thumbnail fails" "$failed_rows"

failed_marker=$(find "$failed_cache/omarchy/image-selector" -maxdepth 1 -type f -name '*.failed' -print -quit)
[[ -n $failed_marker ]] || fail "direct picker remembers a video the converter rejected"

thumbnailer_calls="$test_tmp/thumbnailer-calls"
cat >"$test_tmp/bin/ffmpegthumbnailer" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$THUMBNAILER_CALLS"
exit 1
SH

failed_rows=$(PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$failed_cache" THUMBNAILER_CALLS="$thumbnailer_calls" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$failed_backgrounds")
[[ -z $failed_rows && ! -e $thumbnailer_calls ]] || fail "direct picker skips a rejected video on the next scan" "$(cat "$thumbnailer_calls" 2>/dev/null)"

generator_failed_cache="$test_tmp/generator-failed-cache"
PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$generator_failed_cache" THUMBNAILER_CALLS="$thumbnailer_calls" \
  "$ROOT/bin/omarchy-menu-images" --prepare-only "$failed_backgrounds"
[[ -s $thumbnailer_calls ]] || fail "menu image generator tries a video it has not seen"
generator_marker=$(find "$generator_failed_cache/omarchy/image-selector" -maxdepth 1 -type f -name '*.failed' -print -quit)
[[ -n $generator_marker ]] || fail "menu image generator remembers a video the converter rejected"
rm -f "$thumbnailer_calls"
PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$generator_failed_cache" THUMBNAILER_CALLS="$thumbnailer_calls" \
  "$ROOT/bin/omarchy-menu-images" --prepare-only "$failed_backgrounds"
[[ ! -e $thumbnailer_calls ]] || fail "menu image generator skips a rejected video on the next open" "$(<"$thumbnailer_calls")"

# A repaired file gets a fresh key, so the old marker no longer applies, and
# the rows are not cached over its absence, so an in-place repair that leaves
# the directory's mtime alone is still noticed.
touch -d '2 minutes' "$failed_backgrounds/broken.mp4"
PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$generator_failed_cache" THUMBNAILER_CALLS="$thumbnailer_calls" \
  "$ROOT/bin/omarchy-menu-images" --prepare-only "$failed_backgrounds"
[[ -s $thumbnailer_calls ]] || fail "menu image generator retries a video that changed since it was rejected"

timeout_backgrounds="$test_tmp/timeout-backgrounds"
timeout_cache="$test_tmp/timeout-cache"
mkdir -p "$timeout_backgrounds"
printf 'slow video\n' >"$timeout_backgrounds/slow.mp4"
cat >"$test_tmp/bin/ffmpegthumbnailer" <<'SH'
#!/bin/bash
exit 124
SH
timeout_rows=$(PATH="$test_tmp/bin:$PATH" XDG_CACHE_HOME="$timeout_cache" \
  "$ROOT/shell/plugins/image-picker/list.sh" "$timeout_backgrounds")
[[ -z $timeout_rows ]] || fail "direct picker omits a video whose thumbnail timed out" "$timeout_rows"
timeout_marker=$(find "$timeout_cache/omarchy/image-selector" -maxdepth 1 -type f -name '*.failed' -print -quit)
[[ -z $timeout_marker ]] || fail "a timed out video is left to retry rather than remembered as failed"

grep -qx 'qt6-multimedia' "$ROOT/install/omarchy-base.packages" || fail "Qt Multimedia runtime is a base package"
grep -qx 'qt6-multimedia-ffmpeg' "$ROOT/install/omarchy-base.packages" || fail "Qt Multimedia FFmpeg backend is a base package"

pass "menu image generator creates thumbnails consumed by the picker"
pass "direct picker generates and reuses still thumbnails"
pass "direct picker omits videos whose thumbnails cannot be generated"
pass "a rejected video is remembered so it costs nothing on the next open"
pass "a timed out video is left to retry"
pass "a locked video wallpaper follows the panels' real DPMS state"
pass "Qt Multimedia playback dependencies are declared"

source <(awk '
  /^(is_video_path|snapshot_background_path|background_transition_uses_snapshots|choose_theme_background|choose_staged_theme_background|set_theme_background)\(\) \{/ { copying=1 }
  copying { print }
  copying && /^}$/ { copying=0 }
' "$ROOT/bin/omarchy-theme-set")

transition_home="$test_tmp/transition-home"
CURRENT_THEME_PATH="$transition_home/.local/state/omarchy/current/theme"
NEXT_THEME_PATH="$transition_home/.local/state/omarchy/current/next-theme"
CURRENT_BACKGROUND_LINK="$transition_home/.local/state/omarchy/current/background"
BACKGROUND_TRANSITION_CACHE="$transition_home/.cache/omarchy/background-transitions"
THEME_NAME="video-test"
HOME="$transition_home"
mkdir -p "$CURRENT_THEME_PATH/backgrounds" "$NEXT_THEME_PATH/backgrounds" "$HOME/.config/omarchy/backgrounds/$THEME_NAME"
printf 'old image\n' >"$CURRENT_THEME_PATH/backgrounds/old.png"
printf 'old image staged\n' >"$NEXT_THEME_PATH/backgrounds/old.png"
printf 'new video\n' >"$NEXT_THEME_PATH/backgrounds/new.mp4"
ln -s "$CURRENT_THEME_PATH/backgrounds/old.png" "$CURRENT_BACKGROUND_LINK"

choose_staged_theme_background || fail "staged video background is selected before the theme swap"
expected_staged_background="$CURRENT_THEME_PATH/backgrounds/new.mp4"
[[ $CHOSEN_THEME_BACKGROUND == $expected_staged_background ]] || \
  fail "staged background resolves to its durable post-swap path" "$CHOSEN_THEME_BACKGROUND"
if background_transition_uses_snapshots "$CHOSEN_THEME_BACKGROUND"; then
  fail "image to video theme transitions skip snapshots"
fi
background_transition_uses_snapshots "$CURRENT_THEME_PATH/backgrounds/new.png" || \
  fail "image to image theme transitions retain snapshots"

rm "$CURRENT_BACKGROUND_LINK"
printf 'old video\n' >"$CURRENT_THEME_PATH/backgrounds/old.mp4"
ln -s "$CURRENT_THEME_PATH/backgrounds/old.mp4" "$CURRENT_BACKGROUND_LINK"
if background_transition_uses_snapshots "$CURRENT_THEME_PATH/backgrounds/new.png"; then
  fail "video to image theme transitions skip snapshots"
fi

video_snapshot=$(snapshot_background_path "$CURRENT_THEME_PATH/backgrounds/old.mp4" "video")
[[ -z $video_snapshot && ! -e $BACKGROUND_TRANSITION_CACHE ]] || fail "video files are never snapshotted"

CHOSEN_THEME_BACKGROUND="$transition_home/disappeared.mp4"
BACKGROUND_TRANSITION_SNAPSHOTS=false
OLD_BACKGROUND_SNAPSHOT=""
colors_payload=""
shell_payload=""
shell_ipc() { :; }
set_theme_background
[[ -f $CHOSEN_THEME_BACKGROUND && $(readlink "$CURRENT_BACKGROUND_LINK") == "$CHOSEN_THEME_BACKGROUND" ]] || \
  fail "theme changes recover when a preselected background disappears" "$CHOSEN_THEME_BACKGROUND"

pass "theme transitions skip snapshots whenever either side is a video"
pass "theme changes recover from a missing preselected background"
