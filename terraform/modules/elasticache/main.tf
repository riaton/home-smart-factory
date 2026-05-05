resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis"
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name = "${var.name_prefix}-redis"
  }
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.name_prefix}-redis"
  description          = "Redis for session management (${var.name_prefix})"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = "cache.t3.micro"
  port           = 6379

  num_cache_clusters         = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false

  preferred_cache_cluster_azs = ["ap-northeast-1a"]

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.sg_redis_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  transit_encryption_mode    = "required"

  snapshot_retention_limit = 0

  maintenance_window         = "tue:16:30-tue:17:30"
  auto_minor_version_upgrade = true

  apply_immediately = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-redis"
  }
}
