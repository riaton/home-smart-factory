output "anomaly_insert_failure_alarm_name" {
  description = "異常検知失敗アラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.anomaly_insert_failure.alarm_name
}

output "iot_data_dlq_alarm_name" {
  description = "DLQ メッセージ蓄積アラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.iot_data_dlq.alarm_name
}

output "rds_cpu_high_alarm_name" {
  description = "RDS CPU 使用率アラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name
}

output "rds_storage_low_alarm_name" {
  description = "RDS ストレージ残量アラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.rds_storage_low.alarm_name
}

output "rds_connections_high_alarm_name" {
  description = "RDS 接続数アラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.rds_connections_high.alarm_name
}

output "ecs_worker_task_count_low_alarm_name" {
  description = "ECS Worker タスク数アラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.ecs_worker_task_count_low.alarm_name
}

output "iot_rule_error_alarm_name" {
  description = "IoT ルールエラーアラーム名（name_prefix から確定）"
  value       = aws_cloudwatch_metric_alarm.iot_rule_error.alarm_name
}
