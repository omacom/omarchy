#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import ast
import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
root = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location('credentials', root / 'default/netclaw/credential-setup.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
fixture = r'''NETCLAW_DIR=unused
prompt() {
    local var="$1" prompt_text="$2" default="${3:-}"
    read -r input
    eval "$var=\"${input:-$default}\""
}
prompt_secret() {
    local var="$1" prompt_text="$2"
    read -rs input
    eval "$var=\"$input\""
}
set_env() {
    false
}
'''
with tempfile.TemporaryDirectory() as temp:
    folder = Path(temp)
    sentinel = folder / 'must-not-exist'
    value = 'quotes\'" & | \\ $HOME ${USER} `touch ' + str(sentinel) + '` $(touch ' + str(sentinel) + ')'
    patched = module.patch_wizard(fixture, folder, Path(module.__file__))
    for function in ('prompt', 'prompt_secret'):
        result = subprocess.run(['bash', '-c', patched + '\n' + function + ' VALUE ignored\nprintf "%s" "$VALUE"'], input=value + '\n', text=True, capture_output=True, check=True)
        assert result.stdout == value
        assert not sentinel.exists()
    env = folder / '.env'
    env.write_text('KEEP=value\nPASSWORD=old\n# PASSWORD=example\n')
    module.write_value(env, 'PASSWORD', value)
    lines = env.read_text().splitlines()
    assert lines[0] == 'KEEP=value' and len(lines) == 2
    assert ast.literal_eval(lines[1].split('=', 1)[1]) == value
    assert env.stat().st_mode & 0o777 == 0o600
    before = env.read_bytes()
    for invalid in ('line\nbreak', 'carriage\rreturn', 'nul\0byte'):
        try:
            module.write_value(env, 'PASSWORD', invalid)
        except ValueError:
            pass
        else:
            raise AssertionError('Multiline credential accepted')
        assert env.read_bytes() == before
    try:
        module.patch_wizard(fixture.replace('prompt_secret()', 'changed_prompt()').replace('eval "$var=\\"$input\\""', 'changed'), folder, Path(module.__file__))
    except ValueError:
        pass
    else:
        raise AssertionError('Changed upstream contract accepted')
PY
pass 'credential prompts preserve literal input without command evaluation'
pass 'credential persistence preserves special characters, unrelated keys, and private mode'
pass 'credential adapter rejects multiline values and changed upstream contracts'
