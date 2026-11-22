# The installer and first-boot owner setup (omarchy-provision-owner) are drawn
# in kmscon: real fonts in place of the console's one bitmap font, so both read
# the same on every machine and in Chinese, Japanese and Korean too. The ISO
# vendors this very file beside its copy of setup-form.sh, so an install and
# the first boot that finishes it are drawn and typed in alike.
#
# kmscon takes its keyboard layout and its font once, at its start. Both
# callers ask for a layout and a language, so they have kmscon started again
# once either changes what kmscon was started with: OMARCHY_KMSCON_XKB and
# OMARCHY_KMSCON_FACE, which the command it runs finds in its environment
# beside OMARCHY_KMSCON=1.
#
#   omarchy_keymap_xkb_extra <keymap>
#       XKB "layout variant options" ("-" for none) for a keymap of the form
#       that systemd's kbd-model-map lacks; 1 for any other keymap
#   omarchy_keymap_xkb <keymap>      XKB "layout model variant options" for a
#                                    console keymap, us for one nobody knows
#   omarchy_kmscon_face <lang>       the font family Han characters are drawn in
#   omarchy_kmscon <log> <keymap> <lang> <#rrggbb or ""> <command...>
#       run command in kmscon on this VT; returns when kmscon ends

# The form's keymaps that kbd-model-map lacks, as its rows for the nearest
# keymap give them, so kmscon and the desktop type what the console does:
# kbd's cz is QWERTY and bg-cp1251 phonetic. Non-Latin layouts keep a US layout
# to switch to, so the shared password stays typeable.
omarchy_keymap_xkb_extra() {
  local layout variant=- options=- switch=grp:shifts_toggle,grp_led:scroll
  case $1 in
    colemak) layout=us variant=colemak ;;
    bg-cp1251) layout=bg,us variant=phonetic, options=$switch ;;
    cz) layout=cz,us variant=qwerty, options=$switch ;;
    de_CH-latin1) layout=ch ;;
    kyrgyz) layout=kg,us options=$switch ;;
    no-latin1) layout=no ;;
    pl) layout=pl ;;
    ua) layout=ua,us options=$switch ;;
    *) return 1 ;;
  esac
  printf '%s %s %s\n' "$layout" "$variant" "$options"
}

# kmscon reads keys through XKB, not the console keymap, and the password
# typed in it is typed again at boot under that keymap: the layouts must place
# keys alike. From systemd's table, the one localectl and the installed system
# use.
omarchy_keymap_xkb() {
  local keymap=${1:-us} layout="" model=- variant=- options=-
  if ! read -r layout variant options < <(omarchy_keymap_xkb_extra "$keymap"); then
    read -r layout model variant options < <(awk -v k="$keymap" '$1 == k { print $2, $3, $4, $5; exit }' /usr/share/systemd/kbd-model-map 2>/dev/null) || true
  fi
  printf '%s %s %s %s\n' "${layout:-us}" "${model:--}" "${variant:--}" "${options:--}"
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

omarchy_kmscon() {
  local log=$1 keymap=$2 language=$3 color=${4#\#}
  local layout model variant options bright_red="247, 118, 142"
  shift 4

  # An OEM's colour stands in for the palette's bright red.
  [[ $color =~ ^[0-9a-fA-F]{6}$ ]] && bright_red="$((16#${color:0:2})), $((16#${color:2:2})), $((16#${color:4:2}))"

  (
    export OMARCHY_KMSCON=1 OMARCHY_KMSCON_XKB OMARCHY_KMSCON_FACE
    OMARCHY_KMSCON_XKB=$(omarchy_keymap_xkb "$keymap")
    OMARCHY_KMSCON_FACE=$(omarchy_kmscon_face "$language")
    read -r layout model variant options <<<"$OMARCHY_KMSCON_XKB"
    [[ $model == "-" ]] && model=""
    [[ $variant == "-" ]] && variant=""
    [[ $options == "-" ]] && options=""

    # C.UTF-8: bash string lengths count characters, and gum's width tables
    # stay on narrow ambiguous-width glyphs, as kmscon draws them. The
    # console's size would stand in for kmscon's grid: tput reads COLUMNS and
    # LINES first. The palette is Tokyo Night.
    export LANG=C.UTF-8
    unset LC_ALL COLUMNS LINES
    exec kmscon \
      --vt="$(tty)" \
      --oneshot \
      --no-reset-env \
      --no-mouse \
      --dpms-timeout=0 \
      --font-engine=pango \
      --font-name="JetBrainsMono Nerd Font,$OMARCHY_KMSCON_FACE,monospace" \
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
      --login -- "$@" >>"$log" 2>&1
  ) || true
}
