import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { mkdtemp, mkdir, readFile, writeFile, copyFile, rm, access } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../../../../', import.meta.url));

for (const desktop of [false, true]) {
  test(`manual launcher isolates and cleans browser state (${desktop ? 'read-only desktop' : 'synthetic palette'})`, async t => {
    const directory = await mkdtemp(join(tmpdir(), 'omarchy-local-browser-test-'));
    t.after(() => rm(directory, {recursive: true, force: true}));
    const home = join(directory, 'original-home');
    const current = join(home, '.local/state/omarchy/current');
    const report = join(directory, 'browser-report.json');
    const browser = join(directory, 'browser-stub');
    const launcher = join(directory, 'local-browser.py');
    const runtime = join(directory, 'original-runtime');
    await mkdir(join(current, 'theme'), {recursive: true});
    await mkdir(runtime);
    const original = 'background="#123456"\n';
    await writeFile(join(current, 'theme/colors.toml'), original);
    await writeFile(browser, `#!/bin/bash
exec /usr/bin/python - "$@" <<'PY'
import json, os, pathlib, sys, urllib.request
home = pathlib.Path(os.environ['HOME'])
profile = home / '.config/chromium'
assert '--user-data-dir=' + str(profile) in sys.argv
manifest = json.loads((profile / 'NativeMessagingHosts/com.omarchy.theme.json').read_text())
assert manifest['path'] == os.environ['EXPECTED_ROOT'] + '/bin/omarchy-browser-theme-host'
assert manifest['allowed_origins'] == ['chrome-extension://ppnnomfimbfcofidkfmghapellfbgklc/']
assert 'Theme Sync local test' in urllib.request.urlopen(sys.argv[-1]).read().decode()
state = home / '.local/state/omarchy/current'
result = {'profile': str(profile), 'desktop_link': state.is_symlink(),
  'state': str(state.resolve()), 'colors': (state / 'theme/colors.toml').read_text(),
  'runtime': os.environ['XDG_RUNTIME_DIR']}
pathlib.Path(os.environ['TEST_REPORT']).write_text(json.dumps(result))
PY
`, {mode: 0o755});
    const source = await readFile(new URL('local-browser.py', import.meta.url), 'utf8');
    // Keep the real harness and its lifecycle; replace only the fixed browser
    // binary in this disposable copy so no graphical browser is started.
    await writeFile(launcher, source.replace('Path("/usr/lib/chromium/chromium")', `Path(${JSON.stringify(browser)})`));
    await copyFile(new URL('demo.html', import.meta.url), join(directory, 'demo.html'));
    const env = {...process.env, HOME: home, TMPDIR: directory, XDG_RUNTIME_DIR: runtime,
      EXPECTED_ROOT: root.replace(/\/$/, ''), TEST_REPORT: report};
    delete env.WAYLAND_DISPLAY;
    delete env.DISPLAY;
    const child = spawn('/usr/bin/python', [launcher, root, ...(desktop ? ['--desktop'] : [])], {env, stdio: ['ignore', 'pipe', 'pipe']});
    let output = '';
    child.stdout.on('data', chunk => { output += chunk; });
    child.stderr.on('data', chunk => { output += chunk; });
    const timer = setTimeout(() => child.kill('SIGKILL'), 10000);
    t.after(() => { clearTimeout(timer); child.kill('SIGKILL'); });
    assert.deepEqual(await once(child, 'close'), [0, null], output);
    clearTimeout(timer);
    const result = JSON.parse(await readFile(report, 'utf8'));
    assert.equal(result.desktop_link, desktop);
    assert.equal(result.state === current, desktop);
    assert.notEqual(result.runtime, runtime);
    assert.ok(result.profile.startsWith(directory + '/omarchy-browser-theme-sync-'));
    await assert.rejects(access(result.profile), {code: 'ENOENT'});
    assert.equal(await readFile(join(current, 'theme/colors.toml'), 'utf8'), original);
  });
}
