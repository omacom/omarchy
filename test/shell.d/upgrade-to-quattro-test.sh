#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

upgrade_to_quattro="$ROOT/bin/omarchy-upgrade-to-quattro"

function_body() {
  awk -v name="$1" '$0 == name "() {" { inside = 1; next } inside && $0 == "}" { exit } inside' "$upgrade_to_quattro"
}

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

if grep -E 'install -d -m 0?[27]?777 /etc/.*/policies|chmod a\+rw|2775' "$upgrade_to_quattro" >/dev/null; then
  fail "Omarchy 4 upgrade does not create a world-writable Chromium policy directory"
fi
pass "Omarchy 4 upgrade locks the Chromium policy directory to root"

migrations_body=$(function_body run_post_upgrade_migrations)

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

# --- The order of the steps that mutate the machine ---

# Runs the upgrade's step block as written, with every step logging its name,
# so what is checked is the order the script really runs them in.
upgrade_steps=$(sed -n '/^upgrade_started=1$/,$p' "$upgrade_to_quattro")
grep -qx 'install_omarchy_quattro_packages' <<<"$upgrade_steps" || fail "the upgrade's step block is where this test looks for it"
run_upgrade_steps() {
  bash -c '
    for step in $(grep -xE "[a-z_0-9]+" <<<"$1"); do
      eval "$step() { echo $step; }"
    done
    run_as_user_omarchy() { :; }
    warn() { :; }
    log() { :; }
    as_root() { echo "as_root $*"; }
    gum() { return 1; }
    boot_cmdline_unsafe=$2 auto_reboot=$3
    eval "$1"
  ' bash "$upgrade_steps" "$@" </dev/null 2>/dev/null
}

steps=$(run_upgrade_steps 0 0)
runs_before() {
  local first second
  first=$(grep -nx "$1" <<<"$steps" | cut -d: -f1)
  second=$(grep -nx "$2" <<<"$steps" | cut -d: -f1)
  [[ -n $first && -n $second ]] && (( first < second ))
}
# The snapshot is the way back, so it comes before the first package change.
runs_before create_pre_upgrade_snapshot configure_pacman_channel ||
  fail "the upgrade snapshots before it changes the package channel" "$steps"
# The new kernel's boot entries are written during the package install, from a
# cmdline that must already name root=; checked again once Limine is rewritten.
runs_before preserve_kernel_cmdline_root install_omarchy_quattro_packages ||
  fail "the upgrade pins root= before installing the new kernel" "$steps"
runs_before install_omarchy_quattro_packages verify_kernel_cmdline_root &&
  runs_before normalize_limine_config verify_kernel_cmdline_root ||
  fail "the upgrade checks root= in the boot entries after writing them" "$steps"
pass "the upgrade snapshots first and pins root= around the kernel install"

[[ $(run_upgrade_steps 0 1) == *"as_root systemctl reboot"* ]] ||
  fail "the upgrade reboots when --reboot is passed"
[[ $(run_upgrade_steps 1 1) != *"as_root systemctl reboot"* ]] ||
  fail "the upgrade never reboots into boot entries missing root="
pass "the upgrade reboots on --reboot only when root= is confirmed in the boot entries"

# The base list carries rtkit, which can make a running app with a zero
# realtime budget realtime and get it killed. The repair that raises those
# budgets and installs rtkit runs once the new omarchy package is in and before
# any other package install, and a failed repair stops the upgrade.
packages_body=$(function_body install_omarchy_quattro_packages)
package_calls=$(mktemp)
exercise_package_install() {
  local repair_status=$1

  : >"$package_calls"
  (
    log() { :; }
    warn() { :; }
    fail() { echo fail >>"$package_calls"; exit 1; }
    mark_packages_explicit() { :; }
    as_root() {
      echo "$*" >>"$package_calls"
      [[ $* != *omarchy-realtime-repair* ]] || return "$repair_status"
    }
    use_dev_packages=0
    root_path=/usr/bin
    eval "install_omarchy_quattro_packages() { $packages_body
}"
    install_omarchy_quattro_packages
  )
}

exercise_package_install 0 || fail "Omarchy 4 upgrade installs its packages when the realtime repair succeeds"
awk '/pacman -Syu/ { syu = NR } /omarchy-realtime-repair/ { repair = NR } /(^| )pacman -S / && !first { first = NR }
  END { exit !(syu && repair && syu < repair && repair < first) }' "$package_calls" ||
  fail "Omarchy 4 upgrade repairs realtime budgets after installing omarchy and before the base list" "$(cat "$package_calls")"
pass "Omarchy 4 upgrade repairs realtime budgets after installing omarchy and before the base list"

if exercise_package_install 1; then
  fail "Omarchy 4 upgrade stops when the realtime repair fails"
fi
grep -qx fail "$package_calls" && ! grep -qE '(^| )pacman -S ' "$package_calls" ||
  fail "Omarchy 4 upgrade installs nothing more once the realtime repair fails" "$(cat "$package_calls")"
pass "Omarchy 4 upgrade stops before the base list when the realtime repair fails"
rm -f "$package_calls"
