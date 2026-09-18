#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

LEDGER="$SHELL_TEST_DIR/i18n-parse-boundary.txt"

# The shipped tree only. A caller under test/ comparing English output needs its
# locale pinned, which is a different fix from either kind in the ledger.
SHIPPED_DIRS=(bin shell config default migrations install)

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

# Derived rather than hand-listed: a hand-list rots, and the whole value of the
# ledger is that a new crossing cannot land unclassified.
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

# The ledger is only as good as its shape, so check that before trusting it.
malformed=$(awk -F'\t' '!/^#/ && NF && (NF != 3 || $1 !~ /^omarchy-[a-z0-9-]+$/ || ($2 != "protocol" && $2 != "prose")) { print FILENAME ":" FNR ": " $0 }' "$LEDGER")
[[ -z $malformed ]] || fail "every ledger entry is a command, a known kind, and a vocabulary" "$malformed"
pass "the ledger is well formed"

declared=$(ledger_field "")
(( $(printf '%s\n' "$declared" | wc -l) > 0 )) || fail "the ledger declares at least one command"

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
# has thirteen of the latter -- `gsub("^ +| +$"; "")`, `"...{40}$"`, `"$$"`.
# `--dump-po-strings` is bash's own gettext extractor, so it agrees with the
# shell that would run the file.
translation_markers() {
  local file=$1 strings

  strings=$(bash --dump-po-strings "$file") || return 2
  [[ -n $strings ]]
}

marked=$(while read -r command; do
  status=0
  translation_markers "$ROOT/bin/$command" >/dev/null 2>&1 || status=$?

  if (( status == 0 )); then
    printf '%s\tmarks a string with $"..."\n' "$command"
  elif (( status == 2 )); then
    printf '%s\tcould not be parsed by bash\n' "$command"
  fi

  # `gettext "..."` is a command call rather than a marker, so bash does not
  # dump it and it has to be looked for separately.
  rg -l -P '\bgettext\b|\beval_gettext\b' "$ROOT/bin/$command" || true
done < <(ledger_field protocol))
[[ -z $marked ]] || fail "no protocol command marks its output for translation" "$marked"
pass "no protocol command marks its output for translation"

# Everything above passes on a tree with no i18n in it at all, so prove each
# check can still fail. A guard nothing can fail is a guard nobody should trust.
fixture_root=$(mktemp -d)
trap 'rm -rf "$fixture_root"' EXIT

mkdir -p "$fixture_root/bin"
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

printf '#!/bin/bash\nif then fi (\n' >"$fixture_root/bin/omarchy-fixture-broken"
broken_status=0
translation_markers "$fixture_root/bin/omarchy-fixture-broken" >/dev/null 2>&1 || broken_status=$?
(( broken_status == 2 )) || fail "a file bash cannot parse is reported rather than passed" \
  "got status $broken_status"
pass "a file bash cannot parse is reported rather than passed"
