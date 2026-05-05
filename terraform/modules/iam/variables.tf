variable "name_prefix" {
  description = "全リソース名に付与するプレフィックス"
  type        = string
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}
