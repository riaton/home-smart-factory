---
name: development-guideline-terraform
description: Terraform でコードを実装する際に参照するコーディング規約・開発プロセスガイド。実装・レビュー・テスト設計・リリース準備時に使用する。
allowed-tools: Read, Write, Edit
---

# 開発ガイドラインスキル（Terraform）

チーム開発に必要な2つの要素をカバーします:
1. 実装時のコーディング規約 (implementation-guide.md)
2. 開発プロセスの標準化 (process-guide.md)

## 前提条件

本ガイドラインは以下の技術スタックを前提とします:
- **IaC**: Terraform 1.15+
- **クラウド**: AWS（ap-northeast-1 東京リージョン）
- **Provider**: AWS Provider 6.x
- **テスト**: terraform test（組み込みテストフレームワーク）
- **静的解析**: terraform fmt / terraform validate / tflint（任意）/ checkov（任意）

## 参照ドキュメントの場所
以下を参照する。
  - ./guides/implementation-guide.md: Terraform コーディング規約
  - ./guides/process-guide.md: 開発プロセス・Git運用・CI/CD

## クイックリファレンス

### コード実装時
コード実装時のルールと規約: ./guides/implementation-guide.md

含まれる内容:
- 命名規則（リソース名・変数名・タグ）
- ディレクトリ構成（modules / envs）
- versions.tf・locals.tf・variables.tf の書き方
- リソース定義ベストプラクティス（depends_on / lifecycle / for_each）
- モジュール設計（作成基準・outputs の公開範囲）
- セキュリティ（IAM 最小権限・SG・sensitive 変数）
- ステート管理（S3 バックエンド・DynamoDB ロック）
- テスト（terraform test フレームワーク）

### 開発プロセス時
開発プロセスの標準化: ./guides/process-guide.md

含まれる内容:
- Git Flow ブランチ戦略
- Conventional Commits コミットメッセージ規約
- プルリクエストテンプレート
- CI/CD 自動化（GitHub Actions + terraform fmt / validate / plan / apply）

## 使用シーン別ガイド

### 新規リソース追加時
1. ./guides/implementation-guide.md で命名規則・ファイル構成を確認
2. 既存モジュールに追加か新規モジュール作成かを判断
3. `terraform validate` → `terraform plan` → PR → `terraform apply`

### コードレビュー時
- ./guides/process-guide.md の「コードレビュープロセス」を参照
- ./guides/implementation-guide.md で規約違反がないか確認

### テスト設計時
- ./guides/implementation-guide.md の「テスト」（terraform test フレームワーク）
- plan テスト（unit）と apply テスト（integration）を使い分ける

### リリース準備時
- ./guides/process-guide.md の「Git運用ルール」
- `terraform fmt -check` と `terraform validate` がパスすること
- `terraform plan` の差分を PR に貼り付けてレビューを受けること
