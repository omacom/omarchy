#!/bin/bash

image_dirs=${1:-}
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/image-selector
index_file="$cache_dir/index.tsv"
pending_video_file=$(mktemp)
resolved_file=$(mktemp)

mkdir -p "$cache_dir"
trap 'rm -f "$pending_video_file" "$resolved_file"' EXIT

generate_video_thumbnail() {
  local image="$1"
  local thumbnail="$2"
  local lock="$thumbnail.lock"
  local lock_fd
  local tmp="$thumbnail.$$.jpg"

  if [[ -d $lock ]] && (( $(date +%s) - $(stat -c '%Y' "$lock" 2>/dev/null || date +%s) > 120 )); then
    rmdir "$lock" 2>/dev/null
  fi

  exec {lock_fd}>"$lock" || return
  flock -w 30 "$lock_fd" || return
  rm -f "$thumbnail".*.jpg

  [[ -f $thumbnail ]] && return

  if timeout -k 5 10 ffmpegthumbnailer -i "$image" -o "$tmp" -s 1536 -q 8 {lock_fd}>&-; then
    mv -f "$tmp" "$thumbnail"
  else
    status=$?
    rm -f "$tmp" "$thumbnail"
    # Remember a rejected video so it costs nothing on the next scan; the key
    # covers size and mtime, so a repaired file starts clean. A timeout is
    # left to retry: the machine may only have been busy.
    (( status == 124 || status == 137 )) || : >"$thumbnail.failed"
    return 1
  fi
}

drain_pending_video_thumbnails() {
  local video_jobs

  [[ -s $pending_video_file ]] || return 0

  video_jobs=$(( $(nproc) / 4 ))
  (( video_jobs > 0 )) || video_jobs=1
  export -f generate_video_thumbnail
  xargs -a "$pending_video_file" -0 -n 2 -P "$video_jobs" \
    bash -c 'generate_video_thumbnail "$1" "$2"' _ >/dev/null 2>&1 || true
}

# Resolve signatures, index lookups, and thumbnail hashes in one pass instead
# of forking stat/awk/md5sum per file, and only compute legacy content hashes
# when cache_dir actually holds unmatched .jpg thumbnails.
{
  while IFS= read -r dir; do
    [[ -n $dir && -d $dir ]] || continue
    find -L "$dir" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \
         -o -iname '*.mp4' -o -iname '*.m4v' -o -iname '*.mov' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.avi' \) \
      -print0 2>/dev/null
  done <<<"$image_dirs" | sort -z
} | python3 -c '
import hashlib
import os
import sys

cache_dir, index_file, pending_path, resolved_path = sys.argv[1:5]
VIDEO_EXTS = (".mp4", ".m4v", ".mov", ".webm", ".mkv", ".avi")

indexed = {}
try:
  with open(index_file, "r", encoding="utf-8", errors="surrogateescape") as f:
    for line in f:
      parts = line.rstrip("\n").split("\t")
      if len(parts) >= 3 and parts[2]:
        indexed.setdefault((parts[0], parts[1]), parts[2])
except OSError:
  pass

cached_jpgs = set()
failed_markers = set()
try:
  with os.scandir(cache_dir) as it:
    for entry in it:
      if not entry.is_file():
        continue
      name = entry.name
      if name.endswith(".jpg"):
        cached_jpgs.add(name)
      elif name.endswith(".jpg.failed"):
        failed_markers.add(name)
except OSError:
  pass

raw_paths = sys.stdin.buffer.read().split(b"\0")
entries = []
matched_jpgs = set()

for raw in raw_paths:
  if not raw:
    continue
  image = os.fsdecode(raw)
  try:
    st = os.stat(image)
  except OSError:
    continue
  sig = f"{st.st_size}:{int(st.st_mtime)}"
  h = indexed.get((image, sig))
  if not h:
    h = hashlib.md5(f"{image}\t{sig}".encode("utf-8", "surrogateescape")).hexdigest()
  jpg_name = f"{h}.jpg"
  if jpg_name in cached_jpgs:
    matched_jpgs.add(jpg_name)
  is_video = image.lower().endswith(VIDEO_EXTS)
  entries.append((image, is_video, os.path.join(cache_dir, jpg_name), jpg_name))

has_legacy_candidates = bool(cached_jpgs - matched_jpgs)
pending = []
resolved = []

for image, is_video, thumbnail, jpg_name in entries:
  if is_video:
    if jpg_name in cached_jpgs:
      resolved.append((image, True, thumbnail))
    elif f"{jpg_name}.failed" not in failed_markers:
      pending.append((image, thumbnail))
      resolved.append((image, True, thumbnail))
  else:
    if jpg_name in cached_jpgs:
      resolved.append((image, False, thumbnail))
    else:
      chosen = image
      if has_legacy_candidates:
        try:
          with open(image, "rb") as f:
            legacy_name = hashlib.file_digest(f, "md5").hexdigest() + ".jpg"
          if legacy_name in cached_jpgs:
            chosen = os.path.join(cache_dir, legacy_name)
        except OSError:
          pass
      resolved.append((image, False, chosen))

if pending:
  with open(pending_path, "wb") as pf:
    for image, thumbnail in pending:
      pf.write(os.fsencode(image) + b"\0" + os.fsencode(thumbnail) + b"\0")
  with open(resolved_path, "wb") as rf:
    for image, is_video, thumbnail in resolved:
      rf.write(
        os.fsencode(image) + b"\0"
        + (b"1" if is_video else b"0") + b"\0"
        + os.fsencode(thumbnail) + b"\0"
      )
else:
  out = sys.stdout.buffer
  for image, _, thumbnail in resolved:
    out.write(os.fsencode(image) + b"\t" + os.fsencode(thumbnail) + b"\n")
' "$cache_dir" "$index_file" "$pending_video_file" "$resolved_file"

if [[ -s $pending_video_file ]]; then
  drain_pending_video_thumbnails
  while IFS= read -r -d '' image && IFS= read -r -d '' is_video && IFS= read -r -d '' thumbnail; do
    if [[ $is_video == "0" || -f $thumbnail ]]; then
      printf '%s\t%s\n' "$image" "$thumbnail"
    fi
  done <"$resolved_file"
fi
