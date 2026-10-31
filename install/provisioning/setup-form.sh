# The setup form: every question Omarchy asks a human to describe their machine
# — keyboard, account, hostname, timezone — plus the rules those answers are
# checked against. Shared by the two places that ask them: the ISO
# configurator's user step and this package's first-boot owner setup
# (omarchy-provision-owner). Sourced by both, so the copies cannot drift the way
# the keyboard list already did.
#
# Every prompt reports one of three statuses, and both callers read them the
# same way:
#
#   0    field is set, move on
#   1    Esc — unwind to the start of the form
#   130  Ctrl+C — a per-caller side channel (the installer arms deferred
#        provisioning or toggles encryption; first-boot setup offers a reboot)
#
# gum is the reason those two are the whole vocabulary: Esc and Ctrl+C are the
# only keys any gum widget exits on, and Ctrl+C arrives as a byte in raw mode,
# so it never reaches the shell as SIGINT. Act on the status, never on a trap.
#
# Callers supply `notice <message> <seconds>` for validation feedback, and set
# the variables these prompts write: keyboard, keyboard_label,
# keyboard_input_method, keyboard_xkb_layout, username,
# password, password_confirmation, full_name, email_address, hostname, timezone.
#
# Callers may also set OMARCHY_FORM_LANGUAGE (a language registry code for the
# form's text), OMARCHY_FORM_KEYBOARD_DEFAULT (a layout label to preselect),
# OMARCHY_FORM_TIMEZONE_DEFAULT (a timezone that beats the network's guess) and
# OMARCHY_FORM_TIMEZONE_FALLBACK (one used only when that guess fails).

OMARCHY_FORM_BACK=1
OMARCHY_FORM_SIGNAL=130

# The English layouts lead, then everything else alphabetically. gum choose
# paginates in --height-sized pages and jumps to the page holding --selected,
# so an alphabetical English (US) landed deep enough to sit alone at the edge
# of a page of layouts nobody scanning for it reads. Up here the default and
# its variants are the first thing on screen no matter how the list grows.
OMARCHY_KEYBOARD_LAYOUTS=$'English (US)|us
English (UK)|uk
English (US, Dvorak)|dvorak
English (US, Colemak)|colemak
Belarusian|by
Belgian|be-latin1
Bulgarian|bg-cp1251
Chinese (Simplified, Pinyin)|us|pinyin
Croatian|croat
Czech|cz
Danish|dk-latin1
Dutch|nl
Estonian|et
Finnish|fi
French|fr
French (Canada)|cf
French (Switzerland)|fr_CH
Georgian|ge
German|de
German (Switzerland)|de_CH-latin1
Greek|gr
Hebrew|il
Hong Kong (Cangjie)|us|cangjie5
Hungarian|hu
Icelandic|is-latin1
Irish|ie
Italian|it
Japanese|jp106|mozc
Japanese (US keyboard)|us|mozc
Kazakh|kazakh
Korean|us|hangul|kr:kr104
Kyrgyz|kyrgyz
Lao|us||la
Latvian|lv
Lithuanian|lt
Macedonian|mk-utf
Norwegian|no-latin1
Polish|pl
Portuguese|pt-latin1
Portuguese (Brazil)|br-abnt2
Romanian|ro
Russian|ru
Serbian|sr-latin
Slovak|sk-qwertz
Slovenian|slovene
Spanish|es
Spanish (Latin American)|la-latin1
Swedish|sv-latin1
Taiwan (Zhuyin)|us|chewing
Tajik|tj_alt-UTF8
Turkish|trq
Ukrainian|ua'

OMARCHY_USERNAME_PATTERN='^[a-z_][a-z0-9_-]*[$]?$'
OMARCHY_RESERVED_USERNAMES='^(root|bin|daemon|mail|ftp|http|nobody|dbus|systemd-coredump|systemd-network|systemd-oom|systemd-journal-remote|systemd-resolve|systemd-timesync|tss|uuidd|alpm|git|avahi|cups|cups-browsed|lp|_talkd|polkitd|rtkit|qemu|brltty|gluster|rpc|libvirt-qemu|pcscd|nvidia-persistenced|sddm)$'
OMARCHY_HOSTNAME_PATTERN='^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$'
OMARCHY_HOSTNAME_DEFAULT='omarchy'

