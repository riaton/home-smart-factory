# ---------------------------------------------------------------
# VPC
# ---------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# ---------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# ---------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = {
    "1a" = { cidr = "10.0.1.0/24", az = "ap-northeast-1a" }
    "1c" = { cidr = "10.0.2.0/24", az = "ap-northeast-1c" }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    "1a" = { cidr = "10.0.11.0/24", az = "ap-northeast-1a" }
    "1c" = { cidr = "10.0.12.0/24", az = "ap-northeast-1c" }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
  }
}

# ---------------------------------------------------------------
# NAT Gateway（1a のみ。個人 PJ のためコスト最適化）
# ---------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["1a"].id

  tags = {
    Name = "${var.name_prefix}-nat"
  }
}

# ---------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-rtb-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-rtb-private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------
# Security Groups（ルール定義は aws_security_group_rule で分離し循環参照を回避）
# ---------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb"
  description = "ALB: HTTPS inbound from internet, outbound to ECS Backend"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-alb"
  }
}

resource "aws_security_group" "ecs_backend" {
  name        = "${var.name_prefix}-ecs-backend"
  description = "ECS Backend: inbound from ALB, outbound to RDS/Redis/HTTPS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-ecs-backend"
  }
}

resource "aws_security_group" "ecs_worker" {
  name        = "${var.name_prefix}-ecs-worker"
  description = "ECS Worker: outbound only to RDS and VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-ecs-worker"
  }
}

resource "aws_security_group" "ecs_batch" {
  name        = "${var.name_prefix}-ecs-batch"
  description = "ECS Batch: outbound only to RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-ecs-batch"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds"
  description = "RDS PostgreSQL: inbound from ECS and Grafana"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-rds"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis"
  description = "ElastiCache Redis: inbound from ECS Backend only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-redis"
  }
}

# grafana_ro は Grafana 専用の読み取り専用 DB ユーザー。
# パブリックサブネット配置のため、RDS への経路は SG で明示的に制御する。
resource "aws_security_group" "grafana" {
  name        = "${var.name_prefix}-grafana"
  description = "Grafana: inbound from admin IPs only, outbound to RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-sg-grafana"
  }
}

# ---------------------------------------------------------------
# Security Group Rules
# ---------------------------------------------------------------

# sg-alb
resource "aws_security_group_rule" "alb_ingress_https" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  description       = "HTTPS from internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_to_backend" {
  security_group_id        = aws_security_group.alb.id
  type                     = "egress"
  description              = "To ECS Backend"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_backend.id
}

# sg-ecs-backend
resource "aws_security_group_rule" "ecs_backend_ingress_from_alb" {
  security_group_id        = aws_security_group.ecs_backend.id
  type                     = "ingress"
  description              = "From ALB"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ecs_backend_egress_to_rds" {
  security_group_id        = aws_security_group.ecs_backend.id
  type                     = "egress"
  description              = "To RDS"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ecs_backend_egress_to_redis" {
  security_group_id        = aws_security_group.ecs_backend.id
  type                     = "egress"
  description              = "To Redis"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "ecs_backend_egress_https" {
  security_group_id = aws_security_group.ecs_backend.id
  type              = "egress"
  description       = "HTTPS for VPC Endpoints and external APIs"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# sg-ecs-worker
resource "aws_security_group_rule" "ecs_worker_egress_to_rds" {
  security_group_id        = aws_security_group.ecs_worker.id
  type                     = "egress"
  description              = "To RDS"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ecs_worker_egress_to_endpoints" {
  security_group_id = aws_security_group.ecs_worker.id
  type              = "egress"
  description       = "To VPC Endpoints (SQS/SNS/ECR/Logs)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
}

# sg-ecs-batch
resource "aws_security_group_rule" "ecs_batch_egress_to_rds" {
  security_group_id        = aws_security_group.ecs_batch.id
  type                     = "egress"
  description              = "To RDS"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

# sg-rds
resource "aws_security_group_rule" "rds_ingress_from_backend" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  description              = "From ECS Backend"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_backend.id
}

resource "aws_security_group_rule" "rds_ingress_from_worker" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  description              = "From ECS Worker"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_worker.id
}

resource "aws_security_group_rule" "rds_ingress_from_batch" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  description              = "From ECS Batch"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_batch.id
}

resource "aws_security_group_rule" "rds_ingress_from_grafana" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  description              = "From Grafana"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.grafana.id
}

# sg-redis
resource "aws_security_group_rule" "redis_ingress_from_backend" {
  security_group_id        = aws_security_group.redis.id
  type                     = "ingress"
  description              = "From ECS Backend"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_backend.id
}

# sg-grafana
resource "aws_security_group_rule" "grafana_ingress_from_admin" {
  for_each = length(var.admin_cidr_blocks) > 0 ? { "admin" = var.admin_cidr_blocks } : {}

  security_group_id = aws_security_group.grafana.id
  type              = "ingress"
  description       = "Grafana from admin IPs"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = each.value
}

resource "aws_security_group_rule" "grafana_egress_to_rds" {
  security_group_id        = aws_security_group.grafana.id
  type                     = "egress"
  description              = "To RDS (grafana_ro)"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
}

# ---------------------------------------------------------------
# VPC Endpoints
# ---------------------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]

  tags = {
    Name = "${var.name_prefix}-vpce-s3"
  }
}

locals {
  interface_endpoints = {
    sqs     = "com.amazonaws.ap-northeast-1.sqs"
    sns     = "com.amazonaws.ap-northeast-1.sns"
    logs    = "com.amazonaws.ap-northeast-1.logs"
    ecr_api = "com.amazonaws.ap-northeast-1.ecr.api"
    ecr_dkr = "com.amazonaws.ap-northeast-1.ecr.dkr"
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.name_prefix}-vpc-endpoint"
  description = "VPC Interface Endpoints: HTTPS from private subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.name_prefix}-sg-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.main.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private["1a"].id, aws_subnet.private["1c"].id]
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.name_prefix}-vpce-${replace(each.key, "_", "-")}"
  }
}
