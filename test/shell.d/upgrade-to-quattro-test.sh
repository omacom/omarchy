#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

upgrade_to_quattro="$ROOT/bin/omarchy-upgrade-to-quattro"

function_body() {
  awk -v name="$1" '$0 == name "() {" { inside = 1; next } inside && $0 == "}" { exit } inside' "$upgrade_to_quattro"
}

snapshot_line=$(grep -n '^create_pre_upgrade_snapshot$' "$upgrade_to_quattro" | cut -d: -f1)
pacman_line=$(grep -n '^configure_pacman_channel$' "$upgrade_to_quattro" | cut -d: -f1)
[[ -n $snapshot_line && -n $pacman_line ]] || fail "upgrade snapshot and first mutation calls exist"
(( snapshot_line < pacman_line )) || fail "upgrade snapshot runs before pacman configuration"
grep -F 'omarchy-snapshot create || (($? == 127))' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade snapshots the system before mutation"

# The mirrors are repointed immediately before the keyrings go in, so only a
# forced refresh replaces the legacy database and its stale checksums.
grep -F 'pacman -Syy --noconfirm archlinux-keyring omarchy-keyring' "$upgrade_to_quattro" >/dev/null
if grep -F 'pacman -Sy --noconfirm archlinux-keyring omarchy-keyring' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade forces a database refresh before installing keyrings"
fi
pass "Omarchy 4 upgrade forces a database refresh before installing keyrings"

grep -F 'pacman -Syu --needed' "$upgrade_to_quattro" >/dev/null
grep -F 'omarchy-update-aur-pkgs' "$upgrade_to_quattro" >/dev/null
grep -F 'omarchy-update-available' "$upgrade_to_quattro" >/dev/null
grep -F 'omarchy-update-mise' "$upgrade_to_quattro" >/dev/null
grep -F 'run_final_system_package_upgrade' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade completes package update checks"

grep -F 'run_post_upgrade_migrations' "$upgrade_to_quattro" >/dev/null
grep -F 'omarchy-migrate' "$upgrade_to_quattro" >/dev/null
grep -F 'dust' "$upgrade_to_quattro" >/dev/null
grep -F 'satty' "$upgrade_to_quattro" >/dev/null
final_upgrade_line=$(grep -n '^run_final_system_package_upgrade$' "$upgrade_to_quattro" | cut -d: -f1)
migrations_line=$(grep -n '^run_post_upgrade_migrations$' "$upgrade_to_quattro" | cut -d: -f1)
[[ -n $final_upgrade_line && -n $migrations_line ]] ||
  fail "final package upgrade and migration calls exist"
(( final_upgrade_line < migrations_line )) ||
  fail "Omarchy migrations run after the final package upgrade"
pass "Omarchy 4 upgrade applies packaged migrations"

if grep -F 'skip-first-run-update-notification' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade does not use notification-specific first-run state"
fi
pass "Omarchy 4 upgrade completes first-run as one lifecycle"

grep -F 'touch "$done_dir/first-run-user" "$done_dir/finalize-user"' "$upgrade_to_quattro" >/dev/null
grep -F 'rm -f "$state_dir/first-run-user.done" "$state_dir/finalize-user.done"' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade completes first-run and migrates legacy completion markers"

# The script runs from the branch against whatever packaged tree the channel
# serves, so a packaged command missing from an older build must never be able
# to abort the upgrade partway through.
if grep -F '"$root/bin/omarchy-done"' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade writes completion markers without the packaged omarchy-done"
fi
pass "Omarchy 4 upgrade writes completion markers without the packaged omarchy-done"

for guarded_step in omarchy-refresh-applications 'omarchy-bar defaults'; do
  grep -F "run_as_user_omarchy $guarded_step ||" "$upgrade_to_quattro" >/dev/null ||
    fail "Omarchy 4 upgrade survives a packaged tree without $guarded_step"
done
pass "Omarchy 4 upgrade survives a packaged tree missing top-level commands"

