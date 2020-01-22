module ecs_service {
  source                 = "../../generic/ecs_service"
  aws_region             = "${var.aws_region}"
  environment            = "${var.environment}"
  vpc_id                 = "${var.vpc_id}"
  subnet_ids             = "${var.subnet_ids}"
  security_group         = "${var.ecs_security_group}"
  ecs_cluster_id         = "${var.ecs_cluster_id}"
  ecs_service_role       = "${var.ecs_service_role}"
  alb_listener           = "${var.alb_listener}"
  singleton              = true
  load_balancer_required = true
  blue_green_required    = true
  fargate                = false
  service_name           = "${local.service_name}"
  routing_priority       = 100
  routing_paths          = ["/*"]
  health_check           = "/"
}

resource "aws_cloudwatch_log_group" "log_group_cleaner" {
  name = "sbires-service-cleaner-${var.environment}"

  tags {
    Application = "sbires"
    Environment = "${var.environment}"
  }
}
