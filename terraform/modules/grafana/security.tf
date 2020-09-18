locals {
  app_port = 3000
}

data "aws_ssm_parameter" "external_ips" {
  name = "/${var.environment}/external_ips"
}

resource "aws_security_group" "grafana_alb_group" {
  name        = "${var.app_name}-alb-security-group"
  description = "Controls access to the Grafana load balancer"
  vpc_id      = aws_vpc.main.id
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = split(",", data.aws_ssm_parameter.external_ips.value)
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-security-group-${var.environment}"
  description = "Allow inbound access from the keycloak load balancer only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = local.app_port
    to_port         = local.app_port
    security_groups = [aws_security_group.grafana_alb_group.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    map("Name", "${var.app_name}-ecs-task-security-group-${var.environment}")
  )
}
