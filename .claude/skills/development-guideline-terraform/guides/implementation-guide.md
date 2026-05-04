# 実装ガイド (Implementation Guide)

## Terraform 規約

本ガイドラインは **Terraform 1.15+** / **AWS Provider 6.x** を前提とします。

---

### 命名規則

**リソース名（スネークケース・名詞）**:

```hcl
# ✅ 良い例: スネークケース、リソースタイプを繰り返さない
resource "aws_vpc" "main" { }
resource "aws_subnet" "public" { }
resource "aws_security_group" "ecs_worker" { }
resource "aws_ecs_cluster" "main" { }

# ❌ 悪い例: タイプを繰り返す、キャメルケース
resource "aws_vpc" "main_vpc" { }           # vpc を繰り返している
resource "aws_subnet" "publicSubnet" { }    # キャメルケース
resource "aws_security_group" "sg_ecs" { }  # sg プレフィックス不要
```

**変数名・ローカル変数（スネークケース）**:

```hcl
# ✅ 良い例
variable "instance_type" { }
variable "rds_password" { }
locals {
  name_prefix    = "home-smart-factory"
  common_tags    = { ... }
  db_subnet_ids  = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

# ❌ 悪い例
variable "instanceType" { }   # キャメルケース
variable "RDSPassword" { }    # パスカルケース
```

**AWSリソースの Name タグ（ハイフン区切り）**:

```hcl
# ✅ 良い例: Name タグはハイフン区切り
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"  # home-smart-factory-cluster
}

resource "aws_sqs_queue" "iot_data" {
  name = "${local.name_prefix}-iot-data-queue"
}
```

---

### ディレクトリ構成

**モノリポ構成（本プロジェクト推奨）**:

```
terraform/
├── modules/                  ← 再利用可能なモジュール
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecs/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── sqs/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── envs/
│   └── prod/                 ← 本番環境（本PJは prod のみ）
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── locals.tf
│       ├── versions.tf
│       └── terraform.tfvars  ← 機密情報以外の変数値（gitignore 対象外）
└── tests/
    └── prod.tftest.hcl
```

**各ファイルの役割**:

| ファイル | 内容 |
|---|---|
| `main.tf` | リソース定義・モジュール呼び出し |
| `variables.tf` | 入力変数宣言（description / type / validation 必須） |
| `outputs.tf` | 出力値宣言 |
| `locals.tf` | ローカル変数（共通タグ・名前プレフィックス等） |
| `versions.tf` | Terraform / Provider バージョン制約 |
| `terraform.tfvars` | 変数値の設定ファイル |

---

### versions.tf（バージョン固定）

```hcl
# ✅ バージョンは常に固定する（~> でマイナーアップデートのみ許可）
terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket  = "home-smart-factory-tfstate"
    key     = "prod/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
```

---

### locals.tf（共通設定の集約）

```hcl
locals {
  name_prefix = "home-smart-factory"
  env         = "prod"

  # 全リソースに付与する共通タグ（provider の default_tags で自動付与）
  common_tags = {
    Project     = "home-smart-factory"
    Environment = local.env
    ManagedBy   = "terraform"
  }
}
```

---

### variables.tf（変数定義）

```hcl
# ✅ 良い例: description / type / validation を必ず記述
variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "rds_instance_class" {
  description = "RDS インスタンスタイプ"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.", var.rds_instance_class))
    error_message = "rds_instance_class は 'db.' で始まる必要があります。"
  }
}

variable "rds_password" {
  description = "RDS マスターパスワード（環境変数 TF_VAR_rds_password で設定）"
  type        = string
  sensitive   = true  # plan/apply の出力からマスクされる
}

# ❌ 悪い例: description なし、型なし
variable "password" { }
```

---

### リソース定義のベストプラクティス

**タグ戦略**:

```hcl
# ✅ provider の default_tags + リソース固有タグを組み合わせる
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  # リソース固有の追加タグのみここに記述
  # common_tags は provider の default_tags で自動付与
  tags = {
    Component = "ecs"
  }
}
```

