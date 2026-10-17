#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" CARGO_HOME="$scratch/home/.cargo" OMARCHY_PATH="$ROOT"
mkdir -p "$HOME" "$scratch/bin"
# The live session's environment is a file, never the host's systemd.
export SYSTEMCTL_LOG="$scratch/systemctl" SESSION_ENV="$scratch/session-env"
: >"$SESSION_ENV"
cat >"$scratch/bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
shift
command=$1; shift
case "$command" in
  show-environment) cat "$SESSION_ENV" ;;
  set-environment) for assignment; do grep -v "^${assignment%%=*}=" "$SESSION_ENV" >"$SESSION_ENV.new" || true; printf '%s\n' "$assignment" >>"$SESSION_ENV.new"; mv "$SESSION_ENV.new" "$SESSION_ENV"; done ;;
  unset-environment) for name; do grep -v "^$name=" "$SESSION_ENV" >"$SESSION_ENV.new" || true; mv "$SESSION_ENV.new" "$SESSION_ENV"; done ;;
esac
STUB
chmod +x "$scratch/bin/systemctl"
export PATH="$scratch/bin:$PATH"
user() { "$ROOT/bin/omarchy-region-user" "$@"; }

user cn
grep -qF 'registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"' "$CARGO_HOME/config.toml" ||
  fail "China points cargo at the regional crates.io index" "$(cat "$CARGO_HOME/config.toml")"
user cn
[[ $(grep -c '^\[source.crates-io\]' "$CARGO_HOME/config.toml") == 1 ]] || fail "applying China twice adds one block"
user global
[[ ! -e $CARGO_HOME/config.toml ]] || fail "World removes a cargo config only the region wrote"
pass "the cargo registry follows the region and World removes it"

for original in '[build]\njobs = 4\n\n[net]\nretry = 5\n' '[build]\njobs = 4' '' '[build]\njobs = 4\n\n'; do
  printf "$original" >"$CARGO_HOME/config.toml"
  cp "$CARGO_HOME/config.toml" "$scratch/before.toml"
  user cn
  grep -q 'mirrors.aliyun.com/crates.io-index' "$CARGO_HOME/config.toml" || fail "China adds its registry to an existing cargo config"
  python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$CARGO_HOME/config.toml" || fail "China leaves valid TOML"
  user cn
  user global
  cmp "$scratch/before.toml" "$CARGO_HOME/config.toml" || fail "World restores the user's cargo config byte for byte" "$(od -c "$CARGO_HOME/config.toml" | head)"
done
rm "$CARGO_HOME/config.toml"
user cn
printf '[net]\nretry = 5\n' >>"$CARGO_HOME/config.toml"
user global
[[ $(<"$CARGO_HOME/config.toml") == $'[net]\nretry = 5' ]] || fail "World keeps what the user added after the region's block" "$(cat "$CARGO_HOME/config.toml")"
rm "$CARGO_HOME/config.toml"
user cn
{ printf '[build]\njobs = 4\n'; cat "$CARGO_HOME/config.toml"; } >"$scratch/prepended" && mv "$scratch/prepended" "$CARGO_HOME/config.toml"
user global
[[ $(<"$CARGO_HOME/config.toml") == $'[build]\njobs = 4' ]] || fail "World keeps what the user added above the region's block" "$(cat "$CARGO_HOME/config.toml")"
rm "$CARGO_HOME/config.toml"
printf '[build]\njobs = 4' >"$CARGO_HOME/config.toml"
user cn
printf '[net]\nretry = 5\n' >>"$CARGO_HOME/config.toml"
user global
[[ $(cat "$CARGO_HOME/config.toml"; echo .) == $'[build]\njobs = 4\n[net]\nretry = 5\n.' ]] || fail "World keeps lines apart around a joined block" "$(cat "$CARGO_HOME/config.toml")"
python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$CARGO_HOME/config.toml" || fail "World leaves valid TOML around a joined block"
rm "$CARGO_HOME/config.toml"
pass "the user's own cargo config survives China and World byte for byte, empty or without a final newline"

for own in '[source.crates-io]\n' '[source.omarchy-region]\nregistry = "x"\n' '[source.crates-io]\nreplace-with = "mine"\n' '  [source."crates-io"]\nreplace-with = "mine"\n' '[source]\ncrates-io = { replace-with = "mine" }\n' 'not = valid = toml\n'; do
  printf "$own" >"$CARGO_HOME/config.toml"
  cp "$CARGO_HOME/config.toml" "$scratch/own.toml"
  user cn 2>/dev/null
  cmp "$scratch/own.toml" "$CARGO_HOME/config.toml" || fail "China leaves alone: $own"
