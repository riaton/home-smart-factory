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
