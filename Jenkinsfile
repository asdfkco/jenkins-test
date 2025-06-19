pipeline {
  agent {
    kubernetes {
      label 'kaniko-prod-agent'
      defaultContainer 'kaniko'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: kaniko-prod
spec:
  containers:
  - name: kaniko
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1"
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: IfNotPresent
    command: ["sleep"]
    args: ["infinity"]
    volumeMounts:
    - name: dockerconfig
      mountPath: /kaniko/.docker
    env:
    - name: HOME
      value: "/home/jenkins/agent"
  restartPolicy: Never
  volumes:
  - name: dockerconfig
    projected:
      sources:
      - secret:
          name: harbor-dockerconfig
          items:
          - key: .dockerconfigjson
            path: config.json
"""
    }
  }

  environment {
    REGISTRY   = "harbor.nginx-apim.com"
    PROJECT    = "jenkins-test"
    IMAGE_NAME = "python-custom"
  }

  stages {
    stage('Git Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build & Push') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            def dest = "${env.REGISTRY}/${env.PROJECT}/$[env.IMAGE_NAME]:latest"
            sh """
              echo "Building ${dest}"
              /kaniko/executor \
                --dockerfile=./Dockerfile \
                --context=dir://./ \
                --destination=${dest} \
                --verbosity=debug \
                --skip-tls-verify \
                --insecure \
                --cleanup
            """
          }
        }
      }
    }
  }

  post {
    always {
      script {
        def dest = "${env.REGISTRY}/${env.PROJECT}/$[env.IMAGE_NAME]:latest"
        echo "Finished build of ${dest}"
      }
    }
  }
}
