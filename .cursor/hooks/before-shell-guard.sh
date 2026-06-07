#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=diagram-lib.sh
source "$SCRIPT_DIR/diagram-lib.sh"

input="$(cat)"
command="$(echo "$input" | jq -r '.command // empty')"

if diagram_is_blocked_local_open "$command"; then
  cat <<EOF
{
  "permission": "deny",
  "user_message": "図解はローカル HTML ではなく publish-diagram.sh で公開してください。公開後に surge の URL が開きます。",
  "agent_message": "output/*.html を open するのは禁止です。bash scripts/publish-diagram.sh output/{slug}.html {slug} を実行してください。"
}
EOF
  exit 0
fi

if diagram_is_direct_surge "$command"; then
  cat <<EOF
{
  "permission": "deny",
  "user_message": "surge の直接実行は禁止です。publish-diagram.sh 経由で公開してください。",
  "agent_message": "npx surge の直叩きは禁止です。bash scripts/publish-diagram.sh output/{slug}.html {slug} を使ってください。"
}
EOF
  exit 0
fi

echo '{"permission": "allow"}'
