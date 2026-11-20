# The install progress screen: Omarchy's icon traced as setup progresses, with
# the percentage, a status line and a tip beneath it.
#
# The ISO install dashboard and first-boot setup (omarchy-provision-owner) both
# draw it, so an install that finishes on first boot continues on the screen it
# started on. The ISO vendors this very file out of the runtime package it
# bundles, as it does setup-form.sh, so the two can never draw it differently.
# Each caller keeps its own progress model and hands this the per-mille result.
#
# Sourcing this file only defines functions and state; it never draws.
#
#   progress_icon_layout <tty> <text-width>  measure the console, build the icon
#   progress_icon_static                     clear and draw the trace so far
#   progress_icon_frame <pm> [status] [tip]  ease toward pm and draw one frame
#   progress_icon_finish                     ease to the end and draw it solid
#
# Frames go to stdout; the caller points that at the console.

PROGRESS_ICON_CSI=$'\033['
PROGRESS_ICON_RESET="${PROGRESS_ICON_CSI}0m"
PROGRESS_ICON_ESCAPE=$'\033''\[[0-9;?]*[A-Za-z]'

# The icon uses half-block glyphs, scaled to the terminal's actual cell aspect
# ratio so its square silhouette stays square. No graphics protocol is needed.
# Coordinates follow the 15 x 15 grid of Omarchy's icon.svg. Each segment
# paints the full stroke width, starting at the bottom middle of the outer ring.
ICON_WIDTH=30
ICON_COLUMN=2
ICON_HEIGHT=15
ICON_TOP=1
ICON_LEFT=1
CELL_WIDTH=8
CELL_HEIGHT=16
ICON_STEPS=0
ICON_DRAWN=0
ICON_FRAME=""
ICON_TTY=/dev/tty
ICON_SIZE=""
ICON_COLS=80
ICON_FRAMES=0
ICON_TEXT_WIDTH=78
ICON_TEXT_LIMIT=78
ICON_DISPLAY_PM=0
ICON_TARGET_PM=0
declare -a ICON_ORDER=() ICON_TRACE=() ICON_FILL=()

# Read the actual character dimensions instead of assuming an 8 x 16 font.
# Desktop terminals expose pixels in their window size. A Linux VT leaves those
# at zero but reports its font through KDFONTOP.
progress_icon_cell_size() {
  python3 - "$1" <<'PY'
import fcntl
import struct
import sys
import termios

with open(sys.argv[1], "r+b", buffering=0) as terminal:
  fd = terminal.fileno()
  rows, cols, width, height = struct.unpack(
    "HHHH", fcntl.ioctl(fd, termios.TIOCGWINSZ, bytes(8)))
  if rows and cols and width and height:
    print(round(width / cols), round(height / rows))
    sys.exit()
  try:
    # KD_FONT_OP_GET with no data pointer fills in only the size, but the
    # kernel refuses with ENOSPC a font larger than the width and height
    # passed in. A plain GET returns fonts up to 32 rows, and none here is
    # wider than 16, so 32 x 32 lets it answer.
    font = bytearray(struct.pack("@5IP", 1, 0, 32, 32, 0, 0))
    fcntl.ioctl(fd, 0x4B72, font)  # KDFONTOP / KD_FONT_OP_GET, no glyph data
    _, _, width, height, _ = struct.unpack_from("@5I", font)
    if width and height:
      print(width, height)
      sys.exit()
  except OSError:
    pass
  print(8, 16)  # Conventional console font when dimensions aren't available.
PY
}

progress_icon_term_size() { stty size 2>/dev/null <"$ICON_TTY" || printf '24 80\n'; }

