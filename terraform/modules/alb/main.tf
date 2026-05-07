locals {
  np = var.name_prefix
}

# ---------------------------------------------------------------
# ACM 証明書（DNS 検証）
# ---------------------------------------------------------------

resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.np}-cert"
  }
}

# apply 前に aws_acm_certificate.main.domain_validation_options を確認し、
# 該当 CNAME レコードを DNS へ手動追加すること。
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
}

# ---------------------------------------------------------------
# ALB セキュリティグループ: HTTP:80 インバウンドルール追加
# （VPC モジュールでは HTTPS:443 のみ定義済みのため、redirect 用に追加）
# ---------------------------------------------------------------

resource "aws_security_group_rule" "alb_ingress_http" {
  security_group_id = var.sg_alb_id
  type              = "ingress"
  description       = "HTTP from internet for HTTPS redirect"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------------

resource "aws_lb" "main" {
  name               = "${local.np}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = values(var.public_subnet_ids)

  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = {
    Name = "${local.np}-alb"
  }
}

# ---------------------------------------------------------------
# ターゲットグループ: Backend（port 8080, IP タイプ）
# ---------------------------------------------------------------

resource "aws_lb_target_group" "backend" {
  name        = "${local.np}-backend-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${local.np}-backend-tg"
  }
}

# ---------------------------------------------------------------
# HTTPS:443 リスナー（TLS 終端 → Backend へ転送）
# ---------------------------------------------------------------

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# ---------------------------------------------------------------
# HTTP:80 リスナー（HTTPS:443 へ 301 リダイレクト）
# ---------------------------------------------------------------

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
