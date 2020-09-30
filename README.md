# TDR Grafana

Repository containing the configuration necessary to setup a Grafana instance for the TDR project.

There is a single TDR Grafana instance running in the TDR management AWS Account.

The ECS cluster is created by Terraform, and runs on the Jenkins VPC on the TDR management AWS account.

For further documentation on the TDR Jenkins configuration see here: https://github.com/nationalarchives/tdr-jenkins

## Project components

### Terraform

This creates the following AWS resources:
* Subnets
* ECS cluster
* ECS service
* ECS task definition
* Security groups
* AWS SSM parameters
* Database (postgres)
* IAM permissions for the ECS task role to read the necessary metrics from the different TDR environments (management, integration, production and staging)

The Terraform uses some shared components from the tdr-terraform-modules repository: https://github.com/nationalarchives/tdr-terraform-modules

The Grafana instance runs on the existing Jenkins VPC in the TDR management AWS account.

### Docker image

The application uses the standard grafana docker image: https://hub.docker.com/r/grafana/grafana

The ECS task definition pulls the latest version of the Grafana image.

## Deployment

There is a Jenkins job configured to deploy changes to the Grafana configuration: https://jenkins.tdr-management.nationalarchives.gov.uk/job/TDR%20Grafana%20Deploy/

**NOTE: The Jenkins Job requires a STAGE parameter to be set. This is ignored by the job, as it always defaults to the management environment.**

There is a tech debt item to address this issue: https://national-archives.atlassian.net/jira/software/projects/TDR/boards/6/backlog?selectedIssue=TDR-540

To deploy changes to the Grafana instance:

1. Make changes to the Terraform
2. Run `terraform` plan command locally to check changes
3. Merge changes to master branch
4. Run the Jenkins job: TDR Grafana Deploy

## Creating and Updating Grafana Visualisations

Documentation for using Grafana can be found here: https://grafana.com/docs/grafana/latest/

Dashboards etc are persisted in the Grafana postgres database.

## Grafana Data Sources

Four data sources have been configured, corresponding to each of the TDR environments:
* TDR-Integration-CloudWatch
* TDR-Management-CloudWatch
* TDR-Production-CloudWatch (default)
* TDR-Staging-CloudWatch

For the integration, production and staging data sources, access to the metrics is provided by assuming an IAM role in the corresponding TDR environment which has permission to read the necessary metrics within that environment.

For the management data sources, permission to access the metrics is given to the IAM ECS task role.

IAM assumed roles are configured in the tdr-terraform-backend repository: https://github.com/nationalarchives/tdr-terraform-backend

## Adding a Dashboard

When adding a new dashboard for TDR, ensure that the dashboard is:
* added to the TDR folder
* tagged with `TDR`
