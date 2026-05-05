# ECR モジュールは data source を使用しないため mock_provider は不要
# ただし vpc/iam モジュールが data source を使うため mock_provider は必要
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
}

run "ecr_repository_names_contain_all_services" {
  command = plan

  # リポジトリ名は設定値から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = length(module.ecr.repository_names) == 4
    error_message = "ECR リポジトリは 4 つである必要があります"
  }

  assert {
    condition     = contains(keys(module.ecr.repository_names), "worker")
    error_message = "worker リポジトリが存在しません"
  }

  assert {
    condition     = contains(keys(module.ecr.repository_names), "batch")
    error_message = "batch リポジトリが存在しません"
  }

  assert {
    condition     = contains(keys(module.ecr.repository_names), "backend")
    error_message = "backend リポジトリが存在しません"
  }

  assert {
    condition     = contains(keys(module.ecr.repository_names), "grafana")
    error_message = "grafana リポジトリが存在しません"
  }
}
