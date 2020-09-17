locals {
  app_port = 3000
}

data "aws_ssm_parameter" "intg_account_id" {
  name = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "prod_account_id" {
  name = "/mgmt/prod_account"
}

data "aws_ssm_parameter" "staging_account_id" {
  name = "/mgmt/staging_account"
}

resource "aws_ecs_cluster" "grafana_ecs" {
  name = "grafana-${var.environment}"

  tags = merge(
    var.common_tags,
    map("Name", "tdr-grafana-${var.environment}")
  )
}

data "template_file" "app" {
  template = file("modules/grafana/templates/grafana.json.tpl")

  vars = {
    admin_user          = aws_ssm_parameter.grafana_admin_user.name
    admin_user_password = aws_ssm_parameter.grafana_admin_password.name
    app_image           = "grafana/grafana:latest"
    app_port            = local.app_port
    app_environment     = var.environment
    aws_region          = var.region
  }
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "${var.container_name}-${var.environment}"
  execution_role_arn       = aws_iam_role.grafana_ecs_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  container_definitions    = data.template_file.app.rendered
  task_role_arn            = aws_iam_role.grafana_ecs_task.arn

  tags = merge(
    var.common_tags,
    map("Name", "${var.container_name}-task-definition-${var.environment}")
  )
}

resource "aws_ecs_service" "grafana_service" {
  name                              = "${var.container_name}-service-${var.environment}"
  cluster                           = aws_ecs_cluster.grafana_ecs.id
  task_definition                   = aws_ecs_task_definition.grafana_task.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = "360"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.app_name
    container_port   = 3000
  }

  depends_on = [var.alb_target_group_arn]
}

resource "aws_iam_role" "grafana_ecs_execution" {
  name               = "TDRGrafanaAppExecutionRole${title(var.environment)}"
  assume_role_policy = data.template_file.ecs_assume_role.rendered

  tags = merge(
    var.common_tags,
    map(
      "Name", "grafana-ecs-execution-iam-role-${var.environment}",
    )
  )
}

resource "aws_iam_role" "grafana_ecs_task" {
  name               = "TDRGrafanaAppTaskRole${title(var.environment)}"
  assume_role_policy = data.template_file.ecs_assume_role.rendered

  tags = merge(
    var.common_tags,
    map(
      "Name", "grafana-ecs-task-iam-role-${var.environment}",
    )
  )
}

data "template_file" "assume_grafana_env_monitoring_roles" {
  template = file("modules/grafana/templates/assume_grafana_env_monitoring_roles_policy.json.tpl")

  vars = {
    intg_account_id    = data.aws_ssm_parameter.intg_account_id.value
    prod_account_id    = data.aws_ssm_parameter.prod_account_id.value
    staging_account_id = data.aws_ssm_parameter.staging_account_id.value
  }
}

data "template_file" "ecs_assume_role" {
  template = file("modules/grafana/templates/ecs_assume_role.json.tpl")
}

data "template_file" "grafana_ecs_execution" {
  template = file("modules/grafana/templates/grafana_ecs_execution_policy.json.tpl")

  vars = {
    cloudwatch_log_group = aws_cloudwatch_log_group.grafana_log_group.arn
  }
}

resource "aws_iam_policy" "grafana_ecs_execution" {
  name   = "TDRGrafanaEcsExecutionPolicy${title(var.environment)}"
  path   = "/"
  policy = data.template_file.grafana_ecs_execution.rendered
}

resource "aws_iam_policy" "assume_grafana_env_monitoring_roles" {
  name   = "TDRGrafanaEnvMonitoringAssumeRoles"
  policy = data.template_file.assume_grafana_env_monitoring_roles.rendered
}

resource "aws_iam_role_policy_attachment" "grafana_ecs_execution" {
  role       = aws_iam_role.grafana_ecs_execution.name
  policy_arn = aws_iam_policy.grafana_ecs_execution.arn
}

resource "aws_iam_role_policy_attachment" "grafana_ecs_execution_ssm" {
  role       = aws_iam_role.grafana_ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "grafana_env_monitoring" {
  role       = aws_iam_role.grafana_ecs_task.name
  policy_arn = aws_iam_policy.assume_grafana_env_monitoring_roles.arn
}
