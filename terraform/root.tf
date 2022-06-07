module "global_parameters" {
  source = "./tdr-configurations/terraform"
}

module "grafana" {
  source = "./modules/grafana"

  alb_dns_name                = module.grafana_alb.alb_dns_name
  alb_zone_id                 = module.grafana_alb.alb_zone_id
  az_count                    = var.az_count
  common_tags                 = local.common_tags
  database_availability_zones = local.database_availability_zones
  dns_zone                    = var.dns_zone
  ecs_task_role_name          = module.grafana_ecs.grafana_ecs_task_role_name
  environment                 = local.environment
  ip_allowlist                = local.ip_allowlist
  kms_key_id                  = module.encryption_key.kms_key_arn
  vpc_id                      = module.grafana_vpc.vpc_id
  private_subnet_ids          = module.grafana_vpc.private_subnets
}

module "grafana_vpc" {
  source      = "./tdr-terraform-modules/vpc"
  app_name    = "tdr-grafana"
  az_count    = 2
  common_tags = local.common_tags
  environment = local.environment
}

module "grafana_flow_log_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGrafanaFlowlogPolicy${title(local.environment)}"
  policy_string = templatefile("./templates/iam/grafana_vpc_flow_logs.json.tpl", {})
}

module "grafana_flow_log_role" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("./templates/iam/flow_logs_assume_role.json.tpl", {})
  common_tags        = local.common_tags
  name               = "grafana_flowlog_role_${local.environment}"
  policy_attachments = { flow_log_policy = module.grafana_flow_log_policy.policy_arn }
}

module "grafana_flow_logs_cloudwatch_group" {
  source      = "./tdr-terraform-modules/cloudwatch_logs"
  common_tags = local.common_tags
  name        = "/flowlogs/tdr-grafana-vpc-${local.environment}"
}

module "grafana_flow_logs" {
  source        = "./tdr-terraform-modules/flowlogs"
  log_group_arn = module.grafana_flow_logs_cloudwatch_group.log_group_arn
  role_arn      = module.grafana_flow_log_role.role.arn
  s3_arn        = "arn:aws:s3:::tdr-log-data-mgmt/flowlogs/${local.environment}/grafana/"
  vpc_id        = module.grafana_vpc.vpc_id
}

module "grafana_ecs" {
  source = "./tdr-terraform-modules/ecs"

  alb_target_group_arn       = module.grafana_alb.alb_target_group_arn
  app_name                   = "grafana"
  common_tags                = local.common_tags
  domain_name                = var.domain_name
  ecs_task_security_group_id = data.aws_security_group.ecs_task_security_group.id
  grafana_build              = true
  project                    = var.project
  vpc_private_subnet_ids     = module.grafana_vpc.private_subnets
  vpc_id                     = module.grafana_vpc.vpc_id
}

module "grafana_certificate" {
  source = "./tdr-terraform-modules/certificatemanager"

  common_tags = local.common_tags
  dns_zone    = var.dns_zone
  domain_name = var.domain_name
  function    = var.function
  project     = var.project
}

module "grafana_alb" {
  source = "./tdr-terraform-modules/alb"

  alb_log_bucket        = module.alb_logs_s3.s3_bucket_id
  alb_security_group_id = module.grafana.alb_security_group_id
  alb_target_group_port = 3000
  alb_target_type       = "ip"
  certificate_arn       = module.grafana_certificate.certificate_arn
  common_tags           = local.common_tags
  environment           = local.environment
  function              = var.function
  health_check_matcher  = "200,302"
  health_check_path     = ""
  project               = var.project
  public_subnets        = module.grafana_vpc.public_subnets
  vpc_id                = module.grafana_vpc.vpc_id
}

module "alb_logs_s3" {
  source = "./tdr-terraform-modules/s3"

  access_logs   = false
  bucket_policy = "alb_logging_euwest2"
  common_tags   = local.common_tags
  function      = "${var.function}-logs"
  project       = var.project
}

module "encryption_key" {
  source      = "./tdr-terraform-modules/kms"
  project     = "${var.project}-grafana"
  function    = "encryption"
  environment = local.environment
  common_tags = local.common_tags
}
