#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick
require_command ffmpeg

test_tmp=$(mktemp -d)
export OMARCHY_PATH="$ROOT"
trap 'rm -rf "$test_tmp"' EXIT

# The script finishes with a clipboard write and a notification, and with no
# arguments it is menu-driven: stub all three so the test runs headless.
mkdir -p "$test_tmp/bin"
printf '#!/bin/bash\ncat > /dev/null\n' >"$test_tmp/bin/wl-copy"
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/omarchy-notification-send"
chmod +x "$test_tmp/bin/wl-copy" "$test_tmp/bin/omarchy-notification-send"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

export HOME="$test_tmp/home"
mkdir -p "$HOME"

run_transcode() {
  bash "$ROOT/bin/omarchy-transcode" "$@"
}

# Camera-style EXIF: asymmetric pixels reveal rotation/mirroring, not just
# swapped dimensions. Inject a minimal Orientation IFD without a new tool.
magick -size 120x80 xc:white -fill red -draw 'rectangle 0,0 59,39' \
  -fill blue -draw 'rectangle 60,0 119,39' -fill green -draw 'rectangle 0,40 59,79' \
  -quality 100 "$test_tmp/orientation-raw.jpg"
for tag in 6 2 1 0; do
  input="$test_tmp/orientation-$tag.jpg"
  if (( tag )); then
    {
      printf '\377\330\377\341\000\042Exif\000\000II\052\000\010\000\000\000\001\000\022\001\003\000\001\000\000\000'
      printf '%b' "$(printf '\\%03o' "$tag")"
      printf '\000\000\000\000\000\000\000'
      tail -c +3 "$test_tmp/orientation-raw.jpg"
    } >"$input"
  else
    cp "$test_tmp/orientation-raw.jpg" "$input"
  fi
  before=$(sha256sum "$input")
  transform=()
  case "$tag" in
  6) transform=(-rotate 90) ;;
  2) transform=(-flop) ;;
  esac
  magick "$test_tmp/orientation-raw.jpg" "${transform[@]}" -resize '64x64>' -strip "$test_tmp/orientation-expected.png"
  expected=$(magick identify -format '%w,%h' "$test_tmp/orientation-expected.png")
  for format in jpg png webp avif; do
    run_transcode "$input" "$format" high 64 cpu >"$test_tmp/orientation-$tag-$format.log" 2>&1 \
      || fail "EXIF orientation $tag exports as $format" "$(cat "$test_tmp/orientation-$tag-$format.log")"
    output="$test_tmp/orientation-$tag-64-high.$format"
    actual=$(magick identify -format '%w,%h' "$output[0]")
    [[ $actual == "$expected" ]] || fail "EXIF orientation $tag is applied before $format resizing" "$actual (expected $expected)"
    error=$(magick compare -metric RMSE "$test_tmp/orientation-expected.png" "$output[0]" null: 2>&1 || true)
    error=$(awk -F '[()]' '{ print $2 }' <<<"$error")
    awk -v e="$error" 'BEGIN { exit (e != "" && e + 0 < 0.04) ? 0 : 1 }' \
      || fail "EXIF orientation $tag has the intended $format pixels, including mirroring" "$error"
    profiles=$(magick identify -quiet -format '%[profiles]' "$output[0]")
    orientation=$(magick identify -format '%[orientation]' "$output[0]")
    [[ -z $profiles && ( $orientation == "Undefined" || $orientation == "TopLeft" ) ]] \
      || fail "the $format export needs no source metadata to display correctly" "$profiles $orientation"
    if (( tag == 0 )) && [[ $format == "jpg" ]]; then
      magick "$input" -resize '64x64>' -quality 85 -strip "$test_tmp/orientation-control.jpg"
      cmp -s "$output" "$test_tmp/orientation-control.jpg" || fail "untagged JPG output stays byte-identical"
    fi
  done
  [[ $(sha256sum "$input") == "$before" ]] || fail "orientation normalization leaves the camera original untouched"
done
pass "rotated, mirrored, normal and untagged photos export correctly without metadata or source changes"

