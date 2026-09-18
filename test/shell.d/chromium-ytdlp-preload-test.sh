#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

host="$ROOT/bin/omarchy-chromium-ytdlp-host"

preload_state=$(
  LD_PRELOAD=browser-codec.so VIVALDI_PRELOADS=vivaldi-codecs.so \
    bash -c '
      source "$1"
      printf "LD_PRELOAD=%s\n" "${LD_PRELOAD-unset}"
      printf "VIVALDI_PRELOADS=%s\n" "${VIVALDI_PRELOADS-unset}"
    ' bash "$host" 2>/dev/null
)

[[ $preload_state == $'LD_PRELOAD=unset\nVIVALDI_PRELOADS=unset' ]] ||
  fail "yt-dlp native host drops browser codec preloads" "$preload_state"
pass "yt-dlp native host drops browser codec preloads"
