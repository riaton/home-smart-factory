# Grafanaダッシュボード設計書

## Home Smart Factory -- IoT設備監視基盤

------------------------------------------------------------------------

# 1. 概要

| 項目 | 内容 |
|---|---|
| 用途 | 管理者向け運用監視。ユーザー向けアプリ（React）とは独立した管理画面 |
| アクセス | `http://{GrafanaパブリックIP}:3000`（管理者IPのみ sg-grafana で許可） |
| データソース | Amazon RDS PostgreSQL（読み取り専用ユーザー `grafana_ro`） |
| 対象者 | 運用担当者 |
| 認証方式 | Google OAuth 2.0（機能要件 4.3節に基づく） |

## 1.1 Google OAuth 設定

Google Cloud Console でOAuthアプリを作成し、以下の環境変数をECSタスク定義に追加する（インフラ定義書 セクション5.6の環境変数テーブルと合わせて管理する）。

| 環境変数 | 値 |
|---|---|
| `GF_AUTH_GOOGLE_ENABLED` | `true` |
| `GF_AUTH_GOOGLE_CLIENT_ID` | Google Cloud Console で発行したクライアントID |
| `GF_AUTH_GOOGLE_CLIENT_SECRET` | AWS Secrets Manager から取得 |
| `GF_AUTH_GOOGLE_SCOPES` | `https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email` |
| `GF_AUTH_GOOGLE_AUTH_URL` | `https://accounts.google.com/o/oauth2/auth` |
| `GF_AUTH_GOOGLE_TOKEN_URL` | `https://accounts.google.com/o/oauth2/token` |
| `GF_AUTH_GOOGLE_ALLOWED_DOMAINS` | 許可するGoogleアカウントのドメイン（例: `example.com`） |
| `GF_AUTH_GOOGLE_ALLOW_SIGN_UP` | `false`（管理者が手動でGrafanaユーザーを作成する） |

**Google Cloud Console での設定:**

1. Google Cloud Console → 「APIとサービス」→「認証情報」→「OAuthクライアントIDを作成」
2. アプリケーションの種類: **ウェブアプリケーション**
3. 承認済みのリダイレクトURI: `http://{GrafanaパブリックIP}:3000/login/google`

> **注:** `GF_AUTH_ANONYMOUS_ENABLED=false`（インフラ定義書 セクション5.6）と組み合わせることで、Google OAuth 未認証ユーザーはログイン画面にリダイレクトされる。IPホワイトリスト（sg-grafana）は引き続き有効であり、二重の防御となる。

------------------------------------------------------------------------

# 2. データソース設定

## 2.1 PostgreSQL接続設定

| 項目 | 値 |
|---|---|
| データソース名 | `home-smart-factory-rds` |
| ホスト | RDS エンドポイント:5432 |
| データベース | `home_smart_factory` |
| ユーザー | `grafana_ro` |
| パスワード | AWS Secrets Manager から取得（Grafana 起動時に環境変数で注入） |
| TLS/SSL | 有効 |
| タイムゾーン | UTC（Grafana UI 側で JST に変換） |

## 2.2 grafana_ro ユーザーの権限

```sql
-- RDS 上で実行
CREATE USER grafana_ro WITH PASSWORD '...';
GRANT CONNECT ON DATABASE home_smart_factory TO grafana_ro;
GRANT USAGE ON SCHEMA public TO grafana_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana_ro;
-- 将来テーブルが追加された場合も自動的に SELECT 権限を付与する
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO grafana_ro;
```

------------------------------------------------------------------------

# 3. ダッシュボード一覧

| ダッシュボードID | ダッシュボード名 | 用途 | リフレッシュ間隔 |
|---|---|---|---|
| D-01 | IoTデータ監視 | デバイス別センサーデータの時系列推移 | 1分 |
| D-02 | 異常検知モニタリング | 異常ログの傾向・デバイス別集計 | 1分 |
| D-03 | 運用データ概況 | ユーザー数・データ量等の運用指標 | 5分 |

