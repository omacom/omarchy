var KIB_PER_GIB = 1024 * 1024
var BYTES_PER_GIB = 1024 * 1024 * 1024

// /proc/meminfo as kB numbers by field name; null until it names a total.
function parseMeminfo(raw) {
  var fields = {}
  var rows = String(raw || "").split("\n")
  for (var i = 0; i < rows.length; i++) {
    var match = rows[i].match(/^([\w()]+):\s+(\d+)/)
    if (match) fields[match[1]] = Number(match[2])
  }
  return fields.MemTotal > 0 ? fields : null
}

// The machine's memory split by what holds it, in GiB, adding up to the
// total: each running model, then apps and the system, then the cache the
// kernel gives back on demand, then what's free. Cache is what's reclaimable:
// page cache less shared memory (tmpfs, GPU buffers), reclaimable slab, and
// the pages a GPU driver keeps pooled (GPUReclaim on unified-memory machines).
// A model's weights may be mapped from the page cache, so what the models
// hold comes out of apps first and then out of cache.
function memoryBreakdown(meminfo, models) {
  var m = meminfo || {}
  var total = (m.MemTotal || 0) / KIB_PER_GIB
  var free = Math.min(total, (m.MemFree || 0) / KIB_PER_GIB)
  var cacheKib = (m.Buffers || 0) + Math.max(0, (m.Cached || 0) - (m.Shmem || 0)) + (m.SReclaimable || 0) + (m.GPUReclaim || 0)
  var cache = Math.min(total - free, cacheKib / KIB_PER_GIB)
  var used = Math.max(0, total - free - cache)

  var held = []
  var heldTotal = 0
  var list = Array.isArray(models) ? models : []
  for (var i = 0; i < list.length; i++) {
    var gib = Math.min(Number(list[i].gib) || 0, total - free - heldTotal)
    if (!(gib > 0)) continue
    held.push({ kind: "model", name: String(list[i].name || ""), gib: gib })
    heldTotal += gib
  }

  var apps = Math.max(0, used - heldTotal)
  cache = Math.max(0, cache - Math.max(0, heldTotal - used))
  return {
    total: total,
    used: total - free - cache,
    segments: held.concat([
      { kind: "apps", gib: apps },
      { kind: "cache", gib: cache },
      { kind: "free", gib: free }
    ])
  }
}

// Running local models with what each holds: what omarchy-models measures it
// holding now, else what it took to load. A model still loading or stopping
// counts only once it has been measured.
function runningModels(models, measured) {
  var all = models || {}
  var now = measured || {}
  var list = []
  for (var id in all) {
    var model = all[id] || {}
    if (["active", "activating", "deactivating"].indexOf(model.unit) < 0) continue
    var gib = typeof now[id] === "number" ? now[id] : (model.unit === "active" && model.observed ? Number(model.observed.ram_used_gib) || 0 : 0)
    if (gib > 0) list.push({ name: model.name || id, gib: gib })
  }
  list.sort(function(a, b) { return b.gib - a.gib })
  return list
}

// /proc/stat's per-CPU jiffies: the aggregate first, then each core.
function parseCpuStat(raw) {
  var rows = String(raw || "").split("\n")
  var cpus = []
  for (var i = 0; i < rows.length; i++) {
    if (!/^cpu\d*\s/.test(rows[i])) continue
    var parts = rows[i].trim().split(/\s+/)
    var total = 0
    for (var j = 1; j < parts.length; j++) total += Number(parts[j]) || 0
    // idle plus iowait: time the core had nothing to run.
    cpus.push({ idle: (Number(parts[4]) || 0) + (Number(parts[5]) || 0), total: total })
  }
  return cpus
}

// Busy fraction (0..1) of each CPU between two reads, aggregate first.
function cpuUsage(previous, next) {
  var before = previous || []
  var after = next || []
  var usage = []
  for (var i = 0; i < after.length; i++) {
    var a = before[i]
    var span = a ? after[i].total - a.total : 0
    usage.push(span > 0 ? Math.max(0, Math.min(1, 1 - (after[i].idle - a.idle) / span)) : 0)
  }
  return usage
}

