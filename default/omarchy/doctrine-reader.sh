#!/bin/bash

# The reader uses fzf's preview and input handling, as the package pickers do.
set -euo pipefail

index_layout='right,60%,wrap-word,border-left,<60(down,60%,border-top)'
read_layout='default,up,99%,wrap-word,border-bottom'
doctrine_url="https://omarchy.org/doctrine/"
reader='bash "$OMARCHY_PATH/default/omarchy/doctrine-reader.sh"'

website() {
  local number=$1 title slug
  printf '%s' "$doctrine_url"
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
}

header() {
  local number=$1 mode
  mode=$(cat "$OMARCHY_DOCTRINE_STATE/mode")
  if [[ $mode == "index" ]]; then
    printf '\033[1mOMARCHY DOCTRINE\033[0m\033[2m · DHH\033[0m\n\n'
    printf '\033[1;7m[ Index ]\033[0m   [ Full ]   [ Website ↗ ]'
  elif (( number == 11 )); then
    printf '[‹ Back ]   \033[1;7m[ Full ]\033[0m   [ Website ↗ ]'
  else
    printf '[‹ Back ]   [ Full ]   [ Website ↗ ]'
  fi
}

link_label() {
  if (( $1 == 11 )); then
    printf 'Read the doctrine online ↗'
  else
    printf 'Read this principle online ↗'
  fi
}

