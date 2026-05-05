output "execution_role_arn" {
  description = "ECS タスク実行ロール ARN（全 ECS タスク共通）"
  value       = aws_iam_role.execution.arn
}

output "ecs_worker_task_role_arn" {
  description = "ECS Worker タスクロール ARN"
  value       = aws_iam_role.ecs_worker.arn
}

output "ecs_batch_task_role_arn" {
  description = "ECS Batch タスクロール ARN"
  value       = aws_iam_role.ecs_batch.arn
}

output "ecs_backend_task_role_arn" {
  description = "ECS Backend タスクロール ARN"
  value       = aws_iam_role.ecs_backend.arn
}

output "ecs_grafana_task_role_arn" {
  description = "ECS Grafana タスクロール ARN"
  value       = aws_iam_role.ecs_grafana.arn
}

output "lambda_batch_restart_role_arn" {
  description = "Lambda バッチ再実行ロール ARN"
  value       = aws_iam_role.lambda_batch_restart.arn
}

output "eventbridge_ecs_role_arn" {
  description = "EventBridge ECS 実行ロール ARN"
  value       = aws_iam_role.eventbridge_ecs.arn
}

# plan テスト用：ロール名は設定値から確定するため plan 時点で既知
output "role_names" {
  description = "作成される全 IAM ロール名のマップ"
  value = {
    execution           = aws_iam_role.execution.name
    ecs_worker          = aws_iam_role.ecs_worker.name
    ecs_batch           = aws_iam_role.ecs_batch.name
    ecs_backend         = aws_iam_role.ecs_backend.name
    ecs_grafana         = aws_iam_role.ecs_grafana.name
    lambda_batch_restart = aws_iam_role.lambda_batch_restart.name
    eventbridge_ecs     = aws_iam_role.eventbridge_ecs.name
  }
}
