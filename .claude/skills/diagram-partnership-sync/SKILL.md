---
name: diagram-partnership-sync
description: AI講師とSNSマーケターがSlackで共有する会議サマリー用の図解HTMLを作るスキル。「Slack用に図解して」「議事録を図解して」「会議のネクストアクションを図解」「ミーティングを一枚にまとめて」「決定事項を図にして」と依頼された際に使用する。
---

# Diagram Partnership Sync

**目的**: 会議の議事録・メモ・決定事項を、**文章だけでは追いにくい**状態から、**一目で直感的に**把握できる1枚の図解HTMLにまとめる。

**想定読者（2人）**:
- **AI新規事業を構築中の講師（本人）** — AIには詳しいが、SNSマーケ用語に弱い部分がある
- **SNSマーケター（契約パートナー）** — SNSマーケには詳しいが、AI用語に弱い部分がある

**成功状態**: 両者が図解を見終わったとき、**会議での決定事項**と**ネクストアクション**（誰が・いつまでに・何を）を**即座に**言語化できる。

---

## 依存（SSoT）

| 用途 | 参照先 |
|------|--------|
| HTMLの額縁（プレースホルダー・Tailwind・禁止事項） | [creating-visual-explainers/SKILL.md](../creating-visual-explainers/SKILL.md) |
| テンプレート本体 | [creating-visual-explainers/references/base.html](../creating-visual-explainers/references/base.html) |
| 品質・デザインの水準感 | [creating-visual-explainers/references/model-answer.html](../creating-visual-explainers/references/model-answer.html) |
| 会議図解向けのレイアウト・コンポーネント指針 | [references/html-structure.md](references/html-structure.md) |
| 用語の橋渡し（AI⇄マーケ） | [references/term-dictionary.md](references/term-dictionary.md) |
| 読者別の見せ方 | [references/audience-bridge.md](references/audience-bridge.md) |
| ページ構成の型・チェックリスト | [references/exemplar.md](references/exemplar.md) |

---

## ワークフロー

### Phase 0: 入力の確定

- ユーザーから **議事録・Slackのやりとり要約・メモ** を受け取る。不足があれば、日時・参加者・論点だけでもよいので補足を依頼する。
- 外部調査が主題でない限り、**exploreサブエージェントは必須ではない**（会議内容が入力に含まれるため）。

### Phase 1: ソース読み込みと構造化

1. 入力全文を読み、次に分類する: **決定したこと** / **未決・継続論点** / **ネクストアクション** / **参考・コンテキスト**
2. 決定とアクションに **担当** と **期限（あれば）** を紐づける。曖昧なら「要確認」と明示する。

### Phase 2: 二方向用語チェック

- 文中の **AI・生成AI・プロダクト用語** と **SNS・マーケ・集客用語** を洗い出す。
- 初出または重要箇所では、相手側が読んでも迷わないよう **短い括弧解説** か **用語ボックス** を付ける。
- 変換の原則・例 → [references/term-dictionary.md](references/term-dictionary.md)

### Phase 3: 情報の絞り込み（Slack閲覧向け）

- **ファーストビュー**に載せるのは「今日の結論」と「次にやること」までに絞る。
- 詳細は下段のカードや折りたたみ相当の**視覚的セクション分け**（見出し＋余白）で後ろに回す。
- 詳細 → [references/exemplar.md](references/exemplar.md)（情報の優先順位）

### Phase 4: ビジュアル設計

- **タイムライン**（会議の流れ）、**ステップフロー**（施策の順序）、**担当×タスクのマトリクス**、**論点の分岐**など、内容に合うパターンを1〜2種類選ぶ。
- Lucide Icons で記号を統一する（絵文字は使わない）。パターン詳細 → [references/html-structure.md](references/html-structure.md)

### Phase 5: 読者別のスキャン導線

- 見出し・バッジ・短いラベルで **「AI側が見るところ」「マーケ側が見るところ」** を過不足なく示す（排他ではなく、両方が最後まで読めることを前提）。
- 指針 → [references/audience-bridge.md](references/audience-bridge.md)

### Phase 6: HTML生成

1. `creating-visual-explainers` の **禁止事項・額縁** に従う（`base.html` を改変しない）。
2. `references/base.html` を `output/{スラッグ}.html` にコピーし、`<!-- TITLE -->` / `<!-- DESCRIPTION -->` / `<!-- CONTENT_START -->`〜`<!-- CONTENT_END -->` を置換する。
3. 模範のトーン・密度は `model-answer.html` に合わせ、**会議サマリー用セクション**は html-structure / exemplar に従う。

### Phase 7: 批判的レビュー（サブエージェント）

**readonly** で、**2つのペルソナを同一プロンプト内で**順に当てはめてレビューさせる。

```
Task({
  subagent_type: "generalPurpose",
  description: "会議図解の二重ペルソナレビュー",
  readonly: true,
  prompt: `
    以下のHTML図解は「AI講師」と「SNSマーケター」の二人がSlackで共有する会議サマリーです。

    【HTMLファイルパス】{path}

    ## ペルソナA（AIには詳しいがSNSマーケ用語に弱い）
    - マーケ専門用語だけで書かれた箇所はどこか。補足は足りているか。

    ## ペルソナB（SNSマーケに詳しいがAI用語に弱い）
    - AI・技術用語だけで書かれた箇所はどこか。補足は足りているか。

    ## 共通
    1. 決定事項が一文で言えるか
    2. ネクストアクションが「誰・何・いつ」で追えるか
    3. 情報過多でスキップしたくなる箇所
    4. ファーストビューで次の一手がわかるか

    ## 出力形式
    ### 致命的な問題
    ### 改善すべき点
    ### 良かった点
    ### 総評（5段階＋一言）
  `
})
```

### Phase 8: ブラッシュアップ

Phase 7のうち **致命的** → 必ず修正、**改善** → 可能な範囲で対応。**良かった点**は維持。

### Phase 9: 保存と公開

1. `output/` に `index.html` 相当の1ファイルを置く（手順は creating-visual-explainers と同じスラッグ運用）。
2. デプロイする場合 → **実行**: `bash .claude/skills/creating-visual-explainers/scripts/deploy-diagram.sh output/{スラッグ}.html {スラッグ}`
3. 公開しない場合 → ファイルパスを報告し、ブラウザで開ける旨を伝える。

詳細・トラブルシュート → [creating-visual-explainers/SKILL.md](../creating-visual-explainers/SKILL.md) の Step 5〜7

---

## 品質チェックリスト

**必須**: [references/exemplar.md](references/exemplar.md) のチェックリストを全項目確認する（内容・技術・レビュー後）。

---

## 模範解答

ページ構成の型とチェックリスト → [references/exemplar.md](references/exemplar.md)
