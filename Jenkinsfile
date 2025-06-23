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
          name: dockerhubconfig
          items:
          - key: .dockerconfigjson
            path: config.json
"""
    }
  }

  environment {
    REGISTRY   = "docker.io"
    PROJECT    = "asdfkco/jenkinstest"
  }

  stages {
    stage('Git Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Build & Push') {
      when {
        beforeAgent true            // 에이전트 띄우기 전에 조건 확인
        not {                       // <─ 변경 집합이 ↓ 패턴에 *전부* 매치되면 false → stage skip
          changeset pattern: '^(\\.gitignore$|Jenkinsfile$|LICENSE$|README\\.md$|manifest/.*)',
                    comparator: 'REGEXP'
        }

      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            def dest = "${env.REGISTRY}/${env.PROJECT}:latest"
            sh """
              echo "Building ${dest}"
              /kaniko/executor \
                --dockerfile=./Dockerfile \
                --context=dir://./ \
                --destination=${dest} \
                --verbosity=debug \
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
            def dest = "${env.REGISTRY}/${env.PROJECT}:latest"
        echo "Finished build of ${dest}"
      }
    }
  }
}
