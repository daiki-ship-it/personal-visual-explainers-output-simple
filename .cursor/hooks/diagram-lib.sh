#!/bin/bash
# personal-visual-explainers-output-simple 用 Hook 共通ライブラリ

diagram_root() {
  local hook_dir
  hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$hook_dir/../.." && pwd
}

diagram_state_dir() {
  local root
  root="$(diagram_root)"
  mkdir -p "$root/.cursor/hooks"
  echo "$root/.cursor/hooks"
}

diagram_pending_file() {
  echo "$(diagram_state_dir)/diagram-pending.json"
}

diagram_last_publish_file() {
  echo "$(diagram_state_dir)/last-publish.json"
}

diagram_read_json_field() {
  local file="$1"
  local field="$2"
  if [[ ! -f "$file" ]] || ! command -v jq &>/dev/null; then
    return 1
  fi
  jq -r ".$field // empty" "$file" 2>/dev/null
}

diagram_html_mtime() {
  local file="$1"
  stat -f '%m' "$file" 2>/dev/null || stat -c '%Y' "$file"
}

diagram_is_output_html() {
  local path="$1"
  local root basename_path
  root="$(diagram_root)"
  basename_path="$(basename "$path")"

  [[ "$basename_path" == *.html ]] || return 1
  [[ "$path" == *"/output/"* ]] || return 1
  [[ "$basename_path" == "index.html" && "$path" == *report-automation-dashboard* ]] && return 1

  if [[ "$path" == "$root/output/"* ]]; then
    return 0
  fi
  if [[ "$path" == *"personal-visual-explainers-output-simple/output/"* ]]; then
    return 0
  fi
  return 1
}

diagram_normalize_html_path() {
  local path="$1"
  local root
  root="$(diagram_root)"

  if [[ "$path" == "$root/output/"* ]]; then
    echo "$path"
    return
  fi
  if [[ "$path" == *"personal-visual-explainers-output-simple/output/"* ]]; then
    echo "$root/output/$(basename "$path")"
    return
  fi
  if [[ -f "$root/$path" ]]; then
    echo "$root/$path"
    return
  fi
  echo "$path"
}

diagram_validate_html() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  grep -q '<!-- TITLE -->' "$file" && return 1
  grep -q '<!-- DESCRIPTION -->' "$file" && return 1
  grep -q '</body>' "$file" || return 1
  awk '/<!-- CONTENT_START -->/,/<!-- CONTENT_END -->/ {
    if (/<div|<section|<h[1-6]|<p|<main|<article|<ul|<ol|<table/) found = 1
  }
  END { exit !found }' "$file"
}

diagram_already_published() {
  local html="$1"
  local pub_file mtime pub_html pub_mtime
  pub_file="$(diagram_last_publish_file)"
  [[ -f "$pub_file" ]] || return 1
  pub_html="$(diagram_read_json_field "$pub_file" html)"
  pub_mtime="$(diagram_read_json_field "$pub_file" mtime)"
  mtime="$(diagram_html_mtime "$html")"
  [[ "$pub_html" == "$html" && "$pub_mtime" == "$mtime" ]]
}

diagram_set_pending() {
  local html="$1"
  local slug
  slug="$(basename "$html" .html)"
  local mtime
  mtime="$(diagram_html_mtime "$html")"
  cat > "$(diagram_pending_file)" <<EOF
{"html":"$html","slug":"$slug","mtime":$mtime}
EOF
}

diagram_clear_pending() {
  rm -f "$(diagram_pending_file)"
}

diagram_is_publish_command() {
  local cmd="$1"
  [[ "$cmd" == *publish-diagram.sh* || "$cmd" == *deploy-diagram.sh* ]]
}

diagram_is_blocked_local_open() {
  local cmd="$1"
  local root
  root="$(diagram_root)"
  if [[ "$cmd" =~ open[[:space:]]+.*output/.*\.html ]]; then
    return 0
  fi
  if [[ "$cmd" == *"$root/output/"*.html* && "$cmd" == *open* ]]; then
    return 0
  fi
  return 1
}

diagram_is_direct_surge() {
  local cmd="$1"
  [[ "$cmd" == *npx*surge* || "$cmd" == *"surge "* ]] && ! diagram_is_publish_command "$cmd"
}