grep -F 'configure_snapper_policy' "$upgrade_to_quattro" >/dev/null
grep -F '/usr/share/omarchy/install/config/snapper.sh' "$upgrade_to_quattro" >/dev/null
grep -F 'bash -euo pipefail "$snapper_config_script"' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade normalizes Snapper retention"

grep -F 'configure_lock_authentication' "$upgrade_to_quattro" >/dev/null
grep -F 'OMARCHY_INSTALL_USER="$target_user"' "$upgrade_to_quattro" >/dev/null
grep -F '"$apply_lock"' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade configures lock screen authentication for the target user"

root_path_count=$(awk '/^root_path=/{ count++ } END { print count + 0 }' "$upgrade_to_quattro")
(( root_path_count == 1 )) || fail "Omarchy 4 upgrade defines exactly one root command path"
grep -Fx 'root_path=/usr/share/omarchy/bin:/usr/local/bin:/usr/bin:/bin' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade limits root command lookup to trusted system directories"
if grep -E '^root_path=.*(target_home|\.local/bin)' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade does not put the target user's bin directory on the root command path"
fi
grep -Fx 'package_path="$root_path:$target_home/.local/bin"' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade retains the target user's bin directory for user commands"

lock_authentication_body=$(function_body configure_lock_authentication)
lock_path_assignment_count=$(awk '{ count += gsub(/(^|[[:space:]])PATH=/, "") } END { print count + 0 }' <<<"$lock_authentication_body")
(( lock_path_assignment_count == 1 )) ||
  fail "Omarchy 4 upgrade gives the privileged lock helper exactly one command path"
grep -Fx '    PATH="$root_path" \' <<<"$lock_authentication_body" >/dev/null ||
  fail "Omarchy 4 upgrade gives the privileged lock helper the trusted root path"
if grep -E '(package_path|target_home|\.local/bin)' <<<"$lock_authentication_body" >/dev/null; then
  fail "Omarchy 4 upgrade does not give the privileged lock helper the target user's path"
fi

firewall_body=$(function_body apply_firewall_defaults)
firewall_path_assignment_count=$(awk '{ count += gsub(/(^|[[:space:]])PATH=/, "") } END { print count + 0 }' <<<"$firewall_body")
(( firewall_path_assignment_count == 1 )) ||
  fail "Omarchy 4 upgrade gives the privileged firewall helper exactly one command path"
grep -Fx '  as_root env OMARCHY_PATH=/usr/share/omarchy PATH="$root_path" \' <<<"$firewall_body" >/dev/null ||
  fail "Omarchy 4 upgrade gives the privileged firewall helper the trusted root path"
if grep -E '(package_path|target_home|\.local/bin)' <<<"$firewall_body" >/dev/null; then
  fail "Omarchy 4 upgrade does not give the privileged firewall helper the target user's path"
fi

user_omarchy_body=$(function_body run_as_user_omarchy)
grep -F 'PATH="$package_path"' <<<"$user_omarchy_body" >/dev/null ||
  fail "Omarchy 4 upgrade retains the package and user path for target-user commands"
if grep -F 'PATH="$root_path"' <<<"$user_omarchy_body" >/dev/null; then
  fail "Omarchy 4 upgrade does not narrow target-user commands to the root-only path"
fi
pass "Omarchy 4 upgrade separates privileged and target-user command paths"

grep -F 'install/helpers/browser-policy.sh' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade uses the shared browser-policy helper"
grep -F 'as_root test -f "$browser_policy_helper"' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade survives a packaged tree without the browser-policy helper"
if grep -F 'browser_policy_setup_group' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade does not create a browser-policy group"
fi
grep -F 'browser_policy_setup_dir /etc/chromium/policies/managed' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade creates a root-owned Chromium policy directory"
grep -F 'BROWSER_POLICY_MANAGED_DIRS' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade hardens every Chromium-family policy directory"
grep -F 'run_as_user_omarchy omarchy-theme-set-browser' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade rewrites browser theme colour after a headless theme-set"
if grep -E 'install -d -m 0?[27]?777 /etc/.*/policies|chmod a\+rw|2775' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade does not create a world-writable Chromium policy directory"
fi
pass "Omarchy 4 upgrade locks the Chromium policy directory to root"