# A 640x360 two-frame animated gif, a static gif, and a 128x128 two-frame
# transparent gif (a transparent index, so the alpha check fires).
magick -size 640x360 xc:red -fill blue -draw "circle 320,180 320,80" "$test_tmp/a1.png"
magick -size 640x360 xc:blue -fill red -draw "circle 320,180 320,80" "$test_tmp/a2.png"
magick "$test_tmp/a1.png" "$test_tmp/a2.png" -set delay 100 "$test_tmp/anim.gif"
magick "$test_tmp/a1.png" "$test_tmp/static.gif"
magick -size 128x128 xc:none -fill red -draw "circle 64,64 64,40" "$test_tmp/t1.png"
magick -size 128x128 xc:none -fill blue -draw "circle 64,64 64,40" "$test_tmp/t2.png"
magick "$test_tmp/t1.png" "$test_tmp/t2.png" -set delay 100 "$test_tmp/alpha.gif"

# Menu answers in call order: the axis, a resolution rung, then the format.
menu_log="$test_tmp/menu.log"
: >"$menu_log"
cat >"$test_tmp/bin/omarchy-menu-select" <<STUB
#!/bin/bash
echo "\$*" >> "$menu_log"
n=\$(cat "$test_tmp/menu-count" 2>/dev/null || echo 0)
answers=(Resolution 360 webp webp)
echo "\${answers[\$(( n % \${#answers[@]} ))]}"
echo \$(( n + 1 )) > "$test_tmp/menu-count"
STUB
chmod +x "$test_tmp/bin/omarchy-menu-select"

# A no-argument animated gif takes the axis flow: Resolution first, then the
# format menu offers every animated-capable output, and the rung sizes the
# longest side of the webp encode.
run_transcode "$test_tmp/anim.gif" >"$test_tmp/t1.log" 2>&1 || fail "a no-argument animated gif takes the resolution axis" "$(cat "$test_tmp/t1.log")"
grep -q '^Select resolution 640' "$menu_log" || fail "the gif resolution ladder starts at the longest side" "$(head -2 "$menu_log")"
grep -q ' webp avif gif mp4 webm$' "$menu_log" || fail "the animated gif format menu offers every animated output" "$(head -3 "$menu_log")"
w=$(magick identify -format '%w' "$test_tmp/anim-360.webp[0]")
(( w == 360 )) || fail "a picked rung sizes a gif's longest side for webp" "$w"
pass "a no-argument animated gif is resized from the longest side and offered every animated output"

# A static gif with an explicit video output takes the video path instead of
# dying in the picture encoder.
run_transcode "$test_tmp/static.gif" gif >"$test_tmp/t2.log" 2>&1 || fail "a static gif with an explicit gif output takes the video path" "$(cat "$test_tmp/t2.log")"
[[ -e $test_tmp/static-re.gif ]] || fail "a static gif re-encoded to gif is written"
pass "a static gif with an explicit video output is transcoded"

# A picked rung reaches the gif video encoder as a longest-side size.
run_transcode "$test_tmp/anim.gif" gif 360 >"$test_tmp/t3.log" 2>&1 || fail "a gif rung reaches the gif encoder" "$(cat "$test_tmp/t3.log")"
w=$(magick identify -format '%w' "$test_tmp/anim-360.gif[0]")
(( w == 360 )) || fail "a picked rung sizes a gif's longest side for gif" "$w"
pass "a picked rung sizes a gif's longest side for gif"

# A transparent gif encodes to avif at a picked rung: the alpha branch must
# build its magick resize from the rung, not from a ffmpeg scale string.
run_transcode "$test_tmp/alpha.gif" avif 128 >"$test_tmp/t4.log" 2>&1 || fail "a transparent gif encodes to avif at a picked rung" "$(cat "$test_tmp/t4.log")"
[[ -e $test_tmp/alpha-128.avif ]] || fail "the transparent gif's avif is written"
pass "a transparent gif encodes to avif at a picked rung"

# WebM advertises alpha in its container even when ffprobe's native decoder
# reports yuv420p. A CPU re-encode must restore that plane, not just stamp a
# fresh alpha_mode tag over opaque pixels.
run_transcode "$test_tmp/alpha.gif" webm '' 128 cpu >"$test_tmp/webm-alpha.log" 2>&1 \
  || fail "the transparent WebM fixture encodes" "$(cat "$test_tmp/webm-alpha.log")"
