#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=diagram-lib.sh
source "$SCRIPT_DIR/diagram-lib.sh"

input="$(cat)"
file_path="$(echo "$input" | jq -r '.file_path // .path // empty')"

if [[ -z "$file_path" ]]; then
  exit 0
fi

if ! diagram_is_output_html "$file_path"; then
  exit 0
fi

html="$(diagram_normalize_html_path "$file_path")"
if [[ ! -f "$html" ]]; then
  exit 0
fi

if diagram_validate_html "$html"; then
  diagram_set_pending "$html"
fi

exit 0
