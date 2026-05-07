variables {
  admin_cidr_blocks = ["192.0.2.0/32"]
  db_username       = "testadmin"
  db_password       = "testpassword123"
  operator_email    = "test@example.com"
  domain_name       = "api.example.com"
}

run "public_subnets_have_two_azs" {
  command = plan

  assert {
    condition     = length(module.vpc.public_subnet_ids) == 2
    error_message = "パブリックサブネットは 2 つである必要があります"
  }

  assert {
    condition     = contains(keys(module.vpc.public_subnet_ids), "1a")
    error_message = "パブリックサブネット 1a が存在しません"
  }

  assert {
    condition     = contains(keys(module.vpc.public_subnet_ids), "1c")
    error_message = "パブリックサブネット 1c が存在しません"
  }
}

run "private_subnets_have_two_azs" {
  command = plan

  assert {
    condition     = length(module.vpc.private_subnet_ids) == 2
    error_message = "プライベートサブネットは 2 つである必要があります"
  }

  assert {
    condition     = contains(keys(module.vpc.private_subnet_ids), "1a")
    error_message = "プライベートサブネット 1a が存在しません"
  }

  assert {
    condition     = contains(keys(module.vpc.private_subnet_ids), "1c")
    error_message = "プライベートサブネット 1c が存在しません"
  }
}
