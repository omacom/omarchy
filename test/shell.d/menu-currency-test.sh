#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu currency lookup test"

qml_fixture_scratch
curl_log="$QML_FIXTURE_TMP/curl.log"
marker="$QML_FIXTURE_TMP/flaky-marker"
cat >"$QML_FIXTURE_TMP/bin/curl" <<STUB
#!/bin/bash
url="\${!#}"
printf '%s\n' "\$url" >>"$curl_log"
case "\${CURL_MODE:-online}" in
  offline) exit 7 ;;
  list-is-array) printf '[]'; exit 0 ;;
  list-is-empty) printf '{}'; exit 0 ;;
  list-is-html) printf '<html>captive portal</html>'; exit 0 ;;
  list-is-null) printf 'null'; exit 0 ;;
  menu)
    case "\$url" in
      *currencies.min.json) printf '{"usd":"","inr":"","btc":"","jpy":"","cad":"","nodate":""}' ;;
      *currencies/usd.min.json) sleep 0.3; printf '{"date":"2026-11-05","usd":{"inr":90}}' ;;
      *currencies/inr.min.json) printf '{"date":"2026-11-05","inr":{"btc":0.0000001111}}' ;;
      *currencies/jpy.min.json) sleep 0.3; printf '{"date":"2026-11-05","jpy":{"usd":0.5}}' ;;
      *currencies/cad.min.json) sleep 0.3; printf '{"date":"2026-11-05","cad":{"usd":0.5}}' ;;
      *currencies/nodate.min.json) printf '{"nodate":{"usd":2}}' ;;
      *) exit 22 ;;
    esac
    exit 0
    ;;
esac
case "\$url" in
  *currencies.min.json) printf '{"usd":"US Dollar","inr":"Indian Rupee","eur":"Euro","btc":"Bitcoin","all":"Albanian Lek","one":"Harmony","ada":"Cardano","sol":"Solana","gbp":"Pound","jpy":"Yen","cad":"Canadian Dollar","aud":"Australian Dollar","chf":"Franc","huge":"Huge","nodate":"No Date","mxn":"Peso"}' ;;
  *jsdelivr*currencies/usd.min.json) printf '{"date"'; exit 28 ;;
  *pages.dev*currencies/usd.min.json) printf '{"date":"2026-11-05","usd":{"usd":1,"inr":90,"eur":0.5,"btc":0.00001}}' ;;
  *currencies/inr.min.json) printf '{"date":"2026-11-05","inr":{"usd":0.0111,"btc":0.0000001111,"eur":0.01}}' ;;
  *currencies/ada.min.json) printf '{"date":"2026-11-05","ada":{"usd":0.5,"sol":0.002}}' ;;
  *currencies/all.min.json) printf '{"date":"2026-11-05","all":{"one":3}}' ;;
  *currencies/gbp.min.json) printf '{"date":"2026-11-05","gbp":{"usd":"1.3","eur":null,"inr":true}}' ;;
  *currencies/jpy.min.json) printf '{"date":"2026-11-05","jpy":"not a table"}' ;;
  *currencies/cad.min.json) printf '["not","a","table"]' ;;
  *currencies/aud.min.json) printf '<html>not json</html>' ;;
  *currencies/huge.min.json) printf '{"date":"2026-11-05","huge":{"usd":1e300}}' ;;
  *currencies/nodate.min.json) printf '{"nodate":{"usd":2}}' ;;
  *currencies/mxn.min.json)
    if [[ -e "$marker" ]]; then exit 22; fi
    touch "$marker"
    printf '{"date":"2026-11-05","mxn":{"usd":0.05}}'
    ;;
  *) exit 22 ;;
esac
STUB
chmod +x "$QML_FIXTURE_TMP/bin/curl"

# One run of the fixture on a fresh lookup, so nothing is cached. The log is
# emptied first, for the request counts that follow to be this run's.
run_steps() {
  local description="$1" steps="$2"
  : >"$curl_log"
  MENU_CURRENCY_STEPS="$steps" run_qml_fixture menu-currency "$description"
}

assert_requests() {
  local pattern="$1" expected="$2" description="$3" count
  count=$(grep -c -- "$pattern" "$curl_log" || true)
  if (( count == expected )); then
    pass "$description"
  else
    fail "$description" "expected $expected requests matching $pattern, saw $count: $(<"$curl_log")"
  fi
}

# Nothing that merely looks like "x to y" may reach the network, on a lookup that
# has yet to load the list, which is when it would.
run_steps "searches stay searches before the list has loaded" '[
  ["zen","",""], ["go to settings","",""], ["save as pdf","",""], ["back to main","",""], ["log in vpn","",""],
  ["add to bar","",""], ["all in one","",""], ["link to one","",""], ["top to one","",""], ["5 cats to dogs","",""],
  ["10 go home","",""], ["5 ada to sol","",""], ["5 all in one","",""], ["100 inr","",""], ["$5","",""], ["100 inr to","",""],
  ["1,25 USD to EUR","",""], ["usd to dogs","",""], ["2+2","",""], ["","",""]
]'
assert_requests '.' 0 "text that names no currency never reaches the network"

