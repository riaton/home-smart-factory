locals {
  np            = var.name_prefix
  function_name = "${local.np}-batch-restart-function"
}

data "archive_file" "batch_restart" {
  type        = "zip"
  source_file = "${path.module}/src/batch_restart.py"
  output_path = "${path.module}/batch_restart.zip"
}

resource "aws_cloudwatch_log_group" "batch_restart" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 365

  tags = {
    Name = "/aws/lambda/${local.function_name}"
  }
}

resource "aws_lambda_function" "batch_restart" {
  filename         = data.archive_file.batch_restart.output_path
  source_code_hash = data.archive_file.batch_restart.output_base64sha256
  function_name    = local.function_name
  role             = var.lambda_role_arn
  runtime          = "python3.12"
  handler          = "batch_restart.handler"
  memory_size      = 128
  timeout          = 30

  environment {
    variables = {
      ECS_CLUSTER           = var.ecs_cluster_name
      BATCH_TASK_DEFINITION = var.batch_task_definition_family
      SUBNET_ID             = var.subnet_id
      SECURITY_GROUP_ID     = var.security_group_id
    }
  }

  # ロググループを先に作成することで Lambda が自動生成したグループに retention が設定されない問題を防ぐ
  depends_on = [aws_cloudwatch_log_group.batch_restart]

  tags = {
    Name = local.function_name
  }
}

resource "aws_sns_topic_subscription" "batch_restart" {
  topic_arn = var.batch_task_failure_sns_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.batch_restart.arn
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_restart.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.batch_task_failure_sns_arn
}
