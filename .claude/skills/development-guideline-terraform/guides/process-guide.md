# プロセスガイド (Process Guide)

## 基本原則

### 1. 具体例を豊富に含める

抽象的なルールだけでなく、具体的なコード例を提示します。

**悪い例**:
```
変数名は分かりやすくすること
```

**良い例**:
```hcl
# ✅ 良い例: 役割が明確
variable "rds_instance_class" {
  description = "RDS インスタンスタイプ"
  type        = string
  default     = "db.t3.micro"
}

resource "aws_security_group" "ecs_worker" { }

# ❌ 悪い例: 曖昧
variable "type" { }
resource "aws_security_group" "sg" { }
```

### 2. 理由を説明する

「なぜそうするのか」を明確にします。

**例**:
```
## sensitive 変数を terraform.tfvars に平文で書かない

理由: terraform.tfvars が git にコミットされると機密情報が漏洩します。
パスワードや APIキーは TF_VAR_xxx 環境変数または CI/CD の Secrets から注入します。
```

### 3. 測定可能な基準を設定

曖昧な表現を避け、具体的な数値を示します。

**悪い例**:
```
テストを書くこと
```

**良い例**:
```
terraform test の目標:
- 主要モジュールに plan テスト（ユニット相当）を必ず用意する
- CI では全 plan テストを実行する（apply テストはコスト・時間の観点で任意）
```

---

## Git運用ルール

### ブランチ戦略（Git Flow採用）

**Git Flowとは**:
Vincent Driessenが提唱した、機能開発・リリース・ホットフィックスを体系的に管理するブランチモデル。明確な役割分担により、チーム開発での並行作業と安定したリリースを実現します。

**ブランチ構成**:
```
main (本番環境)
└── develop (開発・統合環境)
    ├── feature/* (新機能開発)
    ├── fix/* (バグ修正)
    └── release/* (リリース準備)※必要に応じて
```

**運用ルール**:
- **main**: 本番リリース済みの安定版コードのみを保持。タグでバージョン管理
- **develop**: 次期リリースに向けた最新の開発コードを統合。CIでの自動テスト実施
- **feature/\*、fix/\***: developから分岐し、作業完了後にPRでdevelopへマージ
- **直接コミット禁止**: すべてのブランチでPRレビューを必須とし、コード品質を担保
- **マージ方針**: feature→develop は squash merge、develop→main は merge commit を推奨

**Git Flowのメリット**:
- ブランチの役割が明確で、複数人での並行開発がしやすい
- 本番環境(main)が常にクリーンな状態に保たれる
- 緊急対応時はhotfixブランチで迅速に対応可能（必要に応じて導入）

### コミットメッセージの規約

**Conventional Commitsを推奨**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type一覧**:
```
feat: 新リソース・モジュール追加 (minor version up)
fix: バグ修正・設定誤り修正 (patch version up)
docs: ドキュメント
style: フォーマット（terraform fmt 等、動作に影響なし）
refactor: リファクタリング（モジュール分割等）
perf: パフォーマンス改善（コスト最適化等）
test: テスト追加・修正
ci: CI/CD設定
chore: その他（Provider バージョン更新など）

BREAKING CHANGE: 破壊的変更 (major version up)
```

**良いコミットメッセージの例**:

```
feat(ecs): Worker / Batch / Backend の ECS サービスを追加

IoTデータ処理に必要な3つの ECS Fargate サービスを定義しました。

実装内容:
- modules/ecs に Worker・Batch・Backend のタスク定義を追加
- Fargate Spot を Worker に適用してコスト最適化
- SQS / RDS / SNS への最小権限 IAM ポリシーを付与

Closes #12
```

### プルリクエストのテンプレート

**効果的なPRテンプレート**:

```markdown
## 変更の種類
- [ ] 新リソース・モジュール追加 (feat)
- [ ] バグ修正・設定誤り修正 (fix)
- [ ] リファクタリング (refactor)
- [ ] ドキュメント (docs)
- [ ] その他 (chore)

## 変更内容
### 何を変更したか
[簡潔な説明]

### なぜ変更したか
[背景・理由]

### どのように変更したか
- [変更点1]
- [変更点2]

## terraform plan の差分
<details>
<summary>plan output</summary>

```
[terraform plan の出力をここに貼る]
```

</details>

## テスト
### 実施したテスト
- [ ] terraform fmt 済み
- [ ] terraform validate 済み
- [ ] terraform plan がエラーなく通ることを確認
- [ ] terraform test (plan テスト) がパスすることを確認

### テスト結果
[テスト結果の説明]

## 関連Issue
Closes #[番号]
Refs #[番号]

## レビューポイント
[レビュアーに特に見てほしい点]
```

---

## テスト戦略

### テストピラミッド

```
       /\
      /E2E\       少（実環境での動作確認: 手動）
     /------\
    /  apply  \   中（terraform test command = apply: 有料・CI任意）
   /------------\
  /  plan (unit) \ 多（terraform test command = plan: 無料・CI必須）
 /----------------\
```

**目標**:
- plan テスト: 主要モジュール全てに用意（CI で必ず実行）
- apply テスト: コスト・時間がかかるため任意（ローカルまたは定期CI）

### テストの書き方

**terraform test（plan = ユニット、apply = 統合）**:

