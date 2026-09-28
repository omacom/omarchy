pragma Singleton
import QtQuick

// Spells dates for the whole shell. Day and month names are English unless
// shell.json names a top-level "locale" ("fr_FR", "de_DE", ...). Widgets go
// through here rather than Qt.formatDateTime, which always formats in the C
// locale whatever the session's language.
QtObject {
  id: root

  property string localeName: "en_US"
  readonly property var locale: Qt.locale(localeName)

  // Many languages write day and month names in lowercase; a label that
  // starts with one still starts with a capital, as it does in English.
  function capitalized(text) {
    text = String(text || "")
    return text.charAt(0).toUpperCase() + text.slice(1)
  }

  function format(date, pattern) {
    return capitalized(date.toLocaleString(locale, pattern))
  }

  function dayName(weekday, form) {
    return capitalized(locale.dayName(weekday, form))
  }
}
