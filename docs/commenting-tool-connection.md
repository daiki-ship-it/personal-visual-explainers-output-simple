# 図解とコメントツールのつながり（メモ）

## フォルダの場所（2026-05 移行後）

```
src/
├── personal-visual-explainers-output-simple/  … 図解を作って Surge に載せる
└── commenting-visual-explainers-personal/              … コメントを預かる（Vercel + Neon）
```

コメントツールは、もともと `ADS/ADS-tool/` の下にありましたが、**src の直下** に移しました。

## 誰が何をするか

| やること | personal | commenting-visual-explainers-personal |
|----------|:--------:|:----------------------------:|
| 図解 HTML を作る | ✅ | — |
| Surge に公開 | ✅ | — |
| 公開時に「コメント係を呼ぶ」1 行を足す | ✅ | — |
| コメント UI（widget） | — | ✅ |
| コメントを Neon に保存 | — | ✅ |

## 公開の流れ

1. personal が `output/○○.html` を作る
2. `deploy-diagram.sh` が `../commenting-visual-explainers-personal` の設定を読む
3. HTML に widget 用の `<script>` を 1 行足して Surge に載せる
4. 読者が URL を開くと、widget が Vercel 経由で Neon からコメントを取り、画面に表示する

コメント本文は図解 HTML に書き込まず、**閲覧時にくっついて見える**。
