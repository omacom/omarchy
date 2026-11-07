# Shared console/XKB persistence for the LUKS Plymouth prompt and Hyprland.
# Plymouth reads XKBLAYOUT from the vconsole.conf bundled in the initramfs;
# loadkeys alone only affects the live VT where the passphrase was typed.

# Keep in sync with etc/mkinitcpio.conf.d/omarchy_hooks.conf and
# default/hypr/input.lua.
OMARCHY_NON_LATIN_LAYOUTS='^(af|am|ara|bd|bg|by|et|ge|gr|il|in|iq|ir|kg|kh|kz|la|lk|mk|mm|mn|mv|np|rs|ru|sy|th|tj|ua)$'

omarchy_vconsole_conf() {
  printf '%s\n' "${OMARCHY_VCONSOLE_CONF:-/etc/vconsole.conf}"
}

omarchy_vconsole_get() {
  local key="$1"
  local file
  file=$(omarchy_vconsole_conf)
  [[ -f $file ]] || return 0

  awk -F= -v key="$key" '
    $1 == key {
      value = $2
      sub(/^[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
      print value
      exit
    }
  ' "$file"
}

omarchy_vconsole_set() {
  local key="$1"
  local value="$2"
  local file dir
  file=$(omarchy_vconsole_conf)
  dir=$(dirname "$file")

  # Migrations run unprivileged; /etc/vconsole.conf is root-owned. Elevate the
  # write when the target is not writable so change detection still works.
  if { [[ -e $file ]] && [[ ! -w $file ]]; } || { [[ ! -e $file ]] && [[ ! -w $dir ]]; }; then
    if [[ -f $file ]] && grep -q "^$key=" "$file" 2>/dev/null; then
      sudo sed -i "s/^$key=.*/$key=$value/" "$file"
    else
      printf '%s=%s\n' "$key" "$value" | sudo tee -a "$file" >/dev/null
    fi
    return
  fi

  mkdir -p "$dir"
  touch "$file"

  if grep -q "^$key=" "$file" 2>/dev/null; then
    sed -i "s/^$key=.*/$key=$value/" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >>"$file"
  fi
}

# Map a console KEYMAP to XKB layout + variant via systemd's kbd-model-map.
# Prints "layout variant" (variant may be empty). Returns 1 when unknown.
omarchy_keymap_to_xkb() {
  local keymap="$1"
  local map="${OMARCHY_KBD_MODEL_MAP:-/usr/share/systemd/kbd-model-map}"
  local layout="" variant="" alias=""

  case "$keymap" in
    colemak | dvorak)
      printf '%s %s\n' us "$keymap"
      return 0
      ;;
    # Offered in setup-form but absent/aliased in systemd's kbd-model-map.
    no-latin1)
      printf 'no \n'
      return 0
      ;;
    de_CH-latin1 | sg-latin1)
      printf 'ch de_nodeadkeys\n'
      return 0
      ;;
  esac

  if [[ -f $map ]]; then
    # Columns: keymap layout model variant options …
    layout=$(awk -v k="$keymap" 'BEGIN { IGNORECASE = 1 }
      $1 ~ /^#/ || NF < 2 { next }
      $1 == k { print $2; exit }
    ' "$map")
    variant=$(awk -v k="$keymap" 'BEGIN { IGNORECASE = 1 }
      $1 ~ /^#/ || NF < 2 { next }
      $1 == k {
        if ($4 == "-" || $4 == "") next
        print $4
        exit
      }
    ' "$map")
    if [[ -n $layout ]]; then
      printf '%s %s\n' "$layout" "$variant"
      return 0
    fi

    # Hyphenated *-latin1 names often share a row with the bare keymap (no).
    if [[ $keymap == *-latin1 ]]; then
      alias=${keymap%-latin1}
      layout=$(awk -v k="$alias" 'BEGIN { IGNORECASE = 1 }
        $1 ~ /^#/ || NF < 2 { next }
        $1 == k { print $2; exit }
      ' "$map")
      variant=$(awk -v k="$alias" 'BEGIN { IGNORECASE = 1 }
        $1 ~ /^#/ || NF < 2 { next }
        $1 == k {
          if ($4 == "-" || $4 == "") next
          print $4
          exit
        }
      ' "$map")
      if [[ -n $layout ]]; then
        printf '%s %s\n' "$layout" "$variant"
        return 0
      fi
    fi
  fi

  # Bare two-letter console names (fr, de, es) are usually valid XKB layouts.
  if [[ $keymap =~ ^[a-z]{2}$ ]]; then
    printf '%s \n' "$keymap"
    return 0
  fi

  return 1
}

# Returns 0 when the layout cannot type Latin letters. A Latin XKBVARIANT
# (Serbian sr-latin → rs/latin) keeps a Latin passphrase path into Plymouth.
omarchy_layout_is_non_latin() {
  local layout="${1%%,*}"
  local variant="${2-}"
  variant=${variant%%,*}
  [[ $variant == latin* ]] && return 1
  [[ $layout =~ $OMARCHY_NON_LATIN_LAYOUTS ]]
}

# After KEYMAP is written, make sure Plymouth/Hyprland also see XKBLAYOUT.
# Prints nothing. Exit 0 always; sets OMARCHY_VCONSOLE_XKB_CHANGED=1 when the
# file was updated so callers can decide whether to rebuild the UKI.
omarchy_ensure_vconsole_xkb() {
  local keymap layout variant current_layout current_variant
  OMARCHY_VCONSOLE_XKB_CHANGED=0

  keymap=$(omarchy_vconsole_get KEYMAP)
  [[ -n $keymap ]] || return 0

  if ! read -r layout variant < <(omarchy_keymap_to_xkb "$keymap"); then
    return 0
  fi

  current_layout=$(omarchy_vconsole_get XKBLAYOUT)
  current_variant=$(omarchy_vconsole_get XKBVARIANT)

  # Colemak/Dvorak must win even when a prior firstboot left XKBLAYOUT empty or
  # wrong; ordinary layouts only fill a missing XKBLAYOUT so an admin override
  # is left alone.
  case "$keymap" in
    colemak | dvorak)
      if [[ $current_layout != "$layout" || $current_variant != "$variant" ]]; then
        omarchy_vconsole_set XKBLAYOUT "$layout"
        omarchy_vconsole_set XKBVARIANT "$variant"
        OMARCHY_VCONSOLE_XKB_CHANGED=1
      fi
      ;;
    *)
      if [[ -z $current_layout ]]; then
        omarchy_vconsole_set XKBLAYOUT "$layout"
        if [[ -n $variant ]]; then
          omarchy_vconsole_set XKBVARIANT "$variant"
        fi
        OMARCHY_VCONSOLE_XKB_CHANGED=1
      fi
      ;;
  esac
}

# Rebuild the UKI so the Plymouth LUKS prompt picks up the new vconsole.conf.
# Latin layouts must be bundled (omarchy_hooks.conf); non-Latin stay out so a
# Latin passphrase remains typeable (#6229 / #8196).
omarchy_rebuild_boot_keyboard() {
  local layout
  layout=$(omarchy_vconsole_get XKBLAYOUT)
  layout=${layout%%,*}

  # No layout means nothing for Plymouth to learn; skip the expensive rebuild.
  [[ -n $layout ]] || return 0

  if command -v limine-mkinitcpio >/dev/null 2>&1; then
    limine-mkinitcpio "$@"
  elif command -v limine-update >/dev/null 2>&1; then
    limine-update "$@"
  else
    return 0
  fi
}
