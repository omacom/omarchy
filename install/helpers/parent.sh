# Shared by omarchy-parent and its feature commands (omarchy-parent-*), so a
# feature can install a sudoers grant the same careful way, and read and
# document its own keys in the parent's settings file, without copying the
# code. Sourced after the caller has defined `fail`.

SUDOERS_DIR="${OMARCHY_SUDOERS_DIR:-/etc/sudoers.d}"
PARENT_CONF="${OMARCHY_PARENT_CONF:-/etc/omarchy/parent.conf}"

# Stage in the target directory itself, so the final rename is atomic and a
# stray stage file, whose name carries a dot, is one sudo ignores. visudo
# checks the stage before it can become live: a sudoers file that fails to
# parse locks sudo out. Identical content is left alone.
install_sudoers() {
  local name="$1" content="$2"
  local target="$SUDOERS_DIR/$name" stage

  if [[ -f $target ]] && [[ $(<"$target") == "$content" ]]; then
    return 0
  fi

  install -d -m 755 "$SUDOERS_DIR"
  stage=$(mktemp "$SUDOERS_DIR/.$name.XXXXXX")
  printf '%s\n' "$content" >"$stage"
  if ! visudo -cf "$stage" >/dev/null; then
    rm -f "$stage"
    fail "generated sudoers file $name does not parse; nothing was changed"
  fi
  chmod 440 "$stage"
  mv -f "$stage" "$target"
}

# The parent's settings: one key=value per line, world-readable, with every
# key documented in place by whichever command owns it (conf_document), so a
# parent reading the file sees every choice and its default. A hand edit
# takes effect at the owning command's next apply. The file outlives
# `omarchy-parent apply --remove` and every feature's off on purpose.
#
# All writers share a separate lock file, which survives replacement of the
# settings file. Hold it from the first existence/key check through the final
# rename, so documenting a default cannot overwrite a concurrent explicit
# choice. Readers need no lock: they see either complete version. The subshell
# closes the lock descriptor and keeps its umask/trap local to this operation.
conf_change() (
  local operation="$1" key="${2:-}" value="${3:-}" directory lock_fd stage line
  directory=$(dirname "$PARENT_CONF") || return
  mkdir -p "$directory" || return
  umask 077
  exec {lock_fd}>"$directory/.${PARENT_CONF##*/}.lock" || return
  flock -x "$lock_fd" || return

  if [[ $operation == "init" && -f $PARENT_CONF ]]; then
    return 0
  fi
  if [[ $operation == "document" && -f $PARENT_CONF ]] &&
    grep -q "^[[:space:]]*$key[[:space:]]*=" "$PARENT_CONF"; then
    return 0
  fi

  stage=$(mktemp "$directory/.${PARENT_CONF##*/}.XXXXXX") || return
  trap 'rm -f -- "$stage"' EXIT
  if [[ $operation == "set" && -f $PARENT_CONF ]] &&
    grep -q "^[[:space:]]*$key[[:space:]]*=" "$PARENT_CONF"; then
    sed "s/^[[:space:]]*$key[[:space:]]*=.*/$key=$value/" "$PARENT_CONF" >"$stage" || return
  else
    if [[ -f $PARENT_CONF ]]; then
      cat "$PARENT_CONF" >"$stage" || return
    else
      cat >"$stage" <<'CONF' || return
# Omarchy kids mode: what the kid account may do without the parent password,
# and what the parent has switched on. Each key is explained where it appears.
# Change a value and run the matching `sudo omarchy-parent` command's apply
# (`sudo omarchy-parent apply --user <kid>` for the keys omarchy-parent owns),
# or use that command directly; it edits this file for you.
CONF
    fi
    if [[ $operation == "document" ]]; then
      shift 3
      printf '\n' >>"$stage" || return
      for line in "$@"; do printf '# %s\n' "$line" >>"$stage" || return; done
    fi
    if [[ $operation != "init" ]]; then
      printf '%s=%s\n' "$key" "$value" >>"$stage" || return
    fi
  fi
  chmod 644 "$stage" || return
  mv -f -- "$stage" "$PARENT_CONF"
)

conf_init() {
  conf_change init
}

conf_get() {
  local key="$1" default="$2" value=""
  if [[ -f $PARENT_CONF ]]; then
    value=$(sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*//p" "$PARENT_CONF" | tail -1)
    value=${value%"${value##*[![:space:]]}"}
  fi
  printf '%s\n' "${value:-$default}"
}

conf_set() {
  conf_change set "$@"
}

# conf_document KEY DEFAULT COMMENT... appends a commented block and the
# default the first time a command sees the file, and leaves a key the parent
# has already set alone.
conf_document() {
  conf_change document "$@"
}
