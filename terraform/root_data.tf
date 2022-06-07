data "aws_security_group" "ecs_task_security_group" {
  vpc_id = module.grafana_vpc.vpc_id
  tags = {
    Name = "${var.project}-grafana-ecs-task-security-group-${local.environment}"
  }
}

data "aws_ssm_parameter" "cost_centre" {
  name = "/mgmt/cost_centre"
}

