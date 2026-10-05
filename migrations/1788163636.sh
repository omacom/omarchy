echo "Replace unauthenticated Apple T2 packages with signed Omarchy packages"

pacman_conf=/etc/pacman.conf
repair_marker=/var/lib/omarchy/t2-package-provenance-repaired
t2_packages=(linux-t2 linux-t2-headers apple-t2-audio-config apple-bcm-firmware t2fanrd)
t2_targets=("${t2_packages[@]/#/omarchy/}")

# Avoid a password prompt on unaffected or already repaired machines. Repeat
# discovery inside the machine lock before acting on shared state.
needs_machine_repair() {
  local installed_packages pci_devices package policy_status
  if legacy_repository_is_unsafe; then
    return 0
  else
    policy_status=$?
    (( policy_status == 1 )) || return 2
  fi
  [[ ! -e $repair_marker ]] || return 1

  installed_packages=$(/usr/bin/pacman -Qq) || return 2
  for package in "${t2_packages[@]}"; do
    if [[ $'\n'$installed_packages$'\n' == *$'\n'"$package"$'\n'* ]]; then
      return 0
    fi
  done
  pci_devices=$(/usr/bin/lspci -nn) || return 2
  [[ $pci_devices == *"106b:1801"* || $pci_devices == *"106b:1802"* ]]
}

