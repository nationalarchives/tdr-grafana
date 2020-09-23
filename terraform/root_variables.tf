variable "az_count" {
  default = 2
}

variable "default_aws_region" {
  default = "eu-west-2"
}

variable "dns_zone" {
  description = "DNS zone name e.g. tdr-management.nationalarchives.gov.uk"
  default     = "tdr-management.nationalarchives.gov.uk"
}

variable "domain_name" {
  description = "fully qualified domain name for the service"
  default     = "grafana.tdr-management.nationalarchives.gov.uk"
}

variable "function" {
  description = "forms the second part of the bucket name, eg. upload"
  default     = "grafana"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
  default     = "tdr"
}

variable "vpc_name_tag" {
  default = "tdr-jenkins-vpc-mgmt"
}
