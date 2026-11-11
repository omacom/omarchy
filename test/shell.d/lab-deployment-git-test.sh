#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
update_helper="${OMARCHY_PATH:-$ROOT}/bin/omarchy-update-dev"
export OMARCHY_PATH="$ROOT"
source "$ROOT/bin/omarchy-lab-checkout"
repository="$test_tmp/source repo"
destination="$test_tmp/guest checkout"
mkdir -p "$repository" "$destination"
git -C "$repository" init -q -b main
printf 'committed\n' >"$repository/marker"
git -C "$repository" add marker
git -C "$repository" -c user.name=Fixture -c user.email=fixture@example.test commit -qm source
source_commit=$(git -C "$repository" rev-parse HEAD)
git -C "$destination" init -q -b guest-original
printf 'recovery\n' >"$destination/recovery"
git -C "$destination" add recovery
git -C "$destination" -c user.name=Fixture -c user.email=fixture@example.test commit -qm recovery
recovery_commit=$(git -C "$destination" rev-parse HEAD)
require_running_lab() { :; }
guest_user() { echo fixture; }
push_lab() { mkdir -p "$2"; rsync -a --delete --exclude .git "$1/" "$2/"; }
lab_ssh() {
  if [[ $1 == /usr/bin/omarchy-dev-link* ]]; then return 0; fi
  bash -c "$1"
}
DEPLOYMENT_FILE="$test_tmp/deployment.json"
printf 'uncommitted\n' >"$repository/marker"
deploy_source "$repository" --destination "$destination" --no-reboot --json >"$test_tmp/result.json"
[[ $(git -C "$destination" rev-parse HEAD) == "$source_commit" ]]
[[ $(git -C "$destination" rev-parse guest-original) == "$recovery_commit" ]]
[[ $(cat "$destination/marker") == "uncommitted" ]]
[[ -n $(git -C "$destination" diff -- marker) ]]
! git -C "$destination" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1
if [[ -f $update_helper ]]; then
  OMARCHY_PATH="$destination" bash "$update_helper" >"$test_tmp/update.log"
  grep -q 'no upstream' "$test_tmp/update.log"
fi
pass "path deployment preserves dirty files, usable Git metadata and previous guest refs; source updates skip safely"
git -C "$repository" switch -qc feature/portable
printf 'branch commit\n' >"$repository/marker"
git -C "$repository" -c user.name=Fixture -c user.email=fixture@example.test commit -qam branch
branch_commit=$(git -C "$repository" rev-parse HEAD)
git -C "$repository" switch -q main
deploy_source --branch feature/portable --repository "$repository" --destination "$destination" --no-reboot --json >"$test_tmp/branch.json"
[[ $(git -C "$destination" rev-parse HEAD) == "$branch_commit" ]]
[[ $(cat "$destination/marker") == "branch commit" ]]
[[ $(git -C "$destination" rev-parse guest-original) == "$recovery_commit" ]]
[[ -z $(git -C "$destination" status --porcelain --untracked-files=no) ]]
! git -C "$destination" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1
pass "branch deployment imports the selected commit without host paths or loss of guest recovery branches"
