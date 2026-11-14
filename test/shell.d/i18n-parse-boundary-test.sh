#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

LEDGER="$SHELL_TEST_DIR/i18n-parse-boundary.txt"

# The shipped tree only. A caller under test/ comparing English output needs its
# locale pinned, which is a different fix from either kind in the ledger.
SHIPPED_DIRS=(bin shell config default migrations install)

# Every derivation below is an `rg -P` call whose failure is swallowed, so an rg
# that is missing, or built without PCRE2, derives nothing and the first thing to
# fail is the staleness check reporting the entire ledger. Name what is missing.
require_command rg
printf 'x\n' | rg -q -P 'x' || fail "rg is built with PCRE2, which every derivation here needs"

# `var=$(omarchy-thing)` on one line and `[[ $var == ready ]]` on another is the
# same crossing as doing both at once, so each capture is paired with its own
# file before the comparison is looked for.
derive_indirect_crossings() {
  local file variable command

  while IFS=: read -r file variable command; do
    if rg -q -P '\$\{?'"$variable"'\}?\\?"?[[:space:]]*[=!]=[[:space:]]*\\?"?[A-Za-z]|case[[:space:]]+\\?"?\$\{?'"$variable"'\}?\\?"?[[:space:]]+in' "$file"; then
      printf '%s\n' "$command"
    fi
  done < <(rg -HNo -P -r '$1:$2' '\b([A-Za-z_][A-Za-z0-9_]*)=\\?"?\$\((omarchy-[a-z0-9-]+)[^)]*\)' "$@" || true)
}