**依存関係は明示しない（暗黙の依存を活用）**:

```hcl
# ✅ 良い例: 参照で暗黙の依存を表現
resource "aws_ecs_service" "worker" {
  cluster = aws_ecs_cluster.main.id  # 参照により自動的に依存関係が設定される
  # ...
}

# ❌ 悪い例: 不要な depends_on（参照で十分な場合）
resource "aws_ecs_service" "worker" {
  cluster    = aws_ecs_cluster.main.id
  depends_on = [aws_ecs_cluster.main]  # 冗長
}

# ✅ 良い例: 参照がない場合のみ depends_on を使用
resource "aws_ecs_service" "worker" {
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution]
}
```

**lifecycle の活用**:

```hcl
# RDS はうっかり削除を防ぐ
resource "aws_db_instance" "main" {
  # ...
  lifecycle {
    prevent_destroy = true
    # パスワード変更はTerraform外で行うため ignore
    ignore_changes = [password]
  }
}

# ECS タスク定義は新バージョンに置き換えるため古いものを残す
resource "aws_ecs_task_definition" "worker" {
  # ...
  lifecycle {
    create_before_destroy = true
  }
}
```

---

### モジュール設計

**モジュールを作るべき判断基準**:
- 同じリソースセットを複数箇所で使い回す場合
- 10リソース以上が1つの論理コンポーネントを構成する場合

**モジュールの呼び出し**:

```hcl
# envs/prod/main.tf
module "vpc" {
  source = "../../modules/vpc"

  name_prefix      = local.name_prefix
  vpc_cidr         = "10.0.0.0/16"
  az_count         = 2
}

module "rds" {
  source = "../../modules/rds"

  name_prefix    = local.name_prefix
  instance_class = var.rds_instance_class
  password       = var.rds_password
  subnet_ids     = module.vpc.private_subnet_ids
  vpc_id         = module.vpc.vpc_id
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  db_endpoint    = module.rds.endpoint
  sqs_queue_url  = module.sqs.queue_url
}
```

**モジュールの outputs.tf（必要最小限を公開）**:

```hcl
# modules/vpc/outputs.tf
output "vpc_id" {
  description = "VPC の ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "プライベートサブネット ID のリスト"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "パブリックサブネット ID のリスト"
  value       = aws_subnet.public[*].id
}
```

---

### セキュリティ

**機密情報の管理**:

```hcl
# ✅ 良い例: sensitive = true でマスク
variable "rds_password" {
  type      = string
  sensitive = true
}

# ✅ 環境変数から注入（TF_VAR_rds_password）
# CI/CD では GitHub Actions Secrets から注入

# ❌ 悪い例: terraform.tfvars にパスワードを直書き（git に含まれる危険）
# rds_password = "plaintext_password"  # NG

# ✅ terraform.tfvars は機密情報を含まない値のみ
# rds_instance_class = "db.t3.micro"
# aws_region         = "ap-northeast-1"
```

**最小権限の IAM ポリシー**:

```hcl
# ✅ 良い例: Resource を絞る
resource "aws_iam_role_policy" "ecs_worker" {
  name = "${local.name_prefix}-ecs-worker"
  role = aws_iam_role.ecs_worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.iot_data.arn
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.anomaly_alert.arn
      }
    ]
  })
}

# ❌ 悪い例: ワイルドカードで過剰な権限
policy = jsonencode({
  Statement = [{
    Effect   = "Allow"
    Action   = ["*"]         # NG
    Resource = "*"            # NG
  }]
})
```

**セキュリティグループは最小開放**:

```hcl
# ✅ 良い例: 必要なポートのみ、CIDR は絞る
resource "aws_security_group" "rds" {
  name   = "${local.name_prefix}-rds"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_worker.id]  # ECS からのみ許可
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ❌ 悪い例: 全世界に開放
ingress {
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # NG
}
```

---

### ステート管理

**S3 バックエンド（暗号化）**:

```hcl
# versions.tf
terraform {
  backend "s3" {
    bucket  = "home-smart-factory-tfstate"
    key     = "prod/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true  # SSE-S3 暗号化
    # dynamodb_table は個人プロジェクトのため不要（同時実行しない）
  }
}
```

