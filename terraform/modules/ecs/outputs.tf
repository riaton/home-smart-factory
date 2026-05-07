output "cluster_name" {
  description = "ECS クラスター名"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS クラスター ARN"
  value       = aws_ecs_cluster.main.arn
}

output "worker_task_definition_arn" {
  description = "ECS Worker タスク定義 ARN"
  value       = aws_ecs_task_definition.worker.arn
}

output "batch_task_definition_arn" {
  description = "ECS Batch タスク定義 ARN"
  value       = aws_ecs_task_definition.batch.arn
}

output "batch_task_definition_family" {
  description = "ECS Batch タスク定義ファミリー名（EventBridge モジュールで参照）"
  value       = aws_ecs_task_definition.batch.family
}

output "backend_task_definition_arn" {
  description = "ECS Backend タスク定義 ARN"
  value       = aws_ecs_task_definition.backend.arn
}

output "grafana_task_definition_arn" {
  description = "ECS Grafana タスク定義 ARN"
  value       = aws_ecs_task_definition.grafana.arn
}

output "worker_log_group_name" {
  description = "ECS Worker CloudWatch ロググループ名"
  value       = aws_cloudwatch_log_group.worker.name
}

output "batch_log_group_name" {
  description = "ECS Batch CloudWatch ロググループ名"
  value       = aws_cloudwatch_log_group.batch.name
}

output "backend_log_group_name" {
  description = "ECS Backend CloudWatch ロググループ名"
  value       = aws_cloudwatch_log_group.backend.name
}

output "grafana_log_group_name" {
  description = "ECS Grafana CloudWatch ロググループ名"
  value       = aws_cloudwatch_log_group.grafana.name
}
