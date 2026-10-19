#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const U = requireFromRoot('shell/plugins/update/UpdateModel.js')

const feedAll = (chunks) => chunks.reduce((s, c) => U.feed(s, c), U.create())
const view = (s) => JSON.stringify({ step: s.step, packages: s.packages, tools: s.tools, ask: s.ask, exit: s.exit, errors: s.errors, reboot: s.reboot })

// A transcript in the shape omarchy update -y prints: colour codes, OSC 3008
// bookkeeping, pacman redrawing its progress lines with \r, and the markers.
const bar = (name, i, n) => [0, 40, 100].map((p) => `(${String(i).padStart(String(n).length)}/${n}) upgrading ${name.padEnd(30)} [${'#'.repeat(p / 10).padEnd(10, '-')}] ${String(p).padStart(3)}%`).join('\r')
const names = ['claude-code', 'google-chrome', 'ttf-jetbrains-mono-nerd-basic', 'spotifast-bin']
const transcript = [
  '\x1b[32m\r\nPrune package cache\x1b[0m\r\nIdentifying face...\r\n',
  '\x1b]3008;start=abc;user=u;hostname=h\x1b\\\x1b[32m\r\nUpdate system packages\x1b[0m\r\n:: Retrieving packages...\r\n',
  ' Total ( 0/4)   0.0   B  0.00   B/s 00:00 [--------]   0%\r Total ( 2/4)  12.3 MiB  23.0 MiB/s 00:02 [###-----]  40%\r Total ( 4/4)  40.1 MiB  22.9 MiB/s 00:00 [########] 100%\r\n',
  ':: Processing package changes...\r\n',
  ...names.slice(0, 3).map((n, i) => bar(n, i + 1, 3) + '\r\n'),
  ':: Running post-transaction hooks...\r\n(1/2) Arming ConditionNeedsUpdate...\r\n\x1b]3008;end=abc\x1b\\',
  '\x1b[32m\r\nUpdate mise tools\x1b[0m\r\nUpgraded 2 tools:\r\n  claude 2.1.296 → 2.1.299\r\n  pi 1.1.0 → 1.2.0\r\n',
  '\x1b[32m\r\nUpdate AUR packages\x1b[0m\r\n==>\x1b(B Making package: spotifast-bin 0.13.1-1 (Wed)\x1b(B\r\n', bar(names[3], 1, 1) + '\r\n',
  '\x1b[32m\r\nRestarting shell\x1b[0m\r\nAll plugins have been reloaded\r\n',
  '\r\nLinux kernel has been updated. Reboot? Run omarchy-system reboot when ready.\r\n\x1b]5150;exit;0\x07'
].join('')

const whole = feedAll([transcript])
let stable = true
for (let round = 0; round < 50 && stable; round++) {
  const pieces = []
  for (let i = 0; i < transcript.length; ) { const n = 1 + Math.floor(Math.random() * 40); pieces.push(transcript.slice(i, i + n)); i += n }
  stable = view(feedAll(pieces)) === view(whole)
}
assert(stable, 'splitting the stream anywhere lands on the same picture')
assertEqual(JSON.stringify(Object.keys(whole.packages)), JSON.stringify(names), 'every upgraded package gets a tile, in order')
assert(names.every((n) => whole.packages[n] === 'done'), 'every package ends done')
assertEqual(whole.tools.map((t) => t.name).join(','), 'claude,pi', 'mise upgrades become developer tools')
assertEqual([whole.step, whole.exit, whole.errors.length].join(','), 'cleanup,0,0', 'a clean run ends in cleanup with exit 0')
assertEqual(whole.reboot, 'Linux kernel has been updated. Reboot?', 'the unattended reboot notice becomes a restart offer')
assertEqual(U.progress(whole), 1, 'a finished update is all the way there')

// Questions are pending until output follows them.
let s = U.create()
U.feed(s, 'Identifying face...\n')
assertEqual(s.auth, 'Identifying face...', 'face authentication shows while sudo waits')
U.feed(s, '\x1b]5150;pass')
assertEqual(s.ask, null, 'half a marker is held back')
U.feed(s, 'word\x07')
assertEqual(s.ask && s.ask.kind, 'password', 'the sudo prompt marker asks for the password')
U.feed(s, '\nSorry, try again.\n\x1b]5150;password\x07')
assert(s.ask.retry, 'a second password prompt after a failure is a retry')
U.feed(s, '\n\x1b[32m\nUpdate system packages\x1b[0m\n')
assertEqual([s.ask, s.step].join(','), ',packages', 'output after a question answers it')

U.feed(s, ':: Proceed with installation? [Y/n] ')
assertEqual([s.ask.kind, s.ask.question, s.ask.yes].join(','), 'pacman,Proceed with installation?,true', 'a pacman prompt left on the last line is a question')
U.feed(s, 'y\n(1/2) removing python-foo  [####] 100%\n')
assertEqual(s.ask, null, 'answering clears the question')
assert(!('python-foo' in s.packages), 'removals are not tiles')

