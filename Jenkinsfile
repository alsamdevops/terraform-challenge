pipeline {
    agent any

    environment {
        TF_DIR       = "terraform"
        ANSIBLE_DIR  = "ansible"
        GIT_BRANCH   = "main"
        STATE_DIR    = "/var/lib/jenkins/terraform-state"
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

        stage('Move hosts.ini to Ansible') {
            steps {
                sh """
                    cp ${TF_DIR}/hosts.ini ${ANSIBLE_DIR}/hosts.ini
                """
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh """
                        ansible-playbook -i hosts.ini site.yml
                    """
                }
            }
        }

        stage('Commit & Push hosts.ini to GitHub') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                dir("${ANSIBLE_DIR}") {
                    withCredentials([string(credentialsId: 'git-hubpat', variable: 'GITHUB_PAT')]) {
                        sh """
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@yourdomain.com"
                            git checkout ${GIT_BRANCH}
                            git add hosts.ini
                            git commit -m "Update hosts.ini from Jenkins on $(date)" || true
                            git remote set-url origin https://x-access-token:${GITHUB_PAT}@github.com/alsamdevops/terraform-challenge.git
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
                    cp ${TF_DIR}/terraform.tfstate ${STATE_DIR}/terraform.tfstate
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
