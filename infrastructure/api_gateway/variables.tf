variable aws_region {
  type = "string"
}

variable environment {
  type = "string"
}

variable vpc_id {
  type = "string"
}

variable public_subnet_ids {
  type = "list"
}

variable ecs_security_group {
  type = "string"
}
