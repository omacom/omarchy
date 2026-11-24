#!/bin/bash

# Captures the current clipboard as a JSON entry on stdout. In watch mode,
# wl-paste invokes this with the payload on stdin and the mime as $1. Without
# arguments, it snapshots the current selection itself.

set -o pipefail
umask 077

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
IMAGE_DIR="$STATE_DIR/clipboard-images"
mkdir -p "$IMAGE_DIR"
chmod 700 "$IMAGE_DIR"

types=$(timeout 2s wl-paste --list-types 2>/dev/null || true)

if [[ ${CLIPBOARD_STATE:-} == "sensitive" ]] || grep -qx 'x-kde-passwordManagerHint' <<<"$types"; then
  exit 0
fi

tmp=
html_tmp=
text_check_tmp=
trap 'rm -f -- "$tmp" "$html_tmp" "$text_check_tmp"' EXIT

# Rich text kept beside a text entry is capped so a huge page copy can't bloat
# the history file; past the cap the entry keeps its plain text only.
HTML_LIMIT=262144

# The clipboard owner streams the copy and can stall without closing its end, so
# every read is bounded, and a copy cut off at the deadline is dropped, not kept.
read_copy() {
  timeout 2s "$@" >"$tmp" 2>/dev/null && [[ -s $tmp ]]
}

# Copies from Slack, browsers and office apps also offer text/html, which holds
# their links and formatting. Read it so pasting from history can offer it again.
# The read stops one byte past the cap, so a huge page copy is never written out.
# The HTML is read after the text, so a newer copy could have replaced it in
# between; it's kept only when the clipboard still holds the same text.
read_html() {
  grep -qx 'text/html' <<<"$types" || return 1

  html_tmp=$(mktemp --tmpdir="$STATE_DIR" clipboard-html.XXXXXX) || return 1
  text_check_tmp=$(mktemp --tmpdir="$STATE_DIR" clipboard-check.XXXXXX) || return 1

  if timeout 2s wl-paste --type text/html --no-newline 2>/dev/null | head -c $(( HTML_LIMIT + 1 )) >"$html_tmp" &&
    [[ -s $html_tmp ]] && (( $(stat -c %s "$html_tmp") <= HTML_LIMIT )) &&
    timeout 2s wl-paste --type text --no-newline >"$text_check_tmp" 2>/dev/null &&
    cmp -s "$tmp" "$text_check_tmp"; then
    return 0
  fi

  rm -f "$html_tmp"
  html_tmp=
  return 1
}

emit_image() {
  local mime="$1"
  local ext hash file meta inode gen
  shift

  ext=${mime#image/}
  [[ $ext == "jpeg" ]] && ext=jpg
  [[ $ext =~ ^[A-Za-z0-9]+$ ]] || return 0

  tmp=$(mktemp --tmpdir="$IMAGE_DIR" clipboard.XXXXXX) || return 0
  read_copy "$@" || return

  hash=$(sha256sum "$tmp" | awk '{print $1}')
  file="$IMAGE_DIR/$hash.$ext"
  meta=$(
    {
      flock 9 || exit 1
      mv -f -- "$tmp" "$file" || exit 1
      gen=0
      [[ -f $IMAGE_DIR/.gen ]] && read -r gen <"$IMAGE_DIR/.gen" || true
      [[ $gen =~ ^[0-9]+$ ]] || gen=0
      gen=$((gen + 1))
      printf '%s\n' "$gen" >"$IMAGE_DIR/.gen"
      printf '%s %s\n' "$(stat -c '%i' -- "$file")" "$gen"
    } 9>"$IMAGE_DIR/.lock"
  ) || return 0
  read -r inode gen <<<"$meta"

  jq -cn --arg mime "$mime" --arg path "$file" --arg inode "$inode" --argjson gen "$gen" --arg captured_at "$(LC_TIME="$(omarchy-language locale 2>/dev/null)" date +'%A %H:%M')" \
    '{type:"image", mime:$mime, path:$path, inode:$inode, gen:$gen, capturedAt:$captured_at}'
}

emit_text() {
  local entry

  tmp=$(mktemp --tmpdir="$STATE_DIR" clipboard.XXXXXX) || return 0
  read_copy "$@" || return

  entry=$(decode_text <"$tmp") || return
  [[ -n $entry ]] || return

  if read_html; then
    jq -c --rawfile html "$html_tmp" '. + {html: $html}' <<<"$entry"
  else
    printf '%s\n' "$entry"
  fi
}

decode_text() {
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
