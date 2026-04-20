---
description: 詳細設計書作成: 4つの永続ドキュメントを対話的に作成する
---

# 初回プロジェクトセットアップ

このコマンドは、プロジェクトの詳細設計関連の4つの永続ドキュメントを対話的に作成します。

## 実行方法

```bash
claude
> /create-detailed-design-docs
```

## 実行前の確認

`docs/` ディレクトリ内のファイルを確認します。
```bash
# 確認
ls docs/basic_design/
ls docs/spec_requirements/

# ファイルが存在する場合
✅ docs/ 配下にmdファイルが見つかりました
   見つかったmdファイルを元に詳細設計書を作成します

# ファイルが存在しない場合
⚠️  docs/ 配下にファイルがありません
   対話形式で詳細設計書を作成します
```

## 手順

### ステップ0: インプットの読み込み

1. `docs/` 配下のmdファイルを全て読む
2. 内容を理解し、詳細設計書作成の参考にする

### ステップ1: IoTメッセージフォーマット定義の作成

1. `docs/`配下の内容を元に`docs/detailed_design/iot-message-format.md`を作成
  - MQTTトピック名の命名規則（例: devices/{device_id}/telemetry）
  - ペイロードのJSONスキーマ（フィールド名・型・単位）
  - IoT Ruleのクエリ（SELECT文）
2. ユーザーに確認を求め、**承認されるまで待機**

### ステップ2: ECS Workerのバッチ処理ロジックの作成

1. `docs/`配下の内容を元に`docs/detailed_design/ecs-worker-batch-logic.md`を作成
  - 異常検知のアルゴリズム（いつ、どの閾値と比較するか）
  - 日次レポート生成の集計クエリ
  - データ削除バッチの対象条件
2. ユーザーに確認を求め、**承認されるまで待機**

### ステップ3: 画面設計書（ワイヤーフレーム）の作成

1. `docs/`配下の内容を元に`docs/detailed_design/wireframe-design.md`を作成
  - React画面のレイアウト・遷移図
2. ユーザーに確認を求め、**承認されるまで待機**

### ステップ4: Grafanaダッシュボード設計書の作成

1. `docs/`配下の内容を元に`docs/detailed_design/grafana-dashboard-design.md`を作成
  - パネル構成・クエリ方針
2. ユーザーに確認を求め、**承認されるまで待機**

## 完了条件

- 4つの永続ドキュメントが全て作成されていること

完了時のメッセージ:
```
「詳細設計書作成が完了しました!

作成したドキュメント:
✅ docs/detailed_design/iot-message-format.md
✅ docs/detailed_design/ecs-worker-batch-logic.md
✅ docs/detailed_design/wireframe-design.md
✅ docs/detailed_design/grafana-dashboard-design.md

これで開発を開始する準備が整いました。
```