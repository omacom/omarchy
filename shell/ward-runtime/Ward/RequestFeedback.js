function linkError(status) {
  switch (status) {
  case "denied": return "Browser access is not approved. Review plugin access."
  case "rate_limited": return "Links are being opened too quickly. Try again in a moment."
  case "busy": return "A link is already opening. Try again shortly."
  case "invalid": return "This link is not a valid HTTP or HTTPS address."
  case "failed": return "The browser launch failed. Check your default browser."
  default: return "Browser launch could not be confirmed. Check the browser before retrying."
  }
}

function placement(bar, gap, defaultSize) {
  var position = bar ? bar.position : "top"
  var size = bar ? (bar.visible ? bar.size : 0) : defaultSize
  return {
    top: gap + (position === "top" ? size : 0),
    right: gap + (position === "right" ? size : 0)
  }
}
