locals {
  aws_region = var.default_aws_region
  common_tags = tomap({
    "Environment" =  local.environment,
    "Owner" = "TDR",
    "Terraform" = true,
    "TerraformSource" = "https://github.com/nationalarchives/tdr-grafana/tree/master/terraform",
    "CostCentre" = data.aws_ssm_parameter.cost_centre.value
  })
  database_availability_zones = ["eu-west-2a", "eu-west-2b"]
  environment                 = "mgmt"

  developer_ip_list = split(",", module.global_parameters.developer_ips)
  trusted_ip_list   = split(",", module.global_parameters.trusted_ips)
  ip_allowlist      = concat(local.developer_ip_list, local.trusted_ip_list)
}
