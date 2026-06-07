#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=diagram-lib.sh
source "$SCRIPT_DIR/diagram-lib.sh"

input="$(cat)"
loop_count="$(echo "$input" | jq -r '.loop_count // 0')"
status="$(echo "$input" | jq -r '.status // "completed"')"

if [[ "$status" == "aborted" || "$status" == "error" ]]; then
  echo '{}'
  exit 0
fi

if [[ "$loop_count" -ge 3 ]]; then
  echo '{}'
  exit 0
fi

pending_file="$(diagram_pending_file)"
if [[ ! -f "$pending_file" ]]; then
  echo '{}'
  exit 0
fi

html="$(diagram_read_json_field "$pending_file" html)"
slug="$(diagram_read_json_field "$pending_file" slug)"

if [[ -z "$html" || ! -f "$html" ]]; then
  diagram_clear_pending
  echo '{}'
  exit 0
fi

if diagram_already_published "$html"; then
  diagram_clear_pending
  echo '{}'
  exit 0
fi

if ! diagram_validate_html "$html"; then
  echo '{}'
  exit 0
fi

root="$(diagram_root)"
rel_html="output/$(basename "$html")"
log_file="$(mktemp)"
if bash "$root/scripts/publish-diagram.sh" "$rel_html" "$slug" >"$log_file" 2>&1; then
  diagram_clear_pending
  echo '{}'
  exit 0
fi

log_tail="$(tail -n 20 "$log_file" | sed 's/"/\\"/g' | tr '\n' ' ')"
rm -f "$log_file"

jq -n \
  --arg msg "図解の自動公開に失敗しました。次を実行して修正してください: bash scripts/publish-diagram.sh $rel_html $slug

ログ: $log_tail" \
  '{followup_message: $msg}'
