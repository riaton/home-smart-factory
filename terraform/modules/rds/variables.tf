variable "name_prefix" {
  description = "全リソース名に付与するプレフィックス"
  type        = string
}

variable "private_subnet_ids" {
  description = "DB サブネットグループに使用するプライベートサブネット ID のマップ（キー: AZ suffix）"
  type        = map(string)
}

variable "sg_rds_id" {
  description = "RDS に適用するセキュリティグループ ID"
  type        = string
}

variable "db_name" {
  description = "作成するデータベース名"
  type        = string
  default     = "home_smart_factory"
}

variable "db_username" {
  description = "RDS マスターユーザー名"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS マスターパスワード（8文字以上）"
  type        = string
  sensitive   = true
}
