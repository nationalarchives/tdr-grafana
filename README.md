# TDR Grafana

Repository containing the configuration necessary to setup a Grafana instance for the TDR project.

There is a single TDR Grafana instance running in the TDR management AWS Account.

The ECS cluster is created by Terraform, and runs on the Jenkins vpc on the TDR management AWS account.

TDR Jenkins documentation: https://github.com/nationalarchives/tdr-jenkins/blob/master/README.md 

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
* IAM permissions for the ECS task role to read the necessary metrics from the different TDR environments

The Terraform uses some shared components from the tdr-terraform-modules repository: https://github.com/nationalarchives/tdr-terraform-modules

The Grafana instance runs on the existing Jenkins Vpc in the TDR management AWS account.

#### Running the Terraform

1. Clone the tdr-terraform-modules into the `terraform` directory:
  ``` 
  cd terraform
  git clone git@github.com:nationalarchives/tdr-terraform-modules.git
  ```
2. In the `terraform` directory ensure that running terraform in the `default` workspace

3. Run `terraform plan` and `terraform apply` command as necessary to make changes to the

### Docker image

The application uses the standard grafana docker image: https://hub.docker.com/r/grafana/grafana

The ECS task definition pulls the latest version of the Grafana image.

## Deploying

To deploy changes to the Grafana:

1. Make changes to the Terraform
2. Run `terraform` apply command

## Updating Grafana Visualisations

Documentation for using Grafana can be found here: https://grafana.com/docs/grafana/latest/

Dashboards etc are persisted in the Grafana postgres database.

## Grafana Data Sources

Four data sources have been configured, corresponding to each of the TDR environments:
* TDR-Integration-CloudWatch
* TDR-Management-CloudWatch
* TDR-Production-CloudWatch (default)
* TDR-Staging-CloudWatch

For the integration, production and staging data sources, access to the metrics is provided by assuming an IAM role in the corresponding TDR environment which has permission to read the necessary metrics within that environment.

IAM assumed roles are configured in the tdr-terraform-backend repository: https://github.com/nationalarchives/tdr-terraform-backend
