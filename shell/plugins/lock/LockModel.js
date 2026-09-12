function blankDisplayEnabled(idleConfig) {
  return !idleConfig || idleConfig.blankDisplay !== false
}

function shouldBlankDisplay(enabled, lockRequested, authenticatingPassword) {
  return Boolean(enabled && lockRequested && !authenticatingPassword)
}

if (typeof module !== "undefined") {
  module.exports = {
    blankDisplayEnabled: blankDisplayEnabled,
    shouldBlankDisplay: shouldBlankDisplay
  }
}
