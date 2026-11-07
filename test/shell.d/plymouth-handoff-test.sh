#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

# Quitting Plymouth while a display still shows its frame blanks that display
# until the compositor reaches it, so the handoff waits for every one.
HANDOFF="$ROOT/bin/omarchy-plymouth-handoff" python3 - <<'PY' || fail "the handoff waits until every display Plymouth lit has been drawn over"
import importlib.machinery, importlib.util, os
loader = importlib.machinery.SourceFileLoader("handoff", os.environ["HANDOFF"])
spec = importlib.util.spec_from_loader(loader.name, loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)
handoff = module.handoff

panel, external, dark = ("card1", 39), ("card1", 40), ("card0", 51)
splash = {panel: 46, external: 47}

assert handoff(splash, {panel: 46, external: 47}) == (False, False), "nothing drawn yet"
assert handoff(splash, {panel: 52, external: 47}) == (True, False), "one display still shows the splash"
assert handoff(splash, {panel: 52, external: 0}) == (True, True), "a display the compositor turned off no longer shows it"
assert handoff(splash, {panel: 52, external: 53}) == (True, True), "both drawn over"
assert handoff({}, {dark: 0}) == (False, False), "a text splash: nothing drawn yet"
assert handoff({}, {dark: 60}) == (True, True), "a text splash: the compositor's first frame"
PY
pass "the handoff waits until every display Plymouth lit has been drawn over"