grep -F 'OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1' "$upgrade_to_quattro" >/dev/null
grep -F 'systemd-networkd.service' "$upgrade_to_quattro" >/dev/null
grep -F 'systemd-networkd.socket' "$upgrade_to_quattro" >/dev/null
grep -F 'systemd-networkd-resolve-hook.socket' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade retires systemd-networkd for NetworkManager"

# Booting with both managers enabled leaves them fighting over the Wi-Fi
# adapter, so enabling NetworkManager and disabling iwd cannot be separated by
# any step that might abort in between.
migrations_body=$(function_body run_post_upgrade_migrations)
grep -F 'fail "Omarchy migrations did not complete.' <<<"$migrations_body" >/dev/null ||
  fail "Omarchy 4 upgrade fails when a migration cannot complete"
grep -F 'omarchy-migrate --pending' <<<"$migrations_body" >/dev/null ||
  fail "Omarchy 4 upgrade verifies that migrations actually completed"
grep -F 'fail "Omarchy migrations are still pending.' <<<"$migrations_body" >/dev/null ||
  fail "Omarchy 4 upgrade fails when a successful migration command leaves pending work"
grep -F 'pending_status != 1' <<<"$migrations_body" >/dev/null ||
  fail "Omarchy 4 upgrade distinguishes no pending work from a failed verification"
grep -F 'fail "Could not verify that Omarchy migrations completed.' <<<"$migrations_body" >/dev/null ||
  fail "Omarchy 4 upgrade fails when it cannot verify migration state"
if grep -F 'return 0' <<<"$migrations_body" >/dev/null || grep -F 'warn ' <<<"$migrations_body" >/dev/null; then
  fail "Omarchy 4 upgrade does not continue past failed migrations"
fi

exercise_post_upgrade_migrations() {
  local stub_migration_status="$1" stub_pending_status="$2"

  (
    log() { :; }
    fail() { exit 1; }
    run_as_user_omarchy() {
      if [[ " $* " == *" --pending "* ]]; then
        return "$stub_pending_status"
      else
        return "$stub_migration_status"
      fi
    }
    eval "run_post_upgrade_migrations() { $migrations_body
}"
    run_post_upgrade_migrations
  )
}

exercise_post_upgrade_migrations 0 1 >/dev/null 2>&1 ||
  fail "Omarchy 4 upgrade accepts a completed migration queue"
if exercise_post_upgrade_migrations 1 1 >/dev/null 2>&1; then
  fail "Omarchy 4 upgrade accepts a failed migration"
fi
if exercise_post_upgrade_migrations 0 0 >/dev/null 2>&1; then
  fail "Omarchy 4 upgrade accepts pending migrations"
fi
if exercise_post_upgrade_migrations 0 2 >/dev/null 2>&1; then
  fail "Omarchy 4 upgrade accepts a failed pending-state check"
fi
pass "Omarchy 4 upgrade cannot finish with pending migrations"