**ステートバケット自体は別途手動作成（初回のみ）**:

```bash
aws s3api create-bucket \
  --bucket home-smart-factory-tfstate \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-versioning \
  --bucket home-smart-factory-tfstate \
  --versioning-configuration Status=Enabled
```

---

### テスト

**terraform test（Terraform 1.6+ 組み込みテストフレームワーク）**:

```
tests/
└── vpc.tftest.hcl
└── ecs.tftest.hcl
```

```hcl
# tests/vpc.tftest.hcl

# ユニットテスト: plan のみ実行（インフラを実際に作らない）
run "vpc_cidr_validation" {
  command = plan

  variables {
    vpc_cidr = "10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR が期待値と一致しません"
  }
}

# 統合テスト: 実際に apply して検証（CI でのみ実行）
run "vpc_is_created" {
  command = apply

  assert {
    condition     = aws_vpc.main.enable_dns_hostnames == true
    error_message = "DNS ホスト名が有効になっていません"
  }
}
```

**テスト実行**:

```bash
# ユニットテスト（plan のみ: 高速、無料）
terraform test -filter=tests/vpc.tftest.hcl

# 統合テスト（実際のリソースを作成: 有料・低速）
terraform test

# 全テスト
terraform test
```

---

## コメント規約

```hcl
# ✅ 設計上の理由・非自明な制約を説明する
# device_id は varchar のため DB CASCADE が使えない。
# デバイス削除はアプリ層でトランザクション管理するため SQS キューを別途参照している。
resource "aws_sqs_queue" "iot_data_dlq" { }

# ✅ WHY を説明する（WHAT はコードを見ればわかる）
# grafana_ro は Grafana 専用の読み取り専用ユーザー。
# アプリ用ユーザーとは分離し、RDS の IAM 認証ではなくパスワード認証を使用する。
resource "aws_db_instance" "main" { }

# ❌ コードをそのまま説明するだけ
# RDS インスタンスを作成する
resource "aws_db_instance" "main" { }
```

---

## パフォーマンス・コスト

```hcl
# ✅ for_each でリソースを効率的に管理（count より柔軟）
resource "aws_subnet" "private" {
  for_each = {
    "a" = "10.0.10.0/24"
    "c" = "10.0.11.0/24"
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "ap-northeast-1${each.key}"
}

# ✅ ECS Fargate Spot でコスト最適化（Worker は中断許容）
resource "aws_ecs_service" "worker" {
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }
}

# ✅ RDS は開発中のみ小インスタンス、prod では適切なサイズ
variable "rds_instance_class" {
  default = "db.t3.micro"
}
```

---

## チェックリスト

### コード品質
- [ ] リソース名がスネークケースで、タイプ名を繰り返していない
- [ ] 変数に `description` と `type` が付いている
- [ ] `sensitive = true` が機密変数に設定されている
- [ ] `locals.tf` に共通タグ・名前プレフィックスが集約されている
- [ ] `versions.tf` でバージョンが固定されている

### セキュリティ
- [ ] IAM ポリシーが最小権限になっている（`*` が使われていない）
- [ ] セキュリティグループのインバウンドが必要最小限に絞られている
- [ ] terraform.tfvars に機密情報が含まれていない
- [ ] S3 バックエンドで `encrypt = true` と DynamoDB ロックが設定されている

### ステート管理
- [ ] リモートバックエンド（S3）が設定されている
- [ ] `terraform plan` がエラーなく通る
- [ ] `terraform validate` がパスする
- [ ] `terraform fmt -check` がパスする

### テスト
- [ ] 主要モジュールに `terraform test` の plan テストがある
- [ ] `terraform test` が全てパスする

### ツール
- [ ] `terraform fmt` でフォーマット済み
- [ ] `terraform validate` でバリデーション済み
- [ ] `tflint` でベストプラクティス違反がない（任意）
- [ ] `checkov` または `tfsec` でセキュリティスキャン済み（任意）
