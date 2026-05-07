data "aws_caller_identity" "current" {}

locals {
  np     = var.name_prefix
  region = var.aws_region

  main_queue_name = "${local.np}-iot-data-queue"

  grafana_admin_secret_arn = "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${local.np}/grafana-admin-password"
  grafana_db_secret_arn    = "arn:aws:secretsmanager:${local.region}:${data.aws_caller_identity.current.account_id}:secret:${local.np}/grafana-db-password"
}

# ---------------------------------------------------------------
# ECS クラスター
# ---------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = local.np

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = local.np
  }
}

# ---------------------------------------------------------------
# CloudWatch ロググループ（4サービス分）
# ---------------------------------------------------------------

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${local.np}/worker"
  retention_in_days = 365

  tags = {
    Name = "/ecs/${local.np}/worker"
  }
}

resource "aws_cloudwatch_log_group" "batch" {
  name              = "/ecs/${local.np}/batch"
  retention_in_days = 365

  tags = {
    Name = "/ecs/${local.np}/batch"
  }
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.np}/backend"
  retention_in_days = 365

  tags = {
    Name = "/ecs/${local.np}/backend"
  }
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${local.np}/grafana"
  retention_in_days = 365

  tags = {
    Name = "/ecs/${local.np}/grafana"
  }
}

# ---------------------------------------------------------------
# タスク定義: Worker
# ---------------------------------------------------------------

resource "aws_ecs_task_definition" "worker" {
  family                   = "${local.np}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.worker_task_role_arn

  container_definitions = jsonencode([{
    name      = "worker"
    image     = var.worker_image
    essential = true

    environment = [
      { name = "SQS_QUEUE_URL", value = var.main_queue_url },
      { name = "AWS_REGION", value = local.region }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.worker.name
        "awslogs-region"        = local.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "${local.np}-worker"
  }
}

# ---------------------------------------------------------------
# タスク定義: Batch（サービスなし。EventBridge から RunTask で呼び出す）
# ---------------------------------------------------------------

resource "aws_ecs_task_definition" "batch" {
  family                   = "${local.np}-batch"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.batch_task_role_arn

  container_definitions = jsonencode([{
    name      = "batch"
    image     = var.batch_image
    essential = true

    environment = [
      { name = "AWS_REGION", value = local.region }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.batch.name
        "awslogs-region"        = local.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "${local.np}-batch"
  }
}

# ---------------------------------------------------------------
# タスク定義: Backend
# ---------------------------------------------------------------

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.np}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.backend_task_role_arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = var.backend_image
    essential = true

    portMappings = [
      { containerPort = 8080, protocol = "tcp" }
    ]

    environment = [
      { name = "DB_HOST", value = var.db_endpoint },
      { name = "DB_PORT", value = tostring(var.db_port) },
      { name = "DB_NAME", value = var.db_name },
      { name = "REDIS_HOST", value = var.redis_primary_endpoint },
      { name = "REDIS_PORT", value = tostring(var.redis_port) },
      { name = "AWS_REGION", value = local.region }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.backend.name
        "awslogs-region"        = local.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "${local.np}-backend"
  }
}

# ---------------------------------------------------------------
# タスク定義: Grafana
# ---------------------------------------------------------------

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${local.np}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.grafana_task_role_arn

  container_definitions = jsonencode([{
    name      = "grafana"
    image     = var.grafana_image
    essential = true

    portMappings = [
      { containerPort = 3000, protocol = "tcp" }
    ]

    environment = [
      { name = "GF_SERVER_HTTP_PORT", value = "3000" },
      { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "false" },
      { name = "GF_SECURITY_ADMIN_USER", value = "admin" },
      { name = "GF_DATABASE_TYPE", value = "postgres" },
      { name = "GF_DATABASE_HOST", value = "${var.db_endpoint}:${var.db_port}" },
      { name = "GF_DATABASE_NAME", value = var.db_name },
      { name = "GF_DATABASE_USER", value = "grafana_ro" },
      { name = "AWS_REGION", value = local.region }
    ]

    secrets = [
      { name = "GF_SECURITY_ADMIN_PASSWORD", valueFrom = local.grafana_admin_secret_arn },
      { name = "GF_DATABASE_PASSWORD", valueFrom = local.grafana_db_secret_arn }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
        "awslogs-region"        = local.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name = "${local.np}-grafana"
  }
}

# ---------------------------------------------------------------
# ECS サービス: Worker
# ---------------------------------------------------------------

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = values(var.private_subnet_ids)
    security_groups  = [var.sg_ecs_worker_id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name = "${local.np}-worker"
  }
}

# ---------------------------------------------------------------
# ECS サービス: Backend
# ---------------------------------------------------------------

resource "aws_ecs_service" "backend" {
  name                              = "backend"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.backend.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets          = values(var.private_subnet_ids)
    security_groups  = [var.sg_ecs_backend_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "backend"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name = "${local.np}-backend"
  }
}

# ---------------------------------------------------------------
# ECS サービス: Grafana（パブリックサブネット・パブリックIP有効）
# ---------------------------------------------------------------

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_ids["1a"]]
    security_groups  = [var.sg_grafana_id]
    assign_public_ip = true
  }

  tags = {
    Name = "${local.np}-grafana"
  }
}

# ---------------------------------------------------------------
# Application Auto Scaling: Worker（SQS キュー深度ベース）
# ---------------------------------------------------------------

resource "aws_appautoscaling_target" "worker" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "worker_scale_out" {
  name               = "${local.np}-worker-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_scale_out" {
  alarm_name          = "${local.np}-worker-sqs-depth-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 100

  dimensions = {
    QueueName = local.main_queue_name
  }

  alarm_actions = [aws_appautoscaling_policy.worker_scale_out.arn]

  tags = {
    Name = "${local.np}-worker-sqs-depth-high"
  }
}

resource "aws_appautoscaling_policy" "worker_scale_in" {
  name               = "${local.np}-worker-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_scale_in" {
  alarm_name          = "${local.np}-worker-sqs-depth-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 10

  dimensions = {
    QueueName = local.main_queue_name
  }

  alarm_actions = [aws_appautoscaling_policy.worker_scale_in.arn]

  tags = {
    Name = "${local.np}-worker-sqs-depth-low"
  }
}

# ---------------------------------------------------------------
# Application Auto Scaling: Backend（CPU 使用率ベース）
# ---------------------------------------------------------------

resource "aws_appautoscaling_target" "backend" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_scale_out" {
  name               = "${local.np}-backend-scale-out"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 180
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_scale_out" {
  alarm_name          = "${local.np}-backend-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }

  alarm_actions = [aws_appautoscaling_policy.backend_scale_out.arn]

  tags = {
    Name = "${local.np}-backend-cpu-high"
  }
}

resource "aws_appautoscaling_policy" "backend_scale_in" {
  name               = "${local.np}-backend-scale-in"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 600
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_scale_in" {
  alarm_name          = "${local.np}-backend-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 10
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }

  alarm_actions = [aws_appautoscaling_policy.backend_scale_in.arn]

  tags = {
    Name = "${local.np}-backend-cpu-low"
  }
}
