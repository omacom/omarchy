#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs'), os = require('os'), cp = require('child_process')
const work = fs.mkdtempSync(path.join(os.tmpdir(), 'gaming-gpu-'))
try {
  const calls = path.join(work, 'calls')
  function stub(name, body) {
    fs.writeFileSync(path.join(work, name), '#!/bin/bash\n' + body + '\n', {mode:0o755})
  }
  stub('lspci', 'printf "%s\\n" "$PCI_DEVICES"')
  stub('omarchy-hw-nvidia-gsp', '[[ $NVIDIA_GSP == 1 ]]')
  stub('omarchy-hw-nvidia-without-gsp', '[[ $NVIDIA_LEGACY == 1 ]]')
  stub('omarchy-pkg-add', `printf 'pkg-add %s\\n' "$*" >> "$CALLS"
[[ $1 == steam ]] && exit 0
exit "$DRIVER_STATUS"`)
  stub('setsid', 'printf "launch %s\\n" "$*" >> "$CALLS"')
  const intel = '00:02.0 VGA compatible controller: Intel Corporation Graphics'
  const amd = '03:00.0 Display controller: AMD Radeon Graphics'
  const noGpu = '01:00.0 Network controller: Broadcom Inc. BCM4387'
  function run(command, extra={}) {
    fs.writeFileSync(calls, '')
    return cp.spawnSync('bash', [path.join(root, 'bin', command)], {
      encoding:'utf8',
      env:{...process.env, OMARCHY_PATH:root, CALLS:calls, PATH:work+':'+root+'/bin:'+process.env.PATH,
        PCI_DEVICES:noGpu, NVIDIA_GSP:'0', NVIDIA_LEGACY:'0', DRIVER_STATUS:'0', ...extra}
    })
  }
  const cases = [
    {name:'no PCI GPU', env:{}, packages:[]},
    {name:'Intel', env:{PCI_DEVICES:intel}, packages:['lib32-vulkan-intel']},
    {name:'Intel and AMD', env:{PCI_DEVICES:intel+'\n'+amd}, packages:['lib32-vulkan-intel','lib32-vulkan-radeon']},
    {name:'NVIDIA GSP', env:{NVIDIA_GSP:'1', NVIDIA_LEGACY:'1'}, packages:['lib32-nvidia-utils']},
    {name:'NVIDIA legacy', env:{NVIDIA_LEGACY:'1'}, packages:['lib32-nvidia-580xx-utils']},
    {name:'driver install failure', env:{PCI_DEVICES:intel, DRIVER_STATUS:'42'}, packages:['lib32-vulkan-intel'], status:42}
  ]
  for (const test of cases) {
    const result = run('omarchy-install-gaming-gpu-lib32', test.env)
    assertEqual(result.status, test.status || 0, `${test.name}: exit status`, result.stderr)
    const lines = fs.readFileSync(calls, 'utf8').trim().split('\n').filter(Boolean)
    assertEqual(lines.length, test.packages.length ? 1 : 0, `${test.name}: one transaction or successful no-op`)
    const packages = lines.length ? lines[0].replace(/^pkg-add /, '').split(' ').sort() : []
    assertDeepEqual(packages, [...test.packages].sort(), `${test.name}: selected packages`)
  }

  const success = run('omarchy-install-gaming-steam')
  assertEqual(success.status, 0, 'Steam completes with no PCI GPU', success.stderr)
  // Steam detaches its launcher: wait only for the recording stub, not an app.
  const deadline = Date.now() + 2000
  while (!fs.readFileSync(calls, 'utf8').includes('launch ') && Date.now() < deadline) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 10)
  }
  assertDeepEqual(fs.readFileSync(calls, 'utf8').trim().split('\n'), [
    'pkg-add steam', 'launch uwsm-app -- gtk-launch steam'
  ], 'Steam installs before launch and skips an empty driver transaction')

  const failure = run('omarchy-install-gaming-steam', {PCI_DEVICES:intel, DRIVER_STATUS:'42'})
  assertEqual(failure.status, 42, 'Steam propagates driver installation failure', failure.stderr)
  assertDeepEqual(fs.readFileSync(calls, 'utf8').trim().split('\n'), [
    'pkg-add steam', 'pkg-add lib32-vulkan-intel'
  ], 'Steam does not launch after driver installation failure')
} finally {
  fs.rmSync(work, {recursive:true, force:true})
}
JS
