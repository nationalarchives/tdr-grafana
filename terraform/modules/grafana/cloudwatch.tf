# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "grafana_log_group" {
  name              = "/ecs/grafana-${var.environment}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "grafana_log_stream" {
  name           = "tdr-grafana-log-stream-${var.environment}"
  log_group_name = aws_cloudwatch_log_group.grafana_log_group.name
}
