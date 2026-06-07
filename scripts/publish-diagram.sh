#!/bin/bash
# 図解公開の唯一の正本入口: テーマ同期 → 検証 → deploy-diagram.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../.cursor/hooks/diagram-lib.sh
source "$ROOT/.cursor/hooks/diagram-lib.sh"

HTML_ARG="${1:?使い方: publish-diagram.sh <HTMLファイル> [スラッグ]}"
SLUG="${2:-}"

if [[ "$HTML_ARG" = /* ]]; then
  HTML_FILE="$HTML_ARG"
else
  HTML_FILE="$ROOT/$HTML_ARG"
fi

if [[ ! -f "$HTML_FILE" ]]; then
  echo "エラー: HTML が見つかりません: $HTML_FILE" >&2
  exit 1
fi

case "$HTML_FILE" in
  "$ROOT"/output/*.html) ;;
  *)
    echo "エラー: output/ 配下の .html のみ公開できます: $HTML_FILE" >&2
    exit 1
    ;;
esac

BASENAME="$(basename "$HTML_FILE" .html)"
if [[ -z "$SLUG" ]]; then
  SLUG="$BASENAME"
fi

validate_html() {
  local file="$1"
  local err=0

  if grep -q '<!-- TITLE -->' "$file"; then
    echo "  - <!-- TITLE --> が未置換です" >&2
    err=1
  fi
  if grep -q '<!-- DESCRIPTION -->' "$file"; then
    echo "  - <!-- DESCRIPTION --> が未置換です" >&2
    err=1
  fi
  if ! awk '/<!-- CONTENT_START -->/,/<!-- CONTENT_END -->/ {
    if (/<div|<section|<h[1-6]|<p|<main|<article|<ul|<ol|<table/) found = 1
  }
  END { exit !found }' "$file"; then
    echo "  - <!-- CONTENT_START --> と <!-- CONTENT_END --> の間に本文がありません" >&2
    err=1
  fi
  if ! grep -q '</body>' "$file"; then
    echo "  - </body> タグがありません" >&2
    err=1
  fi

  return "$err"
}

echo "==> 1/3 テーマ同期 (ads-theme.js)"
bash "$ROOT/scripts/sync-ads-theme.sh"

echo "==> 2/3 HTML 検証"
if ! validate_html "$HTML_FILE"; then
  echo "エラー: HTML が未完成です。プレースホルダーをすべて置換してから再実行してください。" >&2
  exit 1
fi

echo "==> 3/3 公開 (deploy-diagram.sh)"
bash "$ROOT/.claude/skills/creating-visual-explainers/scripts/deploy-diagram.sh" "$HTML_FILE" "$SLUG"

STATE_DIR="$ROOT/.cursor/hooks"
mkdir -p "$STATE_DIR"
MTIME="$(stat -f '%m' "$HTML_FILE" 2>/dev/null || stat -c '%Y' "$HTML_FILE")"
cat > "$STATE_DIR/last-publish.json" <<EOF
{"html":"$HTML_FILE","slug":"$SLUG","mtime":$MTIME,"published_at":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF
rm -f "$STATE_DIR/diagram-pending.json"

echo "公開パイプライン完了: https://diagram-${SLUG}.surge.sh"
