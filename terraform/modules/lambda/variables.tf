variable "name_prefix" {
  description = "リソース命名プレフィックス"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda 実行 IAM ロール ARN（lambda-batch-restart-role）"
  type        = string
}

variable "batch_task_failure_sns_arn" {
  description = "SNS トリガー ARN（batch-task-failure トピック）"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS クラスター名（Lambda 環境変数 ECS_CLUSTER に渡す）"
  type        = string
}

variable "batch_task_definition_family" {
  description = "ECS Batch タスク定義ファミリー名（Lambda 環境変数 BATCH_TASK_DEFINITION に渡す）"
  type        = string
}

variable "subnet_id" {
  description = "Batch 再実行タスクを起動するサブネット ID（private-1a）"
  type        = string
}

variable "security_group_id" {
  description = "Batch 再実行タスクに適用するセキュリティグループ ID（sg-ecs-batch）"
  type        = string
}
