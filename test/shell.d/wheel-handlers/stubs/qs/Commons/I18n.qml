pragma Singleton
import QtQuick

QtObject {
  property string formatLocale: "en-US"
  property bool rightToLeft: false
  function t(key, fallback) { return fallback || key }
  function tn(key, count, fallback) { return fallback || key }
  function formatNumber(value, decimals) { return decimals === undefined ? String(value) : Number(value).toFixed(decimals) }
}
