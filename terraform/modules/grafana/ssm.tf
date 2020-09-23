resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.environment}/grafana/database/url"
  type  = "SecureString"
  value = aws_rds_cluster.grafana_database.endpoint
}

resource "aws_ssm_parameter" "database_username" {
  name  = "/${var.environment}/grafana/database/username"
  type  = "SecureString"
  value = aws_rds_cluster.grafana_database.master_username
}

resource "aws_ssm_parameter" "database_password" {
  name  = "/${var.environment}/grafana/database/password"
  type  = "SecureString"
  value = aws_rds_cluster.grafana_database.master_password
}