# Run the actual missing-default copy before the actual backend migration, as
# the legacy upgrade does. Package lookup is the only external stub.
(
  dictation_tmp=$(mktemp -d)
  trap 'rm -rf "$dictation_tmp"' EXIT
  root=$dictation_tmp/source
  export HOME=$dictation_tmp/home XDG_CONFIG_HOME=$dictation_tmp/home/.config
  export PATH="$root/bin:$PATH" VOXTYPE_PACKAGE=1
  unset OMARCHY_MIGRATION_STATE
  mkdir -p "$root/config/omarchy/defaults" "$root/migrations" "$root/bin"
  cp "$ROOT/config/omarchy/defaults/dictation" "$root/config/omarchy/defaults/"
  cp "$ROOT/migrations/1791479273.sh" "$root/migrations/"
  ln -s "$ROOT/bin/omarchy-pkg-present" "$root/bin/omarchy-pkg-present"
  printf 'unrelated default\n' >"$root/config/unrelated.conf"
  cat >"$root/bin/pacman" <<'SH'
#!/bin/bash
[[ ${VOXTYPE_PACKAGE:-0} == 1 && $* == '-Q -- voxtype-bin' ]]
SH
  chmod +x "$root/bin/pacman"
  printf '#!/bin/bash\nexit 0\n' >"$root/bin/omarchy-notification-dismiss"
  chmod +x "$root/bin/omarchy-notification-dismiss"
  is_retired_config_file() { return 1; }
  eval "copy_missing_config_defaults() { $(function_body copy_missing_config_defaults)
}"
  backend="$XDG_CONFIG_HOME/omarchy/defaults/dictation"
  copy_defaults() { copy_missing_config_defaults "$root/config" "$XDG_CONFIG_HOME"; }
  migrate_backend() { OMARCHY_PATH="$root" bash "$ROOT/bin/omarchy-migrate" >/dev/null; }
  reset_queue() { rm -f "${OMARCHY_MIGRATION_STATE:-$HOME/.local/state/omarchy/migrations}/1791479273.sh"; }

  copy_defaults
  [[ ! -e $backend && ! -L $backend ]] || fail "legacy Voxtype selection stays missing until its migration"
  [[ $(cat "$XDG_CONFIG_HOME/unrelated.conf") == "unrelated default" ]] ||
    fail "deferring dictation still populates unrelated missing defaults"
  migrate_backend
  [[ $(cat "$backend") == voxtype ]] || fail "copy then migration preserves legacy Voxtype"
  copy_defaults
  migrate_backend
  [[ $(cat "$backend") == voxtype ]] || fail "retry preserves the migrated Voxtype selection"
  pass "legacy default copy lets the ordered migration preserve Voxtype"

  rm "$backend"
  reset_queue
  copy_defaults
  printf 'exit 1\n' >"$root/migrations/0000000001.sh"
  if migrate_backend; then
    fail "a failed queue does not finish the deferred dictation upgrade"
  fi
  [[ ! -e $backend ]] || fail "a failed queue does not certify a new dictation selection"
  rm "$root/migrations/0000000001.sh"
  copy_defaults
  migrate_backend
  [[ $(cat "$backend") == voxtype ]] || fail "retry after queue failure still preserves Voxtype"
  pass "failed migration queues leave the legacy dictation choice recoverable"

  rm "$backend"
  reset_queue
  VOXTYPE_PACKAGE=0 copy_defaults
  VOXTYPE_PACKAGE=0 migrate_backend
  [[ $(cat "$backend") == superwhisper ]] || fail "users without Voxtype retain the packaged default"
  pass "non-Voxtype upgrades retain the packaged dictation default"

  for selection in superwhisper custom-backend voxtype; do
    printf '%s\n' "$selection" >"$backend"
    reset_queue
    copy_defaults
    migrate_backend
    [[ $(cat "$backend") == "$selection" ]] || fail "upgrade keeps explicit dictation choice $selection"
  done
  pass "copy and migration preserve every explicit backend choice"

  rm "$backend"
  printf '%s\n' custom-backend >"$dictation_tmp/linked-backend"
  ln -s "$dictation_tmp/linked-backend" "$backend"
  reset_queue
  copy_defaults
  migrate_backend
  [[ -L $backend && $(cat "$backend") == custom-backend ]] || fail "upgrade preserves a linked backend choice"
  rm "$backend" "$dictation_tmp/linked-backend"
  ln -s "$dictation_tmp/linked-backend" "$backend"
  reset_queue
  copy_defaults
  migrate_backend
  [[ -L $backend && ! -e $backend ]] || fail "migration preserves an existing dangling user selection link"
  pass "copy and migration preserve existing backend links"

  rm "$backend"
  copy_defaults
  migrate_backend
  [[ $(cat "$backend") == superwhisper ]] || fail "completed default migration state does not defer a missing selection forever"
  export OMARCHY_MIGRATION_STATE=$dictation_tmp/custom-state
  mkdir -p "$OMARCHY_MIGRATION_STATE"
  touch "$OMARCHY_MIGRATION_STATE/1791479273.sh"
  rm "$backend"
  copy_defaults
  migrate_backend
  [[ $(cat "$backend") == superwhisper ]] || fail "completed custom migration state does not defer a missing selection forever"
  rm "$backend"
  reset_queue
  copy_defaults
  [[ ! -e $backend ]] || fail "a pending custom queue ignores the completed default-state marker"
  migrate_backend
  [[ $(cat "$backend") == voxtype ]] || fail "pending custom migration state preserves legacy Voxtype"
  pass "dictation default seeding follows both default and custom migration state"

  rm "$backend"
  mv "$root/migrations/1791479273.sh" "$dictation_tmp/migration"
  copy_defaults
  [[ $(cat "$backend") == superwhisper ]] || fail "older trees without the backend migration keep default-copy behavior"
  pass "older packaged trees retain their existing default-copy behavior"
)

