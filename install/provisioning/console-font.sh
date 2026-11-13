# The console font setup is drawn in: Terminus, which covers every language the
# setup form can be read in, patched with the half blocks the Omarchy logo and
# the progress icon are made of (console-font.py). The kernel's own fonts carry
# only the IBM PC character set.
#
# Sourced by first-boot owner setup (omarchy-provision-owner) and, through the
# copy the ISO vendors beside its copy of setup-form.sh, by the installer, so an
# install and the first boot that finishes it are set in one font at one size.
#
#   omarchy_console_font <tty>   0 once the console is in Terminus, 1 when it is
#                                left as it was: not a Linux VT, or no Terminus

omarchy_console_font_py=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/console-font.py

omarchy_console_font() {
  local tty=$1 rows cols width height terminus=ter-v16b font
  [[ $tty == /dev/tty[0-9]* ]] || return 1

  # Twice the size where the kernel itself boots in 16x32 rather than 8x16: a
  # display of 22,000 8x16 cells or more (lib/fonts/fonts.c), 2560x1440 and up.
  # Counted in whole 16x32 cells, which either font reports alike, so asking
  # again once the font is set cannot flip the answer; a display within a row
  # or column of the line can come out a size smaller than the kernel's.
  read -r rows cols < <(stty size 2>/dev/null <"$tty") || return 1
  IFS=x read -r width height _ < <(showconsolefont -i -C "$tty" 2>/dev/null) || return 1
  [[ $rows$cols$width$height =~ ^[0-9]+$ ]] || return 1
  (( 4 * (cols * width / 16) * (rows * height / 32) >= 22000 )) && terminus=ter-v32b

  font=${OMARCHY_CONSOLE_FONT_DIR:-/run/omarchy}/$terminus.psf
  if [[ ! -s $font ]]; then
    mkdir -p "${font%/*}" 2>/dev/null || return 1
    python3 "$omarchy_console_font_py" "/usr/share/kbd/consolefonts/$terminus.psf.gz" "$font" 2>/dev/null || return 1
  fi
  setfont -C "$tty" "$font" 2>/dev/null
}