footer() {
  local number=$1 mode
  mode=$(cat "$OMARCHY_DOCTRINE_STATE/mode")
  printf '\033]8;;%s\033\\\033[4m%s\033[0m\033]8;;\033\\\n' "$(website "$number")" "$(link_label "$number")"
  printf '\033[2m'
  if [[ $mode == "index" ]]; then
    printf '↑↓ Choose · Enter Read · f Full\nEsc/q Exit · w Website'
  elif (( number == 11 )); then
    printf '↑↓ Scroll · PgUp/PgDn Page\nEsc Back · q Exit · w Website'
  else
    printf '↑↓ Principles · PgUp/PgDn/Space Scroll\nEsc Back · q Exit · f Full · w Website'
  fi
  printf '\033[0m'
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
    read)
      if (( number == 11 )); then
        action full "$number"
      else
        read_view
      fi
      ;;
    focus)
      if (( number <= 10 )); then
        echo "$number" > "$OMARCHY_DOCTRINE_STATE/focused"
      fi
      ;;
    index)
      index_view
      if [[ -f $OMARCHY_DOCTRINE_STATE/previous ]]; then
        if (( number == 11 )); then
          printf '+pos(%s)' "$(cat "$OMARCHY_DOCTRINE_STATE/previous")"
        fi
        rm -f "$OMARCHY_DOCTRINE_STATE/previous" "$OMARCHY_DOCTRINE_STATE/previous-mode"
      fi
      ;;
    back)
      if [[ $mode == "index" ]]; then
        printf accept
      elif (( number == 11 )) && [[ -f $OMARCHY_DOCTRINE_STATE/previous ]]; then
        target=$(cat "$OMARCHY_DOCTRINE_STATE/previous")
        if [[ $(cat "$OMARCHY_DOCTRINE_STATE/previous-mode") == "read" ]]; then
          read_view
        else
          index_view
        fi
        printf '+pos(%s)' "$target"
        rm "$OMARCHY_DOCTRINE_STATE/previous" "$OMARCHY_DOCTRINE_STATE/previous-mode"
      else
        action index "$number"
      fi
      ;;
    full)
      if (( number != 11 )); then
        echo "$number" > "$OMARCHY_DOCTRINE_STATE/previous"
        echo "$mode" > "$OMARCHY_DOCTRINE_STATE/previous-mode"
      elif [[ ! -f $OMARCHY_DOCTRINE_STATE/previous ]]; then
        cat "$OMARCHY_DOCTRINE_STATE/focused" > "$OMARCHY_DOCTRINE_STATE/previous"
        echo "$mode" > "$OMARCHY_DOCTRINE_STATE/previous-mode"
      fi
      printf 'pos(11)+'
      read_view
      ;;
    up | down)
      if [[ $mode == "index" ]]; then
        printf '%s' "$event"
      elif (( number == 11 )); then
        printf 'preview-%s' "$event"
      elif [[ $event == "up" ]]; then
        action previous "$number"
      else
        action next "$number"
      fi
      ;;
    space)
      if [[ $mode == "index" ]]; then
        action read "$number"
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
      # Include each button's brackets and padding in its click target.
      local button_line=1
      if [[ $mode == "index" ]]; then button_line=3; fi
      if (( ${FZF_CLICK_HEADER_LINE:-0} == button_line )); then
        local column=${FZF_CLICK_HEADER_COLUMN:-0}
        if (( column >= 1 && column <= 9 )); then
          if [[ $mode == "index" ]]; then
            action index "$number"
          else
            action back "$number"
          fi
        elif (( column >= 13 && column <= 20 )); then
          action full "$number"
        elif (( column >= 24 && column <= 36 )); then
          action web "$number"
        fi
      fi
      ;;
    footer)
      local label
      label=$(link_label "$number")
      if (( ${FZF_CLICK_FOOTER_LINE:-0} == 1 && ${FZF_CLICK_FOOTER_COLUMN:-0} >= 1 && ${FZF_CLICK_FOOTER_COLUMN:-0} <= ${#label} )); then
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
  echo 1 > "$OMARCHY_DOCTRINE_STATE/focused"
  local update_controls="transform-header($reader header {1})+transform-footer($reader footer {1})"
  local bindings=(
    --bind "enter:transform($reader action read {1})+$update_controls,double-click:transform($reader action read {1})+$update_controls"
    --bind "esc:transform($reader action back {1})+$update_controls,q:accept"
    --bind "f:transform($reader action full {1})+$update_controls,w:transform($reader action web {1})"
    --bind "click-header:transform($reader action header {1})+$update_controls,click-footer:transform($reader action footer {1})"
    --bind "pgdn:transform($reader action page-down {1}),pgup:transform($reader action page-up {1}),space:transform($reader action space {1})+$update_controls"
    --bind "focus:transform($reader action focus {1})+change-preview-label()+refresh-preview+preview-top+$update_controls"
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
    bindings+=(--bind "start:pos($initial)+transform($reader action read $initial)+$update_controls")
  fi
  {
    local number=0 title
    while IFS= read -r title; do
      (( number += 1 ))
      printf '%02d\t%02d  %s\0' "$number" "$number" "$title"
    done < <(sed -n 's/^## //p' "$OMARCHY_PATH/default/omarchy/doctrine.md")
    # The internal identifier is hidden; the full text is a separate action.
    printf '11\t\n    Read the full doctrine\0'
  } | fzf --with-shell='bash -c' --no-sort --no-input --info=hidden --layout=reverse \
    --border=rounded --padding=1,2 --ansi --cycle --read0 --delimiter=$'\t' --with-nth=2.. \
    --header="$(header 1)" --header-border=bottom \
    --footer="$(footer 1)" \
    --footer-border=top --preview "$reader preview {1}" --preview-window "$index_layout" \
    --color "border:${BORDER_FOREGROUND:-4},pointer:${BORDER_FOREGROUND:-4},hl:${BORDER_FOREGROUND:-4},hl+:${BORDER_FOREGROUND:-4}" \
    "${bindings[@]}" >/dev/null || status=$?
  return "$status"
}

case "${1:-}" in
  start) start "${2:-0}" ;;
  footer) footer "$((10#${2:-01}))" ;;
  header) header "$((10#${2:-01}))" ;;
  preview) render "$((10#${2:-01}))" ;;
  url) website "$2" ;;
  action) action "$2" "$((10#${3:-01}))" ;;
esac