run_transcode "$test_tmp/alpha-128.webm" webm '' 64 cpu >"$test_tmp/webm-resize.log" 2>&1 \
  || fail "transparent WebM resizes on CPU" "$(cat "$test_tmp/webm-resize.log")"
ffmpeg -v error -y -c:v libvpx-vp9 -i "$test_tmp/alpha-128-64.webm" -frames:v 1 \
  -vf alphaextract "$test_tmp/webm-alpha.png"
mean=$(magick "$test_tmp/webm-alpha.png" -format '%[fx:mean]' info:)
awk -v a="$mean" 'BEGIN { exit (a >= 0 && a < 0.9) ? 0 : 1 }' \
  || fail "transparent WebM retains its alpha pixels when resized" "$mean"
pass "transparent WebM is decoded with its alpha plane before a CPU resize"

# Numeric video rungs are long-edge sizes in both orientations; the top
# menu entry is native, not the height of a landscape recording. Keep the
# explicit legacy height aliases working without advertising them as rungs.
for dims in 642x362 362x642; do
  ffmpeg -v error -y -f lavfi -i "color=c=red:s=$dims:r=2:d=1" -c:v libx264 "$test_tmp/$dims.mp4"
  : >"$menu_log"
  printf '0\n' >"$test_tmp/menu-count"
  run_transcode "$test_tmp/$dims.mp4" >"$test_tmp/ladder-$dims.log" 2>&1 \
    || fail "a video resolution rung converts $dims" "$(cat "$test_tmp/ladder-$dims.log")"
  grep -q '^Select resolution 642 640 540 512 480 360 256 128$' "$menu_log" \
    || fail "the video ladder is descending from the native long edge for $dims" "$(cat "$menu_log")"
  out_dims=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$test_tmp/$dims-360.mp4")
  if [[ $dims == "642x362" ]]; then expected=360,202; else expected=202,360; fi
  [[ $out_dims == "$expected" ]] || fail "the numeric rung bounds the long edge for $dims" "$out_dims"
  run_transcode "$test_tmp/$dims.mp4" mp4 '' 720p cpu >"$test_tmp/legacy-$dims.log" 2>&1 \
    || fail "an explicit legacy video height works for $dims" "$(cat "$test_tmp/legacy-$dims.log")"
  height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$test_tmp/$dims-720p.mp4")
  [[ $height == 720 ]] || fail "the legacy 720p argument remains an explicit height for $dims" "$height"
done
pass "landscape and portrait video ladders use the long edge, while explicit legacy heights still work"

# Cropped VP9 can have odd dimensions. The native ladder rung is numeric,
# unlike an empty native-size argument; both it and an explicit odd rung
# must still produce MP4 dimensions compatible with 4:2:0, in either orientation.
for dims in 1279x719 719x1279; do
  ffmpeg -v error -y -f lavfi -i "testsrc=s=$dims:r=2:d=1" -c:v libvpx-vp9 \
    -pix_fmt yuv420p -deadline realtime -cpu-used 8 "$test_tmp/odd-$dims.webm"
  input_dims=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$test_tmp/odd-$dims.webm")
  [[ $input_dims == "${dims/x/,}" ]] || fail "the cropped VP9 fixture really has odd dimensions" "$input_dims"
  for rung in '' 1279 1277; do
    run_transcode "$test_tmp/odd-$dims.webm" mp4 '' "$rung" cpu >"$test_tmp/odd-$dims-$rung.log" 2>&1 \
      || fail "cropped VP9 converts to MP4 at ${rung:-native} for $dims" "$(cat "$test_tmp/odd-$dims-$rung.log")"
    output="$test_tmp/odd-$dims${rung:+-$rung}.mp4"
    actual=$(ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=width,height,nb_read_frames -of csv=p=0 "$output")
    if [[ $rung == "1277" ]]; then
      if [[ $dims == "1279x719" ]]; then expected=1278,718,2; else expected=718,1278,2; fi
    else
      if [[ $dims == "1279x719" ]]; then expected=1280,720,2; else expected=720,1280,2; fi
    fi
    [[ $actual == "$expected" ]] || fail "MP4 rounds only the odd output edges and retains both frames" "$actual (expected $expected)"
  done
