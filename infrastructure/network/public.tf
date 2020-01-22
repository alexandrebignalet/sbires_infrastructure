resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main.id}"
  count             = "${length(var.public_cidrs)}"
  cidr_block        = "${element(var.public_cidrs, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name        = "sbires_${var.environment}_public_${element(var.availability_zones, count.index)}"
    Environment = "${var.environment}"
    Tier        = "public"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "IGW ${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "sbires"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "main" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"

  tags {
    Name        = "Sbires NAT Gateway ${var.environment}"
    Environment = "${var.environment}"
  }
}
