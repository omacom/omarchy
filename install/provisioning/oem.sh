# What an OEM put on this machine for its first owner: its name, a logo, a
# tagline and a colour for the screen setup opens on, and an agreement to
# accept, under that logo again, as setup's last question. The ISO lays them down in /etc/omarchy/oem from the
# bundle its build was given, checked there: the logo fits setup's column and
# is drawn with characters the console font has, and no text carries control
# characters. Sourced by first-boot owner setup (omarchy-provision-owner),
# after setup-form.sh.
#
#   omarchy_oem_load   sets OMARCHY_OEM_NAME, _TAGLINE, _COLOR, _LOGO, _EULA and
#                      _EULA_TITLE, each empty where the bundle has none
#   omarchy_oem_eula   shows the agreement: 0 accepted, OMARCHY_FORM_BACK on
#                      Esc, OMARCHY_FORM_SIGNAL on Ctrl+C, OMARCHY_OEM_DECLINED
#                      when it is declined
#
# Callers supply measure_terminal and clear_logo, and the PADDING_LEFT,
# LOGO_WIDTH (the column's width) and LOGO_HEIGHT they draw with.

OMARCHY_OEM_DECLINED=3
OMARCHY_OEM_INTERRUPTED=0

# The console the agreement is read and answered on.
omarchy_oem_tty=${OMARCHY_OEM_TTY:-/dev/tty}

omarchy_oem_load() {
  local dir=${OMARCHY_OEM_DIR:-/etc/omarchy/oem}
  OMARCHY_OEM_NAME="" OMARCHY_OEM_TAGLINE="" OMARCHY_OEM_COLOR=""
  OMARCHY_OEM_LOGO="" OMARCHY_OEM_EULA="" OMARCHY_OEM_EULA_TITLE=""
  [[ -r $dir/oem.json ]] || return 0

  {
    IFS= read -r OMARCHY_OEM_NAME
    IFS= read -r OMARCHY_OEM_TAGLINE
    IFS= read -r OMARCHY_OEM_COLOR
    IFS= read -r OMARCHY_OEM_EULA_TITLE
  } < <(jq -r '[.name, .tagline, .color, .eula_title] | map(. // "" | tostring | gsub("[[:cntrl:]]"; " ")) | .[]' \
    "$dir/oem.json" 2>/dev/null) || true

  [[ $OMARCHY_OEM_COLOR =~ ^#[0-9A-Fa-f]{6}$ ]] || OMARCHY_OEM_COLOR=""
  [[ ! -s $dir/logo.txt ]] || OMARCHY_OEM_LOGO=$dir/logo.txt
  [[ ! -s $dir/eula.txt ]] || OMARCHY_OEM_EULA=$dir/eula.txt
}

# One key from the console, by name, in OMARCHY_OEM_KEY. Empty when none came
# within the wait, which is when the caller looks for a console that resized.
# Ctrl+C is the one key that is not read: bash's read turns the console's
# signals back on, so it arrives as the SIGINT omarchy_oem_eula traps.
omarchy_oem_read_key() {
  local key="" sequence="" complete='^[[O][0-9;]*[A-Za-z~]$'
  OMARCHY_OEM_KEY=""
  IFS= read -rsN1 -t 0.25 key 2>/dev/null <"$omarchy_oem_tty" || true
  if ((OMARCHY_OEM_INTERRUPTED)); then
    OMARCHY_OEM_INTERRUPTED=0
    OMARCHY_OEM_KEY=interrupt
    return 0
  fi

  case $key in
    "") ;;
    $'\n' | $'\r') OMARCHY_OEM_KEY=enter ;;
    $'\t') OMARCHY_OEM_KEY=tab ;;
    ' ') OMARCHY_OEM_KEY=pagedown ;;
    $'\033')
      # Esc by itself, or the start of what an arrow or paging key sends.
      while [[ ! $sequence =~ $complete ]] && ((${#sequence} < 8)); do
        IFS= read -rsN1 -t 0.05 key 2>/dev/null <"$omarchy_oem_tty" || break
        sequence+=$key
      done
      case $sequence in
        "") OMARCHY_OEM_KEY=escape ;;
        "[A" | "OA") OMARCHY_OEM_KEY=up ;;
        "[B" | "OB") OMARCHY_OEM_KEY=down ;;
        "[C" | "OC") OMARCHY_OEM_KEY=right ;;
        "[D" | "OD") OMARCHY_OEM_KEY=left ;;
        "[5~") OMARCHY_OEM_KEY=pageup ;;
        "[6~") OMARCHY_OEM_KEY=pagedown ;;
        "[1~" | "[7~" | "[H" | "OH") OMARCHY_OEM_KEY=home ;;
        "[4~" | "[8~" | "[F" | "OF") OMARCHY_OEM_KEY=end ;;
        "[Z") OMARCHY_OEM_KEY=tab ;;
        *) OMARCHY_OEM_KEY=other ;;
      esac
      ;;
    *) OMARCHY_OEM_KEY=other ;;
  esac
}

