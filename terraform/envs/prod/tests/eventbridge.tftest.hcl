mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:root"
      user_id    = "AKIAIOSFODNN7EXAMPLE"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  admin_cidr_blocks = ["192.0.2.0/32"]
  # テスト用ダミー認証情報（機密情報ではない）
  db_username    = "testadmin"
  db_password    = "testpassword123"
  operator_email = "test@example.com"
  domain_name    = "api.example.com"
}

run "eventbridge_schedule_rule_name" {
  command = plan

  # ルール名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.eventbridge.schedule_rule_name == "home-smart-factory-daily-report-batch-schedule"
    error_message = "スケジュールルール名が想定と異なります"
  }
}

run "eventbridge_batch_stopped_rule_name" {
  command = plan

  # ルール名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.eventbridge.batch_stopped_rule_name == "home-smart-factory-batch-task-stopped-rule"
    error_message = "バッチ異常停止検知ルール名が想定と異なります"
  }
}
