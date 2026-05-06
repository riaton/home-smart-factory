output "vpc_id" {
  description = "VPC の ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "パブリックサブネット ID のマップ"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "プライベートサブネット ID のマップ"
  value       = module.vpc.private_subnet_ids
}

output "sg_alb_id" {
  description = "ALB セキュリティグループ ID"
  value       = module.vpc.sg_alb_id
}

output "sg_ecs_backend_id" {
  description = "ECS Backend セキュリティグループ ID"
  value       = module.vpc.sg_ecs_backend_id
}

output "sg_ecs_worker_id" {
  description = "ECS Worker セキュリティグループ ID"
  value       = module.vpc.sg_ecs_worker_id
}

output "sg_ecs_batch_id" {
  description = "ECS Batch セキュリティグループ ID"
  value       = module.vpc.sg_ecs_batch_id
}

output "sg_rds_id" {
  description = "RDS セキュリティグループ ID"
  value       = module.vpc.sg_rds_id
}

output "sg_redis_id" {
  description = "Redis セキュリティグループ ID"
  value       = module.vpc.sg_redis_id
}

output "sg_grafana_id" {
  description = "Grafana セキュリティグループ ID"
  value       = module.vpc.sg_grafana_id
}

output "execution_role_arn" {
  description = "ECS タスク実行ロール ARN"
  value       = module.iam.execution_role_arn
}

output "ecs_worker_task_role_arn" {
  description = "ECS Worker タスクロール ARN"
  value       = module.iam.ecs_worker_task_role_arn
}

output "ecs_batch_task_role_arn" {
  description = "ECS Batch タスクロール ARN"
  value       = module.iam.ecs_batch_task_role_arn
}

output "ecs_backend_task_role_arn" {
  description = "ECS Backend タスクロール ARN"
  value       = module.iam.ecs_backend_task_role_arn
}

output "ecs_grafana_task_role_arn" {
  description = "ECS Grafana タスクロール ARN"
  value       = module.iam.ecs_grafana_task_role_arn
}

output "lambda_batch_restart_role_arn" {
  description = "Lambda バッチ再実行ロール ARN"
  value       = module.iam.lambda_batch_restart_role_arn
}

output "eventbridge_ecs_role_arn" {
  description = "EventBridge ECS 実行ロール ARN"
  value       = module.iam.eventbridge_ecs_role_arn
}

output "ecr_repository_urls" {
  description = "ECR リポジトリ URL のマップ（サービス名 → URL）"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ECR リポジトリ ARN のマップ（サービス名 → ARN）"
  value       = module.ecr.repository_arns
}

output "db_endpoint" {
  description = "RDS エンドポイント（ホスト名）"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS ポート番号"
  value       = module.rds.db_port
}

output "db_name" {
  description = "データベース名"
  value       = module.rds.db_name
}

output "redis_primary_endpoint" {
  description = "Redis プライマリエンドポイント"
  value       = module.elasticache.redis_primary_endpoint
}

output "redis_port" {
  description = "Redis ポート番号"
  value       = module.elasticache.redis_port
}

output "main_queue_url" {
  description = "SQS メインキュー URL"
  value       = module.sqs.main_queue_url
}

output "main_queue_arn" {
  description = "SQS メインキュー ARN"
  value       = module.sqs.main_queue_arn
}

output "dlq_url" {
  description = "SQS DLQ URL"
  value       = module.sqs.dlq_url
}

output "anomaly_notification_arn" {
  description = "異常検知通知 SNS トピック ARN"
  value       = module.sns.anomaly_notification_arn
}

output "cloudwatch_alarms_arn" {
  description = "CloudWatch アラーム通知 SNS トピック ARN"
  value       = module.sns.cloudwatch_alarms_arn
}

output "batch_task_failure_arn" {
  description = "バッチタスク異常終了通知 SNS トピック ARN"
  value       = module.sns.batch_task_failure_arn
}

output "iot_rule_name" {
  description = "IoT Topic Rule 名"
  value       = module.iot.iot_rule_name
}

output "iot_policy_name" {
  description = "IoT デバイスポリシー名"
  value       = module.iot.iot_policy_name
}

output "iot_thing_name" {
  description = "IoT Thing 名（Raspberry Pi デバイス名）"
  value       = module.iot.thing_name
}

output "iot_certificate_arn" {
  description = "IoT X.509 証明書 ARN"
  value       = module.iot.certificate_arn
}

output "iot_rule_log_group_name" {
  description = "IoT Rule エラーログ CloudWatch ロググループ名"
  value       = module.iot.iot_rule_log_group_name
}
