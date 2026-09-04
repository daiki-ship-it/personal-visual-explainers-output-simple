#!/bin/bash
# 図解公開用のログイン（初回・切れ直し用）
# このファイルをダブルクリックして実行してください。

cd "$(dirname "$0")/.." || exit 1

echo "========================================"
echo "  図解の公開アカウントにログインします"
echo "========================================"
echo ""
echo "メールアドレスとパスワードを聞かれたら入力してください。"
echo "（以前と同じ: daiki@aiessences.com）"
echo ""

npx --yes surge login
LOGIN_EXIT=$?

echo ""
if [ "$LOGIN_EXIT" -eq 0 ] && { [ -d "$HOME/.surge" ] || grep -q 'surge.sh' "$HOME/.netrc" 2>/dev/null; }; then
  echo "ログインできました。Cursorのチャットに「再公開して」と送ってください。"
else
  echo "まだログインできていません。"
  echo "パスワードを忘れた場合は、届いたメールのリンクで新しいパスワードを決めてから、"
  echo "もう一度このファイルを実行してください。"
fi

echo ""
read -r -p "このウィンドウを閉じるには Enter を押してください..."
