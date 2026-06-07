#!/bin/bash
set -e

HTML_FILE="${1:?使い方: deploy-diagram.sh <HTMLファイル> [スラッグ]}"
SLUG="${2:-}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if ! command -v node &>/dev/null; then
    echo -e "${RED}エラー: Node.js がインストールされていません${NC}" >&2
    echo "Node.js をインストールしてから、もう一度試してください。" >&2
    exit 1
fi

if [ ! -f "$HTML_FILE" ]; then
    echo -e "${RED}エラー: $HTML_FILE が見つかりません${NC}" >&2
    echo "先に図解を生成してください。" >&2
    exit 1
fi

if [ -n "$SLUG" ]; then
    DOMAIN="diagram-${SLUG}.surge.sh"
else
    DOMAIN="diagram-$(date +%y%m%d%H%M).surge.sh"
fi

ROOT_DIR="$(cd "$(dirname "$0")/../../../.." && pwd)"
FB_ROOT="$ROOT_DIR/../commenting-visual-explainers-personal"

resolve_fb_file() {
    local name="$1"
    if [ -f "$ROOT_DIR/$name" ]; then
        echo "$ROOT_DIR/$name"
        return 0
    fi
    if [ -f "$FB_ROOT/$name" ]; then
        echo "$FB_ROOT/$name"
        return 0
    fi
    return 1
}

FB_URL_FILE="$(resolve_fb_file fb-tool-url.txt || true)"
if [ -z "$FB_URL_FILE" ]; then
    echo -e "${RED}エラー: fb-tool-url.txt が見つかりません${NC}" >&2
    echo "チャット欄で「セットアップして」と伝えてください。" >&2
    echo "（FB バックエンド: commenting-visual-explainers-personal/）" >&2
    exit 1
fi
FB_URL=$(cat "$FB_URL_FILE")

FB_TOKEN_FILE="$(resolve_fb_file fb-api-token.txt || true)"
if [ -z "$FB_TOKEN_FILE" ]; then
    echo -e "${RED}エラー: fb-api-token.txt が見つかりません${NC}" >&2
    echo "セットアップが古い可能性があります。チャット欄で「セットアップして」と伝えてください。" >&2
    exit 1
fi
API_TOKEN=$(cat "$FB_TOKEN_FILE")

if [[ ! "$FB_URL" =~ ^https:// ]]; then
    echo -e "${RED}エラー: fb-tool-url.txt の URL が https:// で始まっていません${NC}" >&2
    exit 1
fi
if [[ "$FB_URL" =~ [\\|\&$'\n'] ]]; then
    echo -e "${RED}エラー: fb-tool-url.txt に不正な文字が含まれています${NC}" >&2
    exit 1
fi
if [[ "$API_TOKEN" =~ [\\|\&$'\n'\ ] ]]; then
    echo -e "${RED}エラー: fb-api-token.txt に不正な文字が含まれています${NC}" >&2
    exit 1
fi

if ! grep -q '</body>' "$HTML_FILE"; then
    echo -e "${RED}エラー: $HTML_FILE に </body> タグが見つかりません${NC}" >&2
    echo "HTML ファイルの構造が壊れている可能性があります。" >&2
    exit 1
fi

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

THEME_JS="$(cd "$(dirname "$0")/../references" && pwd)/ads-theme.js"
if [[ ! -f "$THEME_JS" ]]; then
    echo -e "${RED}エラー: ads-theme.js（色の正本）が見つかりません: $THEME_JS${NC}" >&2
    exit 1
fi

sed "s|</body>|<script src=\"${FB_URL}/widget.js\" data-token=\"${API_TOKEN}\"></script></body>|" "$HTML_FILE" > "$TEMP_DIR/index.html"
cp "$THEME_JS" "$TEMP_DIR/ads-theme.js"
HTML_DIR="$(cd "$(dirname "$HTML_FILE")" && pwd)"
for img in "$HTML_DIR"/*.png "$HTML_DIR"/*.jpg "$HTML_DIR"/*.webp; do
    [[ -f "$img" ]] && cp "$img" "$TEMP_DIR/"
done
printf "User-agent: *\nDisallow: /\n" > "$TEMP_DIR/robots.txt"

echo -e "${YELLOW}公開中...${NC}"
npx --yes surge "$TEMP_DIR" --domain "$DOMAIN"

touch deploy-history.log
echo "$(date '+%Y-%m-%d %H:%M:%S') | https://${DOMAIN}" >> deploy-history.log

echo ""
echo -e "${GREEN}完了！${NC}"
echo "URL: https://${DOMAIN}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "https://${DOMAIN}" | pbcopy
    echo -e "${GREEN}URLをクリップボードにコピーしました${NC}"
    open "https://${DOMAIN}"
elif command -v clip.exe &>/dev/null; then
    echo -n "https://${DOMAIN}" | clip.exe
    echo -e "${GREEN}URLをクリップボードにコピーしました${NC}"
    start "https://${DOMAIN}" 2>/dev/null || true
elif command -v xdg-open &>/dev/null; then
    xdg-open "https://${DOMAIN}"
fi

echo -e "${YELLOW}削除するとき: npx surge teardown ${DOMAIN}${NC}"