> **タイムゾーン表示方針:** 全パネル共通で、タイムゾーン変換はGrafana UIに委ねる（ダッシュボード設定の「Timezone」を `Asia/Tokyo` に設定する）。SQL内での `AT TIME ZONE` 変換は使用しない。

------------------------------------------------------------------------

# 4. D-01: IoTデータ監視

## 4.1 ダッシュボード変数

| 変数名 | タイプ | クエリ | 説明 |
|---|---|---|---|
| `$device_id` | Query | `SELECT DISTINCT device_id FROM devices ORDER BY device_id` | デバイス選択（複数選択可） |
| `$user_id` | Query | `SELECT id, email FROM users ORDER BY email` | ユーザー選択 |

## 4.2 パネル構成

### P-01-01: 温度推移（Time series）

```sql
SELECT
    recorded_at AS "time",
    device_id,
    temperature AS "温度 (℃)"
FROM iot_data
WHERE
    $__timeFilter(recorded_at)
    AND device_id IN ($device_id)
    AND temperature IS NOT NULL
ORDER BY recorded_at;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Time series |
| Y軸単位 | `℃` |
| 凡例 | デバイスIDごとに色分け |
| 異常閾値ライン | なし（Grafana Alert は使用しない） |

---

### P-01-02: 湿度推移（Time series）

```sql
SELECT
    recorded_at AS "time",
    device_id,
    humidity AS "湿度 (%)"
FROM iot_data
WHERE
    $__timeFilter(recorded_at)
    AND device_id IN ($device_id)
    AND humidity IS NOT NULL
ORDER BY recorded_at;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Time series |
| Y軸単位 | `%` |
| Y軸範囲 | 0〜100 |

---

### P-01-03: 消費電力推移（Time series）

```sql
SELECT
    recorded_at AS "time",
    device_id,
    power_w AS "消費電力 (W)"
FROM iot_data
WHERE
    $__timeFilter(recorded_at)
    AND device_id IN ($device_id)
    AND power_w IS NOT NULL
ORDER BY recorded_at;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Time series |
| Y軸単位 | `W` |

---

### P-01-04: 人感センサー検知状況（State timeline）

```sql
SELECT
    recorded_at AS "time",
    device_id,
    CASE WHEN motion = 1 THEN '検知' ELSE '未検知' END AS "人感"
FROM iot_data
WHERE
    $__timeFilter(recorded_at)
    AND device_id IN ($device_id)
    AND motion IS NOT NULL
ORDER BY recorded_at;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | State timeline |
| `検知` カラー | 緑 |
| `未検知` カラー | グレー |

---

### P-01-05: 最新センサー値（Stat）

```sql
SELECT DISTINCT ON (device_id)
    device_id,
    temperature AS "温度",
    humidity    AS "湿度",
    power_w     AS "電力",
    recorded_at AS "最終更新"
FROM iot_data
WHERE device_id IN ($device_id)
ORDER BY device_id, recorded_at DESC;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Table |
| 用途 | 最新データが届いているか確認する死活確認用 |

------------------------------------------------------------------------

# 5. D-02: 異常検知モニタリング

## 5.1 ダッシュボード変数

| 変数名 | タイプ | クエリ | Grafana変数設定 |
|---|---|---|---|
| `$device_id` | Query | `SELECT DISTINCT device_id FROM anomaly_logs ORDER BY device_id` | Include All: 有効、All value: `all` |
| `$metric_type` | Custom | `temperature,humidity,power_w` | Include All: 有効、All value: `all` |

> **注:** `$device_id` のソースは `anomaly_logs` テーブルであるため、異常が一度も発生していないデバイスはこのフィルターに表示されない。これは意図した設計であり、D-02は異常履歴のあるデバイスの傾向分析を目的としているため。全デバイスを対象にする場合は D-01 を参照のこと。

## 5.2 パネル構成

### P-02-01: 異常検知件数（期間合計）（Stat）

```sql
SELECT COUNT(*) AS "異常件数"
FROM anomaly_logs
WHERE $__timeFilter(detected_at)
  AND ($device_id = 'all' OR device_id IN ($device_id))
  AND ($metric_type = 'all' OR metric_type IN ($metric_type));
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Stat |
| カラー閾値 | 0: 緑、1〜9: 黄、10以上: 赤 |