done
pass "cropped VP9 converts to MP4 at native size, the native numeric rung and an odd CLI rung in both orientations"

# Four real still-image routes: AVIF/WebP -> AVIF/WebP. Compare decoded alpha
# pixels after an arbitrary resize, not just the presence of an alpha tag.
require_command avifenc
require_command cwebp
magick -size 192x256 xc:none -fill '#ff000080' -draw 'rectangle 32,32 95,223' \
  -fill red -draw 'rectangle 96,32 159,223' "$test_tmp/still.png"
avifenc --codec aom --yuv 444 --min 20 --max 20 --qalpha 100 "$test_tmp/still.png" "$test_tmp/still.avif" >"$test_tmp/still-avif.log" 2>&1
cwebp -q 90 -alpha_q 100 -m 6 "$test_tmp/still.png" -o "$test_tmp/still.webp" >"$test_tmp/still-webp.log" 2>&1
for input_format in avif webp; do
  magick "$test_tmp/still.$input_format[0]" -resize '128x128>' -alpha extract "$test_tmp/expected-alpha.png"
  for output_format in avif webp; do
    # Separate input stems prevent a same-format run from replacing a fixture.
    cp "$test_tmp/still.$input_format" "$test_tmp/from-$input_format.$input_format"
    run_transcode "$test_tmp/from-$input_format.$input_format" "$output_format" high 128 cpu \
      >"$test_tmp/alpha-$input_format-$output_format.log" 2>&1 \
      || fail "still $input_format -> $output_format resizes" "$(cat "$test_tmp/alpha-$input_format-$output_format.log")"
    output="$test_tmp/from-$input_format-128-high.$output_format"
    dims=$(magick identify -format '%w %h' "$output[0]")
    [[ $dims == "96 128" ]] || fail "still $input_format -> $output_format respects the portrait long edge" "$dims"
    magick "$output[0]" -alpha extract "$test_tmp/actual-alpha.png"
    error=$(magick compare -metric RMSE "$test_tmp/expected-alpha.png" "$test_tmp/actual-alpha.png" null: 2>&1 || true)
    error=$(awk -F '[()]' '{ print $2 }' <<<"$error")
    awk -v e="$error" 'BEGIN { exit (e != "" && e + 0 <= 0.004) ? 0 : 1 }' \
      || fail "still $input_format -> $output_format preserves transparent and semitransparent pixels" "$error"
    pass "still $input_format -> $output_format preserves alpha pixels at an arbitrary portrait resize"
  done
done

