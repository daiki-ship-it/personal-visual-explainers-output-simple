#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=diagram-lib.sh
source "$SCRIPT_DIR/diagram-lib.sh"

input="$(cat)"
command="$(echo "$input" | jq -r '.command // empty')"
exit_code="$(echo "$input" | jq -r '.exit_code // .exitCode // 0')"

if [[ "$exit_code" != "0" ]]; then
  exit 0
fi

if diagram_is_publish_command "$command"; then
  diagram_clear_pending
fi

exit 0
