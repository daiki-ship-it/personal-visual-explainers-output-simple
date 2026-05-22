#!/bin/bash
# ads-theme.js（SSOT）を references / output に同期する
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/.claude/skills/creating-visual-explainers/references/ads-theme.js"

if [[ ! -f "$SRC" ]]; then
  echo "エラー: SSOT が見つかりません: $SRC" >&2
  exit 1
fi

mkdir -p "$ROOT/output" "$ROOT/output/report-automation-dashboard"
cp "$SRC" "$ROOT/output/ads-theme.js"
cp "$SRC" "$ROOT/output/report-automation-dashboard/ads-theme.js"

echo "同期完了:"
echo "  - output/ads-theme.js"
echo "  - output/report-automation-dashboard/ads-theme.js"
