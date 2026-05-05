resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-rds"
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}

resource "aws_db_parameter_group" "pg16" {
  name   = "${var.name_prefix}-pg16"
  family = "postgres16"

  # 静的パラメータ（変更はインスタンス再起動後に反映）
  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "timezone"
    value        = "UTC"
    apply_method = "pending-reboot"
  }

  # 動的パラメータ（即時反映）
  parameter {
    name         = "log_min_duration_statement"
    value        = "1000"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_disconnections"
    value        = "1"
    apply_method = "immediate"
  }

  tags = {
    Name = "${var.name_prefix}-pg16"
  }
}

# ---------------------------------------------------------------
# RDS PostgreSQL インスタンス
# ---------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-rds"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_rds_id]
  parameter_group_name   = aws_db_parameter_group.pg16.name

  backup_retention_period = 7
  backup_window           = "15:00-16:00"
  maintenance_window      = "mon:16:30-mon:17:30"

  auto_minor_version_upgrade = true
  deletion_protection        = true
  skip_final_snapshot        = false
  final_snapshot_identifier  = "${var.name_prefix}-rds-final-snapshot"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}
