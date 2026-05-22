# 図解の色（SSOT）

## 正本は1ファイルだけ

```
.claude/skills/creating-visual-explainers/references/ads-theme.js
```

ここだけ編集する。`base.html` や `output/*.html` に hex を直書きしない。

## 色を変えたあと

```bash
cd personal-visual-explainers-output-simple
bash scripts/sync-ads-theme.sh
```

公開中の URL を更新するときは、該当図解を再デプロイする。

## デプロイ時

`deploy-diagram.sh` が `ads-theme.js` を surge に一緒に載せる。HTML と同じフォルダに置かれる。

## タイトルのグラデーション

HTML では `ads-title-gradient` クラスを使う（色は `ads-theme.js` の `gradient`）。
