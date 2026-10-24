# Writing freedesktop .desktop entries safely: sourced by the commands that
# make launchers (omarchy-webapp-install, omarchy-games-install).

safe_icon_name() {
  printf '%s\n' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'
}

desktop_string_escape() {
  # Desktop Entry "string" value (freedesktop Desktop Entry Spec, "Value types"):
  # a raw newline would start a new key line and let a value inject a second
  # Exec=. Escape backslash first, then tab/CR/LF and a leading space. Every value
  # written into the .desktop file passes through here.
  #
  # Parameter expansion rather than sed: GNU sed's N auto-prints the pattern space
  # and exits at end of input, so a `:a;N;$!ba` slurp skips every following s///
  # for a value with no newline in it - which is every value except the injection
  # attempt this exists to stop.
  local value="$1"

  value=${value//\\/\\\\}
  value=${value//$'\t'/\\t}
  value=${value//$'\r'/\\r}
  value=${value//$'\n'/\\n}
  [[ $value == " "* ]] && value="\\s${value# }"

  printf '%s' "$value"
}

desktop_exec_arg() {
  # One Exec argument, double-quoted per the freedesktop Exec spec: inside quotes
  # " ` $ \ take a backslash and a literal % becomes %%. Only the default Exec's
  # URL needs this; $CUSTOM_EXEC stays a whole command line (file-syntax only).
  local escaped
  escaped=$(printf '%s' "$1" \
    | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/`/\\`/g' -e 's/\$/\\$/g' -e 's/%/%%/g')
  printf '"%s"' "$escaped"
}
