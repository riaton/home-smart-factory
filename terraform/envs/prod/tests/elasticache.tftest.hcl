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
  db_username = "testadmin"
  db_password = "testpassword123"
}

run "redis_replication_group_config" {
  command = plan

  # replication_group_id は変数から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.elasticache.redis_replication_group_id == "home-smart-factory-redis"
    error_message = "Redis レプリケーショングループ ID が想定と異なります"
  }

  # port は設定値から確定するため plan 時点で既知
  assert {
    condition     = module.elasticache.redis_port == 6379
    error_message = "Redis ポートが 6379 ではありません"
  }
}
