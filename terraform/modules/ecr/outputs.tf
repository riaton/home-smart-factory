output "repository_urls" {
  description = "ECR リポジトリ URL のマップ（サービス名 → URL）"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "ECR リポジトリ ARN のマップ（サービス名 → ARN）"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

# plan テスト用：リポジトリ名は設定値から確定するため plan 時点で既知
output "repository_names" {
  description = "ECR リポジトリ名のマップ（サービス名 → リポジトリ名）"
  value       = { for k, v in aws_ecr_repository.this : k => v.name }
}
