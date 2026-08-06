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

load_surge_credentials() {
    if [ -z "${SURGE_LOGIN:-}" ]; then
        local login_file
        login_file="$(resolve_fb_file surge-login.txt || true)"
        [ -n "$login_file" ] && SURGE_LOGIN="$(tr -d '[:space:]' < "$login_file")"
    fi
    if [ -z "${SURGE_TOKEN:-}" ]; then
        local token_file
        token_file="$(resolve_fb_file surge-token.txt || true)"
        [ -n "$token_file" ] && SURGE_TOKEN="$(tr -d '[:space:]' < "$token_file")"
    fi
    if [ -n "${SURGE_LOGIN:-}" ] && [ -n "${SURGE_TOKEN:-}" ]; then
        export SURGE_LOGIN SURGE_TOKEN
        return 0
    fi
    return 1
}

FB_URL_FILE="$(resolve_fb_file fb-tool-url.txt || true)"
FB_TOKEN_FILE="$(resolve_fb_file fb-api-token.txt || true)"

if [ -n "$FB_URL_FILE" ] && [ -n "$FB_TOKEN_FILE" ]; then
    FB_URL=$(cat "$FB_URL_FILE")
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
    INJECT_FB=1
else
    echo -e "${YELLOW}FBツール未設定のため、コメント機能なしで公開します${NC}"
    INJECT_FB=0
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

if [ "$INJECT_FB" -eq 1 ]; then
    sed "s|</body>|<script src=\"${FB_URL}/widget.js\" data-token=\"${API_TOKEN}\"></script></body>|" "$HTML_FILE" > "$TEMP_DIR/index.html"
else
    cp "$HTML_FILE" "$TEMP_DIR/index.html"
fi
cp "$THEME_JS" "$TEMP_DIR/ads-theme.js"
HTML_DIR="$(cd "$(dirname "$HTML_FILE")" && pwd)"
for img in "$HTML_DIR"/*.png "$HTML_DIR"/*.jpg "$HTML_DIR"/*.webp; do
    [[ -f "$img" ]] && cp "$img" "$TEMP_DIR/"
done
printf "User-agent: *\nDisallow: /\n" > "$TEMP_DIR/robots.txt"

if ! load_surge_credentials; then
    if [ ! -t 0 ]; then
        echo -e "${RED}エラー: Surge のログイン情報がありません${NC}" >&2
        echo "Cloud Agent では環境変数 SURGE_LOGIN / SURGE_TOKEN、または surge-login.txt / surge-token.txt が必要です。" >&2
        echo "ローカルでは npx surge login を一度実行してください。" >&2
        exit 1
    fi
fi

echo -e "${YELLOW}公開中...${NC}"
if ! npx --yes surge "$TEMP_DIR" --domain "$DOMAIN"; then
    echo -e "${RED}エラー: Surge への公開に失敗しました${NC}" >&2
    exit 1
fi

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
