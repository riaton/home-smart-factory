variable "name_prefix" {
  description = "全リソース名に付与するプレフィックス"
  type        = string
}

variable "private_subnet_ids" {
  description = "ElastiCache サブネットグループに使用するプライベートサブネット ID のマップ（キー: AZ suffix）"
  type        = map(string)
}

variable "sg_redis_id" {
  description = "ElastiCache Redis に適用するセキュリティグループ ID"
  type        = string
}
