# CLAUDE.md — Home Smart Factory

## プロジェクト概要

家庭環境を小型工場に見立てたIoT設備監視基盤。Raspberry PiからAWSへデータを収集し、Grafana・Reactで可視化・管理を行う個人学習プロジェクト。

**主な技術実証テーマ:** IoTデータ収集 / クラウド基盤 / 設備監視ダッシュボード / 閾値異常検知 / 日次レポート自動生成

---

## システム全体フロー

```
センサー群（温湿度/人感/スマートプラグ）
  └─ Raspberry Pi（Java Collector）
       └─ AWS IoT Core（MQTT over TLS, QoS=1）
            └─ Amazon SQS（iot-data-queue）
                 └─ ECS Worker（常駐） ──► RDS: iot_data 保存
                                     ──► RDS: anomaly_logs 保存
                                     ──► SNS: 異常メール通知
ECS Batch（毎日03:00 JST, EventBridge起動）
  └─ RDS: daily_reports 生成 + 古いデータ定期削除

ブラウザ（React）
  └─ REST API ──► ECS Backend ──► RDS / Redis（セッション管理）
  └─ Grafana ──► RDS 直接クエリ（読み取り専用ユーザー grafana_ro）
```

---

## 技術スタック

| レイヤー | 技術 |
|---|---|
| IoTクライアント | Java（Raspberry Pi常駐, MQTT送信） |
| クラウド | AWS（ap-northeast-1 東京リージョン） |
| メッセージング | AWS IoT Core → Amazon SQS |
| コンテナ | Amazon ECS Fargate（Worker / Batch / Backend） |
| DB | Amazon RDS PostgreSQL 16 |
| セッション | Amazon ElastiCache Redis 7.x |
| 通知 | Amazon SNS |
| スケジューラ | Amazon EventBridge |
| バッチ再実行 | AWS Lambda（Python 3.12） |
| フロントエンド | React（Webアプリ） |
| ダッシュボード | Grafana（ECS Fargate, パブリックサブネット） |
| 認証 | Google OAuth2 + Redis セッション |
| IaC | Terraform |
| ビルドツール | TypeScript / Vitest（現状template。Java移行予定） |

---

## リポジトリ構成

```
home-smart-factory/          ← 本リポジトリ（設計書・共通設定）
  docs/
    spec-requirements/       ← 要件定義
    basic-design/            ← 基本設計（API/DB/インフラ/シーケンス）
    detailed-design/         ← 詳細設計（Worker/Batch/画面/IoTメッセージ形式）
  terraform/
    modules/
      vpc/                   ← VPC・SG・VPCエンドポイントモジュール（実装済み）
      iam/                   ← IAMロール・ポリシーモジュール（実装済み）
      ecr/                   ← ECRリポジトリ・ライフサイクルポリシーモジュール（実装済み）
      rds/                   ← RDS PostgreSQL 16 モジュール（実装済み）
      elasticache/           ← ElastiCache Redis 7.1 モジュール（実装済み）
      sqs/                   ← SQS メインキュー・DLQ モジュール（実装済み）
      sns/                   ← SNS トピック3件・メール通知モジュール（実装済み）
      iot/                   ← IoT Core Thing/Certificate/Policy/TopicRule モジュール（実装済み）
      ecs/                   ← ECS Fargate クラスター・タスク定義・サービス・Auto Scaling モジュール（実装済み）
      alb/                   ← ALB・ACM・リスナー・ターゲットグループモジュール（実装済み）
      lambda/                ← Lambda バッチ再実行関数モジュール（実装済み）
    envs/
      prod/                  ← 本番環境 root module
        tests/               ← terraform test ファイル
```

---

## 主要設計ドキュメント