# Installer targets are empty, so any account is fair game; first-boot setup
# overrides this because its machine already has users.
omarchy_username_taken() { return 1; }

# `x=$(gum ...) && status=0 || status=$?` rather than a bare assignment followed
# by `status=$?`: one caller runs under `set -e`, where a cancelled prompt is a
# failing assignment that would kill the script before the status is read.

# Install media for one market can leave its keyboard and timezone choices for
# a first-boot owner setup: plain KEY=value lines, read as data. The live
# installer sets the same defaults in its environment instead.
omarchy_form_defaults=${OMARCHY_FORM_DEFAULTS:-/etc/omarchy/form-defaults}
if [[ -r $omarchy_form_defaults ]]; then
  while IFS='=' read -r omarchy_form_key omarchy_form_value; do
    case "$omarchy_form_key" in
      KEYBOARD) : "${OMARCHY_FORM_KEYBOARD_DEFAULT:=$omarchy_form_value}" ;;
      TIMEZONE) : "${OMARCHY_FORM_TIMEZONE_DEFAULT:=$omarchy_form_value}" ;;
    esac
  done <"$omarchy_form_defaults"
  unset omarchy_form_key omarchy_form_value
fi

# The form's strings live in Omarchy's CLI catalogs, which the live ISO carries
# too. The caller names the language in OMARCHY_FORM_LANGUAGE; English fills in.
omarchy_form_i18n=${OMARCHY_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}/default/i18n

omarchy_form_text() {
  local language=${OMARCHY_FORM_LANGUAGE:-en} text
  local -a catalogs=("$omarchy_form_i18n/en/cli.json")
  [[ $language =~ ^[a-z]{2,3}(-[A-Z]{2})?$ && -r $omarchy_form_i18n/$language/cli.json ]] &&
    catalogs=("$omarchy_form_i18n/$language/cli.json" "${catalogs[@]}")
  text=$(jq -rn --arg key "$1" 'first(inputs | .[$key] // empty) // empty' "${catalogs[@]}" 2>/dev/null) || text=""
  printf '%s' "${text:-$1}"
}

omarchy_prompt_keyboard() {
  local choice status default=${OMARCHY_FORM_KEYBOARD_DEFAULT:-English (US)}
  # gum splits --selected on commas, so "Chinese (Simplified, Pinyin)" needs them escaped.
  choice=$(printf '%s\n' "$OMARCHY_KEYBOARD_LAYOUTS" | cut -d'|' -f1 |
    gum choose --height 10 --selected "${default//,/\\,}" --header "$(omarchy_form_text setupForm.keyboardHeader)") && status=0 || status=$?
  ((status == 0)) || return $status

  local selection
  selection=$(printf '%s\n' "$OMARCHY_KEYBOARD_LAYOUTS" | awk -F'|' -v c="$choice" '$1==c{print; exit}')
  [[ -n $selection ]] || return 1
  IFS='|' read -r keyboard_label keyboard keyboard_input_method keyboard_xkb_layout <<< "$selection"
  keyboard_input_method=${keyboard_input_method:-none}
  keyboard_xkb_layout=${keyboard_xkb_layout:-}
}

# Root-side persistence. Console keymaps remain real keymaps; the input
# preference survives separately for every user of the installed system.
omarchy_persist_input_selection() {
  local target_root=${1:-} method=${keyboard_input_method:-none} layout=${keyboard_xkb_layout:-}
  case "$method" in none | mozc | hangul | pinyin | chewing | cangjie5) ;; *) return 1 ;; esac
  case "$layout" in "" | kr | kr:kr104 | la) ;; *) return 1 ;; esac
  mkdir -p "$target_root/etc/omarchy"
  printf 'INPUT_METHOD=%s\nXKB_LAYOUT=%s\n' "$method" "$layout" > "$target_root/etc/omarchy/input-method"
}

omarchy_prompt_username() {
  local status
  while true; do
    username=$(gum input --placeholder "$(omarchy_form_text setupForm.usernamePlaceholder)" --prompt.foreground="#845DF9" --prompt "$(omarchy_form_text setupForm.usernamePrompt)") && status=0 || status=$?
    ((status == 0)) || return $status

    if [[ "$username" =~ $OMARCHY_USERNAME_PATTERN ]]; then
      if [[ "$username" =~ $OMARCHY_RESERVED_USERNAMES ]]; then
        notice "$(omarchy_form_text setupForm.usernameReserved)" 1
      elif omarchy_username_taken "$username"; then
        notice "$(omarchy_form_text setupForm.usernameTaken)" 1
      else
        return 0
      fi
    else
      notice "$(omarchy_form_text setupForm.usernameInvalid)" 1
    fi
  done
}

