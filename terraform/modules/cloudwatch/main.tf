locals {
  np             = var.name_prefix
  rds_identifier = "${local.np}-rds"
}

resource "aws_cloudwatch_log_metric_filter" "anomaly_insert_failure" {
  name           = "${local.np}-anomaly-insert-failure"
  log_group_name = var.worker_log_group_name
  pattern        = "\"ERROR\" \"anomaly_logs INSERT failed\""

  metric_transformation {
    namespace     = "HomeSmartFactory/Worker"
    name          = "AnomalyInsertFailureCount"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "anomaly_insert_failure" {
  alarm_name          = "${local.np}-anomaly-insert-failure-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "AnomalyInsertFailureCount"
  namespace           = "HomeSmartFactory/Worker"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  tags = {
    Name = "${local.np}-anomaly-insert-failure-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "iot_data_dlq" {
  alarm_name          = "${local.np}-iot-data-dlq-messages-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "NumberOfMessagesSent"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  dimensions = {
    QueueName = var.dlq_name
  }

  tags = {
    Name = "${local.np}-iot-data-dlq-messages-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.np}-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  dimensions = {
    DBInstanceIdentifier = local.rds_identifier
  }

  tags = {
    Name = "${local.np}-rds-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${local.np}-rds-storage-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Minimum"
  threshold           = 5368709120
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  dimensions = {
    DBInstanceIdentifier = local.rds_identifier
  }

  tags = {
    Name = "${local.np}-rds-storage-low"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${local.np}-rds-connections-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  dimensions = {
    DBInstanceIdentifier = local.rds_identifier
  }

  tags = {
    Name = "${local.np}-rds-connections-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_worker_task_count_low" {
  alarm_name          = "${local.np}-ecs-worker-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "breaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = "worker"
  }

  tags = {
    Name = "${local.np}-ecs-worker-task-count-low"
  }
}

resource "aws_cloudwatch_metric_alarm" "iot_rule_error" {
  alarm_name          = "${local.np}-iot-rule-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  metric_name         = "Failure"
  namespace           = "AWS/IoT"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.cloudwatch_alarms_sns_arn]

  dimensions = {
    RuleName = var.iot_rule_name
  }

  tags = {
    Name = "${local.np}-iot-rule-error-alarm"
  }
}
