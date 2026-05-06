output "function_name" {
  description = "Lambda 関数名（name_prefix から確定）"
  value       = aws_lambda_function.batch_restart.function_name
}

output "function_arn" {
  description = "Lambda 関数 ARN"
  value       = aws_lambda_function.batch_restart.arn
}

output "log_group_name" {
  description = "CloudWatch ロググループ名（name_prefix から確定）"
  value       = aws_cloudwatch_log_group.batch_restart.name
}