---

### P-02-02: 異常検知数の時系列推移（Bar chart）

```sql
SELECT
    date_trunc('day', detected_at) AS "time",
    metric_type,
    COUNT(*) AS "件数"
FROM anomaly_logs
WHERE $__timeFilter(detected_at)
  AND ($device_id = 'all' OR device_id IN ($device_id))
  AND ($metric_type = 'all' OR metric_type IN ($metric_type))
GROUP BY 1, 2
ORDER BY 1;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Bar chart（積み上げ） |
| 凡例 | metric_type で色分け |

---

### P-02-03: デバイス別異常件数（Bar chart）

```sql
SELECT
    device_id,
    COUNT(*) AS "異常件数"
FROM anomaly_logs
WHERE $__timeFilter(detected_at)
GROUP BY device_id
ORDER BY 2 DESC;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Bar chart（横向き） |

---

### P-02-04: 直近の異常ログ一覧（Table）

```sql
SELECT
    detected_at    AS "検知日時",
    device_id      AS "デバイス",
    metric_type    AS "検知項目",
    threshold_value AS "閾値",
    actual_value   AS "実測値",
    message        AS "内容"
FROM anomaly_logs
WHERE $__timeFilter(detected_at)
  AND ($device_id = 'all' OR device_id IN ($device_id))
ORDER BY detected_at DESC
LIMIT 100;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Table |
| ソート | 検知日時 降順 |

------------------------------------------------------------------------

# 6. D-03: 運用データ概況

> **スコープ外（初期リリース）:** DLQ件数の監視は CloudWatch Datasource が必要なため初期リリースでは対象外とする。DLQ蓄積は CloudWatch Alarm + SNS による通知（インフラ定義書 セクション11.3.2）で代替する。

## 6.1 パネル構成

### P-03-01: 総ユーザー数（Stat）

```sql
SELECT COUNT(*) AS "ユーザー数" FROM users;
```

---

### P-03-02: 総デバイス数（Stat）

```sql
SELECT COUNT(*) AS "デバイス数" FROM devices;
```

---

### P-03-03: iot_data レコード数 / 日（Time series）

```sql
SELECT
    date_trunc('day', recorded_at) AS "time",
    COUNT(*)                        AS "レコード数"
FROM iot_data
WHERE $__timeFilter(recorded_at)
GROUP BY 1
ORDER BY 1;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Time series |
| 用途 | データ流量の異常（急減・急増）を検知 |

---

### P-03-04: iot_data テーブルサイズ（Stat）

```sql
SELECT
    pg_size_pretty(pg_total_relation_size('iot_data')) AS "テーブルサイズ";
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Stat |
| 用途 | ストレージ逼迫の早期検知 |

---

### P-03-05: ユーザー別データ件数（Table）

```sql
SELECT
    u.email,
    COUNT(i.id)    AS "IoTデータ件数",
    COUNT(DISTINCT d.id) AS "デバイス数"
FROM users u
LEFT JOIN devices d ON d.user_id = u.id
LEFT JOIN iot_data i ON i.user_id = u.id
GROUP BY u.id, u.email
ORDER BY 2 DESC;
```

| 設定項目 | 値 |
|---|---|
| 可視化タイプ | Table |
| 用途 | 特定ユーザーへのデータ集中を検知 |

------------------------------------------------------------------------

# 7. アラート設定方針

Grafana Alert は使用しない。アラートは CloudWatch Alarm + SNS で統一する（インフラ定義書 セクション11参照）。Grafana はあくまで可視化・調査ツールとして使用する。