omarchy_prompt_password() {
  local status
  while true; do
    password=$(gum input --placeholder "$(omarchy_form_text setupForm.passwordPlaceholder)" --prompt.foreground="#845DF9" --password --prompt "$(omarchy_form_text setupForm.passwordPrompt)") && status=0 || status=$?
    ((status == 0)) || return $status
    password_confirmation=$(gum input --placeholder "$(omarchy_form_text setupForm.confirmPlaceholder)" --prompt.foreground="#845DF9" --password --prompt "$(omarchy_form_text setupForm.confirmPrompt)") && status=0 || status=$?
    ((status == 0)) || return $status

    if [[ -n "$password" && "$password" == "$password_confirmation" ]]; then
      return 0
    elif [[ -z "$password" ]]; then
      notice "$(omarchy_form_text setupForm.passwordBlank)" 1
    else
      notice "$(omarchy_form_text setupForm.passwordMismatch)" 1
    fi
  done
}

# Only ISO configurators from before omarchy-setup-git still call this.
# Both fields are skippable with Return, so an empty value is a real answer and
# only Esc/Ctrl+C end the prompt early.
omarchy_prompt_identity() {
  local status
  full_name=$(gum input --placeholder "Used for git authentication (hit return to skip)" --prompt.foreground="#845DF9" --prompt "Full name> ") && status=0 || status=$?
  ((status == 0)) || return $status
  email_address=$(gum input --placeholder "Used for git authentication (hit return to skip)" --prompt.foreground="#845DF9" --prompt "Email address> ") && status=0 || status=$?
  return $status
}

omarchy_prompt_hostname() {
  local status
  while true; do
    hostname=$(gum input --placeholder "$(omarchy_form_text setupForm.hostnamePlaceholder)" --prompt.foreground="#845DF9" --prompt "$(omarchy_form_text setupForm.hostnamePrompt)") && status=0 || status=$?
    ((status == 0)) || return $status

    if [[ -z $hostname ]]; then
      hostname="$OMARCHY_HOSTNAME_DEFAULT"
      return 0
    elif [[ "$hostname" =~ $OMARCHY_HOSTNAME_PATTERN ]]; then
      return 0
    else
      notice "$(omarchy_form_text setupForm.hostnameInvalid)" 1
    fi
  done
}

# A fresh machine often hasn't joined a network yet, so the geo guess fails
# often; guard it or a `set -e` caller dies before the picker opens.
#
# The picker is always gum filter, so a city can be typed. The guess leads the
# list with the search left empty: Enter takes it, and the first key typed
# searches every zone. Neither --value nor --selected does this. --value puts
# the guess in the search, so typing "london" searches "Europe/Amsterdamlondon".
# At limit 1, --selected prints that entry even after another one was picked.
omarchy_prompt_timezone() {
  local guess status zones
  # A preset install media names its timezone; otherwise ask geo.omarchy.org,
  # Omarchy's own lookup of where this network is, and failing that take the
  # caller's fallback, like the language's capital.
  guess=${OMARCHY_FORM_TIMEZONE_DEFAULT:-}
  [[ -n $guess ]] || guess=$(curl -fsS --max-time 5 https://geo.omarchy.org/ 2>/dev/null | jq -r '.timezone // empty' 2>/dev/null) || guess=""
  [[ -n $guess ]] || guess=${OMARCHY_FORM_TIMEZONE_FALLBACK:-}

  zones=$(timedatectl list-timezones)
  if [[ -n $guess && $guess != *$'\n'* && $'\n'$zones$'\n' == *$'\n'"$guess"$'\n'* ]]; then
    zones=$(printf '%s\n' "$guess"; grep -vxF -- "$guess" <<<"$zones")
  fi

  timezone=$(gum filter --height 10 --header "$(omarchy_form_text setupForm.timezoneHeader)" <<<"$zones") && status=0 || status=$?
  ((status == 0)) || return $status

  [[ -n $timezone ]] || timezone="UTC"
}
