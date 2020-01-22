# ----------------------------------------------------------------
# Infrastructure
# ----------------------------------------------------------------
module "network" {
  source             = "./infrastructure/network"
  aws_region         = "${local.aws_region}"
  environment        = "${local.environment}"
  vpc_cidr           = "${local.vpc_cidr}"
  public_cidrs       = "${local.public_cidrs}"
  private_cidrs      = "${local.private_cidrs}"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

module "ecs" {
  source       = "./infrastructure/ecs"
  aws_region   = "${local.aws_region}"
  environment  = "${local.environment}"
  vpc_id       = "${module.network.vpc_id}"
  subnet_ids   = "${module.network.private_subnet_ids}"
}

module "api_gateway" {
  source               = "./infrastructure/api_gateway"
  aws_region           = "${local.aws_region}"
  environment          = "${local.environment}"
  vpc_id               = "${module.network.vpc_id}"
  public_subnet_ids    = "${module.network.public_subnet_ids}"
  ecs_security_group   = "${module.ecs.cluster_security_group}"
}

# ----------------------------------------------------------------
# Applications
# ----------------------------------------------------------------

module "sbires_service" {
  source                   = "./applications/sbires_service"
  aws_region               = "${local.aws_region}"
  environment              = "${local.environment}"
  vpc_id                   = "${module.network.vpc_id}"
  subnet_ids               = "${module.network.private_subnet_ids}"
  ecs_cluster_id           = "${module.ecs.ecs_cluster_id}"
  ecs_service_role         = "${module.ecs.ecs_service_role}"
  ecs_security_group       = "${module.ecs.cluster_security_group}"
  alb_listener             = "${module.api_gateway.alb_listener}"
  alb_zone_id              = "${module.api_gateway.alb_zone_id}"
  alb_dns_name             = "${module.api_gateway.alb_dns_name}"
}

module "codedeploy" {
  source                     = "git::https://github.com/tmknom/terraform-aws-codedeploy-for-ecs.git?ref=tags/1.2.0"
  name                       = "${module.sbires_service.service_name}-deploy"
  ecs_cluster_name           = "${module.ecs.cluster_name}"
  ecs_service_name           = "${module.sbires_service.service_name}"
  lb_listener_arns           = ["${module.api_gateway.alb_listener}"]
  blue_lb_target_group_name  = "${module.sbires_service.target_group_blue}"
  green_lb_target_group_name = "${module.sbires_service.target_group_green}"

  auto_rollback_enabled            = true
  auto_rollback_events             = ["DEPLOYMENT_FAILURE"]
  action_on_timeout                = "STOP_DEPLOYMENT"
  wait_time_in_minutes             = 20
  termination_wait_time_in_minutes = 20
  test_traffic_route_listener_arns = []
  description                      = "Sbires service deploy"

  tags = {
    Application = "sbires"
    Environment = "${local.environment}"
  }
}