// Other PAM modules, and prompts nobody planned for.
s = U.create()
U.feed(s, 'Please touch the device.\n')
assertEqual(s.auth, 'Please touch the device.', 'security keys show while sudo waits')
U.feed(s, '( 3/9) Updating fontconfig cache...\n')
assertEqual(s.auth, '', 'the next line clears the sign-in hint')
U.feed(s, "Enter PIN for 'YubiKey': ")
assertEqual([s.ask.kind, s.ask.secret, s.ask.question].join(','), "input,true,Enter PIN for 'YubiKey':", 'a PIN prompt is a secret input')
U.feed(s, ' Total ( 1/9)  1.2 MiB  3.4 MiB/s 00:01 [###---]  12%')
assertEqual(s.ask, null, 'download progress is not a question')

// One-click installs: what is being installed and what the installer said last.
s = U.create()
U.feed(s, 'Installing Chrome...\r\nresolving dependencies...\r\nPackages (2) libfoo-1-1 google-chrome-155-1\r\n:: Processing package changes...\r\n')
U.feed(s, bar('libfoo', 1, 2) + '\r\n' + bar('google-chrome', 2, 2) + '\r\nwarning: something\r\n\r\nChrome browser installed. Make it the default via Setup > Defaults > Browser.\r\n')
assertEqual(s.subject, 'Chrome', 'the installer names what it installs')
assertEqual(s.note, 'Chrome browser installed. Make it the default via Setup > Defaults > Browser.', "the installer's last word is kept")
assert(!s.opened && U.transfer(s) > 0.9, 'a finished transaction is nearly done')
assert(U.namesSubject('google-chrome', 'Chrome') && !U.namesSubject('libfoo', 'Chrome'), 'the app tile follows the package named like it')
U.feed(s, 'Opening Spotify...\r\n\x1b]5150;input;no;Icon URL/name> ;Could not fetch favicon\x07')
assert(s.opened, 'an installer that opens the app itself is noticed')
assertEqual([s.ask.kind, s.ask.secret, s.ask.question, s.ask.hint].join(','), 'input,false,Icon URL/name> ,Could not fetch favicon', 'the gum input marker carries its prompt')
U.feed(s, '\n\x1b]5150;confirm;no;Remove 2 packages?\x07')
assertEqual([s.ask.kind, s.ask.yes, s.ask.question].join(','), 'confirm,false,Remove 2 packages?', 'the gum confirm marker carries its default')
JS

# The gum stand-in turns confirm into a marker and reads the answer back.
if command -v script >/dev/null; then
  output=$(printf 'y\n' | script -qec "$ROOT/shell/plugins/update/shims/gum confirm --default=false --affirmative Yes 'Install it?' && echo yes" /dev/null 2>&1 | tr -d '\r')
  [[ $output == *$'\e]5150;confirm;no;Install it?\a'* && $output == *yes ]] || fail 'gum confirm becomes a window question' "$output"
  pass 'gum confirm becomes a window question'
fi

# sudo, pacman and yay speak English for the window to read, by their own name.
probe=$(mktemp -d)
ln -s "$ROOT/shell/plugins/update/shims/english" "$probe/env"
output=$(LC_ALL=de_DE.UTF-8 "$probe/env" | grep '^LC_ALL=')
rm -rf "$probe"
[[ $output == "LC_ALL=C.UTF-8" ]] || fail 'the tools the window reads run in English' "$output"
[[ $(readlink "$ROOT/shell/plugins/update/shims/sudo") == "english" && $(readlink "$ROOT/shell/plugins/update/shims/pacman") == "english" && $(readlink "$ROOT/shell/plugins/update/shims/yay") == "english" ]] ||
  fail 'the tools the window reads run in English' 'sudo, pacman and yay should link to shims/english'
pass 'the tools the window reads run in English'

# Inside the window, an installer handing over to another one runs in place.
output=$(OMARCHY_UPDATE_WINDOW=1 "$ROOT/bin/omarchy-launch-install" 'echo inline')
[[ $output == "inline" ]] || fail 'a nested install runs inside the window' "$output"
pass 'a nested install runs inside the window'

# The window can answer gum confirm and input, not draw a picker, an editor or
# a full-screen wizard, so an install it runs must not open one, nor any helper
# the install calls.
declare -A scanned
interactive() {
  local command=$1 depth=$2 script="$ROOT/bin/$1" next
  [[ -f $script && -z ${scanned[$command]:-} ]] || return 1
  scanned[$command]=1
  grep -v '^\s*#' "$script" | grep -qE 'gum (choose|filter|file|write)|\bfzf\b|[^-]onboard\b' && { echo "$command"; return 0; }
  (( depth < 4 )) || return 1
  for next in $(grep -v '^\s*#' "$script" | grep -oE '\bomarchy-[a-z0-9-]+' | sort -u); do
    interactive "$next" $((depth + 1)) && return 0
  done
  return 1
}
while IFS= read -r command; do
  scanned=()
  if culprit=$(interactive "${command%% *}" 0); then
    fail "installs opened in the update window ask nothing it cannot show" "${command%% *} reaches $culprit, which draws a picker or wizard; leave it in the terminal"
  fi
done < <(grep -o '"action":"omarchy-launch-install [^"]*"' "$ROOT/default/omarchy/omarchy-menu.jsonc" | sed "s/^\"action\":\"omarchy-launch-install //; s/\"\$//; s/'//g")
pass 'installs opened in the update window ask nothing it cannot show'
