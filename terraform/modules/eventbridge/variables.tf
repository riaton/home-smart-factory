variable "name_prefix" {
  description = "リソース命名プレフィックス"
  type        = string
}

variable "aws_region" {
  description = "AWS リージョン（イベントパターン ARN 構築用）"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ECS クラスター ARN（スケジュールターゲット + イベントパターン）"
  type        = string
}

variable "batch_task_definition_arn" {
  description = "ECS Batch タスク定義 ARN（スケジュールターゲットの RunTask 設定）"
  type        = string
}

variable "batch_task_definition_family" {
  description = "ECS Batch タスク定義ファミリー名（イベントパターンの prefix 構築用）"
  type        = string
}

variable "eventbridge_role_arn" {
  description = "EventBridge ECS 実行ロール ARN（ECS RunTask の IAM ロール）"
  type        = string
}

variable "batch_task_failure_sns_arn" {
  description = "バッチタスク異常終了通知 SNS トピック ARN（batch-task-stopped-rule ターゲット）"
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