if function_body cleanup_retired_services | grep -F 'systemctl disable iwd' >/dev/null; then
  fail "Omarchy 4 upgrade does not retire iwd in a step separate from the NetworkManager enable"
fi
grep -A1 -F '  enable_system_service NetworkManager.service' "$upgrade_to_quattro" |
  grep -F 'as_root systemctl disable iwd.service' >/dev/null ||
  fail "Omarchy 4 upgrade retires iwd in the step that enables NetworkManager"
pass "Omarchy 4 upgrade switches from iwd to NetworkManager atomically"

# set -e aborts silently, so only an explicit banner distinguishes a
# half-upgraded system from a finished one.
grep -Fx 'trap cleanup_on_exit EXIT' "$upgrade_to_quattro" >/dev/null ||
  fail "Omarchy 4 upgrade reports an aborted run instead of exiting silently"
cleanup_body=$(function_body cleanup_on_exit)
grep -F 'upgrade_started && ! upgrade_completed' <<<"$cleanup_body" >/dev/null ||
  fail "Omarchy 4 upgrade reports an aborted run instead of exiting silently"
grep -F 'Upgrade incomplete - do NOT reboot.' <<<"$cleanup_body" >/dev/null ||
  fail "Omarchy 4 upgrade reports an aborted run instead of exiting silently"
grep -F 'exit "$exit_status"' <<<"$cleanup_body" >/dev/null ||
  fail "Omarchy 4 upgrade preserves the failing exit status"
grep -F '>&2' <<<"$cleanup_body" >/dev/null ||
  fail "Omarchy 4 upgrade reports an aborted run on stderr"
started_line=$(grep -n '^upgrade_started=1$' "$upgrade_to_quattro" | cut -d: -f1)
completed_line=$(grep -n '^upgrade_completed=1$' "$upgrade_to_quattro" | cut -d: -f1)
suppress_line=$(grep -n '^suppress_hyprland_config_reload$' "$upgrade_to_quattro" | cut -d: -f1)
# The reboot is the cutover, so the last mutating step hands the live session
# back rather than swapping the shell out underneath it.
last_step_line=$(grep -n '^restore_hyprland_config_reload$' "$upgrade_to_quattro" | cut -d: -f1)
[[ -n $started_line && -n $completed_line && -n $suppress_line && -n $last_step_line ]] ||
  fail "upgrade progress markers and the mutating step range exist"
(( started_line < suppress_line )) || fail "the upgrade is marked started before the first mutation"
(( completed_line > last_step_line )) || fail "the upgrade is marked complete only after the last step"
pass "Omarchy 4 upgrade reports an aborted run instead of exiting silently"

# Ordering alone would still pass if either retired entry point came back, so
# name them: the reboot is the cutover, and nothing may swap the shell out from
# under the session being replaced.
! grep -q 'start_omarchy_shell_session' "$upgrade_to_quattro" ||
  fail "Omarchy 4 upgrade does not start the shell in the session it is replacing"
! grep -q 'stop_retired_session_processes' "$upgrade_to_quattro" ||
  fail "Omarchy 4 upgrade leaves the retired session processes running until reboot"
pass "Omarchy 4 upgrade leaves the Omarchy 3 session alone until the reboot"

grep -F 'omarchy-bar defaults' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade restores service-aware bar defaults"

