#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command lua
require_command python3

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# Loads Omarchy's window rules against a fake Hyprland and prints every rule
# in the order Hyprland would hold them, as JSON lines.
OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_dir" XDG_STATE_HOME="$test_dir/state" lua - >"$test_dir/rules.jsonl" <<'LUA' || fail "window rules load" "$(cat "$test_dir/rules.jsonl")"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local order, named = {}, {}

local function noop()
  return setmetatable({}, { __index = function() return noop end, __call = noop })
end

hl = setmetatable({
  window_rule = function(rule)
    if rule.name and named[rule.name] then
      order[named[rule.name]] = rule
      return
    end
    table.insert(order, rule)
    if rule.name then
      named[rule.name] = #order
    end
  end,
  get_monitors = function() return {} end,
  get_active_monitor = function() return nil end,
}, { __index = function() return noop end })

local function encode(value)
  if type(value) == "table" then
    local items = {}
    if #value > 0 then
      for _, item in ipairs(value) do
        table.insert(items, encode(item))
      end
      return "[" .. table.concat(items, ",") .. "]"
    end
    for key, item in pairs(value) do
      table.insert(items, string.format("%q", key) .. ":" .. encode(item))
    end
    return "{" .. table.concat(items, ",") .. "}"
  elseif type(value) == "string" then
    return string.format("%q", value)
  end
  return tostring(value)
end

require("default.hypr.helpers")
require("default.hypr.windows")

for _, rule in ipairs(order) do
  print(encode(rule))
end
LUA

# Plays Hyprland's static rules for a window: every rule in order, then, when
# tags changed, the rules that match on tags again, in order. Class and title
# patterns match anywhere in the string, which matches more windows than
# Hyprland's own matching and so can only make this test stricter.
effective() {
  python3 - "$test_dir/rules.jsonl" "$1" "$2" <<'PY'
import json, re, sys

rules = [json.loads(line) for line in open(sys.argv[1])]
window = {"class": sys.argv[2], "title": sys.argv[3], "tags": set()}

def matches(rule):
    for key, pattern in rule.get("match", {}).items():
        if key == "tag":
            if pattern not in window["tags"]:
                return False
        elif key in ("class", "title"):
            if not re.search(pattern, window[key]):
                return False
        else:
            return False
    return True

effects = {}

def apply(only_tags):
    changed = False
    for rule in rules:
        if only_tags and "tag" not in rule.get("match", {}):
            continue
        if not matches(rule):
            continue
        for key, value in rule.items():
            if key in ("match", "name"):
                continue
            if key == "tag":
                tag = value.lstrip("+-")
                before = set(window["tags"])
                window["tags"].discard(tag) if value.startswith("-") else window["tags"].add(tag)
                changed |= before != window["tags"]
            else:
                effects[key] = value
    return changed

if apply(False):
    apply(True)
print(json.dumps({key: effects.get(key) for key in ("pin", "border_size", "border_color", "no_initial_focus", "workspace")}, sort_keys=True))
PY
}

expected='{"border_color": "rgba(ff8a00ff) rgba(ffc266ff) 45deg", "border_size": 3, "no_initial_focus": true, "pin": false, "workspace": "10 silent"}'

for title in "Picture-in-Picture" "Picture in picture" "Meet - hostile" "omarchy.org is sharing your screen" "Plain page"; do
  for class in agent-1.chromium agent-2.firefox agent-3; do
    output=$(effective "$class" "$title")
    [[ $output == "$expected" ]] || fail "an agent window titled \"$title\" keeps the agent markings ($class)" "$output"
  done
done
pass "agent windows stay unpinned, outlined, unfocused and on the seat whatever title they pick"

output=$(effective chromium "Picture-in-Picture")
[[ $output == *'"pin": true'* ]] || fail "the user's own picture-in-picture windows still pin" "$output"
pass "the user's own picture-in-picture windows still pin"
