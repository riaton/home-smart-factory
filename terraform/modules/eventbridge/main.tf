data "aws_caller_identity" "current" {}

locals {
  np         = var.name_prefix
  account_id = data.aws_caller_identity.current.account_id

  batch_task_def_arn_prefix = "arn:aws:ecs:${var.aws_region}:${local.account_id}:task-definition/${var.batch_task_definition_family}"
}

# ---------------------------------------------------------------
# 日次レポートバッチスケジュール（9.1）
# ---------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.np}-daily-report-batch-schedule"
  description         = "毎日 03:00 JST に ECS Batch タスクを起動する"
  schedule_expression = "cron(0 18 * * ? *)"
  state               = "ENABLED"

  tags = {
    Name = "${local.np}-daily-report-batch-schedule"
  }
}

resource "aws_cloudwatch_event_target" "schedule_ecs" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "BatchTaskTarget"
  arn       = var.ecs_cluster_arn
  role_arn  = var.eventbridge_role_arn

  ecs_target {
    task_definition_arn = var.batch_task_definition_arn
    task_count          = 1
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = [var.subnet_id]
      security_groups  = [var.security_group_id]
      assign_public_ip = false
    }
  }
}

# ---------------------------------------------------------------
# バッチタスク異常停止検知ルール（9.2）
# ---------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "batch_stopped" {
  name        = "${local.np}-batch-task-stopped-rule"
  description = "ECS Batch タスクの異常終了を検知して SNS へ通知する"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    "detail-type" = ["ECS Task State Change"]
    detail = {
      clusterArn = [var.ecs_cluster_arn]
      taskDefinitionArn = [
        { prefix = local.batch_task_def_arn_prefix }
      ]
      lastStatus = ["STOPPED"]
      stopCode   = ["TaskFailedToStart", "EssentialContainerExited"]
      startedBy  = [{ "anything-but" = "lambda-restart" }]
      containers = {
        exitCode = [{ "anything-but" = 0 }]
      }
    }
  })

  tags = {
    Name = "${local.np}-batch-task-stopped-rule"
  }
}

resource "aws_cloudwatch_event_target" "batch_stopped_sns" {
  rule      = aws_cloudwatch_event_rule.batch_stopped.name
  target_id = "BatchFailureSNSTarget"
  arn       = var.batch_task_failure_sns_arn
}

# ---------------------------------------------------------------
# EventBridge → SNS Publish 許可ポリシー
# ---------------------------------------------------------------

data "aws_iam_policy_document" "batch_failure_sns" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [var.batch_task_failure_sns_arn]
  }
}

resource "aws_sns_topic_policy" "batch_failure" {
  arn    = var.batch_task_failure_sns_arn
  policy = data.aws_iam_policy_document.batch_failure_sns.json
}
