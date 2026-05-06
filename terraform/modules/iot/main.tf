data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# ---------------------------------------------------------------
# CloudWatch ロググループ（IoT Rule エラーアクション用）
# ---------------------------------------------------------------

resource "aws_cloudwatch_log_group" "iot_rule_errors" {
  name              = "/aws/iotcore/rule-errors"
  retention_in_days = 365
}

# ---------------------------------------------------------------
# IAM ロール（IoT Topic Rule が SQS 送信 + CW Logs 書き込みに使用）
# ---------------------------------------------------------------

data "aws_iam_policy_document" "iot_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iot_rule" {
  name               = "${var.name_prefix}-iot-rule"
  assume_role_policy = data.aws_iam_policy_document.iot_assume.json

  tags = {
    Name = "${var.name_prefix}-iot-rule"
  }
}

data "aws_iam_policy_document" "iot_rule" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [var.sqs_queue_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.iot_rule_errors.arn,
      "${aws_cloudwatch_log_group.iot_rule_errors.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "iot_rule" {
  name   = "${var.name_prefix}-iot-rule"
  role   = aws_iam_role.iot_rule.id
  policy = data.aws_iam_policy_document.iot_rule.json
}

# ---------------------------------------------------------------
# IoT デバイスポリシー
# ---------------------------------------------------------------

resource "aws_iot_policy" "device" {
  name = "${var.name_prefix}-device-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iot:Connect"
        Resource = "arn:aws:iot:${var.aws_region}:${local.account_id}:client/$${iot:Connection.Thing.ThingName}"
      },
      {
        Effect   = "Allow"
        Action   = "iot:Publish"
        Resource = "arn:aws:iot:${var.aws_region}:${local.account_id}:topic/home/devices/$${iot:Connection.Thing.ThingName}/data"
      },
    ]
  })
}

# ---------------------------------------------------------------
# IoT Thing（Raspberry Pi デバイス登録）
# ---------------------------------------------------------------

resource "aws_iot_thing" "raspberry_pi" {
  name = var.thing_name
}

# ---------------------------------------------------------------
# IoT X.509 証明書
# ---------------------------------------------------------------

resource "aws_iot_certificate" "raspberry_pi" {
  active = true
}

resource "aws_iot_policy_attachment" "raspberry_pi" {
  policy = aws_iot_policy.device.name
  target = aws_iot_certificate.raspberry_pi.arn
}

resource "aws_iot_thing_principal_attachment" "raspberry_pi" {
  thing     = aws_iot_thing.raspberry_pi.name
  principal = aws_iot_certificate.raspberry_pi.arn
}

# ---------------------------------------------------------------
# IoT Topic Rule（SQS 転送）
# ---------------------------------------------------------------

resource "aws_iot_topic_rule" "to_sqs" {
  name        = "iot_to_sqs_rule"
  enabled     = true
  sql         = "SELECT * FROM 'home/devices/+/data'"
  sql_version = "2016-03-23"

  sqs {
    queue_url  = var.sqs_queue_url
    role_arn   = aws_iam_role.iot_rule.arn
    use_base64 = false
  }

  error_action {
    cloudwatch_logs {
      log_group_name = aws_cloudwatch_log_group.iot_rule_errors.name
      role_arn       = aws_iam_role.iot_rule.arn
    }
  }

  tags = {
    Name = "${var.name_prefix}-iot-to-sqs-rule"
  }
}