progress_icon_segment() {
  local scale="$1" x1="$2" y1="$3" x2="$4" y2="$5"
  local x y from to
  if (( y1 == y2 )); then
    from=$(( (x1 * ICON_WIDTH + 14) / 15 ))
    to=$(( ((x2 + 1) * ICON_WIDTH + 14) / 15 ))
    if (( x2 < x1 )); then
      from=$(( ((x1 + 1) * ICON_WIDTH + 14) / 15 - 1 ))
      to=$(( (x2 * ICON_WIDTH + 14) / 15 - 1 ))
    fi
    for ((x=from; x!=to; x+=(x2 >= x1 ? 1 : -1))); do
      for ((y=y1 * scale; y<(y1 + 1) * scale; y++)); do
        progress_icon_pixel "$((y * ICON_WIDTH + x))"
      done
    done
  else
    from=$(( y1 * scale ))
    to=$(( (y2 + 1) * scale ))
    if (( y2 < y1 )); then
      from=$(( (y1 + 1) * scale - 1 ))
      to=$(( y2 * scale - 1 ))
    fi
    for ((y=from; y!=to; y+=(y2 >= y1 ? 1 : -1))); do
      for ((x=(x1 * ICON_WIDTH + 14) / 15; x<((x1 + 1) * ICON_WIDTH + 14) / 15; x++)); do
        progress_icon_pixel "$((y * ICON_WIDTH + x))"
      done
    done
  fi
}

# The screen columns each of the icon's 15 grid columns takes at <scale>. Every
# grid column gets the same whole number, the nearest to square in this font,
# so a font that isn't 2:1, like sun12x22, neither drops a column nor draws some
# strokes narrower than others.
progress_icon_column() {
  ICON_COLUMN=$(( ($1 * CELL_HEIGHT + CELL_WIDTH) / (2 * CELL_WIDTH) ))
  (( ICON_COLUMN > 0 )) || ICON_COLUMN=1
}

