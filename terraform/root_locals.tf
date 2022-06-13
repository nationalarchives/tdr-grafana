locals {
  aws_region = "eu-west-2"
  common_tags = tomap({
    "Environment"     = local.environment,
    "Owner"           = "TDR",
    "Terraform"       = true,
    "TerraformSource" = "https://github.com/nationalarchives/tdr-grafana/tree/master/terraform",
    "CostCentre"      = data.aws_ssm_parameter.cost_centre.value
  })
  environment = "mgmt"
}
