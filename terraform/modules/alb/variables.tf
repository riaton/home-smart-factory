variable "name_prefix" {
  description = "リソース命名プレフィックス"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID（ターゲットグループ用）"
  type        = string
}

variable "public_subnet_ids" {
  description = "パブリックサブネット ID のマップ（ALB 配置先）"
  type        = map(string)
}

variable "sg_alb_id" {
  description = "ALB セキュリティグループ ID"
  type        = string
}

variable "domain_name" {
  description = "ACM 証明書のドメイン名（例: api.example.com）"
  type        = string
}

variable "backend_port" {
  description = "ECS Backend コンテナのリスニングポート"
  type        = number
  default     = 8080
}
