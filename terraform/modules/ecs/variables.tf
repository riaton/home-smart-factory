variable "name_prefix" {
  description = "全リソース名に付与するプレフィックス"
  type        = string
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
}

# ---------------------------------------------------------------
# IAM ロール ARN（IAM モジュールから受け取る）
# ---------------------------------------------------------------

variable "execution_role_arn" {
  description = "ECS タスク実行ロール ARN（全サービス共通）"
  type        = string
}

variable "worker_task_role_arn" {
  description = "ECS Worker タスクロール ARN"
  type        = string
}

variable "batch_task_role_arn" {
  description = "ECS Batch タスクロール ARN"
  type        = string
}

variable "backend_task_role_arn" {
  description = "ECS Backend タスクロール ARN"
  type        = string
}

variable "grafana_task_role_arn" {
  description = "ECS Grafana タスクロール ARN"
  type        = string
}

# ---------------------------------------------------------------
# コンテナイメージ URI（ECR モジュールから受け取る）
# ---------------------------------------------------------------

variable "worker_image" {
  description = "ECS Worker コンテナイメージ URI（ECR リポジトリ URL + タグ）"
  type        = string
}

variable "batch_image" {
  description = "ECS Batch コンテナイメージ URI（ECR リポジトリ URL + タグ）"
  type        = string
}

variable "backend_image" {
  description = "ECS Backend コンテナイメージ URI（ECR リポジトリ URL + タグ）"
  type        = string
}

variable "grafana_image" {
  description = "Grafana コンテナイメージ URI（ECR リポジトリ URL + タグ）"
  type        = string
}

# ---------------------------------------------------------------
# ネットワーク設定（VPC モジュールから受け取る）
# ---------------------------------------------------------------

variable "private_subnet_ids" {
  description = "プライベートサブネット ID のマップ（キー: AZ suffix）"
  type        = map(string)
}

variable "public_subnet_ids" {
  description = "パブリックサブネット ID のマップ（キー: AZ suffix）"
  type        = map(string)
}

variable "sg_ecs_worker_id" {
  description = "ECS Worker セキュリティグループ ID"
  type        = string
}

variable "sg_ecs_batch_id" {
  description = "ECS Batch セキュリティグループ ID"
  type        = string
}

variable "sg_ecs_backend_id" {
  description = "ECS Backend セキュリティグループ ID"
  type        = string
}

variable "sg_grafana_id" {
  description = "Grafana セキュリティグループ ID"
  type        = string
}

# ---------------------------------------------------------------
# RDS 接続情報（RDS モジュールから受け取る）
# ---------------------------------------------------------------

variable "db_endpoint" {
  description = "RDS エンドポイント（ホスト名）"
  type        = string
}

variable "db_port" {
  description = "RDS ポート番号"
  type        = number
}

variable "db_name" {
  description = "データベース名"
  type        = string
}

# ---------------------------------------------------------------
# Redis 接続情報（ElastiCache モジュールから受け取る）
# ---------------------------------------------------------------

variable "redis_primary_endpoint" {
  description = "Redis プライマリエンドポイント"
  type        = string
}

variable "redis_port" {
  description = "Redis ポート番号"
  type        = number
}

# ---------------------------------------------------------------
# SQS 接続情報（SQS モジュールから受け取る）
# ---------------------------------------------------------------

variable "main_queue_url" {
  description = "SQS メインキュー URL（Worker の環境変数として渡す）"
  type        = string
}

variable "main_queue_arn" {
  description = "SQS メインキュー ARN（Auto Scaling アラームの dimensions に使用）"
  type        = string
}

# ---------------------------------------------------------------
# ALB 統合（ALB モジュールから受け取る）
# ---------------------------------------------------------------

variable "target_group_arn" {
  description = "ALB ターゲットグループ ARN（Backend サービスのロードバランサー統合）"
  type        = string
}
