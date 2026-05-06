output "redis_primary_endpoint" {
  description = "Redis プライマリエンドポイント（apply 後に確定）"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "Redis ポート番号"
  value       = aws_elasticache_replication_group.main.port
}

output "redis_replication_group_id" {
  description = "ElastiCache レプリケーショングループ ID（plan 時点で既知）"
  value       = aws_elasticache_replication_group.main.replication_group_id
}

output "redis_at_rest_encryption_enabled" {
  description = "保存時暗号化が有効かどうか"
  value       = aws_elasticache_replication_group.main.at_rest_encryption_enabled
}

output "redis_transit_encryption_enabled" {
  description = "転送時暗号化が有効かどうか"
  value       = aws_elasticache_replication_group.main.transit_encryption_enabled
}
