variable accounts_permission {
  type = "map"

  default = {
    staging = "096040694364"
    prod    = "096040694364"
  }
}

variable vpc_cidr_map {
  type = "map"

  default = {
    default = "YOU MUST SELECT A WORKSPACE"
    staging = "10.1.0.0/16"
    prod    = "10.2.0.0/16"
  }
}


variable public_cidrs_map {
  type = "map"

  default = {
    default = ["YOU MUST SELECT A WORKSPACE"]
    staging = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
    prod    = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  }
}

variable private_cidrs_map {
  type = "map"

  default = {
    default = ["YOU MUST SELECT A WORKSPACE"]
    staging = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
    prod    = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
  }
}


locals {
  vpc_cidr      = "${var.vpc_cidr_map[terraform.workspace]}"
  public_cidrs  = "${var.public_cidrs_map[terraform.workspace]}"
  private_cidrs = "${var.private_cidrs_map[terraform.workspace]}"

  aws_region  = "eu-west-1"
  app_name    = "sbires"
  environment = "${terraform.workspace}"
}
