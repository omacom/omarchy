#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
python3 - "$ROOT" <<'PY'
import json, os, pathlib, subprocess, sys, tempfile
root = pathlib.Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix='tooltip-installer-test.') as temp:
    base = pathlib.Path(temp)
    def write(path, text):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        path.chmod(0o755)
    source = base/'source'
    (source/'shell').mkdir(parents=True)
    (source/'default').mkdir()
    fake = base/'bin'
    def configured(path):
        return f'export OMARCHY_PATH="{path}"\n'
    write(fake/'omarchy-pkg-add' , '#!/bin/bash\nexit 0\n')
    write(fake/'pacman', '''#!/bin/bash
if [[ $1 == -Q ]]; then echo 'quickshell 0.3.1-1'; exit 0; fi
if [[ $1 == -Qi ]]; then printf 'Name            : quickshell\\nArchitecture    : any\\n'; exit 0; fi
exit 99
''')
    write(fake/'sudo', '''#!/bin/bash
printf '%s\\n' "$*" >> "$TEST_LOG"
# The repository now publishes a newer release than the one installed.
if [[ $1 == pacman && $2 == -Sw ]]; then touch "$5/quickshell-0.3.1-3-any.pkg.tar.xz"; exit 0; fi
[[ $1 == pacman && $2 == -U ]] || exit 99
if [[ $* == *new.pkg.tar* && $FAULT == package* ]]; then exit 42; fi
if [[ $* == *previous.pkg.tar* && $FAULT == package-rollback ]]; then exit 43; fi
''')
    write(fake/'makepkg', '''#!/bin/bash
if [[ ${1:-} == --packagelist ]]; then printf '%s/new.pkg.tar\\n' "$PWD"; else touch new.pkg.tar; fi
''')
    write(source/'bin/omarchy-dev-link', '''#!/bin/bash
printf 'link %s\\n' "$1" >> "$TEST_LOG"
if [[ $1 == */trial/omarchy && $FAULT == link ]]; then exit 44; fi
printf 'export OMARCHY_PATH="%s"\\n' "$1" > "$TEST_SELECTION"
''')
    write(source/'bin/omarchy-dev-unlink', '''#!/bin/bash
printf 'unlink\\n' >> "$TEST_LOG"
printf 'export OMARCHY_PATH="/usr/share/omarchy"\\n' > "$TEST_SELECTION"
''')
    write(source/'default/tooltips/check-runtime', '#!/bin/bash\nexit 0\n')
    write(source/'default/tooltips/build-runtime', '#!/bin/bash\nmkdir -p "$TOOLTIP_BUILD_DIR/build/src"\ntouch "$TOOLTIP_BUILD_DIR/build/src/quickshell"\n')
    write(source/'default/tooltips/prepare-trial.py', '''import argparse, os
from pathlib import Path
p=argparse.ArgumentParser()
for name in ['source','installed','stock-package','output','runtime']: p.add_argument('--'+name)
a=p.parse_args(); t=Path(a.output)
open(os.environ['TEST_LOG'],'a').write('installed '+a.installed+'\\n')
for d in ['backup','package','omarchy/shell','omarchy/test/shell.d']: (t/d).mkdir(parents=True,exist_ok=True)
(t/'omarchy/test/shell.d/tooltips-test.sh').write_text('exit 0\\n')
''')
    for fault in ['none','package','link','package-rollback']:
        work=base/fault
        stock=work/'cache/omarchy/tooltips/stock/quickshell-0.3.1-1-any.pkg.tar.xz'
        stock.parent.mkdir(parents=True)
        stock.touch()
        selected=work/'selected'
        (selected/'shell').mkdir(parents=True)
        selection=work/'selection'
        selection.write_text(configured(selected))
        env={**os.environ, 'PATH':str(fake)+':'+os.environ['PATH'], 'HOME':str(work),
             'XDG_STATE_HOME':str(work/'state'), 'XDG_DATA_HOME':str(work/'data'),
             'XDG_CACHE_HOME':str(work/'cache'), 'XDG_CONFIG_HOME':str(work/'config'),
             'OMARCHY_PATH':str(source), 'TEST_SELECTION':str(selection), 'TOOLTIP_OMARCHY_CONF':str(selection), 'FAULT':fault, 'TEST_LOG':str(work/'log')}
        run=subprocess.run(['/bin/bash',str(root/'default/tooltips/install'),'--base',str(source)],env=env,capture_output=True,text=True)
        state=work/'state/omarchy/tooltip-trial.json'
        pending=state.with_name(state.name+'.pending')
        log=(work/'log').read_text()
        assert (run.returncode==0)==(fault=='none'), (fault,run.stdout,run.stderr)
        assert state.exists()==(fault=='none'), (fault,log)
        assert pending.exists()==(fault=='package-rollback'), (fault,log)
        if fault=='none':
            saved=json.loads(state.read_text())
            assert saved['previousOmarchy']==str(selected),saved
            assert pathlib.Path(saved['previousPackage']).exists()
            undone=subprocess.run(['/bin/bash',str(root/'default/tooltips/install'),'--uninstall'],env=env,capture_output=True,text=True)
            assert undone.returncode==0,(undone.stdout,undone.stderr)
            assert selection.read_text()==configured(selected)
            assert not state.exists()
        else:
            assert 'previous.pkg.tar' in log, (fault,log)
            if fault=='link': assert f'link {selected}' in log, log
            if fault.startswith('package'): assert 'link ' not in log, log
        if fault=='package-rollback':
            # The unfinished record blocks a new installation, and uninstall
            # completes its recovery instead of reporting that nothing is installed.
            again=subprocess.run(['/bin/bash',str(root/'default/tooltips/install'),'--base',str(source)],env=env,capture_output=True,text=True)
            assert again.returncode!=0 and 'did not finish' in again.stderr,(again.stdout,again.stderr)
            assert pending.exists()
            recovered=subprocess.run(['/bin/bash',str(root/'default/tooltips/install'),'--uninstall'],env={**env,'FAULT':'none'},capture_output=True,text=True)
            assert recovered.returncode==0,(recovered.stdout,recovered.stderr)
            assert not pending.exists() and not state.exists()
            assert (work/'log').read_text().count('previous.pkg.tar')==2, (work/'log').read_text()
            assert selection.read_text()==configured(selected)
            print('ok - uninstall recovers an unfinished tooltip installation')
        print('ok - tooltip installer transaction: '+fault)

    # Rollback needs the installed release, not another cached or newer one.
    work=base/'other-release'
    for name in ['quickshell-0.3.1-2-any.pkg.tar.xz','quickshell-0.3.1-1-x86_64.pkg.tar.xz']:
        cached=work/'cache/omarchy/tooltips/stock'/name
        cached.parent.mkdir(parents=True,exist_ok=True)
        cached.touch()
    selected=work/'selected'
    (selected/'shell').mkdir(parents=True)
    selection=work/'selection'
    selection.write_text(configured(selected))
    env={**os.environ, 'PATH':str(fake)+':'+os.environ['PATH'], 'HOME':str(work),
         'XDG_STATE_HOME':str(work/'state'), 'XDG_DATA_HOME':str(work/'data'),
         'XDG_CACHE_HOME':str(work/'cache'), 'XDG_CONFIG_HOME':str(work/'config'),
         'OMARCHY_PATH':str(source), 'TEST_SELECTION':str(selection), 'TOOLTIP_OMARCHY_CONF':str(selection),
         'FAULT':'none', 'TEST_LOG':str(work/'log')}
    run=subprocess.run(['/bin/bash',str(root/'default/tooltips/install'),'--base',str(source)],env=env,capture_output=True,text=True)
    assert run.returncode!=0 and 'quickshell-0.3.1-1-any' in run.stderr,(run.stdout,run.stderr)
    log=(work/'log').read_text()
    assert 'pacman -Sw' in log and 'pacman -U' not in log and 'installed ' not in log, log
    assert not (work/'state/omarchy/tooltip-trial.json').exists()
    print('ok - tooltip installer keeps only the installed release for rollback')

    # A package installation has no /etc/omarchy.conf. The caller's OMARCHY_PATH
    # must not turn the feature checkout into the copy source or rollback target.
    work=base/'unconfigured'
    stock=work/'cache/omarchy/tooltips/stock/quickshell-0.3.1-1-any.pkg.tar.xz'
    stock.parent.mkdir(parents=True)
    stock.touch()
    selection=work/'selection'
    env={**os.environ, 'PATH':str(fake)+':'+os.environ['PATH'], 'HOME':str(work),
         'XDG_STATE_HOME':str(work/'state'), 'XDG_DATA_HOME':str(work/'data'),
         'XDG_CACHE_HOME':str(work/'cache'), 'XDG_CONFIG_HOME':str(work/'config'),
         'OMARCHY_PATH':str(source), 'TEST_SELECTION':str(selection), 'TOOLTIP_OMARCHY_CONF':str(selection),
         'FAULT':'none', 'TEST_LOG':str(work/'log')}
    run=subprocess.run(['/bin/bash',str(root/'default/tooltips/install')],env=env,capture_output=True,text=True)
    if pathlib.Path('/usr/share/omarchy/shell').is_dir():
        assert run.returncode==0,(run.stdout,run.stderr)
        log=(work/'log').read_text()
        assert 'installed /usr/share/omarchy\n' in log, log
        saved=json.loads((work/'state/omarchy/tooltip-trial.json').read_text())
        assert saved['previousOmarchy']=='/usr/share/omarchy',saved
        undone=subprocess.run(['/bin/bash',str(root/'default/tooltips/install'),'--uninstall'],env=env,capture_output=True,text=True)
        assert undone.returncode==0,(undone.stdout,undone.stderr)
        assert selection.read_text()==configured('/usr/share/omarchy')
        assert 'unlink\n' in (work/'log').read_text()
    else:
        assert run.returncode!=0 and 'Invalid selected Omarchy tree: /usr/share/omarchy' in run.stderr,(run.stdout,run.stderr)
        assert not (work/'log').exists() or 'installed ' not in (work/'log').read_text()
    print('ok - tooltip installer uses the package tree without /etc/omarchy.conf')
PY
