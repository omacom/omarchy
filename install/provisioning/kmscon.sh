# First-boot owner setup (omarchy-provision-owner) drawn in kmscon, the way the
# installer is: real fonts in place of the console's one bitmap font, so setup
# reads the same on every machine and in Chinese, Japanese and Korean too.
#
# kmscon takes its keyboard layout and its font once, at its start. Setup asks
# for both, so it has kmscon started again once they change: see
# omarchy_kmscon_show's caller.
#
#   omarchy_kmscon_wanted          0 where setup should try kmscon
#   omarchy_kmscon_xkb             the machine's XKB "layout model variant options"
#   omarchy_kmscon_face <lang>     the font family Han characters are drawn in
#   omarchy_kmscon_show <state dir> <lang> <#rrggbb or ""> <command...>
#       run command in kmscon on this VT and return when kmscon ends: 0 if the
#       command touched <state dir>/started, 1 if kmscon never showed it

# Not when it is turned off (omarchy.kmscon=0 on the kernel command line, for a
# machine whose display kmscon gets wrong), and not without a VT to take over
# and a DRM device to draw on.
omarchy_kmscon_wanted() {
  ! grep -qw 'omarchy.kmscon=0' /proc/cmdline 2>/dev/null &&
    [[ $(tty 2>/dev/null) == /dev/tty[0-9]* ]] &&
    omarchy-cmd-present kmscon && compgen -G '/dev/dri/card*' >/dev/null
}

# kmscon reads keys through XKB, not the console keymap: the layout
# /etc/vconsole.conf names beside that keymap, which the desktop types in too.
omarchy_kmscon_xkb() {
  env -i /bin/bash --noprofile --norc -c \
    '. /etc/vconsole.conf 2>/dev/null; printf "%s %s %s %s\n" "${XKBLAYOUT:-us}" "${XKBMODEL:--}" "${XKBVARIANT:--}" "${XKBOPTIONS:--}"'
}

# Han characters take a different form in each CJK language, and Noto's
# collection carries every one of them: draw them as the language writes them.
omarchy_kmscon_face() {
  case $1 in
    ja) printf 'Noto Sans Mono CJK JP' ;;
    ko) printf 'Noto Sans Mono CJK KR' ;;
    zh-TW) printf 'Noto Sans Mono CJK TC' ;;
    *) printf 'Noto Sans Mono CJK SC' ;;
  esac
}

# Pixel height for about 100 columns (cells are ~0.6 of the height wide) and no
# more than 36 rows, so the 81-column logo fits and a 4K panel isn't 300 columns
# of tiny text.
omarchy_kmscon_font_size() {
  local w h size
  { IFS=, read -r w h </sys/class/graphics/fb0/virtual_size; } 2>/dev/null || { w=1280 h=800; }
  size=$((h / 36))
  ((w * 10 / 6 / 100 < size)) && size=$((w * 10 / 6 / 100))
  ((size < 14)) && size=14
  printf '%s' "$size"
}

omarchy_kmscon_show() {
  local state=$1 language=$2 color=${3#\#} watchdog
  local layout model variant options bright_red="247, 118, 142"
  shift 3

  export OMARCHY_KMSCON_XKB OMARCHY_KMSCON_FACE
  OMARCHY_KMSCON_XKB=$(omarchy_kmscon_xkb)
  OMARCHY_KMSCON_FACE=$(omarchy_kmscon_face "$language")
  read -r layout model variant options <<<"$OMARCHY_KMSCON_XKB"
  [[ $model == "-" ]] && model=""
  [[ $variant == "-" ]] && variant=""
  [[ $options == "-" ]] && options=""
  # An OEM's colour stands in for the palette's bright red, as on the console.
  [[ $color =~ ^[0-9a-fA-F]{6}$ ]] && bright_red="$((16#${color:0:2})), $((16#${color:2:2})), $((16#${color:4:2}))"

  mkdir -p "$state"
  rm -f "$state/started" "$state/kmscon.pid"

  # kmscon with no display it can drive waits for one and draws nothing, so one
  # that has not started the command within 15 s is stopped.
  (
    sleep 15
    [[ -e $state/started ]] || kill "$(<"$state/kmscon.pid")"
  ) &>/dev/null &
  watchdog=$!

  # C.UTF-8: bash string lengths count characters, and gum's width tables stay
  # on narrow ambiguous-width glyphs, as kmscon draws them. The console's size
  # would stand in for kmscon's grid: tput reads COLUMNS and LINES first.
  # Tokyo Night, as the installer and the console setup are drawn in.
  {
    (
    export OMARCHY_KMSCON=1 LANG=C.UTF-8
    unset LC_ALL COLUMNS LINES
    echo "$BASHPID" >"$state/kmscon.pid"
    exec kmscon \
      --vt="$(tty)" \
      --oneshot \
      --no-reset-env \
      --no-mouse \
      --dpms-timeout=0 \
      --font-engine=pango \
      --font-name="Adwaita Mono,$OMARCHY_KMSCON_FACE,monospace" \
      --font-size="$(omarchy_kmscon_font_size)" \
      --xkb-layout="$layout" \
      ${model:+--xkb-model="$model"} \
      ${variant:+--xkb-variant="$variant"} \
      ${options:+--xkb-options="$options"} \
      --palette=custom \
      --palette-black="26, 27, 38" \
      --palette-red="247, 118, 142" \
      --palette-green="158, 206, 106" \
      --palette-yellow="224, 175, 104" \
      --palette-blue="122, 162, 247" \
      --palette-magenta="187, 154, 247" \
      --palette-cyan="125, 207, 255" \
      --palette-light-grey="169, 177, 214" \
      --palette-dark-grey="65, 72, 104" \
      --palette-light-red="$bright_red" \
      --palette-light-green="158, 206, 106" \
      --palette-light-yellow="224, 175, 104" \
      --palette-light-blue="122, 162, 247" \
      --palette-light-magenta="187, 154, 247" \
      --palette-light-cyan="125, 207, 255" \
      --palette-white="192, 202, 245" \
      --palette-foreground="169, 177, 214" \
      --palette-background="26, 27, 38" \
      --login -- "$@" >>"$state/kmscon.log" 2>&1
    )
  } 2>/dev/null || true

  kill "$watchdog" 2>/dev/null || true
  [[ -e $state/started ]]
}
