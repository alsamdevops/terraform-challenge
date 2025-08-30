pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "/var/lib/jenkins/ansible"
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh """
                        terraform init
                        terraform apply -auto-approve
                    """
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh """
		    ansible-playbook -i host.yaml site.yaml
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed. Use the separate destroy pipeline to clean up infra."
        }
    }
}

