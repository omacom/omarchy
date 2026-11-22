#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const system = requireFromRoot('shell/plugins/panels/system/Model.js')
const gib = 1024 * 1024

const meminfo = system.parseMeminfo([
  `MemTotal: ${64 * gib} kB`, `MemFree: ${8 * gib} kB`, `Buffers: 0 kB`,
  `Cached: ${30 * gib} kB`, `Shmem: ${4 * gib} kB`, `SReclaimable: ${2 * gib} kB`
].join('\n'))
const sum = (b) => b.segments.reduce((n, s) => n + s.gib, 0)

// Cache is page cache less shmem plus reclaimable slab; shmem counts as used.
let b = system.memoryBreakdown(meminfo, [])
assertDeepEqual(b.segments.map(s => s.gib), [28, 28, 8], 'system splits memory into apps, reclaimable cache and free')

// A model held in anonymous memory comes out of apps.
b = system.memoryBreakdown(meminfo, [{ name: 'Qwen', gib: 20 }])
assertDeepEqual(b.segments.map(s => s.gib), [20, 8, 28, 8], 'system takes a model out of apps')

// Weights mapped from the page cache: what apps can't cover comes out of cache.
b = system.memoryBreakdown(meminfo, [{ name: 'Qwen', gib: 30 }, { name: 'FLUX', gib: 10 }])
assertDeepEqual(b.segments.map(s => s.gib), [30, 10, 0, 16, 8], 'system takes models beyond apps out of cache')
assertEqual(sum(b), 64, 'system breakdown adds up to the total')

const usage = system.cpuUsage(
  system.parseCpuStat('cpu  100 0 100 700 100 0 0 0\ncpu0 50 0 50 400 0 0 0 0\n'),
  system.parseCpuStat('cpu  200 0 200 1300 300 0 0 0\ncpu0 150 0 150 400 0 0 0 0\n'))
assertDeepEqual(usage.map(u => Math.round(u * 100)), [20, 100], 'system counts iowait as idle when reading CPU load')

const df = system.parseDf([
  'Filesystem 1B-blocks',
  `/dev/mapper/root btrfs ${100 * gib * 1024} ${60 * gib * 1024} ${30 * gib * 1024} /home`,
  `/dev/mapper/root btrfs ${100 * gib * 1024} ${60 * gib * 1024} ${30 * gib * 1024} /`,
  `/dev/nvme0n1p1 vfat ${gib * 1024} 0 ${gib * 1024} /boot`,
  `/dev/loop0 btrfs ${gib * 1024} 0 ${gib * 1024} /run/media/me/image`,
  'tmpfs tmpfs 1024 0 1024 /tmp',
  `/dev/sda1 ext4 ${500 * gib * 1024} ${100 * gib * 1024} ${400 * gib * 1024} /run/media/me/My Drive`
].join('\n'))
assertDeepEqual(df.map(d => d.target), ['/', '/run/media/me/My Drive'], 'system shows each real disk once, at its shortest mount')
assertEqual(df[0].fraction, 2 / 3, 'system reads disk use as df does, leaving out the reserve')
JS
