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

run "cloudwatch_anomaly_insert_failure_alarm_name" {
  command = plan

  # アラーム名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.cloudwatch.anomaly_insert_failure_alarm_name == "home-smart-factory-anomaly-insert-failure-alarm"
    error_message = "異常検知失敗アラーム名が想定と異なります"
  }
}

run "cloudwatch_ecs_worker_task_count_low_alarm_name" {
  command = plan

  # アラーム名は name_prefix から確定するため plan 時点で既知の値としてアサートできる
  assert {
    condition     = module.cloudwatch.ecs_worker_task_count_low_alarm_name == "home-smart-factory-ecs-worker-task-count-low"
    error_message = "ECS Worker タスク数アラーム名が想定と異なります"
  }
}
