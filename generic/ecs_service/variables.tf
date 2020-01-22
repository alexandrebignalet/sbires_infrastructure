variable aws_region {
  type = "string"
}

variable environment {
  type = "string"
}

variable vpc_id {
  type = "string"
}

variable subnet_ids {
  type    = "list"
  default = []
}

variable security_group {
  type    = "string"
  default = ""
}

variable ecs_cluster_id {
  type = "string"
}

variable ecs_service_role {
  type = "string"
}

variable alb_listener {
  type = "string"
}

variable fargate {
  type    = "string"
  default = false
}

variable service_name {
  type = "string"
}

variable routing_priority {
  type = "string"
}

variable routing_paths {
  type = "list"
}

variable health_check {
  type = "string"
}

variable container_port {
  type    = "string"
  default = 8080
}

variable singleton {
  type    = "string"
  default = false
}

variable cpu_tracking {
  type    = "string"
  default = "75"
}

variable load_balancer_required {
  type    = "string"
  default = true
}

variable blue_green_required {
  type    = "string"
}

variable task_definition {
  type    = "string"
  default = ""
}

variable enabled {
  type    = "string"
  default = true
}

locals {
  can_scale     = "${(var.enabled && !var.singleton) ? 1 : 0}"
  default_count = "${var.singleton ? 1 : (var.environment == "prod" ? 2 : 1)}"
  desired_count = "${var.enabled ? local.default_count : 0}"
}
