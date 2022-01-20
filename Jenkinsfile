library("tdr-jenkinslib")

terraformDeployJob(
  //Always default to the management (mgmt) environment as Grafana should only be deployed in this environment
  stage: "mgmt",
  repo: "tdr-grafana",
  taskRoleName: "TDRTerraformRoleMgmt",
  deployment: "Grafana",
  terraformDirectoryPath: "./terraform",
  terraformModulesBranch: "terraform-v1",
  terraformNode: "terraform-latest"
)
