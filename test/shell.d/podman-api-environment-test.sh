#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
cat >"$test_dir/pacman" <<'STUB'
#!/bin/bash
[[ $* == '-Qq docker' ]] || exit 2
printf '%s\n' "$TEST_PROVIDER"
STUB
chmod +x "$test_dir/pacman"
generator="$ROOT/default/systemd/user-environment-generators/60-omarchy-podman"
run_generator() {
  env -u DOCKER_HOST -u DOCKER_CONTEXT PATH="$test_dir:$PATH" XDG_RUNTIME_DIR="$test_dir/runtime" "$@" "$generator"
}
expected="DOCKER_HOST=unix://$test_dir/runtime/podman/podman.sock"
if (( EUID == 0 )); then
  expected='DOCKER_HOST=unix:///run/podman/podman.sock'
fi
[[ $(run_generator TEST_PROVIDER=podman-docker) == "$expected" ]] || fail "Docker API endpoint is wrong"
[[ -z $(run_generator TEST_PROVIDER=docker) ]] || fail "pending Docker migration redirects SDK clients"
[[ -z $(run_generator TEST_PROVIDER=missing) ]] || fail "default appears without Docker compatibility package"
[[ -z $(run_generator TEST_PROVIDER=podman-docker DOCKER_HOST=ssh://custom.example) ]] || fail "explicit Docker endpoint was overridden"
[[ -z $(run_generator TEST_PROVIDER=podman-docker DOCKER_CONTEXT=remote) ]] || fail "explicit Docker context was overridden"
pass "Docker API defaults activate only after engine replacement and preserve explicit endpoints and contexts"
