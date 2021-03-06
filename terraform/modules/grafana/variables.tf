variable "alb_dns_name" {}

variable "alb_zone_id" {}

variable "az_count" {}

variable "common_tags" {}

variable "database_availability_zones" {}

variable "dns_zone" {}

variable "ecs_task_role_name" {}

variable "environment" {}

variable "ip_allowlist" {
  type = list
}

variable "kms_key_id" {}

variable "vpc_cidr_block" {}

variable "vpc_id" {}
