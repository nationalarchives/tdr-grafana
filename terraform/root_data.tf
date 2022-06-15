data "aws_ssm_parameter" "cost_centre" {
  name = "/${local.environment}/cost_centre"
}

data "aws_ssm_parameter" "intg_account_id" {
  name = "/${local.environment}/intg_account"
}

data "aws_ssm_parameter" "prod_account_id" {
  name = "/${local.environment}/prod_account"
}

data "aws_ssm_parameter" "staging_account_id" {
  name = "/${local.environment}/staging_account"
}
