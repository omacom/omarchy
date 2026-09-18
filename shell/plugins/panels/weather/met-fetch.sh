#!/bin/bash
# Fetch MET Norway Locationforecast for one coordinate pair with client-side
# caching: at most one network request per 30 minutes, If-Modified-Since
# revalidation, and Expires honoured. Prints a one-line JSON status to stdout.
#
# Usage: met-fetch.sh <lat> <lon> <cacheDir>
# Exit 0 when usable cached data exists (fresh, throttled, ok, not-modified);
# exit 1 on network/HTTP errors with no usable cache update.
set -u

USER_AGENT="omarchy-weather/1.0 https://github.com/omacom/omarchy"
MIN_INTERVAL=1800

lat_raw="${1:-}"
lon_raw="${2:-}"
cache_dir="${3:-}"
if [[ -z "$lat_raw" || -z "$lon_raw" || -z "$cache_dir" ]]; then
  echo '{"status":"error","reason":"usage: met-fetch.sh <lat> <lon> <cacheDir>"}'
  exit 1
fi

# At most 4 decimals, matching the API guidance.
if ! lat=$(printf "%.4f" "$lat_raw" 2>/dev/null) || ! lon=$(printf "%.4f" "$lon_raw" 2>/dev/null); then
  echo '{"status":"error","reason":"invalid coordinates"}'
  exit 1
fi

mkdir -p "$cache_dir" || {
  echo '{"status":"error","reason":"cannot create cache dir"}'
  exit 1
}

meta="$cache_dir/meta"
body="$cache_dir/body.json"
headers="$cache_dir/headers.txt"

last_fetch=""
expires=""
last_modified=""
meta_lat=""
meta_lon=""
if [[ -f "$meta" ]]; then
  # shellcheck disable=SC1090
  source "$meta" 2>/dev/null || true
fi

now=$(date +%s)
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf "%s" "$s"
}

if [[ "$meta_lat" == "$lat" && "$meta_lon" == "$lon" && -f "$body" ]]; then
  if [[ -n "$last_fetch" && $((now - last_fetch)) -lt $MIN_INTERVAL ]]; then
    echo "{\"status\":\"throttled\",\"last_fetch\":$last_fetch}"
    exit 0
  fi
  if [[ -n "$expires" && "$now" -lt "$expires" ]]; then
    echo "{\"status\":\"fresh\",\"expires\":$expires}"
    exit 0
  fi
fi

if ! command -v curl >/dev/null 2>&1; then
  echo '{"status":"error","reason":"curl not found"}'
  exit 1
fi

url="https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=${lat}&lon=${lon}"
tmp_body="${body}.tmp"
tmp_headers="${headers}.tmp"
curl_args=(-sS --max-time 15 -D "$tmp_headers" -o "$tmp_body" -H "User-Agent: $USER_AGENT")
if [[ "$meta_lat" == "$lat" && "$meta_lon" == "$lon" && -n "$last_modified" && -f "$body" ]]; then
  curl_args+=(-H "If-Modified-Since: $last_modified")
fi
http_code=$(curl "${curl_args[@]}" -w "%{http_code}" "$url" 2>/dev/null) || http_code="000"

finish_meta() {
  # $1 = expires epoch or empty, $2 = last-modified string or empty
  {
    echo "meta_lat=\"$lat\""
    echo "meta_lon=\"$lon\""
    echo "last_fetch=\"$now\""
    echo "expires=\"$1\""
    echo "last_modified=\"$(json_escape "$2")\""
  } >"$meta"
}

parse_header() {
  grep -i -m1 "^$1:" "$tmp_headers" 2>/dev/null | cut -d: -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '\r'
}

case "$http_code" in
  200)
    new_expires=""
    exp_str=$(parse_header "Expires")
    if [[ -n "$exp_str" ]]; then
      new_expires=$(date -d "$exp_str" +%s 2>/dev/null || true)
    fi
    new_modified=$(parse_header "Last-Modified")
    mv -f "$tmp_body" "$body"
    mv -f "$tmp_headers" "$headers"
    finish_meta "$new_expires" "$new_modified"
    echo "{\"status\":\"ok\",\"http_code\":200,\"expires\":\"$new_expires\"}"
    exit 0
    ;;
  304)
    rm -f "$tmp_body" "$tmp_headers"
    # Revalidation counts as a check: back off so a tight refresh loop
    # cannot poll the API.
    finish_meta "$expires" "$last_modified"
    echo '{"status":"not-modified","http_code":304}'
    exit 0
    ;;
  *)
    rm -f "$tmp_body" "$tmp_headers"
    if [[ -f "$body" ]]; then
      echo "{\"status\":\"error\",\"http_code\":\"$(json_escape "$http_code")\",\"cached\":true}"
    else
      echo "{\"status\":\"error\",\"http_code\":\"$(json_escape "$http_code")\",\"cached\":false}"
    fi
    exit 1
    ;;
esac