legacy_repository_is_unsafe() {
  local repositories signature_policy
  repositories=$(/usr/bin/pacman-conf --config "$pacman_conf" --repo-list) || return 2
  [[ $'\n'$repositories$'\n' == *$'\narch-mact2\n'* ]] || return 1

  # Resolve includes, inherited policy and directive precedence through pacman
  # itself. DatabaseOptional/DatabaseNever do not weaken package signatures.
  if ! signature_policy=$(/usr/bin/pacman-conf --config "$pacman_conf" --repo arch-mact2 SigLevel); then
    echo "Could not resolve the arch-mact2 signature policy; leaving the repair pending." >&2
    return 2
  fi
  if [[ -z ${signature_policy//[$' \t\n\r']/} ]]; then
    if ! signature_policy=$(/usr/bin/pacman-conf --config "$pacman_conf" SigLevel); then
      echo "Could not resolve the inherited signature policy; leaving the repair pending." >&2
      return 2
    fi
  fi
  signature_policy=${signature_policy//$'\n'/ }
  signature_policy=${signature_policy//$'\t'/ }
  if [[ " $signature_policy " == *" PackageRequired "* &&
    " $signature_policy " == *" PackageTrustedOnly "* &&
    " $signature_policy " != *" PackageOptional "* &&
    " $signature_policy " != *" PackageNever "* &&
    " $signature_policy " != *" PackageTrustAll "* ]]; then
    return 1
  fi
  return 0
}

disable_unsafe_t2_repository() (
  local section backup stage="" policy_status
  if legacy_repository_is_unsafe; then
    :
  else
    policy_status=$?
    if (( policy_status == 1 )); then
      return 0
    else
      return 1
    fi
  fi

  section=$(/usr/bin/awk '
    found && /^[[:space:]]*\[/ { exit }
    /^[[:space:]]*\[arch-mact2\][[:space:]]*$/ { found = 1 }
    found { print }
  ' "$pacman_conf")
  if [[ -z $section ]]; then
    echo "Unsafe arch-mact2 policy is defined in an included file; disable that repository and retry this migration." >&2
    return 1
  fi

  backup="$(/usr/bin/dirname "$pacman_conf")/arch-mact2.omarchy-disabled.$(/usr/bin/date +%s).txt"
  /usr/bin/install -T -o root -g root -m 0600 /dev/stdin "$backup" <<<"$section"
  stage=$(/usr/bin/mktemp \
    --tmpdir="$(/usr/bin/dirname "$pacman_conf")" \
    '.pacman.conf.omarchy-t2.XXXXXXXX')
  trap '[[ -z ${stage:-} ]] || /usr/bin/rm -f -- "$stage"' EXIT
  /usr/bin/awk '
    /^[[:space:]]*\[arch-mact2\][[:space:]]*$/ { drop = 1; next }
    drop && /^[[:space:]]*\[/ { drop = 0 }
    !drop { print }
  ' "$pacman_conf" |
    /usr/bin/install -T -o root -g root -m 0644 /dev/stdin "$stage"
  /usr/bin/mv -Tf -- "$stage" "$pacman_conf"
  stage=""
  trap - EXIT
  echo "Disabled the unsafe arch-mact2 section; preserved it at $backup"
)

repair_machine() {
  # This is intentionally first inside the machine lock. If package discovery, download, signature
  # validation, or reinstall fails later, retrying is safe and the unsigned
  # repository remains unavailable.
  disable_unsafe_t2_repository

  [[ ! -e $repair_marker ]] || exit 0

  if needs_machine_repair; then
    :
  else
    discovery_status=$?
    if (( discovery_status == 1 )); then
      return 0
    else
      echo "Could not inspect T2 hardware or packages; leaving the repair pending." >&2
      return 1
    fi
  fi

  # Do not assume an earlier update helper ran this migration. Ask pacman for the
  # effective policy and require both mandatory package signatures and trusted
  # signers before querying or reinstalling any replacement.
  effective_siglevel=$(/usr/bin/pacman-conf --config "$pacman_conf" --repo omarchy SigLevel 2>/dev/null) || {
    echo "Could not resolve the Omarchy repository signature policy; refusing T2 replacement." >&2
    exit 1
  }
  if [[ -z ${effective_siglevel//[$' \t\n\r']/} ]]; then
    effective_siglevel=$(/usr/bin/pacman-conf --config "$pacman_conf" SigLevel 2>/dev/null) || {
      echo "Could not resolve the inherited package signature policy; refusing T2 replacement." >&2
      exit 1
    }
  fi
  effective_siglevel=${effective_siglevel//$'\n'/ }
  effective_siglevel=${effective_siglevel//$'\t'/ }
  if [[ " $effective_siglevel " != *" PackageRequired "* ||
    " $effective_siglevel " != *" PackageTrustedOnly "* ||
    " $effective_siglevel " == *" PackageOptional "* ||
    " $effective_siglevel " == *" PackageNever "* ||
    " $effective_siglevel " == *" PackageTrustAll "* ]]; then
    echo "The Omarchy repository does not enforce trusted package signatures; refusing T2 replacement." >&2
    exit 1
  fi

  # Resolve every replacement before beginning the reinstall, and require the
  # pinned-key Omarchy repository by name. The repository itself inherits the
  # effective package-required/trusted-only policy verified above.
  for package in "${t2_packages[@]}"; do
    if ! repository_metadata=$(LC_ALL=C /usr/bin/pacman -Si "omarchy/$package" 2>/dev/null); then
      repository=""
    else
      # Consume the complete producer output. Exiting awk after the first field
      # turns a large successful pacman query into SIGPIPE under pipefail.
      repository=$(/usr/bin/awk -F: '
        !found && /^Repository[[:space:]]*:/ {
          gsub(/[[:space:]]/, "", $2)
          print $2
          found = 1
        }
      ' <<<"$repository_metadata")
    fi
    if [[ $repository != "omarchy" ]]; then
      echo "Authenticated replacement '$package' is unavailable from the Omarchy repository." >&2
      echo "The unsafe repository is disabled. Publish all signed T2 artifacts, then retry this migration." >&2
      exit 1
    fi
  done

  # No --needed: the bytes already installed under SigLevel=Never have no trusted
  # provenance even when their version equals the signed replacement.
  if ! /usr/bin/pacman -S --noconfirm "${t2_targets[@]}"; then
    echo "Authenticated T2 package reinstall failed; leaving the repair pending." >&2
    exit 1
  fi

  marker_dir=$(/usr/bin/dirname "$repair_marker")
  /usr/bin/install -d -o root -g root -m 0755 "$marker_dir"
  printf 'Reinstalled from signed Omarchy repository at %s\n' "$(/usr/bin/date --iso-8601=seconds)" |
    /usr/bin/install -T -o root -g root -m 0644 /dev/stdin "$repair_marker"
}

if (( $# == 0 )); then
  if needs_machine_repair; then
    echo "Waiting to apply the Apple T2 system repair..."
    umask 077
    # Elevate only the fixed packaged migration. /run is owned by root; keep
    # the lock through the package transaction and completion publication.
    /usr/bin/sudo -N -- /usr/bin/flock --exclusive --no-fork /run/omarchy-t2-package-provenance.lock \
      /usr/bin/bash -p -euo pipefail /usr/share/omarchy/migrations/1788163636.sh --machine
  else
    discovery_status=$?
    if (( discovery_status != 1 )); then
      echo "Could not inspect T2 hardware or packages; leaving the repair pending." >&2
      exit 1
    fi
  fi
elif (( $# == 1 && EUID == 0 )) && [[ $1 == "--machine" ]]; then
  export PATH=/usr/bin:/bin
  repair_machine
else
  echo "This migration accepts no arguments; its machine phase requires root." >&2
  exit 1
fi
