data "aws_security_group" "ecs_task_security_group" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "${var.project}-grafana-ecs-task-security-group-${local.environment}"
  }
}

data "aws_ssm_parameter" "cost_centre" {
  name = "/mgmt/cost_centre"
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "${var.project}-grafana-private-subnet-*-${local.environment}"
  }
}

data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name_tag
  }
}
