locals {
  api_root_response = <<EOF
{
  "intro": "Welcome to the sbires API",
  "docs": "http://docs.${var.environment}.sbires.com"
}
EOF

  api_root_response_prod = <<EOF
{
  "intro": "Welcome to the sbires API"
}
EOF

  api_not_found = <<EOF
{
  "error": "Resource not found"
}
EOF
}

resource "aws_lb" "api" {
  name                             = "alb-api-${var.environment}"
  internal                         = false
  load_balancer_type               = "application"
  subnets                          = ["${var.public_subnet_ids}"]
  enable_cross_zone_load_balancing = "true"
  security_groups                  = ["${aws_security_group.api_alb.id}"]

//  access_logs {
//    bucket  = "${aws_s3_bucket.bucket-logs-infra.bucket}"
//    prefix  = "alb"
//    enabled = true
//  }

  tags = {
    Name        = "sbires"
    Environment = "${var.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.api.arn}"
  protocol          = "HTTP"
  port              = "80"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "${local.api_not_found}"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "service" {
  listener_arn = "${aws_lb_listener.http.arn}"
  priority     = "1000"

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "${local.api_root_response}"
      status_code  = "200"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_security_group" "api_alb" {
  name        = "api-alb-${var.environment}"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # To talk to the services on ECS
  egress {
    from_port   = 32768
    to_port     = 61000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "cluster_from_alb" {
  security_group_id        = "${var.ecs_security_group}"
  type                     = "ingress"
  from_port                = 32768
  to_port                  = 61000
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.api_alb.id}"
}
