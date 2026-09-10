#!/bin/bash

# The reader uses fzf's preview and input handling, as the package pickers do.
set -euo pipefail

index_layout='right,65%,wrap-word,border-left,<60(down,60%,border-top)'
read_layout='default,up,99%,wrap-word,border-bottom'
reader='bash "$OMARCHY_PATH/default/omarchy/doctrine-reader.sh"'

website() {
  local number=$1 title slug
  printf 'https://omarchy.org/doctrine/'
  if (( number <= 10 )); then
    title=$(sed -n 's/^## //p' "$OMARCHY_PATH/default/omarchy/doctrine.md" | sed -n "${number}p")
    slug=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g; s/ /-/g')
    printf '#%s' "$slug"
  fi
}

render() {
  local number=$1 width=${FZF_PREVIEW_COLUMNS:-80}
  if (( width > 74 )); then
    width=74
  elif (( width < 10 )); then
    width=10
  fi
  if (( number == 11 )); then
    printf '\033[1mThe Omarchy Doctrine\033[0m\nBy DHH\n\n'
  else
    printf 'PRINCIPLE %02d / 10\n\n' "$number"
  fi
  awk -v number="$number" '
    /^## / {
      section++
      sub(/^## /, "")
      if (number == 11 || section == number) printf "\033[1m%s\033[0m\n", $0
      next
    }
    number == 11 || section == number { print }
  ' "$OMARCHY_PATH/default/omarchy/doctrine.md" | fmt -w "$width"
  printf '\n%s\n' "$(website "$number")"
}

index_view() {
  echo index > "$OMARCHY_DOCTRINE_STATE/mode"
  printf 'change-preview-window(%s)+refresh-preview' "$index_layout"
}

read_view() {
  echo read > "$OMARCHY_DOCTRINE_STATE/mode"
  printf 'change-preview-window(%s)+refresh-preview+preview-top' "$read_layout"
}

action() {
  local event=$1 number=${2:-1} mode target
  mode=$(cat "$OMARCHY_DOCTRINE_STATE/mode")
  case "$event" in
    read) read_view ;;
    index)
      index_view
      if [[ -f $OMARCHY_DOCTRINE_STATE/previous ]]; then
        if (( number == 11 )); then
          printf '+pos(%s)' "$(cat "$OMARCHY_DOCTRINE_STATE/previous")"
        fi
        rm "$OMARCHY_DOCTRINE_STATE/previous"
      fi
      ;;
    back)
      if [[ $mode == "index" ]]; then
        printf accept
      else
        action index "$number"
      fi
      ;;
    full)
      if (( number != 11 )); then
        echo "$number" > "$OMARCHY_DOCTRINE_STATE/previous"
      fi
      printf 'pos(11)+'
      read_view
      ;;
    up | down)
      if [[ $mode == "index" ]]; then
        printf '%s' "$event"
      else
        printf 'preview-%s' "$event"
      fi
      ;;
    space)
      if [[ $mode == "index" ]]; then
        read_view
      else
        printf preview-page-down
      fi
      ;;
    page-up | page-down)
      if [[ $mode == "index" ]]; then
        printf '%s' "$event"
      else
        printf 'preview-%s' "$event"
      fi
      ;;
    previous | next)
      if (( number == 11 )); then
        number=$(cat "$OMARCHY_DOCTRINE_STATE/previous" 2>/dev/null || echo 1)
      fi
      if [[ $event == "next" ]]; then
        target=$((number % 10 + 1))
      else
        target=$(((number + 8) % 10 + 1))
      fi
      printf 'pos(%s)' "$target"
      ;;
    home | end)
      if [[ $mode == "index" ]]; then
        if [[ $event == "home" ]]; then printf 'pos(1)'; else printf 'pos(10)'; fi
      else
        if [[ $event == "home" ]]; then printf preview-top; else printf preview-bottom; fi
      fi
      ;;
    web)
      if omarchy-launch-browser "$(website "$number")" >/dev/null 2>&1; then
        printf 'change-preview-label(Opened in your browser)'
      else
        printf 'change-preview-label(Could not open your browser)'
      fi
      ;;
    header)
      case "${FZF_CLICK_HEADER_WORD:-}" in
        Index) action index "$number" ;;
        Full) action full "$number" ;;
        Website) action web "$number" ;;
      esac
      ;;
    footer)
      if [[ ${FZF_CLICK_FOOTER_LINE:-0} == "1" ]]; then
        action web "$number"
      fi
      ;;
  esac
}

start() {
  local initial=${1:-0} status=0 key event
  OMARCHY_DOCTRINE_STATE=$(mktemp -d)
  export OMARCHY_DOCTRINE_STATE
  trap 'rm -rf "$OMARCHY_DOCTRINE_STATE"' EXIT
  echo index > "$OMARCHY_DOCTRINE_STATE/mode"
  local bindings=(
    --bind "enter:transform($reader action read {1}),double-click:transform($reader action read {1})"
    --bind "esc:transform($reader action back {1}),q:accept"
    --bind "f:transform($reader action full {1}),w:transform($reader action web {1})"
    --bind "click-header:transform($reader action header {1}),click-footer:transform($reader action footer {1})"
    --bind "pgdn:transform($reader action page-down {1}),pgup:transform($reader action page-up {1}),space:transform($reader action space {1})"
    --bind "focus:change-preview-label(Doctrine)+refresh-preview"
  )
  for key in up k down j left h right l home end; do
    case "$key" in
      up | k) event=up ;;
      down | j) event=down ;;
      left | h) event=previous ;;
      right | l) event=next ;;
      *) event=$key ;;
    esac
    bindings+=(--bind "$key:transform($reader action $event {1})")
  done
  for key in {1..9}; do bindings+=(--bind "$key:pos($key)"); done
  bindings+=(--bind '0:pos(10)')
  if (( initial > 0 )); then
    bindings+=(--bind "start:pos($initial)+transform($reader action read $initial)")
  fi
  {
    sed -n 's/^## //p' "$OMARCHY_PATH/default/omarchy/doctrine.md" | awk '{ printf "%02d  %s\n", NR, $0 }'
    printf '11  Read the full doctrine\n'
  } | fzf --with-shell='bash -c' --no-sort --no-input --info=hidden --layout=reverse \
    --border=rounded --padding=1,2 --ansi --cycle \
    --header=$'THE OMARCHY DOCTRINE · By DHH\n\nIndex    Full    Website' --header-border=bottom \
    --footer=$'https://omarchy.org/doctrine/\n↑↓ move · Enter read · f full · w web\n←→ switch · Esc index · q quit' \
    --footer-border=top --preview "$reader preview {1}" --preview-window "$index_layout" \
    --color "border:${BORDER_FOREGROUND:-4},pointer:${BORDER_FOREGROUND:-4},hl:${BORDER_FOREGROUND:-4},hl+:${BORDER_FOREGROUND:-4}" \
    "${bindings[@]}" >/dev/null || status=$?
  return "$status"
}

case "${1:-}" in
  start) start "${2:-0}" ;;
  preview) render "$((10#${2:-01}))" ;;
  url) website "$2" ;;
  action) action "$2" "$((10#${3:-01}))" ;;
esac
