variable "name_prefix" {
  description = "リソース名プレフィックス"
  type        = string
}

variable "operator_email" {
  description = "SNS メール通知先（運用担当者のメールアドレス）"
  type        = string
  sensitive   = true
}
