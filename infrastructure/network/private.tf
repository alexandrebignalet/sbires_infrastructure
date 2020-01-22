resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.main.id}"
  count             = "${length(var.private_cidrs)}"
  cidr_block        = "${element(var.private_cidrs, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "skilbill_${var.environment}_private_${element(var.availability_zones, count.index)}"
    Environment = "${var.environment}"
    Tier        = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name        = "Skilbill Private Routetable"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "private_subnet_routing" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
