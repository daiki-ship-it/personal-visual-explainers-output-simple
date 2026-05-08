# HTML構造ガイド（会議サマリー向け）

## 目次

- テンプレートのSSoT
- 推奨セクション順（Slackで開いたとき）
- コンポーネント・パターン
- Lucideアイコンの目安

---

## テンプレートのSSoT

- **額縁・CDN・禁止事項**は [creating-visual-explainers/SKILL.md](../../creating-visual-explainers/SKILL.md) に従う。
- **コピー元ファイル**: [creating-visual-explainers/references/base.html](../../creating-visual-explainers/references/base.html)
- **品質の実物基準**: [creating-visual-explainers/references/model-answer.html](../../creating-visual-explainers/references/model-answer.html)

このスキルでは **`head` やテンプレート付属の `script` を変更しない**。コンテンツは `<!-- CONTENT_START -->` 〜 `<!-- CONTENT_END -->` のみに書く。

---

## 推奨セクション順（Slackで開いたとき）

1. **ヒーロー**: 会議名またはテーマ・日付（任意）・一言要約
2. **決定事項**: 箇条書きまたは番号付きカード（各項目は1〜2行）
3. **ネクストアクション**: 表またはグリッド（担当・期限を必須扱い）
4. **論点・未決**（ある場合）: 「保留」「次回まで」のラベルを付ける
5. **用語・補足**: その会議で出た専門語のみ。長い教材にしない
6. **参考**: リンクやドキュメント名（任意）

---

## コンポーネント・パターン

### 決定事項カード（例）

- 左ボーダーまたはアイコンで「確定感」を出す（`border-l-4` + `ads-positive` 系など）
- 1カード1決定。長文は「要約行＋詳細行」に分ける

### ネクストアクション表（例）

- ヘッダ行: 担当 / 内容 / 期限 / メモ
- 期限が未定ならセルに「未定（理由一言）」と書く（空欄にしない）

### 会議フロー（ステップ）

- モバイルでは縦並び、デスクトップでは横並び＋矢印
- 各ステップは **名詞句＋短い動詞**（例: 「方針確認 → 案確定」）

### 論点の分岐

- 「採用」「見送り」「保留」を色またはラベルで区別。意味は凡例で固定

具体的なTailwindの組み方は **model-answer.html** を優先的に参照し、会議向けにセクションを差し替える。

---

## Lucideアイコンの目安

| 用途 | アイコン名の例 |
|------|----------------|
| 決定 | `check-circle` |
| タスク | `list-checks` |
| 期限 | `calendar` |
| 相談・論点 | `message-circle` |
| 注意 | `alert-circle` |
| 共有・連携 | `users` |

絵文字は使わない。アイコンはプロジェクトのテンプレートどおり `data-lucide` で指定する。
