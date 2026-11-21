function claimCurrent(pending, claim, currentManifest, currentUrl, enabled) {
  return Boolean(
    pending && claim && pending === claim
    && enabled
    && currentManifest === claim.manifest
    && currentUrl === claim.url
  )
}

if (typeof module !== "undefined") {
  module.exports = { claimCurrent: claimCurrent }
}
