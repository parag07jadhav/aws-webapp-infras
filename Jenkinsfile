pipeline {
  agent any

  environment {
    REGISTRY = "your-dockerhub-username"
    IMAGE_TAG = "latest"
    REPO = "your-repo-name"
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/your-org/aws-webapp-infras.git'
      }
    }

    stage('Build Docker Images') {
      parallel {
        stage('Frontend') {
          steps {
            dir('app/frontend') {
              sh 'docker build -t $REGISTRY/frontend:$IMAGE_TAG .'
            }
          }
        }
        stage('Backend') {
          steps {
            dir('app/backend') {
              sh 'docker build -t $REGISTRY/backend:$IMAGE_TAG .'
            }
          }
        }
      }
    }

    stage('Push Docker Images') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker push $REGISTRY/frontend:$IMAGE_TAG'
          sh 'docker push $REGISTRY/backend:$IMAGE_TAG'
        }
      }
    }

    stage('Deploy to EKS') {
      when {
        branch 'main'
      }
      steps {
        dir('k8s') {
          sh '''
          kubectl apply -f frontend-deployment.yaml
          kubectl apply -f backend-deployment.yaml
          kubectl apply -f mongodb-deployment.yaml
          '''
        }
      }
    }

    stage('Deploy to ECS') {
      when {
        branch 'dev'
      }
      steps {
        sh '''
        aws ecs update-service --cluster webapp-ecs --service frontend --force-new-deployment
        aws ecs update-service --cluster webapp-ecs --service backend --force-new-deployment
        '''
      }
    }
  }
}
