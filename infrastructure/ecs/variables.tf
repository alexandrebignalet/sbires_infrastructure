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

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = "${data.aws_caller_identity.current.account_id}"
}
