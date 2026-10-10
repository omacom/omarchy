#!/bin/bash

# Captures the current clipboard as a JSON entry on stdout. In watch mode,
# wl-paste invokes this with the payload on stdin and the mime as $1. Without
# arguments, it snapshots the current selection itself.

set -o pipefail

storage_script="$(dirname -- "${BASH_SOURCE[0]}")/storage.py"

[[ ${CLIPBOARD_STATE:-} == "sensitive" ]] && exit 0
# A clear during type enumeration or payload transfer invalidates this event;
# delayed producers must not repopulate history without a new copy.
generation=$(python3 "$storage_script" begin)
[[ $generation =~ ^[0-9a-f]{32}$ ]] || exit 0
types=$(timeout --kill-after=0.1s 2s wl-paste --list-types 2>/dev/null | head -c 65537) || exit 0
(( ${#types} <= 65536 )) || exit 0

if grep -qx 'x-kde-passwordManagerHint' <<<"$types"; then
  exit 0
fi

tmp=
trap 'rm -f -- "$tmp"' EXIT

# The clipboard owner streams the copy and can stall without closing its end, so
# every read is bounded, and a copy cut off at the deadline is dropped, not kept.
read_copy() {
  local limit=$1 status
  shift
  timeout --kill-after=0.1s 2s "$@" 2>/dev/null | head -c "$((limit + 1))" >"$tmp"
  status=$?
  if (( $(stat -c %s "$tmp") > limit )); then
    local message="This copy exceeds the clipboard history size limit and was not recorded. The current clipboard is unchanged."
    printf '%s\n' "$message" >&2
    timeout --kill-after=0.1s 1s omarchy-notification-send "Clipboard history" "$message" >/dev/null 2>&1 || true
    return 1
  fi
  (( status == 0 )) || return "$status"
  [[ -s $tmp ]]
}

emit_image() {
  local mime="$1"
  shift

  # The private staging file is bounded before hashing, decoding, or publishing.
  # Storage publishes the image and history reference in one locked transaction.
  tmp=$(mktemp --tmpdir="${XDG_RUNTIME_DIR:-/tmp}" omarchy-clipboard.XXXXXX) || return 0
  read_copy 16777216 "$@" || return

  python3 "$storage_script" image "$mime" "$(date +'%A %H:%M')" "$generation" <"$tmp"
}

emit_text() {
  tmp=$(mktemp --tmpdir="${XDG_RUNTIME_DIR:-/tmp}" omarchy-clipboard.XXXXXX) || return 0
  # Allow a UTF-16 representation plus its BOM; storage enforces 1 MiB after
  # decoding to UTF-8. Rejected copies are never truncated into history.
  read_copy 2097154 "$@" || return

  perl -MEncode=decode,FB_CROAK,LEAVE_SRC -MJSON::PP=encode_json -0777 -e '
    my $raw = <STDIN>;
    exit unless length $raw;

    my $encoding;
    my $heuristic_encoding = 0;
    if ($raw =~ /^(?:\xFF\xFE|\xFE\xFF)/) {
      $encoding = "UTF-16";
    } elsif (length($raw) % 2 == 0 && index($raw, "\0") >= 0) {
      my $units = length($raw) / 2;
      my $nuls = $raw =~ tr/\0/\0/;

      # Neither byte lane can reach the padding threshold when the entire
      # payload contains fewer NULs than that, so avoid two full string passes.
      if ($nuls * 4 >= $units * 3) {
        my $even_bytes = $raw;
        $even_bytes =~ s/(.)./$1/sg;
        my $even_nuls = $even_bytes =~ tr/\0/\0/;
        undef $even_bytes;

        my $odd_bytes = $raw;
        $odd_bytes =~ s/.(.)/$1/sg;
        my $odd_nuls = $odd_bytes =~ tr/\0/\0/;

        # BOM-less UTF-16 is indistinguishable from NUL-separated bytes. Decode
        # only when at least three quarters of the code units have consistent
        # padding and fewer than one quarter have NULs in the opposite byte.
        if ($odd_nuls * 4 >= $units * 3 && $even_nuls * 4 < $units) {
          $encoding = "UTF-16LE";
          $heuristic_encoding = 1;
        } elsif ($even_nuls * 4 >= $units * 3 && $odd_nuls * 4 < $units) {
          $encoding = "UTF-16BE";
          $heuristic_encoding = 1;
        }
      }
    }

    my $text = $encoding ? eval { decode($encoding, $raw, FB_CROAK | LEAVE_SRC) } : undef;
    if ($heuristic_encoding && defined($text) && $text =~ /[\x00-\x08\x0E-\x1A\x1C-\x1F]/) {
      $text = undef;
    }
    $text = decode("UTF-8", $raw) unless defined $text;
    print "{\"type\":\"text\",\"text\":", encode_json($text), "}\n";
  ' <"$tmp" | python3 "$storage_script" add "$generation"
}

case "${1:-}" in
text) emit_text cat; exit 0 ;;
image/*) emit_image "$1" cat; exit 0 ;;
esac

for mime in image/png image/jpeg image/webp image/gif image/bmp image/tiff; do
  if grep -qx "$mime" <<<"$types"; then
    emit_image "$mime" wl-paste --type "$mime"
    exit 0
  fi
done

if grep -q '^text/' <<<"$types" || grep -qx 'UTF8_STRING' <<<"$types" || grep -qx 'STRING' <<<"$types"; then
  emit_text wl-paste --type text --no-newline
fi
