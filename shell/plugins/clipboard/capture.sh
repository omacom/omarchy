#!/bin/bash

# Captures the current clipboard as a JSON entry on stdout. In watch mode,
# wl-paste invokes this with the payload on stdin and the mime as $1. Without
# arguments, it snapshots the current selection itself.

set -o pipefail

# Largest text entry kept inline in history, in bytes. ClipboardHistory.js holds
# the same limit in UTF-16 units, and a byte count is never smaller than the unit
# count of the text it decodes to, so an entry accepted here is accepted there.
ENTRY_LIMIT=${CLIPBOARD_ENTRY_LIMIT:-2097152}
# A copy over ENTRY_LIMIT is kept as a file with a short preview in history, up to
# this size; anything larger is reported as skipped.
LARGE_LIMIT=${CLIPBOARD_LARGE_LIMIT:-268435456}

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
IMAGE_DIR="$STATE_DIR/clipboard-images"
mkdir -p "$IMAGE_DIR"
TEXT_DIR="$STATE_DIR/clipboard-text"
PREVIEW_BYTES=8192

types=$(wl-paste --list-types 2>/dev/null || true)

if [[ ${CLIPBOARD_STATE:-} == "sensitive" ]] || grep -qx 'x-kde-passwordManagerHint' <<<"$types"; then
  exit 0
fi

emit_image() {
  local mime="$1"
  local ext tmp hash file

  ext=${mime#image/}
  [[ $ext == jpeg ]] && ext=jpg

  tmp=$(mktemp --tmpdir="$IMAGE_DIR" clipboard.XXXXXX) || return 0
  cat >"$tmp"
  if [[ ! -s $tmp ]]; then
    rm -f "$tmp"
    return 0
  fi

  hash=$(sha256sum "$tmp" | awk '{print $1}')
  file="$IMAGE_DIR/$hash.$ext"
  if [[ -e $file ]]; then
    rm -f "$tmp"
  else
    mv "$tmp" "$file"
  fi

  jq -cn --arg mime "$mime" --arg path "$file" --arg captured_at "$(date +'%A %H:%M')" \
    '{type:"image", mime:$mime, path:$path, capturedAt:$captured_at}'
}

emit_small_text() {
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
  '
}

emit_skipped() {
  printf '{"type":"skipped","reason":"too-large"}\n'
}

# A copy over the entry limit, kept as <sha256>.txt like an image. The encoding is
# decided from a sample, by the same NUL-padding test emit_small_text applies to
# the whole text, and converted as a stream, so the copy is never loaded whole.
emit_large_text() {
  local raw=$1 encoding converted bytes hash file

  encoding=$(head -c 65536 -- "$raw" | perl -0777 -ne '
    if (/^(?:\xFF\xFE|\xFE\xFF)/) { print "UTF-16"; exit }
    my $units = int(length($_) / 2);
    exit unless $units && index($_, "\0") >= 0;
    my ($even, $odd) = (0, 0);
    for (my $i = 0; $i + 1 < length($_); $i += 2) {
      $even++ if substr($_, $i, 1) eq "\0";
      $odd++ if substr($_, $i + 1, 1) eq "\0";
    }
    if ($odd * 4 >= $units * 3 && $even * 4 < $units) { print "UTF-16LE" }
    elsif ($even * 4 >= $units * 3 && $odd * 4 < $units) { print "UTF-16BE" }
  ')

  if [[ -n $encoding ]]; then
    converted=$(mktemp --tmpdir="$TEXT_DIR" clipboard.XXXXXX) || { rm -f -- "$raw"; return 0; }
    if iconv -f "$encoding" -t UTF-8 "$raw" >"$converted" 2>/dev/null; then
      mv -f -- "$converted" "$raw"
    else
      rm -f -- "$converted"
    fi
  fi

  bytes=$(stat -c %s -- "$raw")
  if (( bytes > LARGE_LIMIT )); then
    rm -f -- "$raw"
    emit_skipped
    return 0
  fi

  hash=$(sha256sum -- "$raw" | cut -d' ' -f1)
  file="$TEXT_DIR/$hash.txt"
  if [[ -f $file && ! -L $file ]]; then
    rm -f -- "$raw"
    # A fresh mtime keeps prune-text.sh from deleting it before its entry is back.
    touch -- "$file"
  else
    mv -f -- "$raw" "$file"
  fi

  head -c "$PREVIEW_BYTES" -- "$file" | iconv -c -f UTF-8 -t UTF-8 \
    | jq -cRs --arg path "$file" --argjson bytes "$bytes" '{type: "largetext", path: $path, bytes: $bytes, preview: .}'
}

# The copy goes to a file first, bounded at the large-copy limit, so neither this
# script nor the shell ever holds more of it than it keeps.
emit_text() {
  local raw size
  mkdir -p "$TEXT_DIR"
  raw=$(mktemp --tmpdir="$TEXT_DIR" clipboard.XXXXXX) || return 0
  head -c $((LARGE_LIMIT + 1)) >"$raw"
  size=$(stat -c %s -- "$raw")

  if (( size == 0 )); then
    rm -f -- "$raw"
  elif (( size > LARGE_LIMIT )); then
    rm -f -- "$raw"
    emit_skipped
  elif (( size <= ENTRY_LIMIT )); then
    emit_small_text <"$raw"
    rm -f -- "$raw"
  else
    emit_large_text "$raw"
  fi
}

case "${1:-}" in
text) emit_text; exit 0 ;;
image/*) emit_image "$1"; exit 0 ;;
esac

for mime in image/png image/jpeg image/webp image/gif image/bmp image/tiff; do
  if grep -qx "$mime" <<<"$types"; then
    timeout 2s wl-paste --type "$mime" 2>/dev/null | emit_image "$mime"
    exit 0
  fi
done

if grep -q '^text/' <<<"$types" || grep -qx 'UTF8_STRING' <<<"$types" || grep -qx 'STRING' <<<"$types"; then
  wl-paste --type text --no-newline 2>/dev/null | emit_text
fi
