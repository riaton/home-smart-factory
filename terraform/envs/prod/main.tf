module "vpc" {
  source = "../../modules/vpc"

  name_prefix       = local.name_prefix
  vpc_cidr          = "10.0.0.0/16"
  admin_cidr_blocks = var.admin_cidr_blocks
}

module "iam" {
  source = "../../modules/iam"

  name_prefix = local.name_prefix
  aws_region  = var.aws_region
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix = local.name_prefix
}

module "rds" {
  source = "../../modules/rds"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  sg_rds_id          = module.vpc.sg_rds_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "elasticache" {
  source = "../../modules/elasticache"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  sg_redis_id        = module.vpc.sg_redis_id
}

module "sqs" {
  source = "../../modules/sqs"

  name_prefix = local.name_prefix
}

module "sns" {
  source = "../../modules/sns"

  name_prefix    = local.name_prefix
  operator_email = var.operator_email
}

module "iot" {
  source = "../../modules/iot"

  name_prefix   = local.name_prefix
  aws_region    = var.aws_region
  sqs_queue_arn = module.sqs.main_queue_arn
  sqs_queue_url = module.sqs.main_queue_url
}

module "alb" {
  source = "../../modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  sg_alb_id         = module.vpc.sg_alb_id
  domain_name       = var.domain_name
}

module "ecs" {
  source = "../../modules/ecs"

  name_prefix = local.name_prefix
  aws_region  = var.aws_region

  execution_role_arn    = module.iam.execution_role_arn
  worker_task_role_arn  = module.iam.ecs_worker_task_role_arn
  batch_task_role_arn   = module.iam.ecs_batch_task_role_arn
  backend_task_role_arn = module.iam.ecs_backend_task_role_arn
  grafana_task_role_arn = module.iam.ecs_grafana_task_role_arn

  worker_image  = "${module.ecr.repository_urls["worker"]}:latest"
  batch_image   = "${module.ecr.repository_urls["batch"]}:latest"
  backend_image = "${module.ecr.repository_urls["backend"]}:latest"
  grafana_image = "${module.ecr.repository_urls["grafana"]}:latest"

  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  sg_ecs_worker_id   = module.vpc.sg_ecs_worker_id
  sg_ecs_batch_id    = module.vpc.sg_ecs_batch_id
  sg_ecs_backend_id  = module.vpc.sg_ecs_backend_id
  sg_grafana_id      = module.vpc.sg_grafana_id

  db_endpoint = module.rds.db_endpoint
  db_port     = module.rds.db_port
  db_name     = module.rds.db_name

  redis_primary_endpoint = module.elasticache.redis_primary_endpoint
  redis_port             = module.elasticache.redis_port

  main_queue_url   = module.sqs.main_queue_url
  main_queue_arn   = module.sqs.main_queue_arn
  target_group_arn = module.alb.target_group_arn

  depends_on = [module.alb]
}

module "lambda" {
  source = "../../modules/lambda"

  name_prefix                  = local.name_prefix
  lambda_role_arn              = module.iam.lambda_batch_restart_role_arn
  batch_task_failure_sns_arn   = module.sns.batch_task_failure_arn
  ecs_cluster_name             = module.ecs.cluster_name
  batch_task_definition_family = module.ecs.batch_task_definition_family
  subnet_id                    = module.vpc.private_subnet_ids["1a"]
  security_group_id            = module.vpc.sg_ecs_batch_id
}

module "eventbridge" {
  source = "../../modules/eventbridge"

  name_prefix                  = local.name_prefix
  aws_region                   = var.aws_region
  ecs_cluster_arn              = module.ecs.cluster_arn
  batch_task_definition_arn    = module.ecs.batch_task_definition_arn
  batch_task_definition_family = module.ecs.batch_task_definition_family
  eventbridge_role_arn         = module.iam.eventbridge_ecs_role_arn
  batch_task_failure_sns_arn   = module.sns.batch_task_failure_arn
  subnet_id                    = module.vpc.private_subnet_ids["1a"]
  security_group_id            = module.vpc.sg_ecs_batch_id
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix               = local.name_prefix
  cloudwatch_alarms_sns_arn = module.sns.cloudwatch_alarms_arn
  worker_log_group_name     = module.ecs.worker_log_group_name
  dlq_name                  = module.sqs.dlq_name
  ecs_cluster_name          = module.ecs.cluster_name
  iot_rule_name             = module.iot.iot_rule_name
}
