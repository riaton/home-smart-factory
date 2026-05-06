variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "admin_cidr_blocks" {
  description = "Grafana へのアクセスを許可する管理者 IP の CIDR リスト"
  type        = list(string)
  default     = []
}

variable "db_username" {
  description = "RDS マスターユーザー名（TF_VAR_db_username で注入）"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS マスターパスワード（TF_VAR_db_password で注入）"
  type        = string
  sensitive   = true
}

variable "operator_email" {
  description = "SNS メール通知先（TF_VAR_operator_email で注入）"
  type        = string
  sensitive   = true
}
