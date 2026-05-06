output "iot_policy_name" {
  description = "IoT デバイスポリシー名"
  value       = aws_iot_policy.device.name
}

output "iot_rule_name" {
  description = "IoT Topic Rule 名（plan 時点で既知）"
  value       = aws_iot_topic_rule.to_sqs.name
}

output "iot_rule_arn" {
  description = "IoT Topic Rule ARN"
  value       = aws_iot_topic_rule.to_sqs.arn
}

output "thing_name" {
  description = "IoT Thing 名（Raspberry Pi デバイス名）"
  value       = aws_iot_thing.raspberry_pi.name
}

output "certificate_arn" {
  description = "IoT X.509 証明書 ARN"
  value       = aws_iot_certificate.raspberry_pi.arn
}

output "certificate_pem" {
  description = "IoT X.509 証明書 PEM（Raspberry Pi にインストールする）"
  value       = aws_iot_certificate.raspberry_pi.certificate_pem
  sensitive   = true
}

output "private_key" {
  description = "IoT X.509 秘密鍵 PEM（Raspberry Pi にインストールする）"
  value       = aws_iot_certificate.raspberry_pi.private_key
  sensitive   = true
}

output "iot_rule_log_group_name" {
  description = "IoT Rule エラーログ CloudWatch ロググループ名"
  value       = aws_cloudwatch_log_group.iot_rule_errors.name
}