# Hardware is a protocol fixture here, not a claim to have these GPUs in CI.
# Run the real vendor/node selection and gates; only ffmpeg's hardware
# inventory/probe is stubbed. Ordinary CPU encodes still use real ffmpeg.
(
  source "$ROOT/bin/omarchy-transcode"
  export OMARCHY_PCI_DEVICES_PATH="$test_tmp/pci"
  export OMARCHY_DRM_PATH="$test_tmp/drm" OMARCHY_DRI_PATH="$test_tmp/dri"
  mkdir -p "$OMARCHY_PCI_DEVICES_PATH/gpu" "$OMARCHY_DRM_PATH/renderD129/device/driver" "$OMARCHY_DRI_PATH"
  printf '0x030000\n' >"$OMARCHY_PCI_DEVICES_PATH/gpu/class"
  printf '0x10de\n' >"$OMARCHY_PCI_DEVICES_PATH/gpu/vendor"
  gpu_log="$test_tmp/gpu.log"
  inventory=av1_nvenc probe_failure=""
  ffmpeg() {
    printf '%s\n' "$*" >>"$gpu_log"
    if [[ $* == *-encoders* ]]; then
      printf '%s\n' "$inventory"
    elif [[ $* == *testsrc=* ]]; then
      if [[ $probe_failure == "memory" ]]; then
        echo CUDA_ERROR_OUT_OF_MEMORY >&2
        return 1
      elif [[ $probe_failure == "qsv" && $* == *av1_qsv* ]]; then
        echo 'Error initializing an MFX session' >&2
        return 1
      fi
    else
      command ffmpeg "$@"
    fi
  }
  omarchy-pkg-missing() { return 1; }
  : >"$gpu_log"
  gpu_av1_for_input "$test_tmp/alpha.gif" 128
  [[ -z $gpu_enc && ! -s $gpu_log ]] || fail "alpha is gated before hardware discovery or probing"
  gpu_av1_for_input "$test_tmp/alpha-128.webm" 128
  [[ -z $gpu_enc && ! -s $gpu_log ]] || fail "WebM alpha metadata also gates hardware before probing"
  inventory=""
  gpu_av1_for_input "$test_tmp/anim.gif" 360
  [[ -z $gpu_enc ]] && ! grep -q testsrc "$gpu_log" || fail "missing hardware encoder support skips the live probe"
  inventory=av1_nvenc
  : >"$gpu_log"
  gpu_av1_for_input "$test_tmp/static.gif" 360
  [[ -z $gpu_enc ]] && ! grep -q testsrc "$gpu_log" || fail "a single frame skips the live GPU probe"
  : >"$gpu_log"
  gpu_av1_for_input "$test_tmp/anim.gif" 128
  [[ -z $gpu_enc ]] && ! grep -q testsrc "$gpu_log" || fail "a sub-minimum NVIDIA target stays native on CPU"
  probe_failure=memory
  gpu_av1_for_input "$test_tmp/anim.gif" 360 2>"$test_tmp/gpu-memory.log"
  [[ -z $gpu_enc ]] && grep -q 'Not enough GPU memory' "$test_tmp/gpu-memory.log" \
    || fail "a VRAM probe failure is diagnosed and selects CPU"
  probe_failure=""
  : >"$gpu_log"
  main "$test_tmp/anim.gif" webm '' 360 cpu >"$test_tmp/gpu-explicit-cpu.log" 2>&1 \
    || fail "explicit CPU encodes without hardware probes" "$(cat "$test_tmp/gpu-explicit-cpu.log")"
  ! grep -Eq -- '-encoders|testsrc' "$gpu_log" || fail "explicit CPU never probes GPU"
  cp "$test_tmp/anim.gif" "$test_tmp/choice.gif"
  omarchy-menu-select() { echo cpu; }
  : >"$gpu_log"
  main "$test_tmp/choice.gif" webm '' 360 >"$test_tmp/gpu-declined.log" 2>&1 \
    || fail "CPU can be chosen after a successful GPU probe" "$(cat "$test_tmp/gpu-declined.log")"
  grep -q testsrc=s=360x202 "$gpu_log" && grep -q -- '-c:v libvpx-vp9' "$gpu_log" \
    || fail "the probe uses the target dimensions and a CPU choice remains CPU" "$(cat "$gpu_log")"
  pass "AVIF/WebM hardware gates preserve alpha, skip stills and unsupported targets, diagnose VRAM, and honor CPU"

  printf '0x1002\n' >"$OMARCHY_PCI_DEVICES_PATH/gpu/vendor"
  printf '0x1002\n' >"$OMARCHY_DRM_PATH/renderD129/device/vendor"
  : >"$OMARCHY_DRI_PATH/renderD129"
  inventory='av1_vaapi av1_amf'
  gpu_av1_for_input "$test_tmp/anim.gif" 360
  [[ $gpu_enc == "av1_vaapi" && ${gpu_device[*]} == "-vaapi_device $OMARCHY_DRI_PATH/renderD129" \
    && $gpu_upload == "format=nv12,hwupload" && $gpu_pix == "vaapi" ]] \
    || fail "AMD uses its own render node and the VA-API upload path"
  printf '0x8086\n' >"$OMARCHY_PCI_DEVICES_PATH/gpu/vendor"
  printf '0x8086\n' >"$OMARCHY_DRM_PATH/renderD129/device/vendor"
  inventory='av1_qsv av1_vaapi'
  gpu_av1_for_input "$test_tmp/anim.gif" 360
  [[ $gpu_enc == "av1_qsv" && ${gpu_device[*]} == "-qsv_device $OMARCHY_DRI_PATH/renderD129" ]] \
    || fail "Intel QSV is probed on the Intel render node"
  probe_failure=qsv
  gpu_av1_for_input "$test_tmp/anim.gif" 360
  [[ $gpu_enc == "av1_vaapi" ]] || fail "Intel can use VA-API when QSV is unusable"
  pass "AMD VA-API and Intel QSV/VA-API use vendor-matched driver-backed render nodes"
)