grep -F 'install_hardware_transition_packages' "$upgrade_to_quattro" >/dev/null
grep -F 'sof-firmware' "$upgrade_to_quattro" >/dev/null
grep -F 'vulkan-intel' "$upgrade_to_quattro" >/dev/null
grep -F 'apply_user_hardware_transition' "$upgrade_to_quattro" >/dev/null
grep -F 'DX13260' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade backfills hardware support from the legacy release"

grep -F 'omarchy-refresh-applications' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade refreshes application launchers"

grep -F '/etc/systemd/system.conf.d/99-omarchy-nofile.conf' "$upgrade_to_quattro" >/dev/null
grep -F '/etc/systemd/user.conf.d/99-omarchy-nofile.conf' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade removes stale nofile drop-ins"

cmdline_line=$(grep -n '^preserve_kernel_cmdline_root$' "$upgrade_to_quattro" | cut -d: -f1)
packages_line=$(grep -n '^install_omarchy_quattro_packages$' "$upgrade_to_quattro" | cut -d: -f1)
verify_line=$(grep -n '^verify_kernel_cmdline_root$' "$upgrade_to_quattro" | cut -d: -f1)
[[ -n $cmdline_line && -n $packages_line && -n $verify_line ]] ||
  fail "kernel cmdline preservation, verification and package install calls exist"
# The package transaction installs the += drop-in that drops root=, so the pin
# has to be on disk before it runs or the UKI it bakes is unbootable.
(( cmdline_line < packages_line )) || fail "kernel cmdline is pinned before the packages that can drop root="
# The UKIs are rebuilt by the transaction, so they can only be checked after it.
(( verify_line > packages_line )) || fail "kernel cmdline is verified after the packages are installed"
grep -F '/etc/default/limine' "$upgrade_to_quattro" >/dev/null
grep -F 'KERNEL_CMDLINE[default]+=" ${boot_params[*]}"' "$upgrade_to_quattro" >/dev/null
grep -F 'cat /proc/cmdline' "$upgrade_to_quattro" >/dev/null
grep -F 'findmnt -no UUID /' "$upgrade_to_quattro" >/dev/null
grep -F 'rootflags=subvol=' "$upgrade_to_quattro" >/dev/null
grep -F 'cryptdevice' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade preserves the kernel cmdline root parameters"

# The tool's effective cmdline still resolves root= from /proc/cmdline until the
# first += drop-in lands, so it reads healthy on exactly the machines about to
# break. Ask the config layers whether root= is stated instead, for the default
# key alone so a fallback or kernel-specific pin cannot cover for it.
grep -F 'kernel_cmdline_root_pinned' "$upgrade_to_quattro" >/dev/null
grep -F 'KERNEL_CMDLINE\[default\]' "$upgrade_to_quattro" >/dev/null
! grep -F 'limine-entry-tool --get-cmdline' "$upgrade_to_quattro" >/dev/null ||
  fail "the pin check does not depend on the fallback it is about to lose"
pass "Omarchy 4 upgrade checks whether root= is pinned in the limine config"

