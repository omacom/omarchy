.pragma library

function parse(raw) {
  try {
    if (raw.length > 65536) return null
    var scene = JSON.parse(raw)
    if (scene.version !== 1 || !Number.isFinite(scene.width) || !Number.isFinite(scene.height)
        || scene.width < 1 || scene.width > 8192 || scene.height < 1 || scene.height > 8192
        || !Array.isArray(scene.lights) || !scene.lights.length || scene.lights.length > 32) return null
    for (var light of scene.lights) {
      if (!light || ["claude", "codex", "combined"].indexOf(light.channel) < 0
          || typeof light.path !== "string" || light.path.length > 2048
          || !/^[MmLlHhVvCcSsQqTtAaZz0-9., eE+\-]+$/.test(light.path)
          || !/^#[0-9a-fA-F]{6}$/.test(light.color)
          || !Number.isFinite(light.width) || light.width < 0.5 || light.width > 12) return null
    }
    return scene
  } catch (_) { return null }
}

function level(value) {
  return typeof value === "number" && Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : 0
}
