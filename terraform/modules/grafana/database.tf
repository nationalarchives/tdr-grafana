resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_db_subnet_group" "user_subnet_group" {
  name       = "main-${var.environment}"
  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    var.common_tags,
    map(
      "Name", "user-db-subnet-group-${var.environment}"
    )
  )
}

resource "random_string" "snapshot_prefix" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_rds_cluster" "grafana_database" {
  cluster_identifier_prefix       = "grafana-db-postgres-${var.environment}"
  engine                          = "aurora-postgresql"
  engine_version                  = "11.9"
  availability_zones              = var.database_availability_zones
  database_name                   = "grafana"
  master_username                 = "grafana_admin"
  master_password                 = random_password.password.result
  final_snapshot_identifier       = "grafana-db-final-snapshot-${random_string.snapshot_prefix.result}-${var.environment}"
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_id
  vpc_security_group_ids          = aws_security_group.database.*.id
  db_subnet_group_name            = aws_db_subnet_group.user_subnet_group.name
  deletion_protection             = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  tags = merge(
    var.common_tags,
    map(
      "Name", "grafana-db-cluster-${var.environment}"
    )
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to availability zones because AWS automatically adds the
      # extra availability zone "eu-west-2c", which is rejected by the API as
      # unavailable if specified directly.
      availability_zones,
    ]
  }
}

resource "aws_rds_cluster_instance" "user_database_instance" {
  count                = 1
  identifier_prefix    = "content-db-postgres-instance-${var.environment}"
  cluster_identifier   = aws_rds_cluster.grafana_database.id
  engine               = "aurora-postgresql"
  engine_version       = "11.9"
  instance_class       = "db.t3.medium"
  db_subnet_group_name = aws_db_subnet_group.user_subnet_group.name
}
