output "vpc_id" {
  description = "VPC の ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "パブリックサブネット ID のマップ（キー: AZ suffix）"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "プライベートサブネット ID のマップ（キー: AZ suffix）"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "sg_alb_id" {
  description = "ALB セキュリティグループ ID"
  value       = aws_security_group.alb.id
}

output "sg_ecs_backend_id" {
  description = "ECS Backend セキュリティグループ ID"
  value       = aws_security_group.ecs_backend.id
}

output "sg_ecs_worker_id" {
  description = "ECS Worker セキュリティグループ ID"
  value       = aws_security_group.ecs_worker.id
}

output "sg_ecs_batch_id" {
  description = "ECS Batch セキュリティグループ ID"
  value       = aws_security_group.ecs_batch.id
}

output "sg_rds_id" {
  description = "RDS セキュリティグループ ID"
  value       = aws_security_group.rds.id
}

output "sg_redis_id" {
  description = "Redis セキュリティグループ ID"
  value       = aws_security_group.redis.id
}

output "sg_grafana_id" {
  description = "Grafana セキュリティグループ ID"
  value       = aws_security_group.grafana.id
}
