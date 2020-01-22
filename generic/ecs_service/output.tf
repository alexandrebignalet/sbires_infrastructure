output task_role {
  value = "${aws_iam_role.ecs_task_role.id}"
}

output task_role_arn {
  value = "${aws_iam_role.ecs_task_role.arn}"
}

output target_group_blue {
  value = "${join("", aws_lb_target_group.service_1.*.name)}"
}

output target_group_green {
  value = "${join("", aws_lb_target_group.service_2.*.name)}"
}
