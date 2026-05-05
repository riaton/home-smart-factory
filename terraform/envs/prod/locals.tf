locals {
  name_prefix = "home-smart-factory"
  env         = "prod"

  common_tags = {
    Project     = "home-smart-factory"
    Environment = local.env
    ManagedBy   = "terraform"
  }
}
