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

run "rds_instance_identifier_contains_name_prefix" {
  command = plan

  # identifier は変数から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.rds.db_identifier == "home-smart-factory-rds"
    error_message = "RDS インスタンス識別子が想定と異なります"
  }

  assert {
    condition     = module.rds.db_name == "home_smart_factory"
    error_message = "DB 名が想定と異なります"
  }

  assert {
    condition     = module.rds.db_port == 5432
    error_message = "DB ポートが 5432 ではありません"
  }
}
