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