# Derived rather than hand-listed, because a hand-list rots. What it derives is a
# set of comparison shapes: `==` or `!=` against a bare or double-quoted literal
# with the command on either side, and `case`. That covers the way the tree writes
# a boundary today, which is not the same as every way one could be written.
derive_crossings() {
  local root=$1
  local dirs=() dir

  for dir in "${SHIPPED_DIRS[@]}"; do
    [[ -d $root/$dir ]] && dirs+=("$root/$dir")
  done

  # A derivation that reads nothing must not read as a clean tree.
  (( ${#dirs[@]} )) || return 1

  {
    rg -INo -P -r '$1' '\$\((omarchy-[a-z0-9-]+)[^)]*\)[^=!\n]{0,40}[=!]=[[:space:]]*\\?"?[A-Za-z]' "${dirs[@]}" || true
    rg -INo -P -r '$1' '[=!]=[[:space:]]*\\?"?\$\((omarchy-[a-z0-9-]+)[^)]*\)' "${dirs[@]}" || true
    rg -INo -P -r '$1' 'case[[:space:]]+\\?"?\$\((omarchy-[a-z0-9-]+)[^)]*\)' "${dirs[@]}" || true
    derive_indirect_crossings "${dirs[@]}"
  } | sort -u
}

ledger_field() {
  awk -F'\t' -v want="$1" '!/^#/ && NF && (want == "" || $2 == want) { print $1 }' "$LEDGER" | sort -u
}

# The ledger is only as good as its shape, so check that before trusting it. A
# line that ends at its second tab still has three fields as far as awk is
# concerned, so a missing vocabulary has to be named rather than counted.
# Declaring one command twice is the shape that hides itself: `ledger_field`
# sorts unique, so a command recorded as both a protocol and a prose bug reaches
# every later check as one entry that agrees with itself.
#
# Taking the path as an argument is what lets the fixtures below show that each
# of these is a problem the check reports rather than one it reads past.
ledger_problems() {
  awk -F'\t' -v ledger="$1" '
    /^#/ || !NF { next }
    { entries++ }
    NF != 3 { print ledger ":" FNR ": not three tab-separated fields: " $0; next }
    $1 !~ /^omarchy-[a-z0-9-]+$/ { print ledger ":" FNR ": not a command name: " $1 }
    $2 != "protocol" && $2 != "prose" { print ledger ":" FNR ": neither protocol nor prose: " $2 }
    $3 !~ /[^[:space:]]/ { print ledger ":" FNR ": no vocabulary recorded: " $1 }
    seen[$1]++ { print ledger ":" FNR ": declared more than once: " $1 }
    END { if (!entries) print ledger ": declares no command at all" }
  ' "$1"
}

problems=$(ledger_problems "$LEDGER")
[[ -z $problems ]] || fail "every ledger entry is one command, a known kind, and a vocabulary" "$problems"
pass "the ledger is well formed"

declared=$(ledger_field "")

missing_commands=$(comm -23 <(printf '%s\n' "$declared") <(ls "$ROOT/bin" | sort))
[[ -z $missing_commands ]] || fail "every declared command still exists in bin/" "$missing_commands"
pass "every declared command still exists in bin/"

derived=$(derive_crossings "$ROOT") || fail "the derivation found directories to read"

undeclared=$(comm -13 <(printf '%s\n' "$declared") <(printf '%s\n' "$derived"))
[[ -z $undeclared ]] || fail "every command whose output is parsed is declared in the ledger" \
  "$(printf 'undeclared parse boundary:\n%s\nclassify each in %s\n' "$undeclared" "${LEDGER#"$ROOT"/}")"
pass "every parsed command is declared"

stale=$(comm -23 <(printf '%s\n' "$declared") <(printf '%s\n' "$derived"))
[[ -z $stale ]] || fail "the ledger records no boundary that has gone away" "$stale"
pass "the ledger records no boundary that has gone away"

# The point of the whole file: a protocol vocabulary must survive translation,
# which means it must never be marked for it in the first place.
#
# Ask bash rather than grepping for `$"`. A regex cannot tell bash's translation
# marker from a regex anchor inside an already-open string, and the shipped tree
# has thirteen of the latter: `gsub("^ +| +$"; "")`, `"...{40}$"`, `"$$"`.
# `--dump-po-strings` is bash's own gettext extractor, so it agrees with the
# shell that would run the file.
translation_markers() {
  local file=$1 strings

  strings=$(bash --dump-po-strings "$file") || return 2
  [[ -n $strings ]]
}

# `gettext "..."` is a command call rather than a marker, so bash does not dump
# it and it has to be looked for separately. GNU gettext's shell set is wider
# than `gettext`: `ngettext` and the `eval_` forms mark a string just as well,
# and `\bgettext\b` matches none of them because the boundary it wants is inside
# the word. Matching the word anywhere is wrong in the other direction too, since
# a comment is free to talk about gettext and this file does. So look for a call:
# the name at a command position, with comment-only lines blanked out first to
# keep the line numbers. A trailing comment on a line of code is the one shape
# this still reads as a call.
gettext_calls() {
  local file=$1

  awk '/^[[:space:]]*#/ { print ""; next } { print }' "$file" |
    rg -n -P '(?:^|[;&|(]|\b(?:then|else|do)\b)[[:space:]]*(?:eval_)?n?p?gettext\b' || true
}

marked=$(while read -r command; do
  status=0
  translation_markers "$ROOT/bin/$command" >/dev/null 2>&1 || status=$?

  if (( status == 0 )); then
    printf '%s\tmarks a string with $"..."\n' "$command"
  elif (( status == 2 )); then
    printf '%s\tcould not be parsed by bash\n' "$command"
  fi

  while IFS= read -r hit; do
    printf '%s\tcalls gettext: %s\n' "$command" "$hit"
  done < <(gettext_calls "$ROOT/bin/$command")
done < <(ledger_field protocol))
[[ -z $marked ]] || fail "no protocol command marks its output for translation" "$marked"
pass "no protocol command marks its output for translation"

# Everything above passes on a tree with no i18n in it at all, so prove each
# check can still fail. A guard nothing can fail is a guard nobody should trust.
fixture_root=$(mktemp -d)
trap 'rm -rf "$fixture_root"' EXIT

mkdir -p "$fixture_root/bin"

# The shipped ledger is sound, so the shape problems have to be demonstrated on
# ledgers that are not.
printf 'omarchy-dns\tprotocol\tCustom\n' >"$fixture_root/ledger-sound.txt"
[[ -z $(ledger_problems "$fixture_root/ledger-sound.txt") ]] \
  || fail "a sound ledger reports no problem" "$(ledger_problems "$fixture_root/ledger-sound.txt")"
pass "a sound ledger reports no problem"

printf '# a header and nothing else\n' >"$fixture_root/ledger-empty.txt"
[[ -n $(ledger_problems "$fixture_root/ledger-empty.txt") ]] \
  || fail "a ledger that declares nothing is a problem"
pass "a ledger that declares nothing is a problem"

printf 'omarchy-dns\tprotocol\t\n' >"$fixture_root/ledger-no-vocabulary.txt"
[[ -n $(ledger_problems "$fixture_root/ledger-no-vocabulary.txt") ]] \
  || fail "an entry that records no vocabulary is a problem"
pass "an entry that records no vocabulary is a problem"

printf 'omarchy-dns\tprotocol\tCustom\nomarchy-dns\tprose\tCustom\n' >"$fixture_root/ledger-conflicting.txt"
[[ -n $(ledger_problems "$fixture_root/ledger-conflicting.txt") ]] \
  || fail "one command declared under both kinds is a problem"
pass "one command declared under both kinds is a problem"
cat >"$fixture_root/bin/omarchy-fixture-state" <<'FIXTURE'
#!/bin/bash
echo "Custom"
FIXTURE
cat >"$fixture_root/bin/omarchy-fixture-caller" <<'FIXTURE'
#!/bin/bash
[[ $(omarchy-fixture-state) == "Custom" ]] && echo same
FIXTURE
cat >"$fixture_root/bin/omarchy-fixture-indirect" <<'FIXTURE'
#!/bin/bash
state=$(omarchy-fixture-later)
[[ $state == "Custom" ]] && echo same
FIXTURE

fixture_derived=$(derive_crossings "$fixture_root")
[[ $fixture_derived == *omarchy-fixture-state* ]] || fail "a same-line parse boundary is derived" "got: $fixture_derived"
pass "a same-line parse boundary is derived"

[[ $fixture_derived == *omarchy-fixture-later* ]] || fail "a parse boundary through a variable is derived" "got: $fixture_derived"
pass "a parse boundary through a variable is derived"

if derive_crossings "$fixture_root/bin" >/dev/null 2>&1; then
  fail "a derivation with no directory to read reports failure"
fi
pass "a derivation with no directory to read reports failure"

printf '#!/bin/bash\necho $"Custom"\n' >"$fixture_root/bin/omarchy-fixture-marked"
translation_markers "$fixture_root/bin/omarchy-fixture-marked" \
  || fail "the translation-marker scan catches a marked string"
pass "the translation-marker scan catches a marked string"

# The regex this check replaced flagged all of these, and a protocol command is
# free to contain any of them.
printf '#!/bin/bash\ngrep -q "^ +$" x\necho "$$"\njq \047gsub("^ +| +$"; "")\047\n' \
  >"$fixture_root/bin/omarchy-fixture-anchors"
if translation_markers "$fixture_root/bin/omarchy-fixture-anchors"; then
  fail "a regex anchor before a closing quote is not a translation marker"
fi
pass "a regex anchor before a closing quote is not a translation marker"

cat >"$fixture_root/bin/omarchy-fixture-gettext-family" <<'FIXTURE'
#!/bin/bash
ngettext "one" "many" "$count"
eval_ngettext "one" "many"
eval_pgettext "menu" "Custom"
FIXTURE
(( $(gettext_calls "$fixture_root/bin/omarchy-fixture-gettext-family" | wc -l) == 3 )) \
  || fail "every shell command in gettext's set counts as a call" \
    "$(gettext_calls "$fixture_root/bin/omarchy-fixture-gettext-family")"
pass "every shell command in gettext's set counts as a call"

# The pattern this check replaced flagged both of these, and this file's own
# comments are written the first way.
cat >"$fixture_root/bin/omarchy-fixture-gettext-comment" <<'FIXTURE'
#!/bin/bash
# `gettext "..."` is a command call rather than a marker.
  # then gettext, else ngettext: still only a comment.
FIXTURE
[[ -z $(gettext_calls "$fixture_root/bin/omarchy-fixture-gettext-comment") ]] \
  || fail "a comment that says gettext is not a call" \
    "$(gettext_calls "$fixture_root/bin/omarchy-fixture-gettext-comment")"
pass "a comment that says gettext is not a call"

printf '#!/bin/bash\nif then fi (\n' >"$fixture_root/bin/omarchy-fixture-broken"
broken_status=0
translation_markers "$fixture_root/bin/omarchy-fixture-broken" >/dev/null 2>&1 || broken_status=$?
(( broken_status == 2 )) || fail "a file bash cannot parse is reported rather than passed" \
  "got status $broken_status"
pass "a file bash cannot parse is reported rather than passed"
