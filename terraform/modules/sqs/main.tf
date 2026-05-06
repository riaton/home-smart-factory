# DLQ を先に定義（main キューの redrive_policy が ARN を参照するため）
resource "aws_sqs_queue" "dlq" {
  name = "${var.name_prefix}-iot-data-dlq"

  message_retention_seconds  = 1209600 # 14日
  visibility_timeout_seconds = 30
  sqs_managed_sse_enabled    = true

  tags = {
    Name = "${var.name_prefix}-iot-data-dlq"
  }
}

resource "aws_sqs_queue" "main" {
  name = "${var.name_prefix}-iot-data-queue"

  message_retention_seconds  = 345600 # 4日
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 20 # ロングポーリング
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${var.name_prefix}-iot-data-queue"
  }
}
