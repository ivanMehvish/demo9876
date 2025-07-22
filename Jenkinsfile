pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    TF_WORKDIR = '.'
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir(env.TF_WORKDIR) {
          sh 'terraform init -upgrade' // ensures provider lock updates to v6.x :contentReference[oaicite:1]{index=1}
        }
      }
    }

    stage('Terraform Validate & Plan') {
      steps {
        dir(env.TF_WORKDIR) {
          sh 'terraform validate'
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir(env.TF_WORKDIR) {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
  }

  post {
    always {
      cleanWs()
      echo 'Workspace cleaned'
    }
    success {
      echo '🎉 Terraform applied successfully!'
    }
    failure {
      echo '❌ Build failed — check logs'
    }
  }
}