# --- avif timing regression ------------------------------------------------
# The ffprobe avif demuxer only exposes the first frame, so the timing
# probe reads the container duration from ffprobe and the frame count plus
# per-frame delays (centiseconds) from magick. Use it on any animated avif.
avif_timing() {
  local f="$1" dur frames tsum
  dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -- "$f" 2>/dev/null)
  frames=$(magick identify -format '%n\n' -- "$f" 2>/dev/null | grep -c . || true)
  tsum=$(magick identify -format '%T\n' -- "$f" 2>/dev/null | awk '{ s += $1 } END { print s + 0 }')
  printf '%s %s %s\n' "$dur" "$frames" "$tsum"
}

# A 2s 60fps avif written by the ffmpeg avif muxer. Its libheif per-frame
# delays are a placeholder whose sum (~307s) diverges from the container
# duration (2s), so the re-encode must fall back to the uniform container
# duration and keep the input's playback time.
ffmpeg -v error -y -framerate 60 -stream_loop 59 -start_number 1 -i "$test_tmp/a%d.png" \
  -c:v libaom-av1 -crf 20 -b:v 0 -cpu-used 6 -pix_fmt yuv420p -f avif "$test_tmp/anim.avif"

read -r in_dur in_frames in_tsum < <(avif_timing "$test_tmp/anim.avif")
(( in_frames == 120 )) || fail "the 60fps avif fixture has 120 frames" "$in_frames"
awk -v d="$in_dur" 'BEGIN { exit (d >= 1.8 && d <= 2.2) ? 0 : 1 }' || fail "the 60fps avif fixture is ~2s" "$in_dur"
awk -v d="$in_dur" -v t="$in_tsum" 'BEGIN { exit (d > 0 && t / 100 > 5 * d) ? 0 : 1 }' \
  || fail "the ffmpeg-written avif's per-frame delays are a placeholder" "dur=$in_dur tsum=$in_tsum"

run_transcode "$test_tmp/anim.avif" avif "" 360 cpu >"$test_tmp/t5.log" 2>&1 \
  || fail "the 60fps avif is transcoded" "$(cat "$test_tmp/t5.log")"
read -r out_dur out_frames _ < <(avif_timing "$test_tmp/anim-360.avif")
(( out_frames == 120 )) || fail "the avif re-encode keeps every frame" "$out_frames"
awk -v d="$out_dur" 'BEGIN { exit (d >= 1.7 && d <= 2.4) ? 0 : 1 }' \
  || fail "the avif re-encode keeps the input's playback duration" "$out_dur"
pass "an ffmpeg-written 60fps avif keeps its playback duration through an avif re-encode"

# An avif with real, unequal per-frame delays that reconcile with the
# container total takes the per-frame delay path; the re-encode keeps
# every frame.
magick -size 640x360 xc:green "$test_tmp/a3.png"
magick -delay 50 "$test_tmp/a1.png" -delay 150 "$test_tmp/a2.png" -delay 100 "$test_tmp/a3.png" "$test_tmp/uneven.avif"
read -r in_dur in_frames in_tsum < <(avif_timing "$test_tmp/uneven.avif")
(( in_frames == 3 )) || fail "the uneven-delay avif fixture has 3 frames" "$in_frames"
awk -v t="$in_tsum" 'BEGIN { exit (t >= 280 && t <= 320) ? 0 : 1 }' \
  || fail "the uneven-delay avif fixture carries its 50/150/100 delays" "$in_tsum"

run_transcode "$test_tmp/uneven.avif" avif "" 360 cpu >"$test_tmp/t6.log" 2>&1 \
  || fail "the uneven-delay avif is transcoded" "$(cat "$test_tmp/t6.log")"
out_frames=$(magick identify -format '%n\n' "$test_tmp/uneven-360.avif" 2>/dev/null | grep -c . || true)
(( out_frames == 3 )) || fail "the uneven-delay re-encode keeps every frame" "$out_frames"
pass "an uneven-delay avif re-encode keeps every frame"
