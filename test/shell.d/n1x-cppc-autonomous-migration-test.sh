#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
real_udevadm=$(command -v udevadm || true)
export PATH="$tmp_dir/bin:$PATH"

cat > "$tmp_dir/bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
[[ ${IS_N1X:-1} == 1 ]]
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1791867831.sh"
rules="$tmp_dir/etc/udev/rules.d/71-omarchy-n1x-cppc.rules"

run_migration() {
  OMARCHY_N1X_CPPC_RULES="$rules" bash -euo pipefail "$migration" >/dev/null 2>&1
}

IS_N1X=0 run_migration
[[ ! -e $rules ]] && pass "other machines are left alone" || fail "other machines are left alone"

run_migration
grep -q '^ACTION=="add", SUBSYSTEM=="module", KERNEL=="cppc_cpufreq", RUN+=' "$rules" &&
  pass "the N1x sets up its cores when cppc_cpufreq loads" || fail "the N1x sets up its cores when cppc_cpufreq loads"
grep -q '^ACTION=="online", SUBSYSTEM=="cpu", TEST=="cpufreq/auto_select", ' "$rules" &&
  pass "the N1x sets up a core that comes back online" || fail "the N1x sets up a core that comes back online"
[[ $(stat -c %a "$rules") == "644" ]] && pass "the rule is world-readable, root-writable" || fail "the rule is world-readable, root-writable"

# Run the load rule's program, as udev unescapes it, against two fake policies
# whose floor the firmware raised to their ceiling.
cpufreq="$tmp_dir/cpufreq"
for spec in "policy0 338000 2808000" "policy5 1378000 4004000"; do
  read -r policy floor ceiling <<<"$spec"
  mkdir -p "$cpufreq/$policy"
  echo "$floor" > "$cpufreq/$policy/cpuinfo_min_freq"
  echo "$ceiling" > "$cpufreq/$policy/cpuinfo_max_freq"
  echo "$ceiling" > "$cpufreq/$policy/scaling_min_freq"
  echo "$ceiling" > "$cpufreq/$policy/scaling_max_freq"
  echo 0 > "$cpufreq/$policy/auto_select"
done
program=$(sed -n "s/.*KERNEL==\"cppc_cpufreq\", RUN+=\"\/usr\/bin\/sh -c '\(.*\)'\"\$/\1/p" "$rules")
program=${program//\$\$/\$}
sh -c "${program//\/sys\/devices\/system\/cpu\/cpufreq/$cpufreq}"
if [[ $(cat "$cpufreq/policy0/scaling_min_freq" "$cpufreq/policy0/scaling_max_freq" "$cpufreq/policy0/auto_select") == $'338000\n2808000\n1' &&
  $(cat "$cpufreq/policy5/scaling_min_freq" "$cpufreq/policy5/scaling_max_freq" "$cpufreq/policy5/auto_select") == $'1378000\n4004000\n1' ]]; then
  pass "every core gets its full range and autonomous selection"
else
  fail "every core gets its full range and autonomous selection"
fi

echo '# administrator copy' > "$rules"
run_migration
grep -Fxq '# administrator copy' "$rules" && pass "an existing rule file is kept" || fail "an existing rule file is kept"

# n1x.sh writes the same rule for new installs, so the two cannot drift apart.
n1x="$ROOT/install/hardware/n1x.sh"
rule_from() { sed -n "/$2/,/^ *$3\$/p" "$1" | sed '1d;$d;s/^ *//'; }
n1x_rule=$(rule_from "$n1x" '71-omarchy-n1x-cppc.rules <<' RULES)
if [[ -n $n1x_rule && $n1x_rule == "$(rule_from "$migration" '"$rules" <<' EOF)" ]]; then
  pass "new installs and the migration write the same rule"
else
  fail "new installs and the migration write the same rule"
fi

if [[ -n $real_udevadm ]] && "$real_udevadm" verify --help >/dev/null 2>&1; then
  printf '%s\n' "$n1x_rule" > "$tmp_dir/71-omarchy-n1x-cppc.rules"
  "$real_udevadm" verify --no-summary "$tmp_dir/71-omarchy-n1x-cppc.rules" >/dev/null 2>&1 &&
    pass "udevadm verify accepts the rule" || fail "udevadm verify accepts the rule"
fi
