resource "aws_lb_listener_rule" "service" {
  count        = "${length(var.routing_paths)}"
  listener_arn = "${var.alb_listener}"
  priority     = "${var.routing_priority + count.index}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.service_1.arn}"
  }

  condition {
    path_pattern {
      values = ["${element(var.routing_paths, count.index)}"]
    }
  }
}

resource "aws_lb_target_group" "service_1" {
  count                = "${var.load_balancer_required ? 1 : 0}"
  name                 = "${var.service_name}-${var.environment}-1"
  port                 = "8080"
  vpc_id               = "${var.vpc_id}"
  protocol             = "HTTP"
  target_type          = "${var.fargate ? "ip" : "instance"}"
  deregistration_delay = 30

  health_check {
    path                = "${var.health_check}"
    matcher             = "200-499"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  tags = {
    Application = "sbires"
    Environment = "${var.environment}"
  }
}


resource "aws_lb_target_group" "service_2" {
  count                = "${var.blue_green_required ? 1 : 0}"
  name                 = "${var.service_name}-${var.environment}-2"
  port                 = "8080"
  vpc_id               = "${var.vpc_id}"
  protocol             = "HTTP"
  target_type          = "${var.fargate ? "ip" : "instance"}"
  deregistration_delay = 30

  health_check {
    path                = "${var.health_check}"
    matcher             = "200-499"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  tags = {
    Application = "sbires"
    Environment = "${var.environment}"
  }
}
