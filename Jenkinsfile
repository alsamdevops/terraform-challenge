pipeline {
    agent any

    environment {
        TF_DIR        = "terraform"
        ANSIBLE_DIR   = "ansible"
        STATE_DIR     = "/var/lib/jenkins"
        GIT_REPO      = "https://github.com/alsamdevops/terraform-challenge.git"
        GIT_BRANCH    = "main"
        GIT_CRED      = "git-hubpat"
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
                        ansible-playbook -i ../${TF_DIR}/hosts.ini site.yaml
                    """
                }
            }
        }

        stage('Commit & Push hosts.ini') {
            when {
                expression { fileExists("${TF_DIR}/hosts.ini") }
            }
            steps {
                dir("${ANSIBLE_DIR}") {
                    withCredentials([usernamePassword(credentialsId: "${GIT_CRED}", usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config user.email "jenkins@local"
                            git config user.name "Jenkins"
                            git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/alsamdevops/terraform-challenge.git
                            cp ../${TF_DIR}/hosts.ini ./hosts.ini
                            git add hosts.ini
                            git commit -m "Added hosts.ini after successful Ansible run" || echo "No changes to commit"
                            git push origin ${GIT_BRANCH}
                        """
                    }
                }
            }
        }

        stage('Save Terraform State') {
            steps {
                sh """
                    mkdir -p ${STATE_DIR}
                    cp ${TF_DIR}/terraform.tfstate ${STATE_DIR}/terraform.tfstate || true
                """
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
