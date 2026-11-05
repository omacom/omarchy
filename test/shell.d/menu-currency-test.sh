#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu currency lookup test"

qml_fixture_scratch
curl_log="$QML_FIXTURE_TMP/curl.log"
cat >"$QML_FIXTURE_TMP/bin/curl" <<STUB
#!/bin/bash
url="\${!#}"
printf '%s\n' "\$url" >>"$curl_log"
case "\$url" in
  *currencies.min.json) printf '{"usd":"US Dollar","inr":"Indian Rupee","eur":"Euro"}' ;;
  *jsdelivr*currencies/usd.min.json) exit 22 ;;
  *pages.dev*currencies/usd.min.json) printf '{"date":"2026-11-05","usd":{"inr":90,"eur":0.5}}' ;;
  *currencies/inr.min.json) printf '{"date":"2026-11-05","inr":{"usd":0.0111}}' ;;
  *) exit 22 ;;
esac
STUB
chmod +x "$QML_FIXTURE_TMP/bin/curl"

run_qml_fixture menu-currency "the lookup answers conversions, falls back, and leaves searches alone"

assert_requests() {
  local pattern="$1" expected="$2" description="$3" count
  count=$(grep -c -- "$pattern" "$curl_log" || true)
  if (( count == expected )); then
    pass "$description"
  else
    fail "$description" "expected $expected requests matching $pattern, saw $count"
  fi
}

assert_requests 'currencies.min.json' 1 "the currency list is fetched once"
assert_requests 'jsdelivr.*usd.min.json' 1 "usd rates stay cached across queries"
assert_requests 'pages.dev.*usd.min.json' 1 "a failed jsDelivr request falls back to Cloudflare"
assert_requests 'cats\|dogs\|settings\|zen' 0 "text that is no conversion never reaches the network"
