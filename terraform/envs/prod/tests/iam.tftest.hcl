# data.aws_caller_identity が AWS API を必要とするため mock_provider で代替する
mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:root"
      user_id    = "AKIAIOSFODNN7EXAMPLE"
    }
  }

  # aws_iam_policy_document はデフォルトで空文字列を返すため、有効な JSON を返すよう設定する
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  admin_cidr_blocks = ["192.0.2.0/32"]
  db_username       = "testadmin"
  db_password       = "testpassword123"
}

run "iam_role_names_contain_name_prefix" {
  command = plan

  # ロール名は設定値から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = length(module.iam.role_names) == 7
    error_message = "IAM ロールは 7 つである必要があります"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "execution")
    error_message = "execution ロールが存在しません"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "ecs_worker")
    error_message = "ecs_worker ロールが存在しません"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "ecs_batch")
    error_message = "ecs_batch ロールが存在しません"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "ecs_backend")
    error_message = "ecs_backend ロールが存在しません"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "ecs_grafana")
    error_message = "ecs_grafana ロールが存在しません"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "lambda_batch_restart")
    error_message = "lambda_batch_restart ロールが存在しません"
  }

  assert {
    condition     = contains(keys(module.iam.role_names), "eventbridge_ecs")
    error_message = "eventbridge_ecs ロールが存在しません"
  }
}
