output service_name {
  value = "${local.service_name}"
}

output target_group_blue {
  value = "${module.ecs_service.target_group_blue}"
}

output target_group_green {
  value = "${module.ecs_service.target_group_green}"
}
