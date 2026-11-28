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
#   omarchy_keymap_xkb <keymap>      XKB "layout model variant options" for a
#                                    console keymap, us for one nobody knows,
#                                    and US first for one with no Latin letters
#   omarchy_kmscon_face <lang>       the font family Han characters are drawn in
#   omarchy_kmscon <log> <keymap> <lang> <#rrggbb or ""> <command...>
#       run command in kmscon on this VT; returns when kmscon ends
#
# omarchy_keymap_xkb reads the XKB layouts of the form's keymaps that systemd's
# kbd-model-map lacks from omarchy_keymap_xkb_extra in setup-form.sh, sourcing
# the sibling file when the caller has not already.
if ! declare -F omarchy_keymap_xkb_extra >/dev/null; then
  # shellcheck source=setup-form.sh
  source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/setup-form.sh"
fi

# kmscon reads keys through XKB, not the console keymap, and the password
# typed in it is typed again at boot under that keymap: the layouts must place
# keys alike. From systemd's table, the one localectl and the installed system
# use.
#
# A layout that types no Latin letters goes after US, a Shift+Shift away, as
# the console's keymaps for it start in Latin: the boot splash and the login
# screen start in US for it too, with the layout a click away
# (default/splash/layouts), and so does the desktop, so a password typed as
# kmscon starts types at each of them.
omarchy_keymap_xkb() {
  local keymap=${1:-us} layout="" model=- variant=- options=-
  local i moved=0 us_variant="" others="" other_variants=""
  local -a layouts variants

  if ! read -r layout variant options < <(omarchy_keymap_xkb_extra "$keymap"); then
    read -r layout model variant options < <(awk -v k="$keymap" '$1 == k { print $2, $3, $4, $5; exit }' /usr/share/systemd/kbd-model-map 2>/dev/null) || true
  fi
  layout=${layout:-us}

  # omarchy_hooks.conf's list, Serbian's Latin variants included, as at every
  # prompt after kmscon.
  case ${layout%%,*} in
    af | am | ara | bd | bg | by | et | ge | gr | il | in | iq | ir | kg | kh | kz | la | lk | mk | mm | mn | mv | np | rs | ru | sy | th | tj | ua)
      IFS=, read -ra layouts <<<"$layout"
      IFS=, read -ra variants <<<"${variant#-}"
      for i in "${!layouts[@]}"; do
        if ((!moved)) && [[ ${layouts[i]} == us ]]; then
          us_variant=${variants[i]:-} moved=1
        else
          others+=,${layouts[i]} other_variants+=,${variants[i]:-}
        fi
      done
      layout=us$others variant=$us_variant$other_variants
      [[ $variant == *[!,]* ]] || variant=-
      if [[ $options != *grp:* ]]; then
        [[ $options != "-" ]] || options=""
        options=${options:+$options,}grp:shifts_toggle
      fi
      ;;
  esac

  printf '%s %s %s %s\n' "$layout" "${model:--}" "${variant:--}" "${options:--}"
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

# Pixel height for about 180 columns (cells are 0.6 of the height wide), as
# many as the console's own font gives a laptop panel: the 81-column logo then
# spans under half the screen, as it did there. At least 44 rows (a row is 1.33
# of the height), so an ultrawide panel is sized by its height, and never under
# 14 px, which a small screen stays readable at.
omarchy_kmscon_font_size() {
  local w h size
  { IFS=, read -r w h </sys/class/graphics/fb0/virtual_size; } 2>/dev/null || { w=1280 h=800; }
  size=$((w / 108))
  ((h / 58 < size)) && size=$((h / 58))
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
    # LINES first. The palette is Tokyo Night. --no-issue: kmscon would
    # print /etc/issue, a line naming the system, ahead of the command.
    export LANG=C.UTF-8
    unset LC_ALL COLUMNS LINES
    # On Qualcomm Snapdragon (msm DRM), kmscon's atomic DRM backend fails
    # with EINVAL (-22) when switching a plane across CRTCs when an external
    # display is attached, leaving the external screen blank and spamming
    # adreno_request_fw. Fall back to fbdev (--no-drm) on msmdrmfb, where
    # kmscon renders cleanly across both panels.
    local fb_name=${OMARCHY_KMSCON_FB_NAME-}
    if [[ -z $fb_name && -r /sys/class/graphics/fb0/name ]]; then
      read -r fb_name </sys/class/graphics/fb0/name 2>/dev/null || true
    fi
    local -a drm_args=()
    if [[ $fb_name == "msmdrmfb" ]]; then
      drm_args=(--no-drm)
    fi

    exec kmscon \
      "${drm_args[@]}" \
      --vt="$(tty)" \
      --oneshot \
      --no-reset-env \
      --no-issue \
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
