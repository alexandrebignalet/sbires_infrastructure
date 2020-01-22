variable aws_region {
  type = "string"
}

variable environment {
  type = "string"
}

variable vpc_id {
  type = "string"
}

variable subnet_ids {
  type = "list"
}

variable ecs_cluster_id {
  type = "string"
}

variable ecs_service_role {
  type = "string"
}

variable ecs_security_group {
  type = "string"
}

variable alb_listener {
  type = "string"
}

variable alb_dns_name {
  type = "string"
}

variable alb_zone_id {
  type = "string"
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = "${data.aws_caller_identity.current.account_id}"
  service_name   = "sbires-service"
}
