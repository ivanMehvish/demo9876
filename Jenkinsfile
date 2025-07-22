pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    TF_DIR     = '.'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir(TF_DIR) {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir(TF_DIR) {
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir(TF_DIR) {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }

  post {
    success {
      echo '✅ Terraform applied successfully!'
    }
    failure {
      echo '❌ Pipeline failed. Check logs above.'
    }
  }
}
