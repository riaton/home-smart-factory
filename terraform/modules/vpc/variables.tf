variable "name_prefix" {
  description = "全リソース名に付与するプレフィックス"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC の CIDR ブロック"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr は有効な CIDR 形式である必要があります。"
  }
}

variable "admin_cidr_blocks" {
  description = "Grafana へのアクセスを許可する管理者 IP の CIDR リスト"
  type        = list(string)
  default     = []
}
