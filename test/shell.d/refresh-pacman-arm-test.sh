#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PY'
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory() as d:
    tmp = Path(d)
    stub = tmp / 'bin'
    stub.mkdir()
    etc = tmp / 'etc'
    (etc / 'pacman.d').mkdir(parents=True)
    log = tmp / 'calls'
    scripts = {
        'uname': '#!/bin/bash\necho "$TEST_ARCH"\n',
        'omarchy-hook': '#!/bin/bash\necho "hook $*" >>"$TEST_LOG"\nexit "${TEST_HOOK_FAIL:-0}"\n',
        'sudo': '''#!/usr/bin/env python3
import os,sys,subprocess
from pathlib import Path
args=sys.argv[1:]
with open(os.environ['TEST_LOG'],'a') as f: f.write('sudo '+ ' '.join(args)+'\\n')
if args[0]=='env':
    assert args == ['env','OMARCHY_UPDATE_PACMAN=1','pacman','-Syyuu','--noconfirm']
    sys.exit(int(os.environ.get('TEST_PACMAN_FAIL','0')))
assert args[0] in ('cat','cp'), args
args=[os.environ['TEST_ROOT']+a if a.startswith('/etc/') else a for a in args]
if args[0] == 'cp':
    assert Path(args[-1]).is_relative_to(os.environ['TEST_ROOT']), args
    failure = os.environ.get('TEST_COPY_FAIL')
    if failure == 'backup' and args[-1].endswith('.bak'): sys.exit(1)
    if failure == 'write' and not args[-1].endswith('.bak'): sys.exit(1)
result = subprocess.call(args)
# Simulate a read error even though awk has received a complete valid config.
sys.exit(1 if args[0] == 'cat' and os.environ.get('TEST_READ_FAIL') else result)
''',
    }
    for name, data in scripts.items():
        (stub / name).write_text(data)
        (stub / name).chmod(0o755)
    env = dict(os.environ, PATH=f'{stub}:'+os.environ['PATH'], OMARCHY_PATH=str(root),
               TEST_ROOT=d, TEST_LOG=str(log), TEST_ARCH='aarch64')
    for name in ('OMARCHY_PACMAN_CONFIG', 'OMARCHY_MIRRORLIST'):
        env.pop(name, None)
    original = '''[options]
Architecture = auto
SigLevel = Required DatabaseOptional
[omarchy]
SigLevel = Optional TrustAll
Server = https://pkgs.omarchy.org/stable/$arch
[core]
Server = https://arm.example/$arch/$repo
[extra]
Include = /etc/pacman.d/mirrorlist
[alarm]
Server = https://arm.example/$arch/$repo
[custom]
Server = https://custom.example/stable/$arch
# This endpoint belongs to another repository and must not change.
Server = https://pkgs.omarchy.org/stable/$arch
'''
    def run(config=original, channel='edge', arch='aarch64', **extra):
        (etc/'pacman.conf').write_text(config)
        (etc/'pacman.d/mirrorlist').write_text('ARM mirror\n')
        for backup in (etc/'pacman.conf.bak', etc/'pacman.d/mirrorlist.bak'):
            backup.unlink(missing_ok=True)
        log.write_text('')
        args = [channel] if channel is not None else []
        result = subprocess.run(['bash',str(root/'bin/omarchy-refresh-pacman'),*args],
                                env=dict(env,TEST_ARCH=arch,**extra),capture_output=True,text=True)
        return result, (etc/'pacman.conf').read_text(), log.read_text()

    for source_channel in ('stable', 'rc', 'edge'):
        before = original.replace('org/stable/', f'org/{source_channel}/', 1)
        result, config, calls = run(config=before)
        assert result.returncode == 0, result.stderr
        assert config == original.replace('org/stable/', 'org/edge/', 1), \
            'ARM refresh changed repository order, signature policy, mirrors or another endpoint'
        assert (etc/'pacman.d/mirrorlist').read_text() == 'ARM mirror\n'
        assert not (etc/'pacman.d/mirrorlist.bak').exists()
        assert (etc/'pacman.conf.bak').read_text() == before
        assert calls.index('hook pre-refresh-pacman') < calls.index('sudo env')
    print('ok - ARM edge preserves repository order, signature policy, mirrors and other endpoints')

    before = original.replace('$arch', 'aarch64')
    result, config, _ = run(config=before)
    assert result.returncode == 0, result.stderr
    assert config == before.replace('org/stable/', 'org/edge/', 1)
    result, after, _ = run(config=config)
    assert result.returncode == 0 and after == config
    print('ok - literal aarch64 endpoints and repeated refreshes are supported')

    subprocess.run(['bash', '-c', '''
source "$OMARCHY_PATH/install/helpers/pacman.sh"
pacman_write_repository_config edge "$TEST_ROOT/installed.conf" "$TEST_ROOT/installed-mirrors"
'''], env=env, check=True)
    installed = (tmp/'installed.conf').read_text()
    result, config, _ = run(config=installed)
    assert result.returncode == 0 and config == installed
    print('ok - refresh accepts the ARM edge configuration produced by install finalization')

    for bad in (original.replace('pkgs.omarchy.org','unknown.example'),
                original.replace('[omarchy]','[other]'),
                original.replace('[core]','Include = /another/config\n[core]'),
                original.replace('[core]','Server = https://pkgs.omarchy.org/rc/$arch\n[core]'),
                original.replace('[core]','Server = https://mirror.example/edge/$arch\n[core]'),
                '[offline]\nServer = file:///offline\n'):
        result, config, calls = run(config=bad)
        assert result.returncode != 0 and config == bad
        assert 'sudo cp' not in calls and 'sudo env' not in calls
        assert 'hook ' not in calls
        assert (etc/'pacman.d/mirrorlist').read_text() == 'ARM mirror\n'
        assert 'configuration unchanged' in result.stderr
    print('ok - private, missing and ambiguous ARM repositories stop before writes or upgrades')

    for channel in ('stable', 'rc', None):
        result, config, calls = run(channel=channel)
        assert result.returncode != 0 and not calls and config == original
        assert 'No repository configuration changed' in result.stderr
    print('ok - unpublished ARM channels remain blocked until safe switching is available')

    for arch in ('aarch64', 'x86_64'):
        result, config, calls = run(channel='invalid', arch=arch)
        assert result.returncode != 0 and not calls and config == original
    print('ok - invalid channels stop before privileged commands on either architecture')

    for channel in ('stable','rc','edge'):
        result, config, calls = run(channel=channel, arch='x86_64')
        assert result.returncode == 0, result.stderr
        assert config == (root/f'default/pacman/pacman-{channel}.conf').read_text()
        assert (etc/'pacman.d/mirrorlist').read_bytes() == (root/f'default/pacman/mirrorlist-{channel}').read_bytes()
        assert (etc/'pacman.conf.bak').read_text() == original
        assert (etc/'pacman.d/mirrorlist.bak').read_text() == 'ARM mirror\n'
    print('ok - x86 retains template refresh for all channels')

    result, config, calls = run(TEST_READ_FAIL='1')
    assert result.returncode != 0 and config == original
    assert 'sudo cp' not in calls and 'hook ' not in calls and 'sudo env' not in calls
    print('ok - a failed config read cannot overwrite the installed repositories')

    defaults = tmp/'templates/default/pacman'
    defaults.mkdir(parents=True)
    for config_present in (False, True):
        if config_present:
            (defaults/'pacman-edge.conf').write_bytes((root/'default/pacman/pacman-edge.conf').read_bytes())
        result, config, calls = run(arch='x86_64', OMARCHY_PATH=str(tmp/'templates'))
        assert result.returncode != 0 and config == original and not calls
        assert (etc/'pacman.d/mirrorlist').read_text() == 'ARM mirror\n'
    print('ok - missing x86 templates stop before privileged writes')

    for failure in ('backup', 'write'):
        result, config, calls = run(TEST_COPY_FAIL=failure)
        assert result.returncode != 0 and config == original
        assert 'hook ' not in calls and 'sudo env' not in calls
    result, _, calls = run(TEST_HOOK_FAIL='9')
    assert result.returncode == 9 and 'sudo env' not in calls
    result, _, _ = run(TEST_PACMAN_FAIL='7')
    assert result.returncode == 7
    print('ok - copy and hook failures stop the upgrade; pacman failure propagates')

    for arch in ('aarch64', 'x86_64'):
        result, config, calls = run(arch=arch, OMARCHY_PACMAN_CONFIG=str(etc/'pacman.conf'),
                                   OMARCHY_MIRRORLIST=str(etc/'pacman.d/mirrorlist'))
        assert result.returncode == 0, result.stderr
        expected = (original.replace('org/stable/', 'org/edge/', 1) if arch == 'aarch64'
                    else (root/'default/pacman/pacman-edge.conf').read_text())
        assert config == expected
        assert (etc/'pacman.conf.bak').read_text() == original
    print('ok - explicit configuration paths remain supported')
PY
