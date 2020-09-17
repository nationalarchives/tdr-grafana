resource "random_password" "grafana_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "grafana_admin_password" {
  name  = "/${var.environment}/grafana/admin/password"
  type  = "SecureString"
  value = random_password.grafana_password.result
}

resource "aws_ssm_parameter" "grafana_admin_user" {
  name  = "/${var.environment}/grafana/admin/user"
  type  = "SecureString"
  value = "tdr-grafana-admin-${var.environment}"
}
