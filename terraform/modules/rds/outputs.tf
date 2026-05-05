output "db_endpoint" {
  description = "RDS エンドポイント（ホスト名）。ECS タスク環境変数や Grafana 設定で使用する"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS ポート番号"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "データベース名"
  value       = aws_db_instance.main.db_name
}

# plan テスト用：identifier は変数から確定するため plan 時点で既知
output "db_identifier" {
  description = "RDS インスタンス識別子"
  value       = aws_db_instance.main.identifier
}
