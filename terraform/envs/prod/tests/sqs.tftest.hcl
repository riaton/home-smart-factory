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
}

run "sqs_queue_names" {
  command = plan

  # キュー名は設定値から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.sqs.main_queue_name == "home-smart-factory-iot-data-queue"
    error_message = "メインキュー名が想定と異なります"
  }

  assert {
    condition     = module.sqs.dlq_name == "home-smart-factory-iot-data-dlq"
    error_message = "DLQ 名が想定と異なります"
  }
}
