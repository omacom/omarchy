#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
migration="$ROOT/migrations/1787815267.sh"
grep -Fq '/usr/share/omarchy/migrations/1787815267.sh --machine' "$migration" || fail "CUPS migration lacks fixed machine phase"
grep -Fq '/usr/bin/pacman -Rns --noconfirm -- cups-pdf' "$migration" || fail "CUPS removal target is not fixed"
grep -Fq '/usr/bin/pacman -S --needed --noconfirm -- cups-pk-helper' "$migration" || fail "CUPS install target is not fixed"
grep -Fq 'CUPS printer discovery' "$migration" || fail "CUPS account identity check was lost"
pass "CUPS repair retains fixed package and service policy"