// The filesystems worth showing from `df -B1 --output=source,fstype,size,used,avail,target`:
// real block devices only, one line per device (btrfs subvolumes and bind
// mounts share their device's space), at its shortest mount point, root first.
function parseDf(raw) {
  var rows = String(raw || "").split("\n")
  var byDevice = {}
  for (var i = 1; i < rows.length; i++) {
    var parts = rows[i].trim().split(/\s+/)
    if (parts.length < 6) continue
    var source = parts[0]
    var target = parts.slice(5).join(" ")
    if (source.indexOf("/dev/") !== 0 || source.indexOf("/dev/loop") === 0) continue
    if (target === "/boot" || target === "/efi" || target.indexOf("/boot/") === 0) continue
    var size = Number(parts[2]) || 0
    var used = Number(parts[3]) || 0
    var avail = Number(parts[4]) || 0
    if (!(size > 0)) continue
    var known = byDevice[source]
    if (known && known.target.length <= target.length) continue
    byDevice[source] = {
      source: source,
      fstype: parts[1],
      target: target,
      size: size / BYTES_PER_GIB,
      used: used / BYTES_PER_GIB,
      free: avail / BYTES_PER_GIB,
      // As df's Use%: of what's usable, leaving out root's reserve.
      fraction: used + avail > 0 ? used / (used + avail) : 0
    }
  }
  var list = Object.keys(byDevice).map(function(key) { return byDevice[key] })
  list.sort(function(a, b) {
    if (a.target === "/") return -1
    if (b.target === "/") return 1
    return a.target < b.target ? -1 : (a.target > b.target ? 1 : 0)
  })
  return list
}

function mountLabel(target, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (target === "/") return t("system.diskSystem", "System")
  if (target === "/home") return t("system.diskHome", "Home")
  var parts = String(target || "").split("/")
  return parts[parts.length - 1] || String(target || "")
}

// Whole GB at ten and above, a tenth below, TB from a thousand GB.
function formatSize(gib, fmt, tr) {
  var f = typeof fmt === "function" ? fmt : function(v, d) { return d === undefined ? String(v) : Number(v).toFixed(d) }
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var value = Math.max(0, Number(gib) || 0)
  if (value >= 1000) return t("system.sizeTB", "%1 TB").replace("%1", f(value / 1024, 1))
  return t("system.sizeGB", "%1 GB").replace("%1", value >= 10 ? f(Math.round(value)) : f(value, 1))
}

// Where the GPU's load can be read, as the panel finds it when it opens:
// "amd <file>" (its busy percent), "idle <file>" (Intel's idle time in ms),
// "nvidia" (nvidia-smi, only when the GPU is awake), or nothing for none.
function gpuSource(raw) {
  var line = String(raw || "").split("\n")[0].trim()
  var match = line.match(/^(amd|idle) (\/sys\/\S+)$/)
  if (match) return { kind: match[1], path: match[2] }
  return line === "nvidia" ? { kind: "nvidia", path: "" } : { kind: "", path: "" }
}

// Busy share between two readings of an idle-time counter: whatever of the
// time between them the GPU wasn't idle. -1 until there are two readings.
function gpuBusyFromIdle(previous, next) {
  if (!previous || !next) return -1
  var elapsed = next.atMs - previous.atMs
  if (!(elapsed > 0)) return -1
  var idle = next.idleMs - previous.idleMs
  return Math.max(0, Math.min(1, 1 - idle / elapsed))
}

if (typeof module !== "undefined") {
  module.exports = {
    gpuSource: gpuSource,
    gpuBusyFromIdle: gpuBusyFromIdle,
    parseMeminfo: parseMeminfo,
    memoryBreakdown: memoryBreakdown,
    runningModels: runningModels,
    parseCpuStat: parseCpuStat,
    cpuUsage: cpuUsage,
    parseDf: parseDf,
    mountLabel: mountLabel,
    formatSize: formatSize
  }
}
