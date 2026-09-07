#!/usr/bin/env bash
# Tailnet share and the gateway key. Sourced; do not run.
#
# The key exists from the first Start: agents launched from the panel always send it, the gateway
# always checks it, and sharing adds nothing but the tailnet route. `share --key <value>` replaces
# it in place; the gateway reads the file on every request, so no restart.
#
# The route is the gateway's own port published on this machine's tailnet address, next to the
# loopback one: `docker run --publish 100.x.y.z:12434:12434`. Nothing else is involved. No
# `tailscale serve` (which refuses a plain user until root names them the operator, and which the
# panel cannot escalate), no polkit, no password, no extra image. WireGuard already encrypts
# everything on the tailnet, so a plain http URL there is as private as the https one serve would
# have minted. Toggling restarts the stateless gateway with or without the second publish; agents
# reconnect on their next request. `tailscale status` is the only tailscale call, and it needs no
# operator.

KEY_FILE="$STATE/gateway.key"
SHARE_MARK="$STATE/share.on"      # present while sharing is wanted; gateway_argv honours it on every start
SHARE_ERROR="$STATE/share.error"  # the last refusal, shown under the toggle; cleared by the next success
ts_bin() { command -v tailscale 2>/dev/null; }

ensure_key() {
  [[ -s $KEY_FILE ]] && return 0
  state_dir; head -c 24 /dev/urandom | base64 | tr -d '/+=\n' | cut -c1-32 >"$KEY_FILE"; rm -f "$STATE/gateway.auth"
}
set_key() {
  [[ ${#1} -ge 16 ]] || { fail "key must be at least 16 characters"; return; }
  state_dir; printf '%s\n' "$1" >"$KEY_FILE"; rm -f "$STATE/gateway.auth"
  # every copy of the old key goes with it: agent launch configs are regenerated at the next launch
  local d; for d in "$STATE"/agents/*/; do [[ ${d%/} == "$STATE/agents/args" ]] || rm -rf "$d"; done
  rm -f "$STATE/share.cache"
  snapshot_write
}

tailnet_self() { # -> {ip,dns,online}; empty ip when tailscale is off. IPv4 first, IPv6 when that is all there is.
  local b; b=$(ts_bin) || { printf '{"ip":"","dns":"","online":false}'; return; }
  "$b" status --json 2>/dev/null | jq -c '
    (.Self.TailscaleIPs // []) as $ips
    | {ip: (($ips | map(select(test("^[0-9.]+$"))) | .[0]) // ($ips | map(select(test(":"))) | .[0]) // ""),
       dns: ((.Self.DNSName // "") | rtrimstr(".")),
       online: ((.Self.Online // false) and ((.BackendState // "Running") == "Running"))}' 2>/dev/null \
    || printf '{"ip":"","dns":"","online":false}'
}
share_wanted() { [[ -f $SHARE_MARK ]]; }
bind_addr() { [[ $1 == *:* ]] && printf '[%s]' "$1" || printf '%s' "$1"; }   # IPv6 literals need brackets
share_publish_argv() { # extra `docker run` words for the gateway while sharing is on; nothing otherwise
  share_wanted || return 0
  local ip; ip=$(tailnet_self | jq -r .ip); [[ -n $ip ]] || return 0
  printf '%s' "$ip" >"$SHARE_MARK"   # the address the gateway was published on, for share_state
  printf '%s\0' --publish "$(bind_addr "$ip"):$PORT:12434"
}

# The key is never part of share_state: the snapshot is the panel's read model and the panel shows
# only non-secret state. The card names the key file; agents read it at launch.
share_state() { # -> {available,active,url,keyFile,error}; read from tailscale and docker each time, never cached
  local self ip dns online active=false url="" err bound; err=$(cat "$SHARE_ERROR" 2>/dev/null || true)
  self=$(tailnet_self); ip=$(jq -r .ip <<<"$self"); dns=$(jq -r .dns <<<"$self"); online=$(jq -r .online <<<"$self")
  if [[ -z $ip ]]; then jq -nc --arg k "$KEY_FILE" --arg e "$err" '{available:false,active:false,url:"",keyFile:$k,error:$e}'; return; fi
  if share_wanted && owned "$GATEWAY" && running "$GATEWAY"; then
    bound=$(cat "$SHARE_MARK" 2>/dev/null || true)
    if [[ -z $bound || $bound == "$ip" ]]; then active=true
    elif [[ -z $err ]]; then err="tailnet address changed; share again"; fi   # the gateway still binds the old one
  fi
  [[ $online == true || -n $err ]] || err="tailscale is not connected"
  url="http://$(bind_addr "${dns:-$ip}"):$PORT"
  jq -nc --argjson a "$active" --arg u "$url" --arg k "$KEY_FILE" --arg e "$err" '{available:true,active:$a,url:$u,keyFile:$k,error:$e}'
}

share_on() { state_dir; : >"$SHARE_MARK"; restart_gateway; }
share_off() { rm -f "$SHARE_MARK"; owned "$GATEWAY" && running "$GATEWAY" && restart_gateway; return 0; }
share_forget() { rm -f "$SHARE_MARK"; }
docker_last_error() { # the last line docker wrote to the log, trimmed to what a card can show
  local l; l=$(grep -i "error\|cannot\|denied\|address" "$LOGFILE" 2>/dev/null | tail -1 | sed 's/^.*Error response from daemon: //; s/^docker: //' | cut -c1-140)
  printf '%s' "${l:-see $LOGFILE}"
}   # for unload: the gateway is about to go, no restart
share_refuse() { # the model is still fine, so this goes under the toggle, not into the ledger's error
  log "share: $1"; state_dir; printf '%s\n' "$1" >"$SHARE_ERROR"; op_done; fail "$1"
}

share_toggle() { # share [--key value]
  if [[ ${1:-} == --key ]]; then set_key "${2:-}"; return; fi
  jq -e '.available' >/dev/null <<<"$(share_state)" || { share_refuse "tailscale is not installed or not logged in"; return; }
  jq -e '.online' >/dev/null <<<"$(tailnet_self)" || { share_refuse "tailscale is not connected"; return; }
  [[ $(jq -r .state "$SNAPSHOT" 2>/dev/null) == ready ]] || { share_refuse "load a model first"; return; }
  if jq -e '.active' >/dev/null <<<"$(share_state)"; then
    op share "" "stopping the tailnet route" 0   # an op, so the card shows the toggle in progress
    share_off || { share_refuse "could not restart the gateway (see $LOGFILE)"; return; }; log "share off"
  else
    op share "" "publishing on the tailnet" 0
    share_on || { rm -f "$SHARE_MARK"; restart_gateway || true; share_refuse "could not publish on the tailnet: $(docker_last_error)"; return; }; log "share on"
  fi
  rm -f "$SHARE_ERROR"; op_done
}
