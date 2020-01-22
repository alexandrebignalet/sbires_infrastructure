data "aws_caller_identity" "current" {}

variable aws_region {
  type = "string"
}

variable environment {
  type = "string"
}

variable vpc_cidr {
  type = "string"
}

variable public_cidrs {
  type = "list"
}

variable private_cidrs {
  type = "list"
}

variable availability_zones {
  type = "list"
}
