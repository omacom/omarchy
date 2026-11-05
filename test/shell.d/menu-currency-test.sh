#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const currency = requireFromRoot('shell/plugins/menu/Currency.js')

const conversions = [
  ['INR 100 to USD', 100, 'inr', 'usd'],
  ['$5 to INR', 5, 'usd', 'inr'],
  ['5$ to inr', 5, 'usd', 'inr'],
  ['100inr to usd', 100, 'inr', 'usd'],
  ['inr100 to usd', 100, 'inr', 'usd'],
  ['₹100 in $', 100, 'inr', 'usd'],
  ['€20 to £', 20, 'eur', 'gbp'],
  ['100 rupees to dollars', 100, 'inr', 'usd'],
  ['rs. 500 in usd', 500, 'inr', 'usd'],
  ['1,000.50 JPY into GBP', 1000.5, 'jpy', 'gbp'],
  ['convert 50 usd to eur', 50, 'usd', 'eur'],
  ['how much is $5 in inr?', 5, 'usd', 'inr'],
  ["what's 10 euros in yen", 10, 'eur', 'jpy'],
  ['5 usd inr', 5, 'usd', 'inr'],
  ['usd to inr', 1, 'usd', 'inr'],
  ['5 usd = eur', 5, 'usd', 'eur'],
  ['5 usd -> eur', 5, 'usd', 'eur'],
  ['5usd→eur', 5, 'usd', 'eur'],
  ['0.5 btc to usd', 0.5, 'btc', 'usd'],
  ['A$10 to usd', 10, 'aud', 'usd']
]
for (const [text, amount, from, to] of conversions) {
  assertDeepEqual(currency.parse(text), { amount, from, to }, `currency reads "${text}"`)
}

for (const text of ['zen', '', '2+3', '100', '100 inr', '$5', '100 inr to', 'to usd', '7-zip', 'open file', '5 $$ to inr', '$(id) to usd', '5 usd to $(id)']) {
  assertEqual(currency.parse(text), null, `currency leaves "${text}" to search`)
}

assertEqual(currency.format(1.0578803), '1.06', 'currency rounds money to two places')
assertEqual(currency.format(100), '100', 'currency drops empty decimals')
assertEqual(currency.format(0.0105788), '0.01058', 'currency keeps the digits of a small result')
assertEqual(currency.format(0), '0', 'currency formats zero')
JS

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
