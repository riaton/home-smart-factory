output "main_queue_url" {
  description = "メインキュー URL（ECS Worker がポーリングに使用）"
  value       = aws_sqs_queue.main.url
}

output "main_queue_arn" {
  description = "メインキュー ARN"
  value       = aws_sqs_queue.main.arn
}

output "main_queue_name" {
  description = "メインキュー名（plan 時点で既知）"
  value       = aws_sqs_queue.main.name
}

output "dlq_url" {
  description = "DLQ URL"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  description = "DLQ ARN"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "DLQ 名（plan 時点で既知）"
  value       = aws_sqs_queue.dlq.name
}
