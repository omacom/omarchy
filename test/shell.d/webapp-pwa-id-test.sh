#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
export OMARCHY_WEBAPP_MAP="$tmp/webapps.map"
mkdir -p "$HOME"

id="$ROOT/bin/omarchy-webapp-id"

[[ -z $($id get "https://youtube.com/") ]] || fail "get on an empty map is silent"
pass "get on an empty map is silent"

$id set "https://youtube.com/" agimnkijcaahngcdmfeangaknmldooml
got=$($id get "https://youtube.com/")
[[ $got == "agimnkijcaahngcdmfeangaknmldooml" ]] || fail "set then get returns the app id" "$got"
got=$($id get "https://youtube.com")
[[ $got == "agimnkijcaahngcdmfeangaknmldooml" ]] || fail "get normalizes a trailing slash" "$got"
got=$($id get "https://youtube.com/watch?v=1")
[[ $got == "agimnkijcaahngcdmfeangaknmldooml" ]] || fail "get falls back to the origin for a path" "$got"
pass "webapp id map stores and normalizes the URL"

$id set "https://youtube.com/" otherid
got=$($id get "https://youtube.com/")
[[ $got == "otherid" ]] || fail "set replaces the id for the same URL" "$got"
pass "webapp id map replaces an existing URL"

$id delete "https://youtube.com/"
[[ -z $($id get "https://youtube.com/") ]] || fail "delete removes the mapping"
pass "webapp id map delete removes the mapping"
