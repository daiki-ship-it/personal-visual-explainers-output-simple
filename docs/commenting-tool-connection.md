# 図解とコメントツールのつながり（メモ）

## フォルダの場所

```
personal-visual-explainers-output-simple/
├── output/                         … 図解 HTML
├── .claude/skills/                 … 図解スキル・セットアップスキル
└── tools/voice-diagram-comment/    … コメントを預かる（Vercel + Neon + Gemini 音声）
```

以前は隣の `commenting-visual-explainers-personal/` を使っていました。音声コメントは `tools/voice-diagram-comment/` 側です。

## 誰が何をするか

| やること | personal | tools/voice-diagram-comment |
|----------|:--------:|:--------------------------:|
| 図解 HTML を作る | ✅ | — |
| Surge に公開 | ✅ | — |
| 公開時に「コメント係を呼ぶ」1 行を足す | ✅ | — |
| コメント UI（widget・音声含む） | — | ✅ |
| コメントを Neon に保存 | — | ✅ |

## 公開の流れ

1. personal が `output/○○.html` を作る
2. `deploy-diagram.sh` が次の順で設定を読む
   - このリポジトリ直下の `fb-tool-url.txt` / `fb-api-token.txt`
   - `tools/voice-diagram-comment/` 内の同じファイル
   - （旧）`../commenting-visual-explainers-personal/`
3. HTML に widget 用の `<script>` を 1 行足して Surge に載せる
4. 読者が URL を開くと、widget が Vercel 経由で Neon からコメントを取り、画面に表示する

コメント本文は図解 HTML に書き込まず、**閲覧時にくっついて見える**。

音声コメントを使うには、このリポジトリのチャットで一度「セットアップして」と伝える（Gemini API キーが必要）。
