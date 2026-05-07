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

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "alb_name" {
  description = "ALB 名"
  value       = module.alb.alb_name
}

output "alb_dns_name" {
  description = "ALB の DNS 名（CNAME レコード設定に使用）"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB の Route53 Hosted Zone ID（Alias レコード設定に使用）"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "Backend ターゲットグループ ARN"
  value       = module.alb.target_group_arn
}

output "target_group_name" {
  description = "Backend ターゲットグループ名"
  value       = module.alb.target_group_name
}

output "certificate_arn" {
  description = "ACM 証明書 ARN"
  value       = module.alb.certificate_arn
}

output "acm_validation_options" {
  description = "ACM DNS 検証レコード情報（apply 前に DNS へ手動追加すること）"
  value       = module.alb.acm_validation_options
}

output "ecs_cluster_name" {
  description = "ECS クラスター名"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS クラスター ARN"
  value       = module.ecs.cluster_arn
}

output "worker_task_definition_arn" {
  description = "ECS Worker タスク定義 ARN"
  value       = module.ecs.worker_task_definition_arn
}

output "batch_task_definition_arn" {
  description = "ECS Batch タスク定義 ARN"
  value       = module.ecs.batch_task_definition_arn
}

output "backend_task_definition_arn" {
  description = "ECS Backend タスク定義 ARN"
  value       = module.ecs.backend_task_definition_arn
}

output "grafana_task_definition_arn" {
  description = "ECS Grafana タスク定義 ARN"
  value       = module.ecs.grafana_task_definition_arn
}

output "worker_log_group_name" {
  description = "ECS Worker CloudWatch ロググループ名"
  value       = module.ecs.worker_log_group_name
}

output "batch_log_group_name" {
  description = "ECS Batch CloudWatch ロググループ名"
  value       = module.ecs.batch_log_group_name
}

output "backend_log_group_name" {
  description = "ECS Backend CloudWatch ロググループ名"
  value       = module.ecs.backend_log_group_name
}

output "grafana_log_group_name" {
  description = "ECS Grafana CloudWatch ロググループ名"
  value       = module.ecs.grafana_log_group_name
}

output "lambda_function_name" {
  description = "Lambda バッチ再実行関数名"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "Lambda バッチ再実行関数 ARN"
  value       = module.lambda.function_arn
}

output "lambda_log_group_name" {
  description = "Lambda バッチ再実行 CloudWatch ロググループ名"
  value       = module.lambda.log_group_name
}

output "schedule_rule_name" {
  description = "日次バッチスケジュール EventBridge ルール名"
  value       = module.eventbridge.schedule_rule_name
}

output "batch_stopped_rule_name" {
  description = "バッチタスク異常停止検知 EventBridge ルール名"
  value       = module.eventbridge.batch_stopped_rule_name
}

output "anomaly_insert_failure_alarm_name" {
  description = "異常検知失敗 CloudWatch アラーム名"
  value       = module.cloudwatch.anomaly_insert_failure_alarm_name
}

output "iot_data_dlq_alarm_name" {
  description = "DLQ メッセージ蓄積 CloudWatch アラーム名"
  value       = module.cloudwatch.iot_data_dlq_alarm_name
}

output "rds_cpu_high_alarm_name" {
  description = "RDS CPU 使用率 CloudWatch アラーム名"
  value       = module.cloudwatch.rds_cpu_high_alarm_name
}

output "rds_storage_low_alarm_name" {
  description = "RDS ストレージ残量 CloudWatch アラーム名"
  value       = module.cloudwatch.rds_storage_low_alarm_name
}

output "rds_connections_high_alarm_name" {
  description = "RDS 接続数 CloudWatch アラーム名"
  value       = module.cloudwatch.rds_connections_high_alarm_name
}

output "ecs_worker_task_count_low_alarm_name" {
  description = "ECS Worker タスク数 CloudWatch アラーム名"
  value       = module.cloudwatch.ecs_worker_task_count_low_alarm_name
}

output "iot_rule_error_alarm_name" {
  description = "IoT ルールエラー CloudWatch アラーム名"
  value       = module.cloudwatch.iot_rule_error_alarm_name
}