progress_icon_pixel() {
  local pixel="$1"
  if [[ ! -v ICON_TRACE[pixel] ]]; then
    ICON_ORDER+=("$pixel")
    ICON_TRACE[pixel]=${#ICON_ORDER[@]}
  fi
}

progress_icon_build() {
  local scale="$1" x y row
  local -a mask=(
    111111111111111
    100000010000001
    101111110001101
    101000000000101
    101000000000101
    101000000000101
    101000000000101
    111000000000101
    101000000000101
    101000000000101
    101000000000101
    101000000000101
    101111111111101
    100000010000001
    111111110111111
  )
  progress_icon_column "$scale"
  ICON_WIDTH=$((15 * ICON_COLUMN))
  ICON_HEIGHT=$(((15 * scale + 1) / 2))
  ICON_ORDER=() ICON_TRACE=() ICON_FILL=()
  ICON_DRAWN=0
  # Start at the bottom middle, follow the outer left edge to the top cross,
  # then descend into the inner shape. Fill its two bridges as we reach them.
  progress_icon_segment "$scale" 7 14 0 14
  progress_icon_segment "$scale" 0 14 0 0
  progress_icon_segment "$scale" 0 0 7 0
  progress_icon_segment "$scale" 7 0 7 2
  progress_icon_segment "$scale" 7 2 2 2
  progress_icon_segment "$scale" 2 2 2 7
  progress_icon_segment "$scale" 2 7 0 7
  progress_icon_segment "$scale" 2 7 2 12
  progress_icon_segment "$scale" 2 12 7 12
  progress_icon_segment "$scale" 7 12 7 14
  progress_icon_segment "$scale" 7 12 12 12
  progress_icon_segment "$scale" 12 12 12 2
  progress_icon_segment "$scale" 12 2 11 2
  # Finish from the top cross: right along the outside, down, then left.
  progress_icon_segment "$scale" 7 0 14 0
  progress_icon_segment "$scale" 14 0 14 14
  progress_icon_segment "$scale" 14 14 9 14
  ICON_STEPS=${#ICON_ORDER[@]}
  for ((y=0; y<15 * scale; y++)); do
    row=${mask[y / scale]}
    for ((x=0; x<ICON_WIDTH; x++)); do
      ICON_FILL[y * ICON_WIDTH + x]=${row:x * 15 / ICON_WIDTH:1}
    done
  done
}

# Append one cell with independently colored upper/lower pixels. This also
# handles a green tracing tip sharing a cell with the still-dark outline.
progress_icon_cell() {
  local pixel="$1" drawn="$2" solid="$3" upper=0 lower=0 step
  if (( solid )); then
    (( ICON_FILL[pixel] )) && upper=32
    (( ${ICON_FILL[pixel + ICON_WIDTH]:-0} )) && lower=32
  else
    step=${ICON_TRACE[pixel]:-0}
    (( step > 0 )) && upper=90
    (( step > 0 && step <= drawn )) && upper=32
    step=${ICON_TRACE[pixel + ICON_WIDTH]:-0}
    (( step > 0 )) && lower=90
    (( step > 0 && step <= drawn )) && lower=32
  fi
  if (( upper == 0 && lower == 0 )); then
    ICON_FRAME+="${PROGRESS_ICON_RESET} "
  elif (( upper == lower )); then
    ICON_FRAME+="${PROGRESS_ICON_CSI}${upper};49m█"
  elif (( lower == 0 )); then
    ICON_FRAME+="${PROGRESS_ICON_CSI}${upper};49m▀"
  elif (( upper == 0 )); then
    ICON_FRAME+="${PROGRESS_ICON_CSI}${lower};49m▄"
  elif (( upper >= 90 )); then
    ICON_FRAME+="${PROGRESS_ICON_CSI}${upper};$((lower + 10))m▀"
  else
    # The VT reads bright backgrounds (100-107) as normal ones (40-47), so the
    # grey half under a green tip would vanish. The bright half is always the
    # foreground: green over grey is grey ▄ on green.
    ICON_FRAME+="${PROGRESS_ICON_CSI}${lower};$((upper + 10))m▄"
  fi
}

progress_icon_render() {
  local pm="$1" full="${2:-0}" drawn i pixel row col
  drawn=$((pm * ICON_STEPS / 1000))
  ICON_FRAME=""
  if (( full || pm == 1000 )); then
    for ((row=0; row<ICON_HEIGHT; row++)); do
      ICON_FRAME+="${PROGRESS_ICON_CSI}$((ICON_TOP + row));${ICON_LEFT}H"
      for ((col=0; col<ICON_WIDTH; col++)); do
        progress_icon_cell "$((row * 2 * ICON_WIDTH + col))" "$drawn" "$((pm == 1000))"
      done
    done
  else
    # Between layout changes, repaint only newly traced pixels. This keeps the
    # animation cheap even while pacstrap saturates the disk.
    for ((i=ICON_DRAWN; i<drawn; i++)); do
      pixel=${ICON_ORDER[i]}
      row=$((pixel / ICON_WIDTH / 2)) col=$((pixel % ICON_WIDTH))
      ICON_FRAME+="${PROGRESS_ICON_CSI}$((ICON_TOP + row));$((ICON_LEFT + col))H"
      progress_icon_cell "$((row * 2 * ICON_WIDTH + col))" "$drawn" 0
    done
  fi
  printf '%s%s' "$ICON_FRAME" "$PROGRESS_ICON_RESET"
  ICON_DRAWN=$drawn
}

# Center one line of text, escapes included, across the console the layout
# measured. The text is measured in bash, so drawing a line starts no process.
progress_icon_line() {
  local text="$1" plain pad
  printf -v plain '%b' "$text"
  while [[ $plain =~ $PROGRESS_ICON_ESCAPE ]]; do
    plain=${plain/"${BASH_REMATCH[0]}"/}
  done
  pad=$(( (ICON_COLS - ${#plain}) / 2 ))
  (( pad < 0 )) && pad=0
  printf '\r%s2K%*s%b%s\n' "$PROGRESS_ICON_CSI" "$pad" '' "$text" "$PROGRESS_ICON_RESET"
}

# Set the variable <name> to <text>, cut to the text width.
progress_icon_truncate() {
  local text="$2" width="$ICON_TEXT_WIDTH"
  if (( ${#text} > width )); then
    printf -v "$1" '%s…' "${text:0:$((width - 1))}"
  else
    printf -v "$1" '%s' "$text"
  fi
}

# Pick the largest icon the console fits and center it, with the five text rows
# beneath it, vertically. The text never runs wider than <text-width>, which is
# kept apart from the width the current console leaves, so a console that
# shrinks and grows back shows the full text again.
progress_icon_layout() {
  local rows cols scale=1 top
  ICON_TTY="${1:-/dev/tty}"
  [[ -n ${2:-} ]] && ICON_TEXT_LIMIT=$2
  ICON_SIZE="$(progress_icon_term_size)"
  read -r rows cols <<<"$ICON_SIZE"
  [[ $rows =~ ^[0-9]+$ ]] || rows=24
  [[ $cols =~ ^[0-9]+$ ]] || cols=80
  ICON_COLS=$cols
  read -r CELL_WIDTH CELL_HEIGHT < <(progress_icon_cell_size "$ICON_TTY" 2>/dev/null || printf '8 16\n')
  (( rows >= 34 && cols >= 49 )) && scale=2
  (( rows >= 50 && cols >= 64 )) && scale=3
  progress_icon_column "$scale"
  while (( scale > 1 && 15 * ICON_COLUMN > cols - 4 )); do
    scale=$((scale - 1))
    progress_icon_column "$scale"
  done
  progress_icon_build "$scale"
  top=$(( (rows - ICON_HEIGHT - 5) / 2 ))
  (( top < 0 )) && top=0
  ICON_TOP=$((top + 1))
  ICON_LEFT=$(( (cols - ICON_WIDTH) / 2 + 1 ))
  (( ICON_LEFT < 1 )) && ICON_LEFT=1
  ICON_TEXT_WIDTH=$((cols - 2))
  (( ICON_TEXT_WIDTH > ICON_TEXT_LIMIT )) && ICON_TEXT_WIDTH=$ICON_TEXT_LIMIT
  return 0
}

progress_icon_static() {
  progress_icon_layout "$ICON_TTY"
  printf '%s2J%sH' "$PROGRESS_ICON_CSI" "$PROGRESS_ICON_CSI"
  progress_icon_render "$ICON_DISPLAY_PM" 1
}

# Draw one frame toward <pm>, which must never go back. Phase jumps ease over
# several frames, with the percentage following the same position as the trace.
# The status row is blank when no status is given, so the layout never changes
# height. Callers draw ten frames a second while setup works the disk, so a
# frame starts no process except the console size check on every fifth.
progress_icon_frame() {
  local pm="${1:-0}" status="${2:-}" tip="${3:-}" step shown_status="" shown_tip
  [[ $pm =~ ^[0-9]+$ ]] || pm=$ICON_TARGET_PM
  (( pm > 1000 )) && pm=1000
  (( pm < ICON_TARGET_PM )) && pm=$ICON_TARGET_PM
  ICON_TARGET_PM=$pm
  # The framebuffer can settle late in VMs. Rebuild at the new size, preserving
  # progress, instead of leaving the drawing at the old screen coordinates.
  if (( ICON_FRAMES++ % 5 == 0 )); then
    [[ "$(progress_icon_term_size)" == "$ICON_SIZE" ]] || progress_icon_static
  fi
  step=$(( (ICON_TARGET_PM - ICON_DISPLAY_PM + 3) / 4 ))
  ICON_DISPLAY_PM=$((ICON_DISPLAY_PM + step))
  progress_icon_render "$ICON_DISPLAY_PM"

  printf '%s%d;1H' "$PROGRESS_ICON_CSI" "$((ICON_TOP + ICON_HEIGHT + 1))"
  progress_icon_line "${PROGRESS_ICON_CSI}32m$((ICON_DISPLAY_PM / 10))%"
  progress_icon_line ""
  if [[ -n $status ]]; then
    progress_icon_truncate shown_status "$status"
    progress_icon_line "${PROGRESS_ICON_CSI}2m$shown_status"
  else
    progress_icon_line ""
  fi
  progress_icon_truncate shown_tip "$tip"
  progress_icon_line "${PROGRESS_ICON_CSI}2m$shown_tip"
  printf '%sJ' "$PROGRESS_ICON_CSI"
}

# Finish the trace, then draw the icon solid. Only a successful run calls this.
progress_icon_finish() {
  local status="${1:-}" tip="${2:-}"
  while (( ICON_DISPLAY_PM < 999 )); do
    progress_icon_frame 1000 "$status" "$tip"
    sleep 0.05
  done
  ICON_DISPLAY_PM=1000
  progress_icon_frame 1000 "$status" "$tip"
}
