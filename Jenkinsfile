pipeline {
    agent any

    environment {
        TF_DIR = "terraform"   // folder in repo
        ANSIBLE_DIR = "ansible" // folder in repo
        STATE_DIR = "/var/lib/jenkins/terraform-states"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-hubpat', url: 'https://github.com/alsamdevops/terraform-challenge.git'
            }
        }

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

        stage('Sleep for EC2 Init') {
            steps {
                echo "Sleeping 60 seconds to allow EC2 instances to initialize..."
                sh "sleep 60"
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh """
                        ansible-playbook -i ../${TF_DIR}/hosts.ini site.yml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Archiving terraform.tfstate and hosts.ini"
            sh """
                mkdir -p ${STATE_DIR}
                cp ${TF_DIR}/terraform.tfstate ${STATE_DIR}/terraform.tfstate
                cp ${TF_DIR}/hosts.ini ${STATE_DIR}/hosts.ini
            """
        }
        cleanup {
            echo "Cleaning workspace..."
            deleteDir()
        }
    }
}
