data "aws_ssm_parameter" "intg_account_id" {
  name = "/${var.environment}/intg_account"
}

data "aws_ssm_parameter" "prod_account_id" {
  name = "/${var.environment}/prod_account"
}

data "aws_ssm_parameter" "staging_account_id" {
  name = "/${var.environment}/staging_account"
}

resource "aws_iam_policy" "assume_grafana_env_monitoring_roles" {
  name = "TDRGrafanaEnvMonitoringAssumeRoles"
  policy = templatefile(
    "${path.module}/templates/grafana_assume_env_monitoring_roles_policy.json.tpl",
    {
      intg_account_id    = data.aws_ssm_parameter.intg_account_id.value,
      prod_account_id    = data.aws_ssm_parameter.prod_account_id.value,
      staging_account_id = data.aws_ssm_parameter.staging_account_id.value
    }
  )
}

resource "aws_iam_policy" "grafana_mgmt_log_permissions" {
  name   = "TDRGrafanaMgmtLogPermissions"
  policy = templatefile("${path.module}/templates/grafana_mgmt_log_permissions_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "grafana_env_monitoring" {
  role       = var.ecs_task_role_name[0]
  policy_arn = aws_iam_policy.assume_grafana_env_monitoring_roles.arn
}

resource "aws_iam_role_policy_attachment" "grafana_mgmt_log_permissions_attach" {
  policy_arn = aws_iam_policy.grafana_mgmt_log_permissions.arn
  role       = var.ecs_task_role_name[0]
}
