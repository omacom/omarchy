#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""

export PATH="$ROOT/bin:$PATH"

cleanup() {
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_command jq

TMPDIR=$(mktemp -d)

parse_result=$(bash -c '
  OMARCHY_PATH="$3"
  source "$1"
  parse_url "$2"
' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" '{"url":"https://example.test/watch?v=\"quoted\"&name=a\\b"}' "$ROOT")

[[ $parse_result == "https://example.test/watch?v=\"quoted\"&name=a\\b" ]] ||
  fail "yt-dlp native host parses escaped JSON URLs" "$parse_result"
pass "yt-dlp native host parses escaped JSON URLs"

bash -c '
  OMARCHY_PATH="$3"
  source "$1"
  valid_url "$2"
' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "javascript:alert(1)" "$ROOT" &&
  fail "yt-dlp native host rejects non-web URLs"
pass "yt-dlp native host rejects non-web URLs"

host_fn() {
  OMARCHY_PATH="$ROOT" OMARCHY_YTDLP_DIR="${download_dir:-$TMPDIR}" bash -c '
    source "$1"
    shift
    "$@"
  ' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "$@"
}

download_dir="$TMPDIR/videos"
mkdir -p "$download_dir" "$TMPDIR/outside"
good_file="$download_dir/clip [id].mp4"
printf 'x' >"$good_file"
printf 'x' >"$TMPDIR/outside/secret"
ln -s "$TMPDIR/outside/secret" "$download_dir/escape.mp4"

resolved=$(host_fn resolve_download_file "$good_file")
expected=$(realpath -e -- "$good_file")
[[ $resolved == "$expected" ]] ||
  fail "yt-dlp native host accepts a regular file in the download dir" "$resolved"
pass "yt-dlp native host accepts a regular file in the download dir"

host_fn resolve_download_file "--include=not-a-file" &&
  fail "yt-dlp native host rejects a forged mpv option as the download path"
pass "yt-dlp native host rejects a forged mpv option as the download path"

host_fn resolve_download_file "$TMPDIR/outside/secret" &&
  fail "yt-dlp native host rejects a path outside the download dir"
pass "yt-dlp native host rejects a path outside the download dir"

host_fn resolve_download_file "$download_dir/escape.mp4" &&
  fail "yt-dlp native host rejects a symlink that escapes the download dir"
pass "yt-dlp native host rejects a symlink that escapes the download dir"

host_fn resolve_download_file $'clip.mp4\nOMARCHY_FILE\t--include=not-a-file' &&
  fail "yt-dlp native host rejects a path containing control characters"
pass "yt-dlp native host rejects a path containing control characters"

newline_target="$download_dir/target"$'\n'
printf 'x' >"$newline_target"
# The decoy is the point: dropping the trailing newline lands on a real, different
# file, so a resolver that strips it resolves to the wrong one instead of failing.
printf 'x' >"$download_dir/target"
ln -s "target"$'\n' "$download_dir/newline-link.mp4"

host_fn resolve_download_file "$download_dir/newline-link.mp4" &&
  fail "yt-dlp native host rejects a symlink whose target name ends in a newline"
pass "yt-dlp native host rejects a symlink whose target name ends in a newline"

ln -s / "$TMPDIR/root-link"
root_resolved=$(download_dir="$TMPDIR/root-link" host_fn resolve_download_file /etc/passwd)
[[ $root_resolved == "/etc/passwd" ]] ||
  fail "yt-dlp native host accepts a file when the download dir resolves to /" "$root_resolved"
pass "yt-dlp native host accepts a file when the download dir resolves to /"

title=$(host_fn title_from_file "$good_file")
[[ $title == "clip [id]" ]] || fail "yt-dlp native host titles the toast from the filename" "$title"
pass "yt-dlp native host titles the toast from the filename"

decoded_title=$(host_fn decode_title '"My Great Clip"')
[[ $decoded_title == "My Great Clip" ]] ||
  fail "yt-dlp native host shows the page title on the toast" "$decoded_title"
pass "yt-dlp native host shows the page title on the toast"

forged_title=$(host_fn decode_title '"Clip\nOMARCHY_FILE\tPlay me\t--include=not-a-file"')
[[ $forged_title == "Clip" ]] ||
  fail "yt-dlp native host keeps only the readable part of a forged title" "$forged_title"
pass "yt-dlp native host keeps only the readable part of a forged title"

host_fn decode_title '"--include=not-a-file"' &&
  fail "yt-dlp native host refuses a leading-dash title the notifier would reject as an option"
pass "yt-dlp native host refuses a leading-dash title the notifier would reject as an option"

host_fn decode_title 'null' &&
  fail "yt-dlp native host refuses a title that is not a JSON string"
pass "yt-dlp native host refuses a title that is not a JSON string"

dash_title=$(host_fn title_from_file "$download_dir/--include.mp4")
[[ $dash_title == "Video" ]] || fail "yt-dlp native host does not pass a leading-dash title to the notifier" "$dash_title"
pass "yt-dlp native host does not pass a leading-dash title to the notifier"

# The actions pass the path as a discrete --with argument (asserted
# end-to-end below against the real download); `--` keeps mpv from parsing a
# leading-dash filename as an option.

parse_script="$TMPDIR/parse-ytdlp-lines.sh"
cat >"$parse_script" <<'EOF'
source "$1"
filepath=""
while IFS= read -r line; do
  case $line in
  OMARCHY_FILE*)
    resolved=$(resolve_download_file "${line#OMARCHY_FILE$'\t'}") || continue
    filepath=$resolved
    ;;
  esac
done
printf '%s' "$filepath"
EOF

# A title that ends in a newline closes its own record, so the forged record is the
# last one and the real path lands on a line the loop ignores.
poisoned=$(
  printf '%s\n' \
    $'OMARCHY_FILE\t'"$good_file" \
    $'OMARCHY_FILE\tPlay me\t--include=not-a-file' \
    $'\t'"$good_file" |
    OMARCHY_PATH="$ROOT" OMARCHY_YTDLP_DIR="$download_dir" bash "$parse_script" "$ROOT/bin/omarchy-chromium-ytdlp-host"
)

[[ $poisoned == "$expected" ]] ||
  fail "yt-dlp native host keeps a real file after a forged OMARCHY_FILE record" "$poisoned"
pass "yt-dlp native host keeps a real file after a forged OMARCHY_FILE record"

# Everything above tests the helpers in isolation. Drive the real download_url with
# stubbed tools so the yt-dlp invocation and the toast's click command are covered
# too: a record template that carried the title again would pass every test above.
fake_root="$TMPDIR/fake"
mkdir -p "$fake_root/bin" "$fake_root/default"
# A real install root carries the i18n catalogs omarchy-i18n reads.
ln -s "$ROOT/default/i18n" "$fake_root/default/i18n"
fake_dir="$TMPDIR/fake-videos"
mkdir -p "$fake_dir"
fake_file="$fake_dir/Real_Clip [id].mp4"
printf 'x' >"$fake_file"
ytdlp_argv="$TMPDIR/ytdlp-argv"
notify_argv="$TMPDIR/notify-argv"

cat >"$fake_root/bin/yt-dlp" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$YTDLP_ARGV_LOG"
# A page yt-dlp has no extractor for fails, as it would for real.
[[ -n ${YTDLP_UNSUPPORTED:-} && ${*: -1} == "$YTDLP_UNSUPPORTED" ]] && exit 1
for arg in "$@"; do
  if [[ $arg == "--no-simulate" ]]; then
    printf 'OMARCHY_FILE\t%s\n' "$YTDLP_FAKE_FILE"
    [[ -n ${YTDLP_SKIP_TITLE:-} ]] || printf 'OMARCHY_TITLE\t%s\n' '"My Great Clip"'
    exit 0
  fi
done
exit 0
EOF

cat >"$fake_root/bin/omarchy-notification-send" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_ARGV_LOG"
EOF

for stub in omarchy-osd omarchy-shell ffmpeg; do
  printf '#!/bin/bash\nexit 0\n' >"$fake_root/bin/$stub"
done
chmod +x "$fake_root/bin/"*

YTDLP_ARGV_LOG="$ytdlp_argv" NOTIFY_ARGV_LOG="$notify_argv" YTDLP_FAKE_FILE="$fake_file" \
  OMARCHY_PATH="$fake_root" OMARCHY_YTDLP_DIR="$fake_dir" \
  bash -c '
    source "$1"
    download_url "$2"
  ' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "https://example.test/watch" >/dev/null 2>&1

(($(grep -c -- '--no-exec-before-download' "$ytdlp_argv") == 2)) ||
  fail "yt-dlp native host disarms configured exec hooks on both yt-dlp runs" "$(cat "$ytdlp_argv")"
pass "yt-dlp native host disarms configured exec hooks on both yt-dlp runs"

# The stub answers with a title record whatever it is asked for, so assert the request
# as well as the reply: without this the template could be dropped and nothing notice.
grep -qF -- $'OMARCHY_TITLE\t%(title)j' "$ytdlp_argv" ||
  fail "yt-dlp native host asks for the title JSON-encoded" "$(cat "$ytdlp_argv")"
pass "yt-dlp native host asks for the title JSON-encoded"

grep -qF -- "-o %(title)s.%(ext)s" "$ytdlp_argv" ||
  fail "yt-dlp native host names the saved file after the page title" "$(cat "$ytdlp_argv")"
pass "yt-dlp native host names the saved file after the page title"

grep -q -- '--restrict-filenames' "$ytdlp_argv" &&
  fail "yt-dlp native host keeps spaces in the saved filename" "$(cat "$ytdlp_argv")"
pass "yt-dlp native host keeps spaces in the saved filename"

grep -qF -- $'OMARCHY_FILE\t%(title)s' "$ytdlp_argv" &&
  fail "yt-dlp native host never prints the title into the file record" "$(cat "$ytdlp_argv")"
pass "yt-dlp native host never prints the title into the file record"

grep -qF -- "--action Open mpv -- --action Cut omacut --with $fake_file" "$notify_argv" ||
  fail "yt-dlp native host offers Open in mpv and Cut in Omacut for the download" "$(cat "$notify_argv")"
pass "yt-dlp native host offers Open in mpv and Cut in Omacut for the download"

grep -qF -- "Download complete My Great Clip" "$notify_argv" ||
  fail "yt-dlp native host toasts the page title, not the sanitised filename" "$(cat "$notify_argv")"
pass "yt-dlp native host toasts the page title, not the sanitised filename"

# A page that gives no usable title falls back to the filename rather than an empty toast.
: >"$notify_argv"
: >"$ytdlp_argv"
YTDLP_ARGV_LOG="$ytdlp_argv" NOTIFY_ARGV_LOG="$notify_argv" YTDLP_FAKE_FILE="$fake_file" \
  YTDLP_SKIP_TITLE=1 OMARCHY_PATH="$fake_root" OMARCHY_YTDLP_DIR="$fake_dir" \
  bash -c '
    source "$1"
    download_url "$2"
  ' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "https://example.test/watch" >/dev/null 2>&1

grep -qF -- "Download complete Real_Clip [id]" "$notify_argv" ||
  fail "yt-dlp native host falls back to the filename when no title record arrives" "$(cat "$notify_argv")"
pass "yt-dlp native host falls back to the filename when no title record arrives"

# --- Stream fallback ---

stream_payload='{"url":"https://course.test/lesson","stream":"https://cdn.test/master.m3u8?sig=1","referer":"https://player.test/","title":"Lesson 3"}'
[[ $(host_fn parse_field "$stream_payload" stream) == "https://cdn.test/master.m3u8?sig=1" ]] ||
  fail "yt-dlp native host reads the stream the extension saw"
[[ -z $(host_fn parse_field '{"stream":["https://cdn.test/a.m3u8"]}' stream) ]] ||
  fail "yt-dlp native host ignores a stream that is not a string"
pass "yt-dlp native host reads the stream fields from the extension's message"

[[ $(host_fn output_template_from_title "Lesson 3: Setup") == "Lesson 3: Setup.%(ext)s" ]] ||
  fail "yt-dlp native host names a stream download after the tab title"
[[ $(host_fn output_template_from_title "--100% ../../etc/x"$'\n') == "100%% ..-..-etc-x.%(ext)s" ]] ||
  fail "yt-dlp native host keeps a tab title from becoming an option, a path or a template" "$(host_fn output_template_from_title "--100% ../../etc/x"$'\n')"
[[ $(host_fn output_template_from_title "") == "%(title)s.%(ext)s" ]] ||
  fail "yt-dlp native host falls back to yt-dlp's title without a tab title"
pass "yt-dlp native host names stream downloads safely after the tab title"

# A page yt-dlp can't read falls back to the stream, with the player's referer.
: >"$notify_argv"
: >"$ytdlp_argv"
YTDLP_ARGV_LOG="$ytdlp_argv" NOTIFY_ARGV_LOG="$notify_argv" YTDLP_FAKE_FILE="$fake_file" \
  YTDLP_UNSUPPORTED="https://course.test/lesson" OMARCHY_PATH="$fake_root" OMARCHY_YTDLP_DIR="$fake_dir" \
  bash -c '
    source "$1"
    download_url "$2" "$3" "$4" "$5"
  ' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "https://course.test/lesson" \
  "https://cdn.test/master.m3u8?sig=1" "https://player.test/" "Lesson 3" >/dev/null 2>&1

download_run=$(grep -- '--no-simulate' "$ytdlp_argv" || true)
[[ $download_run == *"-o Lesson 3.%(ext)s --referer https://player.test/ "* && $download_run == *"-- https://cdn.test/master.m3u8?sig=1" ]] ||
  fail "yt-dlp native host downloads the page's stream when yt-dlp can't read the page" "$(cat "$ytdlp_argv")"
grep -qF -- "Download complete Lesson 3 -t" "$notify_argv" ||
  fail "yt-dlp native host toasts a stream download with the tab title" "$(cat "$notify_argv")"
pass "yt-dlp native host falls back to the page's stream when yt-dlp can't read the page"

# A page yt-dlp reads keeps its own URL even when a stream was seen.
: >"$ytdlp_argv"
YTDLP_ARGV_LOG="$ytdlp_argv" NOTIFY_ARGV_LOG="$notify_argv" YTDLP_FAKE_FILE="$fake_file" \
  OMARCHY_PATH="$fake_root" OMARCHY_YTDLP_DIR="$fake_dir" \
  bash -c '
    source "$1"
    download_url "$2" "$3" "$4" "$5"
  ' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "https://example.test/watch" \
  "https://cdn.test/master.m3u8" "https://player.test/" "Clip" >/dev/null 2>&1
download_run=$(grep -- '--no-simulate' "$ytdlp_argv" || true)
[[ $download_run == *"-o %(title)s.%(ext)s --print"* && $download_run == *"-- https://example.test/watch" && $download_run != *"--referer"* ]] ||
  fail "yt-dlp native host prefers the page URL when yt-dlp supports it" "$(cat "$ytdlp_argv")"
pass "yt-dlp native host prefers the page URL when yt-dlp supports it"

# Without a stream, an unreadable page still reports that nothing was found.
: >"$notify_argv"
: >"$ytdlp_argv"
YTDLP_ARGV_LOG="$ytdlp_argv" NOTIFY_ARGV_LOG="$notify_argv" YTDLP_FAKE_FILE="$fake_file" \
  YTDLP_UNSUPPORTED="https://course.test/lesson" OMARCHY_PATH="$fake_root" OMARCHY_YTDLP_DIR="$fake_dir" \
  bash -c '
    source "$1"
    download_url "$2"
  ' bash "$ROOT/bin/omarchy-chromium-ytdlp-host" "https://course.test/lesson" >/dev/null 2>&1
grep -qF -- "No video found for download" "$notify_argv" && ! grep -q -- '--no-simulate' "$ytdlp_argv" ||
  fail "yt-dlp native host reports no video when there is neither a page nor a stream to download" "$(cat "$notify_argv")"
pass "yt-dlp native host reports no video when there is neither a page nor a stream to download"

# --- Extension: which stream it remembers and sends ---

# Drive the extension's service worker under node with a fake chrome API. Storage
# reads are slower than writes, as they can be in Chromium, so an update that ran
# out of event order would show up as a stale stream.
if command -v node >/dev/null; then
  extension_results=$(node - "$ROOT/default/chromium/extensions/yt-dlp/background.js" <<'JS'
const fs = require("fs")
const vm = require("vm")
const source = fs.readFileSync(process.argv[2], "utf8")
const tick = ms => new Promise(resolve => setTimeout(resolve, ms))
const settle = () => tick(60)

function load() {
  const store = {}
  const listeners = {}
  const sent = []
  const tab = { id: 7, url: "https://course.test/lesson/1", title: "Lesson 1" }
  let frameScores = null
  const on = name => ({ addListener: fn => { listeners[name] = fn } })
  const chrome = {
    storage: { session: {
      get: async key => { await tick(10); return key in store ? { [key]: JSON.parse(JSON.stringify(store[key])) } : {} },
      set: async items => { Object.assign(store, JSON.parse(JSON.stringify(items))) },
      remove: async key => { delete store[key] },
    } },
    tabs: { get: async () => ({ ...tab }), onUpdated: on("updated"), onRemoved: on("removed"), query: () => {} },
    webRequest: { onBeforeRequest: on("request") },
    commands: { onCommand: on("command") },
    action: { onClicked: on("clicked") },
    scripting: { executeScript: async () => { if (!frameScores) throw new Error("no access"); return frameScores } },
    runtime: { lastError: undefined, sendNativeMessage: (host, message, callback) => { sent.push(message); callback() } },
  }
  vm.runInNewContext(source, { chrome, console, setTimeout })
  const request = (url, frameId, documentId, type = "xmlhttprequest") =>
    listeners.request({ tabId: tab.id, url, frameId, documentId, type, initiator: "https://player.test" })
  const download = async () => { listeners.clicked({ ...tab }); await settle(); return sent.length ? sent[sent.length - 1].stream || "none" : "unsent" }
  return { tab, store, listeners, request, download, setScores: scores => { frameScores = scores } }
}

const results = {}
;(async () => {
  // A lesson and an ad on one page: the playing lesson wins, and it is still the
  // stream sent when the frames can't be asked which one is playing.
  let ext = load()
  ext.request("https://cdn.test/lesson1/master.m3u8", 1, "lesson-doc")
  ext.request("https://cdn.test/lesson1/720p.m3u8", 1, "lesson-doc")
  ext.request("https://ads.test/ad.m3u8", 2, "ad-doc")
  await settle()
  ext.setScores([{ frameId: 1, documentId: "lesson-doc", result: 1e9 + 4e5 }, { frameId: 2, documentId: "ad-doc", result: 2e4 }])
  results.playing = await ext.download()
  ext.setScores([{ frameId: 1, documentId: "lesson-doc", result: 0 }, { frameId: 2, documentId: "ad-doc", result: 1e9 }])
  results.adPlaying = await ext.download()
  ext.setScores(null)
  results.unscriptable = await ext.download()

  // The next lesson loading into the same iframe replaces that frame's stream.
  ext.setScores(null)
  ext.request("https://cdn.test/lesson2/master.m3u8", 1, "lesson2-doc")
  await settle()
  results.iframeReplaced = await ext.download()

  // A late request from the old page, then a navigation: nothing of the old page survives.
  ext = load()
  ext.request("https://cdn.test/lesson1/master.m3u8", 1, "old-doc")
  ext.listeners.request({ tabId: 7, url: "https://course.test/lesson/2", frameId: 0, type: "main_frame" })
  ext.tab.url = "https://course.test/lesson/2"
  await settle()
  results.afterNavigation = Object.keys(ext.store).length ? "stale" : "cleared"
  ext.request("https://cdn.test/lesson2/master.m3u8", 1, "new-doc")
  await settle()
  results.newPage = await ext.download()

  // A History API lesson change retires the stream; a fragment change does not.
  ext = load()
  ext.request("https://cdn.test/lesson1/master.m3u8", 1, "doc")
  await settle()
  ext.listeners.updated(7, { url: "https://course.test/lesson/1#notes" })
  await settle()
  results.fragment = Object.keys(ext.store).length ? "kept" : "cleared"
  ext.listeners.updated(7, { url: "https://course.test/lesson/2" })
  ext.tab.url = "https://course.test/lesson/2"
  await settle()
  results.historyChange = await ext.download()

  // A stream saved for another page is never sent for this one, and closing the tab forgets it.
  ext = load()
  ext.request("https://cdn.test/lesson1/master.m3u8", 1, "doc")
  await settle()
  ext.tab.url = "https://course.test/lesson/9"
  results.otherPage = await ext.download()
  ext.listeners.removed(7)
  await settle()
  results.closed = Object.keys(ext.store).length ? "kept" : "cleared"

  process.stdout.write(Object.entries(results).map(([key, value]) => `${key}=${value}`).join("\n"))
})()
JS
  )

  expect_result() {
    grep -qxF -- "$1=$2" <<<"$extension_results" || fail "$3" "$extension_results"
    pass "$3"
  }
  expect_result playing "https://cdn.test/lesson1/master.m3u8" "yt-dlp extension sends the playing player's master playlist, not the ad beside it"
  expect_result adPlaying "https://ads.test/ad.m3u8" "yt-dlp extension follows whichever player is playing"
  expect_result unscriptable "https://cdn.test/lesson1/master.m3u8" "yt-dlp extension falls back to the page's first stream when it can't ask the frames"
  expect_result iframeReplaced "https://cdn.test/lesson2/master.m3u8" "yt-dlp extension replaces a frame's stream when a new document loads in it"
  expect_result afterNavigation cleared "yt-dlp extension drops a late request from the page it navigated away from"
  expect_result newPage "https://cdn.test/lesson2/master.m3u8" "yt-dlp extension remembers the new page's stream after navigating"
  expect_result fragment kept "yt-dlp extension keeps the stream across a fragment change"
  expect_result historyChange none "yt-dlp extension retires the stream when a course changes lessons through the History API"
  expect_result otherPage none "yt-dlp extension never sends a stream saved for another page"
  expect_result closed cleared "yt-dlp extension forgets a tab's stream when the tab closes"
else
  skip "node is not installed; skipping the yt-dlp extension stream checks"
fi