# The agreement on one screen: its title, the text in a frame that scrolls, and
# the question under it. The arrows and the paging keys read, Tab and the side
# arrows move between the answers, Return gives the one in focus. gum has no
# widget that scrolls text above a question, so this draws its own in gum
# confirm's look.
omarchy_oem_eula() {
  local title=${OMARCHY_OEM_EULA_TITLE:-} prompt accept decline hint rule
  local -a lines=()
  local width=$((LOGO_WIDTH - 4)) total height=3 max=0 offset=0 focus=accept status=0
  local size drawn=unset rows base=2 left=1 right=1 i row thumb thumb_at bar interrupt_trap

  [[ -n $title ]] || title=$(omarchy_form_text ownerSetup.eulaTitle "$OMARCHY_OEM_NAME")
  prompt=$(omarchy_form_text ownerSetup.eulaPrompt)
  accept=$(omarchy_form_text ownerSetup.eulaAccept)
  decline=$(omarchy_form_text ownerSetup.eulaDecline)
  hint=$(omarchy_form_text ownerSetup.eulaScroll)

  mapfile -t lines < <(tr -d '\r' <"$OMARCHY_OEM_EULA" | expand -t 4 |
    LC_ALL=C.UTF-8 fold -s -w "$width" | sed 's/[[:space:]]*$//')
  total=${#lines[@]}
  printf -v rule '%*s' "$((LOGO_WIDTH - 2))" ''
  rule=${rule// /─}

  # Ctrl+C is an answer here, as it is to gum's own widgets, not the end of setup.
  OMARCHY_OEM_INTERRUPTED=0
  interrupt_trap=$(trap -p INT)
  trap 'OMARCHY_OEM_INTERRUPTED=1' INT
  printf '\033[?25l'
  # Keys typed ahead answer nothing here: a second Return meant for the review
  # would accept an agreement nobody saw.
  while IFS= read -rsN1 -t 0.01 _ 2>/dev/null <"$omarchy_oem_tty"; do :; done

  while true; do
    size=$(stty size 2>/dev/null <"$omarchy_oem_tty") || size=""
    if [[ $size != "$drawn" ]]; then
      drawn=$size
      rows=${size%% *}
      [[ $rows =~ ^[0-9]+$ ]] && ((rows > 0)) || rows=${LINES:-24}

      # On a short console the logo gives way before the agreement does.
      if ((rows - LOGO_HEIGHT - 12 >= 6)); then
        clear_logo
        base=$((LOGO_HEIGHT + 3))
      else
        measure_terminal
        printf '\033[H\033[2J'
        base=2
      fi
      height=$((rows - base - 9))
      ((height >= 3)) || height=3
      max=$((total > height ? total - height : 0))
      ((offset <= max)) || offset=$max
      left=$((PADDING_LEFT + 1))
      right=$((left + LOGO_WIDTH - 1))

      printf '\033[%d;%dH%s' "$base" "$left" "$title"
      printf '\033[%d;%dH\033[90m╭%s╮\033[0m' "$((base + 2))" "$left" "$rule"
      printf '\033[%d;%dH\033[90m╰%s╯\033[0m' "$((base + 3 + height))" "$left" "$rule"
      ((max == 0)) || printf '\033[%d;%dH\033[90m%s\033[0m' "$((base + 4 + height))" "$left" "$hint"
      printf '\033[%d;%dH\033[36m%s\033[0m' "$((base + 6 + height))" "$((left + 1))" "$prompt"
    fi

    # The frame's right edge is the scroll bar: bright beside the part shown.
    thumb=0 thumb_at=0
    if ((max > 0)); then
      thumb=$((height * height / total))
      ((thumb >= 1)) || thumb=1
      thumb_at=$((offset * (height - thumb) / max))
    fi
    for ((i = 0; i < height; i++)); do
      row=$((base + 3 + i))
      bar=$'\033[90m│\033[0m'
      ((i < thumb_at || i >= thumb_at + thumb)) || bar=$'\033[97m│\033[0m'
      printf '\033[%d;%dH\033[90m│\033[0m %s\033[K\033[%d;%dH%s' \
        "$row" "$left" "${lines[offset + i]:-}" "$row" "$right" "$bar"
    done

    printf '\033[%d;%dH' "$((base + 8 + height))" "$((left + 1))"
    if [[ $focus == "accept" ]]; then
      printf '\033[30;42m   %s   \033[0m     %s   ' "$accept" "$decline"
    else
      printf '   %s     \033[30;42m   %s   \033[0m' "$accept" "$decline"
    fi

    omarchy_oem_read_key
    case $OMARCHY_OEM_KEY in
      up) offset=$((offset - 1)) ;;
      down) offset=$((offset + 1)) ;;
      pageup) offset=$((offset - height + 1)) ;;
      pagedown) offset=$((offset + height - 1)) ;;
      home) offset=0 ;;
      end) offset=$max ;;
      left | right | tab)
        if [[ $focus == "accept" ]]; then focus=decline; else focus=accept; fi
        ;;
      enter)
        [[ $focus == "accept" ]] || status=$OMARCHY_OEM_DECLINED
        break
        ;;
      escape) status=$OMARCHY_FORM_BACK; break ;;
      interrupt) status=$OMARCHY_FORM_SIGNAL; break ;;
    esac
    ((offset >= 0)) || offset=0
    ((offset <= max)) || offset=$max
  done

  trap - INT
  eval "$interrupt_trap"
  printf '\033[0m\033[?25h\033[H\033[2J'
  return "$status"
}
