output "schedule_rule_name" {
  description = "日次バッチスケジュールルール名（name_prefix から確定）"
  value       = aws_cloudwatch_event_rule.schedule.name
}

output "batch_stopped_rule_name" {
  description = "バッチタスク異常停止検知ルール名（name_prefix から確定）"
  value       = aws_cloudwatch_event_rule.batch_stopped.name
}
