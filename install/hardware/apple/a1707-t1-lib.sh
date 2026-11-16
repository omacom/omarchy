# Shared helpers for the 2016 15-inch MacBook Pro (A1707, MacBookPro13,3, Apple T1).
# Sourced by the A1707 hardware leaves; no shebang.

A1707_T1_SRC=${A1707_T1_SRC:-${OMARCHY_INSTALL:-$OMARCHY_PATH/install}/hardware/apple/a1707}
A1707_T1_CACHE=${A1707_T1_CACHE:-/var/cache/omarchy/a1707}
A1707_T1_KEY_FPR=35B166F78B063B04DE1E3D913E6C4216EB03D371
A1707_T1_KEY_URL=https://linux.standardagents.ai/arch/standardagents/x86_64/t1bridge-signing-key.asc

# True when this is an A1707 with a live T1. Warns when the DMI matches but
# the iBridge is in recovery (05ac:1281) or missing.
a1707_t1_applicable() {
  if omarchy-hw-macbookpro13-3; then
    return 0
  fi

  local product_name
  product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
  if [[ $product_name == "MacBookPro13,3" ]]; then
    echo "MacBookPro13,3 (A1707) found, but the T1 iBridge is not USB 05ac:8600 (05ac:1281 is recovery). Speaker, Touch Bar and Touch ID setup skipped; keep EFI/APPLE/EMBEDDEDOS on the Apple EFI partition."
  fi
  return 1
}

a1707_t1_read_pin() {
  tr -d '[:space:]' <"$A1707_T1_SRC/$1"
}

# Clone or update a git repo onto a pinned commit. Idempotent.
a1707_t1_clone_pinned() {
  local url=$1 dest=$2 commit=$3

  mkdir -p "$(dirname "$dest")"
  if [[ -d $dest/.git && $(git -C "$dest" rev-parse HEAD 2>/dev/null) == "$commit" ]]; then
    git -C "$dest" reset --quiet --hard "$commit"
    return 0
  fi

  if [[ ! -d $dest/.git ]]; then
    rm -rf "$dest"
    GIT_TERMINAL_PROMPT=0 git clone --quiet -- "$url" "$dest"
  else
    GIT_TERMINAL_PROMPT=0 git -C "$dest" fetch --quiet origin
  fi

  git -C "$dest" checkout --quiet --force "$commit"
  git -C "$dest" reset --quiet --hard "$commit"
  [[ $(git -C "$dest" rev-parse HEAD) == "$commit" ]]
}

# Add the Standard Agents repo so t1bridge packages survive omarchy-apply-pacman.
# DMI-only: keep the repo even when the T1 is in recovery so a later retry works.
a1707_t1_ensure_standardagents_repo() {
  local pacman_conf=${A1707_T1_PACMAN_CONF:-/etc/pacman.conf}
  local key_dir fpr

  if ! grep -q '^\[standardagents\]' "$pacman_conf"; then
    cat >>"$pacman_conf" <<'EOF'

[standardagents]
SigLevel = Required DatabaseRequired
Server = https://linux.standardagents.ai/arch/$repo/$arch
EOF
  fi

  if pacman-key --list-keys "$A1707_T1_KEY_FPR" >/dev/null 2>&1; then
    return 0
  fi

  key_dir=$(mktemp -d)
  curl -fSLo "$key_dir/key.asc" "$A1707_T1_KEY_URL"
  fpr=$(gpg --show-keys --with-colons "$key_dir/key.asc" | awk -F: '$1=="fpr"{print $10; exit}')
  if [[ $fpr != "$A1707_T1_KEY_FPR" ]]; then
    rm -rf "$key_dir"
    echo "T1Bridge signing key fingerprint mismatch (got ${fpr:-none})" >&2
    return 1
  fi
  pacman-key --add "$key_dir/key.asc"
  pacman-key --lsign-key "$A1707_T1_KEY_FPR" || true
  rm -rf "$key_dir"
}
