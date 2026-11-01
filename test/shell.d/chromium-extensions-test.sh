#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Chromium derives an extension's id from its public key: the first 128 bits of
# its SHA-256, each hex digit spelled a-p.
extension_id() {
  jq -r .key "$1" | base64 -d | sha256sum | cut -c1-32 | tr '0-9a-f' 'a-p'
}

# --- Bundled extensions ---

# A keyless unpacked extension gets a path-derived id, so its settings, shortcut
# registrations and native host grants would go stale whenever its load path
# changed. The pinned key keeps the id stable everywhere, and a regenerated key
# would orphan the same things, so the ids that shipped stay pinned here.
declare -A shipped_id=(
  [copy-url]=bgpiichlckmfanooecilcjemknkcpngb
  [whatsapp-slim]=amhpgjbcfakkmkeojmoaoiochhifohdi
  [yt-dlp]=dedjgknigfeelejglamclffonmophnfl
)
declare -A extension_manifest
for manifest in "$ROOT"/default/chromium/extensions/*/manifest.json; do
  extension_dir=${manifest%/manifest.json}
  name=${extension_dir##*/}
  jq -e '.key | type == "string"' "$manifest" >/dev/null || fail "the $name extension pins its id with a manifest key"
  id=$(extension_id "$manifest")
  [[ $id =~ ^[a-p]{32}$ ]] || fail "the $name extension's key decodes to an extension id" "got: $id"
  [[ -z ${shipped_id[$name]:-} || $id == "${shipped_id[$name]}" ]] ||
    fail "the $name extension keeps the id it shipped with" "got: $id"
  extension_manifest[$id]=$manifest

  while read -r file; do
    [[ -f $extension_dir/$file ]] || fail "the $name extension ships $file, which its manifest loads"
  done < <(jq -r '[.background.service_worker, (.content_scripts[]? | .js[]?, .css[]?), (.icons // {} | .[])] | .[] | strings' "$manifest")
done
pass "each bundled Chromium extension pins its id and ships the files its manifest loads"

# --- Native messaging hosts ---

# Each host admits exactly the bundled extensions whose scripts message it, and
# each extension that asks for native messaging has a host admitting its id.
declare -A hosted
for template in "$ROOT"/default/chromium/native-messaging-hosts/*.json; do
  host=$(basename "$template" .json)
  [[ $(jq -r .name "$template") == "$host" ]] || fail "native host $host is named after its manifest file"
  senders=$(
    for id in "${!extension_manifest[@]}"; do
      if grep -rqF -e "sendNativeMessage('$host'" -e "sendNativeMessage(\"$host\"" \
        -e "connectNative('$host'" -e "connectNative(\"$host\"" "$(dirname "${extension_manifest[$id]}")"; then
        printf 'chrome-extension://%s/\n' "$id"
      fi
    done | sort
  )
  [[ -n $senders && $(jq -r '.allowed_origins[]' "$template" | sort) == "$senders" ]] ||
    fail "native host $host admits exactly the extensions that message it" "admits: $(jq -c .allowed_origins "$template"), messaged by: ${senders:-none}"
  while read -r origin; do
    id=${origin#chrome-extension://}
    id=${id%/}
    [[ $origin == "chrome-extension://$id/" && -v extension_manifest[$id] ]] ||
      fail "native host $host admits only bundled extensions" "origin: $origin"
    jq -e '.permissions | index("nativeMessaging")' "${extension_manifest[$id]}" >/dev/null ||
      fail "native host $host admits an extension that asks for native messaging" "origin: $origin"
    hosted[$id]=1
  done < <(jq -r '.allowed_origins[]' "$template")
done
for id in "${!extension_manifest[@]}"; do
  if jq -e '.permissions | index("nativeMessaging")' "${extension_manifest[$id]}" >/dev/null; then
    [[ -v hosted[$id] ]] || fail "a native host admits the $(basename "$(dirname "${extension_manifest[$id]}")") extension's id $id"
  fi
done
pass "each native messaging host admits exactly the bundled extension that talks to it"

# Chromium ships in the base packages, so fresh installs do not go through
# omarchy-install-browser and mark every migration as already applied. The user
# install has to register the hosts itself.
home="$test_tmp/home"
HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  bash -euo pipefail -c 'source "$ROOT/install/user/chromium.sh"' ||
  fail "the user install registers the Chromium native messaging hosts"

for template in "$ROOT"/default/chromium/native-messaging-hosts/*.json; do
  host=$(basename "$template" .json)
  for profile in chromium BraveSoftware/Brave-Origin; do
    installed="$home/.config/$profile/NativeMessagingHosts/$host.json"
    [[ -f $installed ]] || fail "a fresh install registers native host $host for $profile"
    path=$(jq -r .path "$installed")
    [[ $path == "$ROOT/bin/"* && -x $path ]] ||
      fail "native host $host for $profile runs an Omarchy host command" "path: $path"
    [[ $(jq -c .allowed_origins "$installed") == "$(jq -c .allowed_origins "$template")" ]] ||
      fail "native host $host for $profile admits the bundled extension"
  done
done
pass "a fresh install registers every native messaging host for Chromium and Brave Origin"

# --- WhatsApp Slim ---

# The content script switches WhatsApp Web to its system theme mode, which it
# only reads at startup, so it reloads once; with the mode already set it must
# not reload again, or the page would never finish loading.
if command -v node >/dev/null; then
  reloads=$(node - "$ROOT/default/chromium/extensions/whatsapp-slim/system-theme.js" <<'JS'
const fs = require("fs")
const source = fs.readFileSync(process.argv[2], "utf8")
const values = new Map()
const reloads = []
global.localStorage = {
  getItem: key => values.get(key),
  setItem: (key, value) => values.set(key, value),
}
for (const run of [1, 2]) {
  global.location = { reload: () => reloads.push(run) }
  eval(source)
}
process.stdout.write(`${values.get("system-theme-mode")}:${reloads.join(",")}`)
JS
  )
  [[ $reloads == "true:1" ]] || fail "WhatsApp selects its system theme mode and reloads only once" "$reloads"
  pass "WhatsApp follows the system theme through its slim extension"
else
  skip "node is not installed; skipping the WhatsApp Slim content script check"
fi
