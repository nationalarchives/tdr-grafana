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

resource "aws_grafana_role_association" "admin_role" {
  role         = "ADMIN"
  user_ids     = ["9c6727bee3-35c6bc23-3fee-4125-a1ca-08ecd55b099c"]
  workspace_id = aws_grafana_workspace.management_grafana.id
}

resource "aws_grafana_role_association" "editor_role" {
  role         = "EDITOR"
  user_ids     = ["9c6727bee3-71990616-0bf7-452a-bae0-ab74b5f7313c", "9c6727bee3-5ac629bc-c899-40c2-8c0f-0cd45457e0e7", "9c6727bee3-4a36c92a-5dd3-4b71-b7a4-269b8203eba0", "9c6727bee3-92011006-8c2a-40a8-a9d2-b48f2711a593"]
  workspace_id = aws_grafana_workspace.management_grafana.id
}
