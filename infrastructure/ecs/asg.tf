resource "aws_autoscaling_group" "ecs" {
  vpc_zone_identifier = ["${var.subnet_ids}"]
  min_size            = 0
  max_size            = 5
  desired_capacity    = 1
  enabled_metrics     = ["GroupTotalInstances"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.ecs.id}"
        version            = "$$Latest"
      }

      override {
        instance_type = "t2.micro"
      }
    }
  }

  lifecycle {
    ignore_changes = ["desired_capacity"]
  }

  tag {
    key                 = "Name"
    value               = "sbires-ecs-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
