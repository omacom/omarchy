// How the session's regional formats (Setup > Region > Formats, or the LANG
// the installer wrote) reach the shell's dates and units. The language file
// picks the language; the session's locale only picks the region within it,
// so en_AU dates follow Australia while a stale LANG left from another
// language is ignored.

// The locale a category names, as a BCP 47 tag: the first of LC_ALL, the
// category (LC_TIME, LC_MEASUREMENT) and LANG that is set, with the encoding
// and modifier dropped. "" for C, POSIX or nothing set.
function sessionLocale(lcAll, lcCategory, lang) {
  var raw = String(lcAll || lcCategory || lang || "")
  var name = raw.split(/[.@]/)[0]
  if (!/^[a-z]{2,3}(_[A-Za-z]{2,3})?$/.test(name)) return ""
  return name.replace("_", "-")
}

// The session's locale when it writes the shell's language, else the
// registry's. Chinese must match exactly, since zh-CN and zh-TW write
// different scripts.
function pick(registryLocale, session) {
  if (!session) return registryLocale
  var language = registryLocale.split("-")[0]
  if (session.split("-")[0] !== language) return registryLocale
  if (language === "zh" && session !== registryLocale) return registryLocale
  return session
}

// Whether a locale's long date format ("dddd, d MMMM yyyy") writes the day
// before the month. The long form rather than the short one, which is ISO
// order in some regions that write the day first (en-ZA: yyyy/MM/dd).
function dayFirst(longFormat) {
  var format = String(longFormat || "").replace(/'[^']*'/g, "").replace(/d{3,}/g, "")
  var day = format.indexOf("d")
  var month = format.indexOf("M")
  return day >= 0 && month >= 0 && day < month
}

// An English month-first pattern ("MMMM d", "ddd MMM d") turned day first
// ("d MMMM", "ddd d MMM") when the region writes the day first.
function orderDayMonth(pattern, isDayFirst) {
  if (!isDayFirst) return pattern
  return String(pattern).replace(/(M{3,4}) (d{1,2})(?!d)/, "$2 $1")
}

if (typeof module !== "undefined") {
  module.exports = { sessionLocale: sessionLocale, pick: pick, dayFirst: dayFirst, orderDayMonth: orderDayMonth }
}
