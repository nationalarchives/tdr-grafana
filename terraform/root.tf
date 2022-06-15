module "global_parameters" {
  source = "./tdr-configurations/terraform"
}

module "grafana_iam_role" {
  source             = "./tdr-terraform-modules/iam_role"
  assume_role_policy = templatefile("${path.module}/templates/iam/grafana_assume_role.json.tpl", {})
  common_tags        = local.common_tags
  name               = "TDRGrafanaRoleMgmt"
  policy_attachments = {
    grafana_assume_role = module.grafana_iam_policy.policy_arn,
    cloudwatch          = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  }
}

module "grafana_iam_policy" {
  source        = "./tdr-terraform-modules/iam_policy"
  name          = "TDRGrafanaEnvMonitoringAssumeRoles"
  policy_string = templatefile("${path.module}/templates/iam/grafana_assume_env_monitoring_roles_policy.json.tpl", { intg_account_id = data.aws_ssm_parameter.intg_account_id.value, staging_account_id = data.aws_ssm_parameter.staging_account_id.value, prod_account_id = data.aws_ssm_parameter.prod_account_id.value })
}

resource "aws_grafana_workspace" "management_grafana" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["CLOUDWATCH"]
  name                     = "tdr-grafana-mgmt"
  role_arn                 = module.grafana_iam_role.role.arn
  lifecycle {
    ignore_changes = [data_sources]
  }
}
