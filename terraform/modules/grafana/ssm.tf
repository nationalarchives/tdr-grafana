data "aws_ssm_parameter" "intg_account_id" {
  name = "/${var.environment}/intg_account"
}

data "aws_ssm_parameter" "prod_account_id" {
  name = "/${var.environment}/prod_account"
}

data "aws_ssm_parameter" "staging_account_id" {
  name = "/${var.environment}/staging_account"
}
