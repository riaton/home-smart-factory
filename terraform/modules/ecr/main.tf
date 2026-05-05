locals {
  # 4つのサービスに対応するリポジトリサフィックス
  services = toset(["worker", "batch", "backend", "grafana"])

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "タグなしイメージを1日後に削除"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        # latest×1 + SHA×10 = 11件を上限とすることで spec の「latest以外10件」を実現
        rulePriority = 2
        description  = "タグ付きイメージを最新11件まで保持（latest＋SHA×10）"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = 11
        }
        action = { type = "expire" }
      }
    ]
  })
}

resource "aws_ecr_repository" "this" {
  for_each = local.services

  name                 = "${var.name_prefix}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.name_prefix}/${each.key}"
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy     = local.lifecycle_policy
}
