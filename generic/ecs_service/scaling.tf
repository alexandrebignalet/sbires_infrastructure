resource "aws_appautoscaling_target" "ecs_target" {
  count              = "${local.can_scale ? 1 : 0}"
  min_capacity       = "${local.desired_count}"
  max_capacity       = "${local.desired_count + 3}"
  resource_id        = "service/skilbill-services-${var.environment}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_targettracking" {
  count              = "${local.can_scale ? 1 : 0}"
  name               = "ECSServiceAverageCPUUtilization:${aws_appautoscaling_target.ecs_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    target_value       = "${var.cpu_tracking}"
    scale_in_cooldown  = 180
    scale_out_cooldown = 180

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
