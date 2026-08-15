#!/bin/bash
cd "$(dirname "$0")"
set -e
echo "データベースのテーブルを作成します..."
rm -f .env.local
vercel env pull .env.local --environment production --yes
npm run db:migrate
echo ""
echo "完了しました。この窓は閉じて大丈夫です。"
read -r -p "Enterキーで閉じる"
