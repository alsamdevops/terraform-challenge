pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
        STATE_DIR = "/var/lib/jenkins"
        SSH_KEY = "/var/lib/jenkins/.ssh/new.pem"   // private key that matches your "new" key pair
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'git-hubpat',
                    url: 'https://github.com/alsamdevops/terraform-challenge.git'
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

        stage('Wait for SSH') {
            steps {
                dir("${TF_DIR}") {
                    script {
                        def hosts = readFile('hosts.ini').split('\n')
                        for (h in hosts) {
                            if (h.trim() && !h.startsWith('[')) {
                                def ip = h.split(' ')[0]
                                sh """
                                    echo "Waiting for SSH on ${ip}..."
                                    until nc -zv ${ip} 22; do sleep 5; done
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh """
                        ANSIBLE_HOST_KEY_CHECKING=False \
                        ansible-playbook -i ../${TF_DIR}/hosts.ini site.yml \
                        --private-key=${SSH_KEY}
                    """
                }
            }
        }

    }

    post {
        success {
            echo "Saving Terraform state..."
            sh """
                mkdir -p ${STATE_DIR}
                cp -f ${TF_DIR}/terraform.tfstate ${STATE_DIR}/terraform.tfstate
            """
        }
        always {
            echo "Cleaning up workspace..."
            deleteDir()
        }
    }
}
