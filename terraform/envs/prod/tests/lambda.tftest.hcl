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

run "lambda_function_name" {
  command = plan

  # 関数名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.lambda.function_name == "home-smart-factory-batch-restart-function"
    error_message = "Lambda 関数名が想定と異なります"
  }
}

run "lambda_log_group_name" {
  command = plan

  # ロググループ名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.lambda.log_group_name == "/aws/lambda/home-smart-factory-batch-restart-function"
    error_message = "CloudWatch ロググループ名が想定と異なります"
  }
}