| ドキュメント | パス |
|---|---|
| 機能要件 | [docs/spec-requirements/機能要件.md](docs/spec-requirements/機能要件.md) |
| システム構成図 | [docs/basic-design/システム構成図.md](docs/basic-design/システム構成図.md) |
| API設計書 | [docs/basic-design/API設計書.md](docs/basic-design/API設計書.md) |
| DB設計書 | [docs/basic-design/DB設計書.md](docs/basic-design/DB設計書.md) |
| インフラ定義書 | [docs/basic-design/インフラ定義書.md](docs/basic-design/インフラ定義書.md) |
| IoTメッセージ形式 | [docs/detailed-design/iot-message-format.md](docs/detailed-design/iot-message-format.md) |
| ECS Worker/Batch ロジック | [docs/detailed-design/ecs-worker-batch-logic.md](docs/detailed-design/ecs-worker-batch-logic.md) |
| 画面設計書 | [docs/detailed-design/wireframe-design.md](docs/detailed-design/wireframe-design.md) |
| Grafanaダッシュボード設計 | [docs/detailed-design/grafana-dashboard-design.md](docs/detailed-design/grafana-dashboard-design.md) |

---

## DBテーブル一覧

| テーブル | 用途 | 保持期間 |
|---|---|---|
| `users` | Googleログインユーザー | 無期限 |
| `devices` | IoTデバイス（user_id紐付き） | 無期限 |
| `iot_data` | センサー生データ | 90日 |
| `anomaly_thresholds` | 閾値設定（temperature/humidity/power_w） | 無期限 |
| `anomaly_logs` | 異常検知ログ | 1年 |
| `daily_reports` | 日次集計レポート | 1年 |
| `report_downloads` | ダウンロード回数管理（1日3回上限） | 1年 |

---

## API概要

ベースURL: `https://api.example.com`
認証: Redisセッション（Cookie: `session_id`）。`/auth/**` 以外は全て認証必須。

| グループ | エンドポイント |
|---|---|
| 認証 | GET /auth/google, GET /auth/google/callback, POST /auth/logout |
| ユーザー | GET /api/users/me, DELETE /api/users/me |
| デバイス | GET/POST /api/devices, PATCH/DELETE /api/devices/{id} |
| IoTデータ | GET /api/iot-data |
| 閾値設定 | GET/POST /api/anomaly-thresholds, PATCH/DELETE /api/anomaly-thresholds/{id} |
| 異常ログ | GET /api/anomaly-logs |
| レポート | GET /api/reports, GET /api/reports/{id}, POST /api/reports/{id}/download |

---

## 重要な設計上の決定事項

- **IoTメッセージの `user_id` はペイロードに含めない。** Worker側で `devices` テーブルから `device_id` を引いて解決する。
- **重複INSERT対策:** `iot_data` は `(device_id, recorded_at)` に UNIQUE制約。Worker は `ON CONFLICT DO NOTHING` で冪等性確保（QoS=1による再送対策）。
- **バリデーションエラーはDLQへ送らず即廃棄する。** 不正ペイロードはリトライ不可のため DeleteMessage して終了。
- **device_id はvarchar型のためDB CASCADE不可。** デバイス/ユーザー削除時の `iot_data` / `anomaly_logs` の削除はアプリ層で実施し、同一トランザクションに束ねる。
- **Grafana は専用読み取り専用ユーザー（`grafana_ro`）でRDSに直接クエリ。** アプリユーザーとは分離。
- **バッチ再実行は1回のみ。** Lambda再実行タスクに `startedBy="lambda-restart"` を付与してEventBridgeルールでループを防止。
- **`power_w` の閾値は上限のみ有効。** min_valueはAPIレベルで無視する。
- **SNS重複通知は許容する。** Worker クラッシュ時の再処理で重複する可能性があるが、分散ロックは導入しない。
- **Grafanaは管理者専用の運用監視ダッシュボード。** 一般ユーザー向けのデータ可視化はReact（S-02）で担う。IPホワイトリスト（sg-grafana）＋ Google OAuth で保護。

---

## 画面一覧（React）

| 画面ID | URL | 概要 |
|---|---|---|
| S-01 | /login | Googleログイン |
| S-02 | /dashboard | ダッシュボード（IoTデータグラフ: 温度・湿度・消費電力・人感センサー） |
| S-03 | /devices | デバイス一覧・追加・削除 |
| S-04 | /reports | 日次レポート一覧 |
| S-05 | /reports/{id} | レポート詳細 + PDFダウンロード（1日3回） |
| S-06 | /anomaly-logs | 異常一覧（異常検知ログ） |
| S-07 | /thresholds | 設定画面（閾値設定） |
