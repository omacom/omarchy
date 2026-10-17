#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home with spaces"
stub_bin="$test_tmp/bin"
mkdir -p "$test_home/.terraform.d/plugin-cache/registry.terraform.io/hashicorp/aws/6.0.0/linux_amd64" "$stub_bin"

printf 'shared provider binary\n' >"$test_home/.terraform.d/plugin-cache/registry.terraform.io/hashicorp/aws/6.0.0/linux_amd64/terraform-provider-aws"
printf 'plugin_cache_dir = "%s"\ndisable_checkpoint = true\n' "$test_home/.terraform.d/plugin-cache" >"$test_home/.terraformrc"
printf 'complete -C /custom/bin/terraform terraform\n' >"$test_home/.bashrc"
printf 'autoload -U +X bashcompinit && bashcompinit\ncomplete -o nospace -C /custom/bin/terraform terraform\n' >"$test_home/.zshrc"
cp -a "$test_home" "$test_tmp/expected"

cat >"$stub_bin/mise" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_MISE_LOG"
STUB
chmod +x "$stub_bin/mise"

run_dev_env() {
  local command=$1 home=$2
  env -i HOME="$home" PATH="$stub_bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" \
    TEST_MISE_LOG="$test_tmp/mise.log" \
    /bin/bash "$ROOT/bin/omarchy-$command-dev-env" terraform >"$test_tmp/output"
}

# Install

install_home="$test_tmp/install home"
mkdir -p "$install_home"
printf '# existing bashrc\n' >"$install_home/.bashrc"
printf 'disable_checkpoint = true' >"$install_home/.terraformrc"
: >"$test_tmp/mise.log"
run_dev_env install "$install_home"

printf 'disable_checkpoint = true\nplugin_cache_dir = "%s"\n' "$install_home/.terraform.d/plugin-cache" >"$test_tmp/expected-terraformrc"
cmp -s "$test_tmp/expected-terraformrc" "$install_home/.terraformrc" ||
  fail "Terraform install adds the provider cache on its own line after an unterminated config"
[[ -d "$install_home/.terraform.d/plugin-cache" ]] ||
  fail "Terraform install creates the provider cache directory"
pass "Terraform install adds the provider cache on its own line after an unterminated config"

[[ $(<"$install_home/.bashrc") == "# existing bashrc" && ! -e "$install_home/.zshrc" ]] ||
  fail "Terraform install leaves shell rc files alone"
pass "Terraform install leaves shell rc files alone"

[[ $(<"$test_tmp/mise.log") == "use --global terraform@latest" ]] ||
  fail "Terraform install selects the latest version through mise"
pass "Terraform install selects the latest version through mise"

cp "$install_home/.terraformrc" "$test_tmp/first-terraformrc"
run_dev_env install "$install_home"
cmp -s "$test_tmp/first-terraformrc" "$install_home/.terraformrc" ||
  fail "a second Terraform install leaves the config unchanged"
pass "a second Terraform install leaves the config unchanged"

printf '# plugin_cache_dir = "/old/cache"\n' >"$install_home/.terraformrc"
run_dev_env install "$install_home"
grep -qx "plugin_cache_dir = \"$install_home/.terraform.d/plugin-cache\"" "$install_home/.terraformrc" ||
  fail "a commented-out cache setting does not stop Terraform install enabling the cache"
pass "a commented-out cache setting does not stop Terraform install enabling the cache"

custom_rc="  plugin_cache_dir = \"/custom/cache\""
printf '%s\n' "$custom_rc" >"$install_home/.terraformrc"
run_dev_env install "$install_home"
[[ $(<"$install_home/.terraformrc") == "$custom_rc" ]] ||
  fail "Terraform install keeps an existing cache setting"
pass "Terraform install keeps an existing cache setting"

# Remove

: >"$test_tmp/mise.log"
run_dev_env remove "$test_home"

diff -r "$test_tmp/expected" "$test_home" ||
  fail "Terraform removal preserves shared provider cache, config, and shell completions"
pass "Terraform removal preserves shared provider cache, config, and shell completions"

printf 'uninstall terraform --all\nrm -g terraform\n' >"$test_tmp/expected-mise.log"
cmp -s "$test_tmp/expected-mise.log" "$test_tmp/mise.log" ||
  fail "Terraform removal uninstalls mise versions and clears the global selection"
pass "Terraform removal uninstalls mise versions and clears the global selection"
