variable "name_prefix" {
  description = "リソース名プレフィックス（RDS identifier = {name_prefix}-rds として使用）"
  type        = string
}

variable "cloudwatch_alarms_sns_arn" {
  description = "CloudWatch アラーム通知先 SNS トピック ARN"
  type        = string
}

variable "worker_log_group_name" {
  description = "ECS Worker CloudWatch ロググループ名（メトリクスフィルター用）"
  type        = string
}

variable "dlq_name" {
  description = "SQS DLQ キュー名（DLQ メッセージ蓄積アラームの dimension）"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS クラスター名（Worker タスク数アラームの dimension）"
  type        = string
}

variable "iot_rule_name" {
  description = "IoT Topic Rule 名（IoT ルールエラーアラームの dimension）"
  type        = string
}