CURL_MODE=online run_steps "conversions answer, fall back and cache" '[
  ["$5 to INR","ready","450","5","2026-11-05"],
  ["100 inr to usd","ready","1.11","100"],
  ["USD 2 in eur","ready","1","2"],
  ["usd to inr","ready","90","1"],
  ["usd to usd","ready","1","1"],
  ["0 usd to inr","ready","0","0"],
  ["1.5 usd to eur","ready","0.75","1.5"],
  ["1,00,000 inr to usd","ready","1110","100000"],
  ["5 cats to dogs","",""],
  ["go to settings","",""],
  ["1 usd to inr","ready","90"]
]'
assert_requests 'currencies.min.json' 1 "the currency list is fetched once"
assert_requests 'jsdelivr.*usd.min.json' 1 "usd rates stay cached across queries"
assert_requests 'pages.dev.*usd.min.json' 1 "a failed jsDelivr request falls back to Cloudflare"
assert_requests 'pages.dev.*inr.min.json' 0 "the fallback is not asked when jsDelivr answers"
assert_requests 'cats\|dogs\|settings\|zen' 0 "the search text is never in a request"

run_steps "tiny and enormous amounts are written in plain digits" '[
  ["1 inr to btc","ready","0.0000001111"],
  ["1 usd to btc","ready","0.00001"],
  ["0.001 inr to btc","ready","0.0000000001111","0.001"],
  ["9999999999999999999999 usd to inr","ready","900000000000000000000000","10000000000000000000000"]
]'

run_steps "codes outside our list convert once one side is known, and word pairs need an amount" '[
  ["5 ada to usd","ready","2.5"],
  ["5 ada to sol","ready","0.01"],
  ["all in one","",""],
  ["5 all in one","ready","15"],
  ["ada to usd","",""]
]'

run_steps "a pair with no rate between them stays a search" '[
  ["1 inr to gbp","",""],
  ["1 inr to chf","",""]
]'

run_steps "rates that are not numbers have no answer" '[
  ["1 gbp to usd","",""],
  ["1 gbp to eur","",""],
  ["1 gbp to inr","",""]
]'

run_steps "rate tables that are not tables count as failures" '[
  ["1 jpy to usd","failed",""],
  ["1 cad to usd","failed",""],
  ["1 aud to usd","failed",""]
]'

run_steps "an answer too big for a number has no answer" '[
  ["99999999999999999999 huge to usd","",""]
]'

run_steps "rates with no date still answer" '[
  ["2 nodate to usd","ready","4","2",""]
]'

# Failing and retrying. The cold steps all fail, and within the retry window the
# list is only asked for once.
CURL_MODE=offline run_steps "offline, only text naming two known currencies says it failed" '[
  ["usd to inr","failed",""],
  ["5 usd to inr","failed",""],
  ["log in vpn","",""],
  ["go to settings","",""],
  ["5 cats to dogs","",""],
  ["5 usd to dogs","",""],
  ["5 ada to sol","",""],
  ["eur to gbp","failed",""]
]'
assert_requests 'currencies.min.json' 2 "a failed list is not asked for again within the retry window"

CURL_MODE=offline MENU_CURRENCY_RETRY_MS=1 run_steps "a failed list is asked for again after the retry window" '[
  ["usd to inr","failed",""],
  ["eur to gbp","failed",""]
]'
if (( $(grep -c 'jsdelivr.*currencies.min.json' "$curl_log" || true) >= 2 )); then
  pass "the list is retried once the window has passed"
else
  fail "the list is retried once the window has passed" "$(<"$curl_log")"
fi

for mode in list-is-array list-is-empty list-is-html list-is-null; do
  CURL_MODE=$mode run_steps "a list that is really $mode counts as a failure" '[
    ["usd to inr","failed",""],
    ["go to settings","",""]
  ]'
done

# A failed refresh must not take away the answer that was showing, whose date
# says how old it is. Lifetime 1ms makes every query a refresh.
rm -f "$marker"
MENU_CURRENCY_LIFETIME_MS=1 MENU_CURRENCY_RETRY_MS=1 run_steps "old rates still answer when a refresh fails" '[
  ["1 mxn to usd","ready","0.05"],
  ["2 mxn to usd","ready","0.1"],
  ["3 mxn to usd","ready","0.15"]
]'
if (( $(grep -c 'jsdelivr.*mxn.min.json' "$curl_log" || true) >= 2 )); then
  pass "old rates are refreshed once their lifetime is up"
else
  fail "old rates are refreshed once their lifetime is up" "$(<"$curl_log")"
fi

rm -f "$marker"
run_steps "fresh rates are not fetched again" '[
  ["1 mxn to usd","ready","0.05"],
  ["2 mxn to usd","ready","0.1"],
  ["3 mxn to usd","ready","0.15"]
]'
assert_requests 'jsdelivr.*mxn.min.json' 1 "rates within their lifetime stay cached"
