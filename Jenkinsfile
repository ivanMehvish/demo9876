pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'       // e.g. us-east-1
    TF_WORKDIR = '.'                 // Terraform code root directory
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir("${env.TF_WORKDIR}") {
          sh "terraform init \
            -backend-config=\"bucket=mehvish-bt1\" \
            -backend-config=\"key=terraform.tfstate\" \
            -backend-config=\"region=${env.AWS_REGION}\""
        }
      }
    }

    stage('Terraform Validate & Plan') {
      steps {
        dir("${env.TF_WORKDIR}") {
          sh 'terraform validate'
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir("${env.TF_WORKDIR}") {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }

  post {
    always {
      echo 'Cleaning up (if needed)...'
    }
    success {
      echo 'Terraform applied successfully!'
    }
    failure {
      echo 'Pipeline failed. Check the logs above.'
    }
  }
}
