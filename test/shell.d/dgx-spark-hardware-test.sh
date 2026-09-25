#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/nvidia-dgx-spark.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "DGX Spark hardware script has valid syntax"

(
  omarchy-hw-dgx-spark() { return 0; }
  OMARCHY_DGX_SPARK_SLEEP_CONFIG_DIR="$scratch/spark" source "$setup"
)
config="$scratch/spark/omarchy-dgx-spark.conf"
for setting in AllowSuspend AllowHibernation AllowSuspendThenHibernate AllowHybridSleep; do
  grep -Fxq "$setting=no" "$config" || fail "DGX Spark disallows $setting"
done
[[ $(head -n 1 "$config") == "[Sleep]" ]] || fail "DGX Spark sleep settings are in the [Sleep] section"

(
  omarchy-hw-dgx-spark() { return 1; }
  OMARCHY_DGX_SPARK_SLEEP_CONFIG_DIR="$scratch/other" source "$setup"
)
[[ ! -e $scratch/other ]] || fail "other machines keep system sleep"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -F '"system.suspend"' "$menu" | grep -Fq '! omarchy-hw-dgx-spark' ||
  fail "the menu hides Suspend on the DGX Spark"
grep -F '"system.hibernate"' "$menu" | grep -Fq '! omarchy-hw-dgx-spark' ||
  fail "the menu hides Hibernate on the DGX Spark"

pass "DGX Spark disables system sleep and hides it from the menu"
