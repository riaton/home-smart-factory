output "anomaly_notification_arn" {
  description = "異常検知通知 SNS トピック ARN"
  value       = aws_sns_topic.anomaly_notification.arn
}

output "anomaly_notification_name" {
  description = "異常検知通知 SNS トピック名"
  value       = aws_sns_topic.anomaly_notification.name
}

output "cloudwatch_alarms_arn" {
  description = "CloudWatch アラーム通知 SNS トピック ARN"
  value       = aws_sns_topic.cloudwatch_alarms.arn
}

output "cloudwatch_alarms_name" {
  description = "CloudWatch アラーム通知 SNS トピック名"
  value       = aws_sns_topic.cloudwatch_alarms.name
}

output "batch_task_failure_arn" {
  description = "バッチタスク異常終了通知 SNS トピック ARN"
  value       = aws_sns_topic.batch_task_failure.arn
}

output "batch_task_failure_name" {
  description = "バッチタスク異常終了通知 SNS トピック名"
  value       = aws_sns_topic.batch_task_failure.name
}