```hcl
# tests/ecs.tftest.hcl

# ユニットテスト: plan のみ（インフラを作らない・無料）
run "ecs_cluster_name" {
  command = plan

  assert {
    condition     = aws_ecs_cluster.main.name == "home-smart-factory-cluster"
    error_message = "ECS クラスター名が期待値と一致しません"
  }
}

run "worker_uses_fargate_spot" {
  command = plan

  assert {
    condition = contains(
      [for s in aws_ecs_service.worker.capacity_provider_strategy : s.capacity_provider],
      "FARGATE_SPOT"
    )
    error_message = "Worker サービスが FARGATE_SPOT を使用していません"
  }
}

# 統合テスト: apply（実際にリソースを作成・有料）
run "ecs_cluster_is_created" {
  command = apply

  assert {
    condition     = aws_ecs_cluster.main.id != ""
    error_message = "ECS クラスターが作成されていません"
  }
}
```

**テスト実行**:

```bash
# plan テストのみ（高速・無料）
terraform test -filter=tests/ecs.tftest.hcl

# 全テスト（apply を含む: 有料・低速）
terraform test
```

---

## コードレビュープロセス

### レビューの目的

1. **品質保証**: 設定ミス・セキュリティリスクの早期発見
2. **知識共有**: チーム全体でインフラ構成を理解
3. **学習機会**: ベストプラクティスの共有

### 効果的なレビューのポイント

**レビュアー向け**:

1. **建設的なフィードバック**
```markdown
## ❌ 悪い例
このコードはダメです。

## ✅ 良い例
セキュリティグループのインバウンドが 0.0.0.0/0 になっています。
RDS へのアクセスは ECS のセキュリティグループからのみに絞れます:

resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_worker.id
  security_group_id        = aws_security_group.rds.id
}
```

2. **優先度の明示**
```markdown
[必須] セキュリティ: IAM ポリシーに * が使われています。最小権限に絞ってください
[必須] バグ: S3 バックエンドの encrypt = true が設定されていません
[推奨] コスト: Worker に FARGATE_SPOT を使うとコストを削減できます
[提案] 可読性: locals に共通タグをまとめると各リソースがすっきりします
[質問] この lifecycle ignore_changes の意図を教えてください
```

3. **ポジティブなフィードバックも**
```markdown
✨ モジュール分割がきれいですね！
👍 sensitive = true が漏れなく設定されています
💡 このパターンは他のリソースにも使えそうです
```

**レビュイー向け**:

1. **セルフレビューを実施**
   - PR 作成前に `terraform plan` の差分を自分で確認する
   - `terraform fmt -check` と `terraform validate` がパスしているか確認

2. **小さなPRを心がける**
   - 1PR = 1機能（モジュール単位）
   - 変更ファイル数: 10ファイル以内を推奨
   - 変更行数: 300行以内を推奨

3. **plan 差分を PR に貼る**
   - `terraform plan` の出力を PR 本文に貼り付ける
   - 削除されるリソースがある場合は特に強調して説明する

### レビュー時間の目安

- 小規模PR (100行以下): 15分
- 中規模PR (100-300行): 30分
- 大規模PR (300行以上): 1時間以上

**原則**: 大規模PRは避け、モジュール単位で分割する

---

## 自動化の推進

### 品質チェックの自動化

**自動化項目と採用ツール**:

1. **フォーマット**
   - `terraform fmt -check` でスタイル統一を強制
   - `terraform fmt -recursive` で一括修正

2. **バリデーション**
   - `terraform validate` で構文・設定の整合性チェック

3. **テスト実行**
   - `terraform test` で plan テストを実行

4. **静的解析（任意）**
   - **tflint**: Terraform ベストプラクティス違反を検出
   - **checkov / tfsec**: セキュリティリスク（公開 SG、暗号化なし S3 等）を検出

**CI/CD (GitHub Actions)**:

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform/envs/prod

    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "~1.15.0"

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1

      - name: terraform fmt
        run: terraform fmt -check -recursive

      - name: terraform init
        run: terraform init

      - name: terraform validate
        run: terraform validate

      - name: terraform test (plan only)
        run: terraform test
        env:
          TF_VAR_rds_password: ${{ secrets.TF_VAR_RDS_PASSWORD }}

      # main マージ時のみ apply
      - name: terraform apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve
        env:
          TF_VAR_rds_password: ${{ secrets.TF_VAR_RDS_PASSWORD }}
```

**Pre-commit フック（terraform fmt + validate）**:

```bash
# .git/hooks/pre-commit
#!/bin/sh
echo "Running pre-commit checks..."

terraform fmt -check -recursive
if [ $? -ne 0 ]; then
  echo "terraform fmt が失敗しました。'terraform fmt -recursive' を実行してください。"
  exit 1
fi

terraform validate
if [ $? -ne 0 ]; then
  echo "terraform validate が失敗しました。エラーを修正してください。"
  exit 1
fi
```

**導入効果**:
- コミット前にフォーマット漏れを防止
- PR 作成時に自動で plan が走り、差分をレビュアーが確認できる
- main マージ時に自動 apply することで手動オペレーションミスを防止

**この構成を選んだ理由**:
- `terraform fmt` / `terraform validate` / `terraform test` は Terraform 組み込みのため追加依存なし
- GitHub Actions の OIDC を使うと AWS_ACCESS_KEY_ID 不要になるが、初期設定コストを考慮し Key 方式を採用
- tflint / checkov は任意導入（学習コストを考慮）

---

## チェックリスト

- [ ] ブランチ戦略が決まっている
- [ ] コミットメッセージ規約が明確である
- [ ] PR テンプレートが用意されており terraform plan の差分を貼る運用になっている
- [ ] 主要モジュールに terraform test (plan) が用意されている
- [ ] コードレビュープロセスが定義されている
- [ ] CI/CD パイプラインが構築されている（GitHub Actions + terraform fmt / validate / test / apply）
- [ ] Secrets（RDS パスワード等）が GitHub Actions Secrets に登録されている
