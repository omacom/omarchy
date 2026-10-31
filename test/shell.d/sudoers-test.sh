#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sudoers_dir="$ROOT/etc/sudoers.d"
registry="$ROOT/default/i18n/locales.json"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# --- Each shipped drop-in holds exactly its expected rule ---

# Matched whole, so a second line, or a command whose arguments were dropped
# (which sudoers reads as "any arguments"), widens a grant and fails here. A new
# drop-in needs a row: the grant it carries is reviewed here or nowhere.
declare -A expected=(
  [omarchy-dns]='%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-dns Cloudflare, /usr/bin/omarchy-dns Google, /usr/bin/omarchy-dns DHCP'
  [omarchy-locale-generate]="%wheel ALL=(root) NOPASSWD: $(jq -r 'keys | sort | map("/usr/bin/omarchy-locale-generate " + .) | join(", ")' "$registry")"
  [omarchy-passwd-tries]='Defaults passwd_tries=10'
  [omarchy-theme-browser]='%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-theme-set-browser-policy [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]'
  [omarchy-tzupdate]='%wheel ALL=(root) NOPASSWD: /usr/bin/timedatectl ^set-timezone [A-Za-z0-9_+][A-Za-z0-9_+.-]*(/[A-Za-z0-9_+][A-Za-z0-9_+.-]*)*$'
)

rules_in() {
  grep -vE '^[[:space:]]*(#|$)' "$1"
}

have_visudo=0
command -v visudo >/dev/null && have_visudo=1

for dropin in "$sudoers_dir"/*; do
  name=${dropin##*/}
  [[ -v expected[$name] ]] || fail "etc/sudoers.d/$name has an expected rule in this test"
  rules=$(rules_in "$dropin")
  [[ $rules == "${expected[$name]}" ]] ||
    fail "etc/sudoers.d/$name carries exactly its expected rule and nothing else" "got: $rules"
  if (( have_visudo )); then
    visudo -cf "$dropin" >/dev/null || fail "etc/sudoers.d/$name parses"
  fi
done
for name in "${!expected[@]}"; do
  [[ -f $sudoers_dir/$name ]] || fail "etc/sudoers.d/$name still ships"
done
pass "each sudoers drop-in carries exactly its expected rule"
if (( have_visudo )); then
  pass "each sudoers drop-in parses"
else
  skip "visudo is not installed; skipping the sudoers parse check"
fi

# --- Arguments the timezone rule admits and refuses ---

# The other rules are literal lists and a glob, pinned whole above. The
# timezone rule is a regex, so what it admits is checked here.

