# Name of the bucket where we can store build artifacts
output ecs_cluster_id {
  value = "${aws_ecs_cluster.services.id}"
}

# ECS role to apply to all services
output ecs_service_role {
  value = "${aws_iam_role.ecs_service_role.arn}"
}

# ECS cluster security group
output cluster_security_group {
  value = "${aws_security_group.ecs.id}"
}

output cluster_name {
  value = "${aws_ecs_cluster.services.name}"
}
