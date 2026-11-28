#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/ollama-unload-test.py" "$ROOT"
pass "Ollama unloading targets loaded models and keeps model downloads"
