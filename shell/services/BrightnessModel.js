// omarchy-brightness-display's steps for the brightness keys: 1% at or below
// 5%, otherwise 5%, kept between 1% and 100%.
function brightnessKeyTarget(action, current) {
  if (action === "raise") return Math.min(current < 5 ? current + 1 : current + 5, 100)
  return Math.max(current <= 5 ? current - 1 : current - 5, 1)
}

if (typeof module !== "undefined") {
  module.exports = {
    brightnessKeyTarget: brightnessKeyTarget
  }
}
