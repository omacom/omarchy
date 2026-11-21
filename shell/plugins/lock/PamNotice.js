// pam_faillock's preauth check reports a lockout as plain conversation
// messages ("The account is locked due to 10 failed logins.", "(2 minutes
// left to unlock)") before the password prompt, and the stack then refuses
// even the right password. Keep those messages so the refusal can say why,
// instead of "Authentication failed", which reads as a typo.

// Append a PAM message that asked for no response to the notice kept for the
// current attempt. Prompts carry the input request, not information.
function append(notice, message, responseRequired) {
  if (responseRequired) return notice
  var text = String(message || "").replace(/^\s+|\s+$/g, "")
  if (text.length === 0) return notice
  return notice.length > 0 ? notice + " " + text : text
}

// What the field shows after a refused password: PAM's own explanation when
// it gave one, the caller's generic failure text otherwise.
function failureText(notice, fallback) {
  if (notice.length > 0) return notice
  return fallback
}

if (typeof module !== "undefined") {
  module.exports = {
    append: append,
    failureText: failureText
  }
}
