# Main VPC
output vpc_id {
  value = "${aws_vpc.main.id}"
}

# IDs of the private subnets
output public_subnet_ids {
  value = "${aws_subnet.public.*.id}"
}

# IDs of the private subnets
output private_subnet_ids {
  value = "${aws_subnet.private.*.id}"
}
