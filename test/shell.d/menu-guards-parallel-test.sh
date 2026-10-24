#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Guards and readers run side by side. Each pair below only finishes if both
# halves run at once: one leaves its mark and waits for the other's, so a
# batch that ran them one after another would time out instead of answering.
parallel_root=$(mktemp -d)
trap 'rm -rf "$parallel_root"' EXIT

rendezvous_script=$(node -e '
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  const meet = (mine, theirs) => `touch "$MEET/${mine}"; for _ in {1..40}; do [[ -e "$MEET/${theirs}" ]] && exit 0; sleep 0.05; done; exit 1`
  process.stdout.write(menu.guardScript({
    a: { id: "a", when: `(${meet("a", "b")})` },
    b: { id: "b", when: `(${meet("b", "a")})` },
    dns: { id: "dns", checked: "[[ \"$(omarchy-dns)\" == \"Cloudflare\" ]]" },
    google: { id: "google", checked: "[[ \"$(omarchy-dns)\" == \"Google\" ]]" },
    corners: { id: "corners", checked: "[[ \"$(omarchy-hyprland-corners)\" == \"round\" ]]" }
  }))
')

# The DNS reader also prints extra trailing newlines, which `$(...)` drops and
# the captured answer has to drop too.
mkdir -p "$parallel_root/meet"
rendezvous_result=$(MEET="$parallel_root/meet" bash -e -c '
omarchy-dns() { touch "$MEET/dns"; for _ in {1..40}; do [[ -e $MEET/corners ]] && break; sleep 0.05; done; [[ -e $MEET/corners ]] && printf "Cloudflare\n\n"; }
omarchy-hyprland-corners() { touch "$MEET/corners"; for _ in {1..40}; do [[ -e $MEET/dns ]] && break; sleep 0.05; done; [[ -e $MEET/dns ]] && printf "round\n"; }
export -f omarchy-dns omarchy-hyprland-corners
'"$rendezvous_script" | sort | tr '\n' ' ')
[[ $rendezvous_result == "a:w:1 b:w:1 corners:c:1 dns:c:1 google:c:0 " ]] ||
  fail "guard batch runs guards and readers side by side and reports every row once" "got: $rendezvous_result"
pass "guard batch runs guards and readers side by side and reports every row once"

# A reader's output arrives exactly as `$(...)` would have left it: leading
# and inner whitespace kept, every trailing newline dropped, and nothing at all
# when it prints only newlines or nothing.
shape_script=$(node -e '
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  process.stdout.write(menu.guardScript({
    shape: { id: "shape", checked: "[[ \"$(omarchy-dns)\" == \"  two  words\"$'"'"'\\n'"'"'\"line\" ]]" },
    blank: { id: "blank", checked: "[[ -z \"$(omarchy-hyprland-corners)\" ]]" }
  }))
')
shape_result=$(bash -c '
omarchy-dns() { printf "  two  words\nline\n\n\n"; }
omarchy-hyprland-corners() { printf "\n\n"; }
export -f omarchy-dns omarchy-hyprland-corners
'"$shape_script" | sort | tr '\n' ' ')
[[ $shape_result == "blank:c:1 shape:c:1 " ]] ||
  fail "a captured reader keeps exactly what \$(...) keeps" "got: $shape_result"
pass "a captured reader keeps exactly what \$(...) keeps"

# The batch is done only when every group is: a slow guard's line still
# arrives before it exits.
slow_script=$(node -e '
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  const items = {}
  for (let i = 0; i < 20; i++) items[`row${i}`] = { id: `row${i}`, when: i === 7 ? "sleep 0.3" : "true" }
  process.stdout.write(menu.guardScript(items))
')
slow_output=$(bash -c "$slow_script")
(($(sort -u <<<"$slow_output" | wc -l) == 20)) || fail "guard batch waits for its slowest group" "got: $slow_output"
grep -qx 'row7:w:1' <<<"$slow_output" || fail "guard batch waits for its slowest group" "row7 missing"
pass "guard batch exits only after its slowest group has answered"

# A user guard that exits, execs, fails to parse or trips a login shell's `set -u`
# answers for its own row only: every other row is still answered, and the
# batch still succeeds, so the menu takes the answers. The menu keeps the last
# line per row, so that is the line read back for each. The other rows quote,
# since each guard reaches its eval inside single quotes.
for broken in 'exit 0' 'exit 3' 'exit 198' 'exec true' 'exec false' '[[ -n $OMARCHY_TEST_UNSET ]]' '[[ -n '; do
  broken_script=$(BROKEN="$broken" node -e '
    const path = require("path")
    const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
    const items = {}
    for (let i = 0; i < 20; i++) items[`row${i}`] = { id: `row${i}`, when: i === 3 ? process.env.BROKEN : "[[ \"it'"'"'s\" == '"'"'it'"'"'\\'"'"''"'"'s'"'"' ]]" }
    process.stdout.write(menu.guardScript(items))
  ')
  broken_output=$(env -u OMARCHY_TEST_UNSET bash -u -c "$broken_script" 2>/dev/null) ||
    fail "a batch with a broken guard ($broken) still succeeds"
  expected=""
  for i in {0..19}; do
    answer=1
    ((i == 3)) && [[ $broken != "exit 0" && $broken != "exec true" ]] && answer=0
    expected+="row$i:w:$answer "
  done
  result=""
  for i in {0..19}; do result+="$(grep "^row$i:" <<<"$broken_output" | tail -1 || :) "; done
  [[ $result == "$expected" ]] ||
    fail "a broken guard ($broken) answers for its own row only" "got: $result"
done
pass "a guard that exits, execs, fails to parse or trips set -u answers for its own row only"

no_guard_trips=$(node -e '
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  process.stdout.write(menu.guardScript({ set: { id: "set", when: "[[ -n $OMARCHY_TEST_UNSET ]]" } }))
')
no_guard_trips_output=$(OMARCHY_TEST_UNSET=set bash -u -c "$no_guard_trips") &&
  [[ $no_guard_trips_output == "set:w:1" ]] ||
  fail "the batch itself runs under set -u when no guard trips it" "got: ${no_guard_trips_output:-}"
pass "the batch itself runs under set -u when no guard trips it"
