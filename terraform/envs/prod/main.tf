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
