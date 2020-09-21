module "grafana" {
  source               = "./modules/grafana"
  app_name             = "${var.project}-${var.function}"
  alb_dns_name         = module.grafana_alb.alb_dns_name
  alb_target_group_arn = module.grafana_alb.alb_target_group_arn
  alb_zone_id          = module.grafana_alb.alb_zone_id
  az_count             = 2
  common_tags          = local.common_tags
  container_name       = var.function
  dns_zone             = var.dns_zone
  ecs_task_role_name   = module.grafana_ecs.grafana_ecs_task_role_name
  environment          = local.environment
  region               = local.aws_region
}

module "grafana_ecs" {
  source               = "./tdr-terraform-modules/ecs"
  alb_target_group_arn = module.grafana_alb.alb_target_group_arn
  app_name             = "grafana"
  common_tags          = local.common_tags
  grafana_build        = true
  project              = "tdr"
  vpc_name_tag         = module.grafana.vpc_tag_name
}

module "grafana_certificate" {
  source      = "./tdr-terraform-modules/certificatemanager"
  common_tags = local.common_tags
  dns_zone    = var.dns_zone
  domain_name = var.domain_name
  function    = var.function
  project     = var.project
}

module "grafana_alb" {
  source                = "./tdr-terraform-modules/alb"
  alb_log_bucket        = module.alb_logs_s3.s3_bucket_id
  alb_security_group_id = module.grafana.alb_security_group_id
  alb_target_group_port = 3000
  alb_target_type       = "ip"
  certificate_arn       = module.grafana_certificate.certificate_arn
  common_tags           = local.common_tags
  domain_name           = var.domain_name
  environment           = local.environment
  function              = var.function
  health_check_matcher  = "200,302"
  health_check_path     = ""
  http_listener         = false
  project               = var.project
  public_subnets        = module.grafana.public_subnets
  vpc_id                = module.grafana.vpc_id
}

module "alb_logs_s3" {
  source        = "./tdr-terraform-modules/s3"
  access_logs   = false
  bucket_policy = "alb_logging_euwest2"
  common_tags   = local.common_tags
  function      = "${var.function}-logs"
  project       = "tdr"
}
