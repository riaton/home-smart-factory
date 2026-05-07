output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_name" {
  description = "ALB 名（name_prefix から確定）"
  value       = aws_lb.main.name
}

output "alb_dns_name" {
  description = "ALB の DNS 名（CNAME レコード設定に使用）"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB の Route53 Hosted Zone ID（Alias レコード設定に使用）"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Backend ターゲットグループ ARN（ECS サービスの load_balancer ブロックで参照）"
  value       = aws_lb_target_group.backend.arn
}

output "target_group_name" {
  description = "Backend ターゲットグループ名（name_prefix から確定）"
  value       = aws_lb_target_group.backend.name
}

output "certificate_arn" {
  description = "ACM 証明書 ARN"
  value       = aws_acm_certificate.main.arn
}

output "acm_validation_options" {
  description = "ACM DNS 検証レコード情報（apply 前に DNS へ手動追加すること）"
  value       = aws_acm_certificate.main.domain_validation_options
}
