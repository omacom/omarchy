#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

rule_file="$ROOT/etc/udev/rules.d/80-pci-pm.rules"
migration_file="$ROOT/migrations/1789235300.sh"

[[ -f $rule_file ]] || fail "80-pci-pm.rules exists in etc/udev/rules.d/"
grep -Eq 'SUBSYSTEM=="pci"' "$rule_file" || fail "rule matches pci subsystem"
grep -Eq 'ATTR\{power/control\}="auto"' "$rule_file" || fail "rule sets power/control to auto"
pass "80-pci-pm.rules properly configures runtime PM for PCI devices"

[[ -f $migration_file ]] || fail "migration file exists"
bash -n "$migration_file" || fail "migration syntax is valid"
pass "migration file syntax is clean"
