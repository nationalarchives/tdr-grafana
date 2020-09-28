library("tdr-jenkinslib")
repo = "tdr-grafana"

pipeline {
	agent {
		label "master"
	}
	stages {
		stage("Run git secrets") {
			steps {
				script {
					tdr.runGitSecrets(repo)
				}
			}
		}
		stage('Run Terraform build') {
			agent {
				ecs {
					inheritFrom 'terraform'
					taskrole "arn:aws:iam::${env.MANAGEMENT_ACCOUNT}:role/TDRTerraformRoleMgmt"
				}
			}
			environment {
				//no-color option set for Terraform commands as Jenkins console unable to output the colour
				//making output difficult to read
				TF_CLI_ARGS="-no-color"
			}
			stages {
				stage('Set up Terraform workspace') {
					steps {
					  dir("./terraform") {
						  echo 'Initializing Terraform...'
							sh "git clone https://github.com/nationalarchives/tdr-terraform-modules.git"
							sh 'terraform init'
							sh "terraform workspace select default"
							sh 'terraform workspace list'
					  }
					}
				}
				stage('Run Terraform plan') {
					steps {
					  dir("./terraform") {
						  echo 'Running Terraform plan...'
							sh 'terraform plan'
							script {
							  tdr.postToDaTdrSlackChannel(colour: "good",
							    message: "Terraform plan complete for TDR Grafana. " +
								    "View here for plan: https://jenkins.tdr-management.nationalarchives.gov.uk/job/" +
									  "${JOB_NAME.replaceAll(' ', '%20')}/${BUILD_NUMBER}/console"
							  )
							}
						}
					}
				}
				stage('Approve Terraform plan') {
					steps {
						echo 'Sending request for approval of Terraform plan...'
						script {
							tdr.postToDaTdrSlackChannel(colour: "good",
							  message: "Do you approve Terraform deployment for TDR Grafana? " +
								  "https://jenkins.tdr-management.nationalarchives.gov.uk/job/" +
									"${JOB_NAME.replaceAll(' ', '%20')}/${BUILD_NUMBER}/input/"
							)
						}
						input "Do you approve deployment?"
					}
				}
				stage('Apply Terraform changes') {
					steps {
						echo 'Applying Terraform changes...'
						sh 'echo "yes" | terraform apply'
						echo 'Changes applied'
						script {
							tdr.postToDaTdrSlackChannel(colour: "good",
							  message: "Deployment complete for TDR Grafana"
							)
						}
					}
				}
			}
		}
	}
	post {
		always {
			echo 'Deleting Jenkins workspace...'
			deleteDir()
		}
	}
}

