variable "name_prefix" {
  description = "全リソース名に付与するプレフィックス"
  type        = string
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
}

variable "sqs_queue_arn" {
  description = "IoT ルールの転送先 SQS メインキュー ARN"
  type        = string
}

variable "sqs_queue_url" {
  description = "IoT ルールの転送先 SQS メインキュー URL"
  type        = string
}

variable "thing_name" {
  description = "IoT Thing 名（Raspberry Pi デバイス名）"
  type        = string
  default     = "raspberry-pi"
}
