resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name        = "VPC ${var.environment}"
    Environment = "${var.environment}"
  }
}