done
rm "$CARGO_HOME/config.toml"
pass "a user's own crates.io setting, however spelled, and an unreadable config are left alone"

# A hand-edited block is never guessed at: the file stays as it is, and the
# switch itself still succeeds.
begin="# BEGIN omarchy region: managed by omarchy-region, removed for World"
for edited in "$begin appended\n[a]\nx = 1\n[b]\n$begin appended\n[c]\n# END omarchy region\n" \
  "$begin appended\n[a]\n" "$begin appended\n[a]\n# END omarchy region" "$begin mine\n[a]\n# END omarchy region\n" "[a]\n# END omarchy region\n"; do
  printf "$edited" >"$CARGO_HOME/config.toml"
  cp "$CARGO_HOME/config.toml" "$scratch/edited.toml"
  for region in global cn; do
    user "$region" 2>/dev/null || fail "an edited block fails the $region switch"
    cmp "$scratch/edited.toml" "$CARGO_HOME/config.toml" || fail "$region leaves an edited block alone: $edited"
  done
done
rm "$CARGO_HOME/config.toml"
pass "a hand-edited region block is left exactly as it is"

printf 'HOME=/home/x\nPIP_INDEX_URL=https://example.invalid/pip\n' >"$SESSION_ENV"
cp "$SESSION_ENV" "$scratch/session-before"
user cn
grep -qx 'GOSUMDB=sum.golang.google.cn' "$SESSION_ENV" || fail "China updates the running session" "$(cat "$SESSION_ENV")"
grep -qx "MAVEN_ARGS=--global-settings $ROOT/default/regions/cn/maven-settings.xml" "$SESSION_ENV" || fail "Maven settings come from OMARCHY_PATH" "$(cat "$SESSION_ENV")"
grep -qx 'PIP_INDEX_URL=https://example.invalid/pip' "$SESSION_ENV" || fail "China keeps a registry the user set in the session" "$(cat "$SESSION_ENV")"
user global
cmp <(sort "$scratch/session-before") <(sort "$SESSION_ENV") || fail "World returns the session to exactly what it was" "$(cat "$SESSION_ENV")"
pass "the running session's registries follow the region and the user's own values stay"

# Shells read the registries from the marker through env-bootstrap.
printf 'OMARCHY_PATH=%q\n' "$ROOT" >"$scratch/omarchy.conf"
sed "s#/etc/omarchy.conf#$scratch/omarchy.conf#g" "$ROOT/default/bash/env-bootstrap" >"$scratch/env-bootstrap"
shell_env() {
  env -i HOME="$HOME" PATH=/usr/bin:/bin OMARCHY_REGION_FILE="$scratch/region" ${1:+"$1"} \
    sh -c '. "$0"; env' "$scratch/env-bootstrap"
}
rm -f "$scratch/region"
shell_env >/dev/null || fail "env-bootstrap runs for World"
! shell_env | grep -qE '^(NPM_CONFIG_REGISTRY|GOPROXY|GOSUMDB|MAVEN_ARGS)=' || fail "World exports no registries"
printf 'cn\n' >"$scratch/region"
env_cn=$(shell_env) || fail "env-bootstrap runs for China"
grep -qx 'GOSUMDB=sum.golang.google.cn' <<<"$env_cn" || fail "China exports a reachable Go checksum database" "$env_cn"
grep -qx 'NPM_CONFIG_REGISTRY=https://registry.npmmirror.com' <<<"$env_cn" || fail "China exports the npm mirror"
grep -qx 'NPM_CONFIG_REGISTRY=https://example.invalid/npm' <<<"$(shell_env NPM_CONFIG_REGISTRY=https://example.invalid/npm)" ||
  fail "a registry the user set first is kept"
printf '../x\n' >"$scratch/region"
! shell_env | grep -q '^GOPROXY=' || fail "a malformed marker exports nothing"
pass "shells export the region's registries only for China, and keep the user's own"

# Root never sources a region's environment: on a dev link it lives in a
# user-writable checkout.
mkdir -p "$scratch/rootbin"
printf '#!/bin/sh\necho 0\n' >"$scratch/rootbin/id"
chmod +x "$scratch/rootbin/id"
printf 'cn\n' >"$scratch/region"
root_env=$(env -i HOME="$HOME" PATH="$scratch/rootbin:/usr/bin:/bin" OMARCHY_REGION_FILE="$scratch/region" sh -c '. "$0"; env' "$scratch/env-bootstrap") ||
  fail "env-bootstrap runs for root"
! grep -q '^GOPROXY=' <<<"$root_env" || fail "root's shells export no regional registries"
pass "root's shells never source a region's environment"
