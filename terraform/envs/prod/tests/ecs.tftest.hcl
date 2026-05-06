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

run "ecs_cluster_name" {
  command = plan

  # クラスター名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.ecs.cluster_name == "home-smart-factory"
    error_message = "ECS クラスター名が想定と異なります"
  }
}

run "ecs_log_group_names" {
  command = plan

  # ロググループ名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.ecs.worker_log_group_name == "/ecs/home-smart-factory/worker"
    error_message = "Worker ロググループ名が想定と異なります"
  }

  assert {
    condition     = module.ecs.batch_log_group_name == "/ecs/home-smart-factory/batch"
    error_message = "Batch ロググループ名が想定と異なります"
  }

  assert {
    condition     = module.ecs.backend_log_group_name == "/ecs/home-smart-factory/backend"
    error_message = "Backend ロググループ名が想定と異なります"
  }

  assert {
    condition     = module.ecs.grafana_log_group_name == "/ecs/home-smart-factory/grafana"
    error_message = "Grafana ロググループ名が想定と異なります"
  }
}
