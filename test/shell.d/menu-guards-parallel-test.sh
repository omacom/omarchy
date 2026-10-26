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

# A command several guards run first runs once, and each of them answers from
# the status it left, negated, chained or alone, exactly as running it again
# would. A guard that hands it to another shell, pipes its output or reads
# `$?` after it runs its own.
probe_script=$(node -e '
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  process.stdout.write(menu.guardScript({
    alone: { id: "alone", when: "omarchy-test-yes" },
    negated: { id: "negated", when: "! omarchy-test-yes" },
    either: { id: "either", when: "omarchy-test-no || true" },
    failed: { id: "failed", checked: "omarchy-test-no" },
    both: { id: "both", disabled: "omarchy-test-yes && false" },
    quoted: { id: "quoted", when: "bash -c '"'"'true && omarchy-test-yes && true'"'"'" },
    grouped: { id: "grouped", when: "{ omarchy-test-yes; } | grep -qx yes" },
    status: { id: "status", when: "omarchy-test-no || (( $? == 3 ))" }
  }))
')
probe_log="$parallel_root/probe.log"
probe_result=$(PROBE_LOG="$probe_log" bash -c '
omarchy-test-yes() { echo yes >>"$PROBE_LOG"; echo yes; }
omarchy-test-no() { echo no >>"$PROBE_LOG"; return 3; }
export -f omarchy-test-yes omarchy-test-no
'"$probe_script" | sort | tr '\n' ' ')
[[ $probe_result == "alone:w:1 both:d:0 either:w:1 failed:c:0 grouped:w:1 negated:w:0 quoted:w:1 status:w:1 " ]] ||
  fail "a probed command answers every guard as running it would" "got: $probe_result"
[[ $(sort "$probe_log" | tr '\n' ' ') == "no no yes yes yes " ]] ||
  fail "a command several guards run first runs once per batch" "ran: $(tr '\n' ' ' <"$probe_log")"
pass "a command several guards run first runs once per batch and answers each of them"

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

# A group that dies part way leaves its remaining rows unanswered, and the
# menu keeps its last complete answers only when the batch fails. Under a
# login shell's `set -u` an unset variable kills the group mid-guard.
nounset_script=$(node -e '
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  const items = {}
  for (let i = 0; i < 20; i++) items[`row${i}`] = { id: `row${i}`, when: i === 3 ? "[[ -n $OMARCHY_TEST_UNSET ]]" : "true" }
  process.stdout.write(menu.guardScript(items))
')
nounset_status=0
env -u OMARCHY_TEST_UNSET bash -u -c "$nounset_script" >/dev/null 2>&1 || nounset_status=$?
((nounset_status != 0)) || fail "a guard group that dies part way fails the batch"
bash -c "$nounset_script" >/dev/null 2>&1 || fail "a batch whose groups all finish succeeds"
OMARCHY_TEST_UNSET=set bash -u -c "$nounset_script" >/dev/null 2>&1 ||
  fail "the batch itself runs under set -u when no guard trips it"
pass "a guard group that dies part way fails the whole batch, so the menu keeps its last answers"
