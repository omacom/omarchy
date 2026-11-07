#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

skill="$ROOT/default/agents/skills/diagnose-crash/SKILL.md"
reporting="$ROOT/default/agents/skills/diagnose-crash/reporting.md"

grep -Fq 'gh search prs --repo omacom/omarchy' "$skill" ||
  fail "the diagnosis never searches pull requests, so a pending fix is reported again as a new issue"
pass "the diagnosis searches Omarchy pull requests"

grep -Fq 'gh pr list --repo omacom/omarchy --state all' "$reporting" ||
  fail "reporting searches only issues, missing open and merged pull requests"
pass "reporting searches open and closed pull requests"

grep -Fq 'omarchy-version' "$skill" && grep -Fq 'omarchy-channel-current' "$skill" ||
  fail "the diagnosis does not record the installed version and channel"
pass "the diagnosis records the installed version and channel"

grep -Fq 'gh auth status' "$skill" && grep -Fq 'https://github.com/omacom/omarchy/issues?q=' "$skill" ||
  fail "the diagnosis has no fallback when gh is missing or logged out"
pass "the diagnosis falls back to search links without gh"

! grep -q 'basecamp/omarchy' "$skill" "$reporting" ||
  fail "a skill searches basecamp/omarchy, which gh search cannot search"
pass "the skills search the canonical repository"