# Mirrors how sudoers matches one NOPASSWD command list against an invocation:
# the command path must be equal; an entry without arguments admits any; an
# argument spec wrapped in ^...$ is an extended regex and anything else an
# fnmatch glob, either one matched against the arguments joined by spaces.
sudoers_permits() {
  local dropin=$1 command=$2 args="${*:3}" spec entry pattern
  local -a entries
  spec=$(grep -vE '^[[:space:]]*(#|$)' "$dropin" | sed -n 's/^%wheel ALL=(root) NOPASSWD: //p')
  [[ -n $spec ]] || return 1
  readarray -t entries <<<"${spec//, /$'\n'}"
  for entry in "${entries[@]}"; do
    if [[ $entry == "$command" ]]; then
      return 0
    elif [[ $entry == "$command "* ]]; then
      pattern=${entry#"$command "}
      if [[ $pattern == "^"*'$' ]]; then
        [[ $args =~ $pattern ]] && return 0
      else
        # shellcheck disable=SC2053 # the rule's argument is a glob
        [[ $args == $pattern ]] && return 0
      fi
    fi
  done
  return 1
}

while IFS='|' read -r name verdict command args; do
  if sudoers_permits "$sudoers_dir/$name" "$command" "$args"; then
    [[ $verdict == "permit" ]] || fail "etc/sudoers.d/$name refuses '$command $args'"
  else
    [[ $verdict == "refuse" ]] || fail "etc/sudoers.d/$name permits '$command $args'"
  fi
done <<'ROWS'
omarchy-tzupdate|permit|/usr/bin/timedatectl|set-timezone UTC
omarchy-tzupdate|permit|/usr/bin/timedatectl|set-timezone America/Argentina/Buenos_Aires
omarchy-tzupdate|permit|/usr/bin/timedatectl|set-timezone Etc/GMT+5
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-timezone
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-timezone UTC -H host
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-timezone -M machine UTC
omarchy-tzupdate|refuse|/usr/bin/timedatectl|-H host set-timezone UTC
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-timezone ../../etc/shadow
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-timezone /etc/localtime
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-timezone America//New_York
omarchy-tzupdate|refuse|/usr/bin/timedatectl|set-ntp false
omarchy-tzupdate|refuse|/usr/bin/tzupdate|
ROWS
pass "the timezone rule admits zone names and refuses everything else"

# --- Root halves resolve helpers from a trusted PATH ---

# Under sudo, a dev link (etc/sudoers.d/omarchy-dev-path) prepends a
# user-writable checkout bin/ to secure_path, so each helper must pin PATH to
# system directories once it holds root. Each runs as root inside a user and
# mount namespace, with /etc bound to a scratch copy so nothing it writes or
# reads is the host's, and a PATH whose front is poisoned with every tool they
# call by bare name. The probes need no host privileges, but a sandbox or
# hardened kernel can refuse the namespaces; then they skip.
if unshare --user --map-root-user --mount true 2>/dev/null; then
  poison_dir="$test_tmp/poison"
  poison_ran="$test_tmp/poison-ran"
  mkdir -p "$poison_dir"
  for helper in awk dirname grep install jq locale-gen mktemp rm sed tee tr; do
    cat >"$poison_dir/$helper" <<SH
#!/bin/bash
printf '%s\n' "$helper" >>"$poison_ran"
exec "/usr/bin/$helper" "\$@"
SH
    chmod +x "$poison_dir/$helper"
  done

  scratch_etc() {
    local etc="$test_tmp/etc-$1"
    mkdir -p "$etc"
    printf 'root:x:0:0::/root:/bin/bash\n' >"$etc/passwd"
    printf 'root:x:0:\n' >"$etc/group"
    printf '%s\n' "$etc"
  }

  # as_root <etc> <command> [args...]
  as_root() {
    local etc=$1
    shift
    rm -f "$poison_ran"
    PATH="$poison_dir:$PATH" unshare --user --map-root-user --mount \
      /bin/bash -c '/usr/bin/mount --bind "$1" /etc && shift && exec /bin/bash "$@"' _ "$etc" "$@"
  }

  assert_trusted_path() {
    [[ ! -e $poison_ran ]] ||
      fail "root $1 resolves system helpers from a trusted PATH, not the invocation PATH" "ran: $(tr '\n' ' ' <"$poison_ran")"
  }

  # omarchy-dns with no argument only reads the DNS config.
  etc=$(scratch_etc dns)
  as_root "$etc" "$ROOT/bin/omarchy-dns" </dev/null >/dev/null 2>&1 ||
    fail "root omarchy-dns runs its read-only trusted-PATH probe"
  assert_trusted_path omarchy-dns

  # omarchy-locale-generate reads only the packaged registry and the real
  # locale.gen as root: the test overrides below would otherwise enable
  # sv_SE for a code the packaged registry does not know.
  etc=$(scratch_etc locale)
  printf '#sv_SE.UTF-8 UTF-8\n' >"$etc/locale.gen"
  printf '#sv_SE.UTF-8 UTF-8\n' >"$test_tmp/override.gen"
  printf '{"zz": {"locale": "sv_SE.UTF-8"}}\n' >"$test_tmp/override.json"
  if OMARCHY_LOCALE_REGISTRY="$test_tmp/override.json" OMARCHY_LOCALE_GEN="$test_tmp/override.gen" \
    as_root "$etc" "$ROOT/bin/omarchy-locale-generate" zz </dev/null >/dev/null 2>&1; then
    fail "root omarchy-locale-generate ignores a caller's registry override"
  fi
  [[ $(<"$test_tmp/override.gen") == "#sv_SE.UTF-8 UTF-8" && $(<"$etc/locale.gen") == "#sv_SE.UTF-8 UTF-8" ]] ||
    fail "root omarchy-locale-generate ignores the caller's locale.gen and registry overrides"
  assert_trusted_path omarchy-locale-generate

  # A code the packaged registry knows gets as far as locale.gen, which has to
  # be /etc's, not the caller's. locale-gen itself then fails to write the
  # host's locale archive, which it could do if the test ran as real root.
  if (( EUID == 0 )); then
    skip "running as root; skipping the root locale.gen override probe, whose locale-gen would rewrite this machine's locales"
  elif [[ $(jq -r '.sv.locale // empty' /usr/share/omarchy/default/i18n/locales.json 2>/dev/null) == "sv_SE.UTF-8" ]]; then
    OMARCHY_LOCALE_GEN="$test_tmp/override.gen" \
      as_root "$etc" "$ROOT/bin/omarchy-locale-generate" sv </dev/null >/dev/null 2>&1 || true
    [[ $(<"$test_tmp/override.gen") == "#sv_SE.UTF-8 UTF-8" && $(<"$etc/locale.gen") == "sv_SE.UTF-8 UTF-8" ]] ||
      fail "root omarchy-locale-generate enables the locale in /etc/locale.gen, not the caller's" "$(<"$etc/locale.gen")"
  else
    skip "Omarchy's packaged locale registry is not installed; skipping the root locale.gen override probe"
  fi

  # omarchy-theme-set-browser-policy writes its fixed policy directories: a
  # planted color.json directory or symlink is replaced, a planted managed
  # directory symlink and a browser that is not installed are left alone.
  etc=$(scratch_etc browser)
  mkdir -p "$etc/chromium/policies/managed/color.json/nested" "$etc/brave/policies/managed" \
    "$etc/opt/edge/policies" "$test_tmp/attacker"
  printf 'original\n' >"$test_tmp/pwn"
  ln -s "$test_tmp/pwn" "$etc/brave/policies/managed/color.json"
  ln -s "$test_tmp/attacker" "$etc/opt/edge/policies/managed"
  as_root "$etc" "$ROOT/bin/omarchy-theme-set-browser-policy" 1c2027 </dev/null >/dev/null 2>&1 ||
    fail "root omarchy-theme-set-browser-policy writes the policy directories"
  assert_trusted_path omarchy-theme-set-browser-policy
  for browser in chromium brave; do
    policy="$etc/$browser/policies/managed/color.json"
    [[ -f $policy && ! -L $policy ]] ||
      fail "root omarchy-theme-set-browser-policy replaces a planted $browser color.json with a file"
    [[ $(jq -r .BrowserThemeColor "$policy") == "#1c2027" ]] ||
      fail "root omarchy-theme-set-browser-policy writes the color into $browser's policy"
  done
  [[ $(<"$test_tmp/pwn") == "original" ]] ||
    fail "root omarchy-theme-set-browser-policy does not write through a planted color.json symlink"
  [[ -z $(ls -A "$test_tmp/attacker") ]] ||
    fail "root omarchy-theme-set-browser-policy skips a managed directory that is a symlink"
  [[ ! -e $etc/opt/chrome ]] ||
    fail "root omarchy-theme-set-browser-policy does not create a policy root for a browser that is not installed"

  pass "root helpers resolve system tools from a trusted PATH and honor no caller overrides"
else
  skip "no unprivileged user and mount namespace; skipping the root trusted-PATH probes"
fi

# --- Self-elevating helpers take the grant only where it reaches ---

# require_root returns immediately for root, so the stubs below would not stand
# between these helpers and the host's real DNS and browser policy.
if (( EUID == 0 )); then
  skip "running as root; skipping the elevation checks, which would rewrite this machine's DNS and browser policy"
  exit 0
fi

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# pkexec stands in for the exec at the end of require_root, so the privileged
# half never runs.
cat >"$stub_bin/pkexec" <<'SH'
#!/bin/bash
printf 'pkexec %s\n' "$*" >"$ELEVATION_LOG"
SH
chmod +x "$stub_bin/pkexec"

# sudo answers listings the way it would with STUB_DROPIN installed beside
# Omarchy's blanket %wheel rule: every command is permitted, and only the long
# listing (-l -l) prints the tags that show the drop-in's passwordless grant.
# STUB_DROPIN empty stands for an install whose omarchy-settings predates it,
# or a user outside %wheel. Anything else is the elevation itself, logged.
{
  echo '#!/bin/bash'
  declare -f sudoers_permits
  cat <<'SH'
if [[ $1 == -n && $2 == -l ]]; then
  shift 2
  options=""
  if [[ $1 == -l ]]; then
    shift
    if [[ -n $STUB_DROPIN ]] && sudoers_permits "$STUB_DROPIN" "$@"; then
      options=$'    Options: !authenticate\n'
    fi
  fi
  # The caller's grep -q stops reading at its first match, so a write that
  # lands after it would kill this stub with SIGPIPE and fail the caller's
  # pipefail pipeline. Under load that happened even to one printf.
  trap '' PIPE
  printf '%s    %s\n' "$options" "$*" 2>/dev/null || true
  exit 0
fi
printf 'sudo %s\n' "$*" >"$ELEVATION_LOG"
SH
} >"$stub_bin/sudo"
chmod +x "$stub_bin/sudo"

# elevation_for <drop-in> <command> [args...]
elevation_for() {
  local dropin=$1
  shift
  : >"$test_tmp/elevation"
  STUB_DROPIN="${dropin:+$sudoers_dir/$dropin}" ELEVATION_LOG="$test_tmp/elevation" PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/$1" "${@:2}" </dev/null >/dev/null 2>&1 || true
  cat "$test_tmp/elevation"
}

while IFS='|' read -r dropin command arg want; do
  got=$(elevation_for "$dropin" "$command" "$arg")
  [[ $got == "$want" ]] || fail "$command $arg elevates as '$want' without a terminal" "got: $got"

  if [[ $want == sudo* ]]; then
    # A dev-linked checkout elevates the packaged path like everyone else,
    # rather than handing sudo a path no rule can name.
    got=$(OMARCHY_PATH="$test_tmp/checkout" elevation_for "$dropin" "$command" "$arg")
    [[ $got == "$want" ]] || fail "$command $arg elevates the system install wherever OMARCHY_PATH points" "got: $got"

    # Without the grant there is no terminal for sudo's prompt, so polkit asks.
    got=$(elevation_for "" "$command" "$arg")
    [[ $got == "pkexec ${want#sudo }" ]] ||
      fail "$command $arg falls back to polkit where the sudoers grant is not installed" "got: $got"
  fi
done <<'ROWS'
omarchy-dns|omarchy-dns|Cloudflare|sudo /usr/bin/omarchy-dns Cloudflare
omarchy-dns|omarchy-dns|Google|sudo /usr/bin/omarchy-dns Google
omarchy-dns|omarchy-dns|DHCP|sudo /usr/bin/omarchy-dns DHCP
omarchy-dns|omarchy-dns|cloudflare|sudo /usr/bin/omarchy-dns Cloudflare
omarchy-dns|omarchy-dns|Custom|pkexec /usr/bin/omarchy-dns Custom
omarchy-theme-browser|omarchy-theme-set-browser-policy|1c2027|sudo /usr/bin/omarchy-theme-set-browser-policy 1c2027
ROWS
pass "helpers take the passwordless sudo grant where it reaches and polkit elsewhere"

# expect_rejected <drop-in> <command> [args...]
expect_rejected() {
  if STUB_DROPIN="$sudoers_dir/$1" ELEVATION_LOG="$test_tmp/elevation" PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/$2" "${@:3}" </dev/null >/dev/null 2>&1; then
    fail "$2 rejects '${*:3}'"
  fi
  got=$(elevation_for "$@")
  [[ -z $got ]] || fail "$2 rejects '${*:3}' before elevating" "got: $got"
}

for bad in "" 1C2027 abc12 abc1234 1c202g ../../etc/passwd "1c2027 1c2027" '$(id)' "1c2027;id" "#1c2027"; do
  expect_rejected omarchy-theme-browser omarchy-theme-set-browser-policy "$bad"
done
expect_rejected omarchy-theme-browser omarchy-theme-set-browser-policy 1c2027 ffffff
for bad in Quad9 "Cloudflare;id" "Cloudflare Google"; do
  expect_rejected omarchy-dns omarchy-dns "$bad"
done
expect_rejected omarchy-dns omarchy-dns Cloudflare Google
pass "helpers reject malformed arguments before elevating"
