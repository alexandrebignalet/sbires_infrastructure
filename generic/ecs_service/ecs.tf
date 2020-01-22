data "external" "current_task_def" {
  program = ["/bin/bash", "generic/ecs_service/get-task.sh"]

  query = {
    environment  = "${var.environment}"
    service_name = "${var.service_name}"
  }
}

locals {
  current_task_name = "${coalesce(var.task_definition, data.external.current_task_def.result["task_name"])}"
}

resource "aws_ecs_service" "service" {
  count                             = "${!var.fargate && var.load_balancer_required ? 1 : 0}"
  name                              = "${var.service_name}"
  cluster                           = "${var.ecs_cluster_id}"
  iam_role                          = "${var.ecs_service_role}"
  task_definition                   = "${local.current_task_name}"
  health_check_grace_period_seconds = 120
  desired_count                     = "${local.desired_count}"

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.service_1.arn}"
    container_name   = "server"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

resource "aws_ecs_service" "service_without_load_balancer" {
  count           = "${!var.fargate && !var.load_balancer_required ? 1 : 0}"
  name            = "${var.service_name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${local.current_task_name}"
  desired_count   = "${local.desired_count}"

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_ecs_service" "service_fargate" {
  count                             = "${var.fargate && var.load_balancer_required ? 1 : 0}"
  name                              = "${var.service_name}"
  cluster                           = "${var.ecs_cluster_id}"
  task_definition                   = "${local.current_task_name}"
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120
  desired_count                     = "${local.desired_count}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.service_1.arn}"
    container_name   = "server"
    container_port   = "${var.container_port}"
  }

  network_configuration {
    security_groups = ["${var.security_group}"]
    subnets         = ["${var.subnet_ids}"]
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_ecs_service" "service_fargate_without_alb" {
  count           = "${var.fargate && !var.load_balancer_required ? 1 : 0}"
  name            = "${var.service_name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${local.current_task_name}"
  launch_type     = "FARGATE"
  desired_count   = "${local.desired_count}"

  network_configuration {
    security_groups = ["${var.security_group}"]
    subnets         = ["${var.subnet_ids}"]
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

// production logs are retained for 10 years
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.service_name}-${var.environment}"
  retention_in_days = "${var.environment == "prod" ? 3653 : 5}"

  tags {
    Application = "sbires"
    Environment = "${var.environment}"
  }
}
