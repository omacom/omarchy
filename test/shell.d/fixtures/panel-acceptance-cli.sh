#!/bin/bash

# Offline command boundary for the real acceptance script. No compositor or
# Quickshell is launched; QML timing and focus still require guest validation.
hyprctl() {
  printf 'hyprctl %s\n' "$*" >> "$PANEL_TEST_STATE/calls"
  case "$*" in
    '-j layers') printf '%s\n' '{"Virtual-1":{"levels":{"0":[{"namespace":"owe-background"}],"3":[]}}}' ;;
    '-j getoption animations:enabled') jq -cn --argjson enabled "$(cat "$PANEL_TEST_STATE/effective")" '{bool:$enabled}' ;;
    reload)
      local enabled=true
      [[ ! -f $HOME/.local/state/omarchy/toggles/hypr/no-animations.lua ]] || enabled=false
      printf '%s\n' "$enabled" > "$PANEL_TEST_STATE/effective"
      # Model the old refresh completing before the later runtime override.
      printf '%s\n' "$enabled" > "$PANEL_TEST_STATE/style"
      ;;
    'keyword animations:enabled '*) printf '%s\n' "keyword can't work with non-legacy parsers. Use eval." ;;
    'eval hl.config({ animations = { enabled = '* )
      local enabled=false
      [[ $2 != *'enabled = true'* ]] || enabled=true
      printf '%s\n' "$enabled" > "$PANEL_TEST_STATE/effective"
      ;;
    *) return 2 ;;
  esac
}

omarchy-shell() {
  printf 'omarchy-shell %s\n' "$*" >> "$PANEL_TEST_STATE/calls"
  case "$1 $2" in
    'shell listPlugins') printf '%s\n' '[{"id":"acceptance.panel-reopen"}]' ;;
    'shell setPluginEnabled')
      printf '%s\n' '{"changedByFixture":true}' > "$HOME/.config/omarchy/shell.json"
      if [[ $4 == "true" ]]; then
        local entrypoint
        entrypoint=$(jq -r '.entryPoints.overlay' "$HOME/.config/omarchy/plugins/acceptance.panel-reopen/manifest.json")
        [[ -f $HOME/.config/omarchy/plugins/acceptance.panel-reopen/$entrypoint ]] || return 1
        printf '%s\n' "$entrypoint" >> "$PANEL_TEST_STATE/entrypoints"
      fi
      printf 'ok\n'
      ;;
    'shell summon')
      printf 'ready\n' > "$PANEL_TEST_STATE/phase"
      jq -r '.escapeDelay == 110' <<< "$4" > "$PANEL_TEST_STATE/late"
      ;;
    'shell hide') printf 'idle\n' > "$PANEL_TEST_STATE/phase" ;;
    'shell rescanPlugins'|'shell reloadConfig') ;;
    'acceptance.panel-reopen begin') printf 'done\n' > "$PANEL_TEST_STATE/phase"; printf 'true\n' ;;
    'acceptance.panel-reopen refreshStyle')
      cp "$PANEL_TEST_STATE/effective" "$PANEL_TEST_STATE/style"
      printf 'true\n'
      ;;
    'acceptance.panel-reopen state')
      local fade=0
      [[ $(cat "$PANEL_TEST_STATE/style") != "true" ]] || fade=140
      jq -cn --arg phase "$(cat "$PANEL_TEST_STATE/phase")" --argjson fade "$fade" --argjson late "$(cat "$PANEL_TEST_STATE/late")" \
        '{phase:$phase,error:"",activationLost:true,activationGained:true,windowActiveAtEscape:true,fadeDuration:$fade,retainedMapping:true,escapeCount:1,targetFocusedAtEscape:true,mapped:false,open:false,primedAtEscape:$late}'
      ;;
    *) return 2 ;;
  esac
}

omarchy-toggle-animations() {
  [[ $1 == "on" ]] || return 2
  command rm -f "$HOME/.local/state/omarchy/toggles/hypr/no-animations.lua"
  hyprctl reload
}

cp() {
  if [[ ${PANEL_TEST_FAULT:-} == "restore-config" && ${!#} == "$HOME/.config/omarchy/shell.json" && $1 != "$HOME/.config/omarchy/shell.json" ]]; then
    printf 'fault restore-config\n' >> "$PANEL_TEST_STATE/calls"
    return 1
  fi
  command cp "$@"
}

rm() {
  if [[ ${PANEL_TEST_FAULT:-} == "remove-plugin" && " $* " == *" $HOME/.config/omarchy/plugins/acceptance.panel-reopen "* ]]; then
    printf 'fault remove-plugin\n' >> "$PANEL_TEST_STATE/calls"
    return 1
  fi
  command rm "$@"
}

mkdir() {
  if [[ ${PANEL_TEST_FAULT:-} == "restore-animation-directory" && ${!#} == "$HOME/.local/state/omarchy/toggles/hypr" ]]; then
    printf 'fault restore-animation-directory\n' >> "$PANEL_TEST_STATE/calls"
    return 1
  fi
  command mkdir "$@"
}

export -f hyprctl omarchy-shell omarchy-toggle-animations cp rm mkdir