# Run the pin check against fixture config layers. A false positive skips the
# pin and the next boot has no root=; a false negative appends a second pin.
eval "$(sed -n '/^kernel_cmdline_root_pinned() {$/,/^}$/p' "$upgrade_to_quattro")"
pin_root=$(mktemp -d)
trap 'rm -rf "$pin_root"' EXIT
as_root() {
  local script=${3//\/etc\//$pin_root/etc/}
  bash -c "${script//\/usr\/share\//$pin_root/usr/share/}"
}
# Takes pairs of a config layer and a line to append to it.
root_pinned() {
  rm -rf "${pin_root:?}"/{etc,usr}
  mkdir -p "$pin_root/etc/default" "$pin_root/etc/limine-entry-tool.d" "$pin_root/usr/share/limine-entry-tool.d"
  while (($#)); do
    printf '%s\n' "$2" >>"$pin_root/$1"
    shift 2
  done
  kernel_cmdline_root_pinned
}
root_pinned etc/default/limine 'KERNEL_CMDLINE[default]+=" root=UUID=abc rw"' || fail "a quoted root= pin is recognised"
root_pinned etc/default/limine 'KERNEL_CMDLINE[default]=root=UUID=abc' || fail "an unquoted root= pin is recognised"
root_pinned etc/default/limine 'KERNEL_CMDLINE[default]+=" dm-mod.create="foo" root=UUID=abc rw"' ||
  fail "a pin with a quoted parameter before root= is recognised"
root_pinned usr/share/limine-entry-tool.d/root.conf 'KERNEL_CMDLINE[default]+="root=UUID=abc"' \
  etc/default/limine 'KERNEL_CMDLINE[default]+=" rw"' || fail "an appending layer keeps an earlier pin"
root_pinned etc/default/limine 'KERNEL_CMDLINE[default] += " root=UUID=abc rw"' || fail "a pin spaced around += is recognised"
! root_pinned etc/default/limine "KERNEL_CMDLINE[default]+='root=UUID=abc rw'" ||
  fail "single quotes are kept, as limine-entry-tool keeps them"
! root_pinned etc/default/limine 'OLD_KERNEL_CMDLINE[default]+=" root=UUID=abc rw"' || fail "a renamed key is not a pin"
! root_pinned etc/default/limine '# KERNEL_CMDLINE[default]+=" root=UUID=abc rw"' || fail "a commented-out pin is not a pin"
! root_pinned etc/default/limine 'KERNEL_CMDLINE[fallback]+=" root=UUID=abc rw"' || fail "a fallback-only pin does not cover default"
! root_pinned etc/default/limine 'KERNEL_CMDLINE[default]+=" rootflags=subvol=@ rw"' || fail "rootflags= is not root="
! root_pinned etc/default/limine 'KERNEL_CMDLINE[default]+=" systemd.setenv="root=UUID=abc" rw"' ||
  fail "root= inside another parameter's value is not a pin"
! root_pinned etc/default/limine 'KERNEL_CMDLINE[default]+=" systemd.setenv="NOTE=x root=UUID=abc" rw"' ||
  fail "root= after a space inside a quoted value is not a pin"
! root_pinned etc/default/limine 'KERNEL_CMDLINE[default]=systemd.setenv="NOTE=x root=UUID=abc rw' ||
  fail "root= after an unmatched quote is not a pin"
! root_pinned etc/default/limine 'KERNEL_CMDLINE[default]=ro"x"ot=UUID=abc rw' ||
  fail "a quoted segment inside a parameter name does not make it root="
! root_pinned etc/limine-entry-tool.conf 'KERNEL_CMDLINE[default]=root=UUID=abc rw' \
  etc/default/limine 'KERNEL_CMDLINE[default]=quiet' || fail "a pin replaced by a later layer is not a pin"
! root_pinned etc/default/limine 'KERNEL_CMDLINE[default]+=" root=UUID=abc rw"' \
  etc/default/limine 'KERNEL_CMDLINE[default]="quiet"' || fail "a pin replaced later in the same layer is not a pin"
unset -f as_root
pass "Omarchy 4 upgrade recognises exactly the root= pins that hold"

# Installing the limine packages can deploy limine on a machine that had no
# limine.conf when the pin ran, so verification pins whatever the first call skipped.
(
  eval "$(sed -n '/^kernel_cmdline_root_checked=/p;/^preserve_kernel_cmdline_root() {$/,/^}$/p;/^verify_kernel_cmdline_root() {$/,/^}$/p' "$upgrade_to_quattro")"
  limine_conf=0 pin_checks=0
  as_root() {
    if [[ $1 == "test" ]]; then
      ((limine_conf))
    fi
  }
  kernel_cmdline_root_pinned() { ((++pin_checks)); }
  limine-mkinitcpio() { :; }
  preserve_kernel_cmdline_root
  ((pin_checks == 0)) || fail "the pin waits for a limine.conf"
  limine_conf=1
  verify_kernel_cmdline_root
  ((pin_checks == 1)) || fail "kernel cmdline verification pins a machine the transaction put on limine"
  verify_kernel_cmdline_root
  ((pin_checks == 1)) || fail "kernel cmdline verification pins a machine only once"
)
pass "Omarchy 4 upgrade pins root= on machines the transaction moves to limine"

# The crypt layer hides in the parents on LVM-on-LUKS, and a partial cmdline
# for an encrypted root must not be written at all.
grep -F 'findmnt -no SOURCE --nofsroot /' "$upgrade_to_quattro" >/dev/null
grep -F 'lsblk -nso TYPE "$root_source"' "$upgrade_to_quattro" >/dev/null
grep -F 'grep -qx crypt' "$upgrade_to_quattro" >/dev/null
grep -F '((have_mount_mode)) || boot_params+=(rw)' "$upgrade_to_quattro" >/dev/null
pass "Omarchy 4 upgrade repair path refuses a partial dm-crypt cmdline"

# The cmdline that boots is the one embedded in the UKIs, and an unverified
# root= must block the reboot rather than just warn.
grep -F -- '--only-section=.cmdline' "$upgrade_to_quattro" >/dev/null
grep -F "as_root find /boot/EFI/Linux -maxdepth 1 -name 'omarchy_linux*.efi'" "$upgrade_to_quattro" >/dev/null
grep -F 'boot_cmdline_unsafe=1' "$upgrade_to_quattro" >/dev/null
unsafe_line=$(grep -n 'if (( boot_cmdline_unsafe )); then' "$upgrade_to_quattro" | cut -d: -f1)
reboot_line=$(grep -n 'Rebooting because --reboot was passed' "$upgrade_to_quattro" | cut -d: -f1)
[[ -n $unsafe_line && -n $reboot_line ]] || fail "reboot gate and reboot branch exist"
(( unsafe_line < reboot_line )) || fail "an unverified kernel cmdline blocks the reboot"
pass "Omarchy 4 upgrade verifies the UKIs and refuses to reboot unverified"

# Lazydocker is optional on fresh installs, but a pre-quattro install keeps it.
lazydocker_body=$(function_body migrate_lazydocker_package)
[[ -n $lazydocker_body ]] || fail "upgrade has a Lazydocker replacement step"
eval "migrate_lazydocker_package() { $lazydocker_body; }"
lazydocker_calls=""
package_installed_exact() { [[ $1 == "lazydocker-bin" && $legacy_lazydocker == "yes" ]]; }
log() { :; }
warn() { :; }
as_root() {
  lazydocker_calls+="swap:$*"$'\n'
  return "$lazydocker_swap_status"
}
mark_packages_explicit() { lazydocker_calls+="explicit:$*"$'\n'; }

legacy_lazydocker=no
lazydocker_swap_status=0
migrate_lazydocker_package
[[ -z $lazydocker_calls ]] || fail "upgrade does not install Lazydocker for users without the legacy package"
pass "upgrade does not install Lazydocker for users without the legacy package"

legacy_lazydocker=yes
migrate_lazydocker_package
grep -Fxq 'swap:pacman -S --needed --noconfirm --ask 4 lazydocker' <<<"$lazydocker_calls" ||
  fail "upgrade replaces existing lazydocker-bin with lazydocker"
grep -Fxq 'explicit:lazydocker' <<<"$lazydocker_calls" || fail "upgrade retains Lazydocker as an explicit package"
pass "upgrade replaces existing lazydocker-bin with lazydocker and keeps it explicit"

lazydocker_calls=""
lazydocker_swap_status=1
migrate_lazydocker_package
if grep -Fq 'explicit:' <<<"$lazydocker_calls"; then
  fail "failed Lazydocker replacement does not mark an absent package explicit"
fi
for cleanup in remove_conflicting_legacy_packages remove_retired_default_packages; do
  if grep -qw lazydocker-bin <<<"$(function_body "$cleanup")"; then
    fail "upgrade cleanup must not remove existing Lazydocker when replacement fails"
  fi
done
pass "upgrade cleanup preserves existing Lazydocker when replacement fails"

grep -Fxq migrate_lazydocker_package "$upgrade_to_quattro" || fail "upgrade invokes the Lazydocker replacement step"
pass "upgrade invokes the Lazydocker replacement step"
