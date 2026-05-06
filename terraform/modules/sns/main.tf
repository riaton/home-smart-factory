resource "aws_sns_topic" "anomaly_notification" {
  name = "${var.name_prefix}-iot-anomaly-notification"

  tags = {
    Name = "${var.name_prefix}-iot-anomaly-notification"
  }
}

resource "aws_sns_topic_subscription" "anomaly_email" {
  topic_arn = aws_sns_topic.anomaly_notification.arn
  protocol  = "email"
  endpoint  = var.operator_email
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "${var.name_prefix}-cloudwatch-alarms"

  tags = {
    Name = "${var.name_prefix}-cloudwatch-alarms"
  }
}

resource "aws_sns_topic_subscription" "cloudwatch_email" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.operator_email
}

# Lambda サブスクリプションは Lambda モジュールで追加（循環依存回避）
resource "aws_sns_topic" "batch_task_failure" {
  name = "${var.name_prefix}-batch-task-failure"

  tags = {
    Name = "${var.name_prefix}-batch-task-failure"
  }
}
