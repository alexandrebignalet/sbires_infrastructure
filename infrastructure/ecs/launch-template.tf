data "aws_ami" "latest_ecs" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ecs_user_data = <<EOF
#!/bin/bash
# Register against the ECS cluster
echo "ECS_CLUSTER=${aws_ecs_cluster.services.name}" >> /etc/ecs/ecs.config

# Install updates
yum update -y

# Install SSM agent
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
start amazon-ssm-agent
EOF
}

resource "aws_launch_template" "ecs" {
  name                   = "sbires-ecs-launch-${var.environment}"
  image_id               = "${data.aws_ami.latest_ecs.id}"
  user_data              = "${base64encode(local.ecs_user_data)}"
  vpc_security_group_ids = ["${aws_security_group.ecs.id}"]

  iam_instance_profile {
    name = "${aws_iam_instance_profile.ecs.name}"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags {
      Name        = "sbires"
      environment = "${var.environment}"
    }
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs-security-group-${var.environment}"
  description = "ECS access from the load balancer"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "cluster_allow_outbound" {
  security_group_id = "${aws_security_group.ecs.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
