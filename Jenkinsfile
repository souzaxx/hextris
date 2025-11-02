pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.7.0-debug
    tty: true
    command:
    - /busybox/sleep
    - infinity
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    emptyDir: {}
'''
    }
  }

  environment {
    REGISTRY_IMAGE = "souzaxx/hextris"
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    DOCKER_CFG_DIR = "/kaniko/.docker"
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Write docker config (from Jenkins creds)') {
      steps {
        container('kaniko') {
          withCredentials([usernamePassword(
            credentialsId: 'dockerhub',
            usernameVariable: 'GH_USER',
            passwordVariable: 'GH_PAT'
          )]) {
            sh '''
                set -euo pipefail
                mkdir -p "${DOCKER_CFG_DIR}"
                AUTH=$(printf "%s:%s" "$GH_USER" "$GH_PAT" | base64 | tr -d '\n')
                cat > "${DOCKER_CFG_DIR}/config.json" <<EOF
                {
                  "auths": {
                    "https://index.docker.io/v1/": { "auth": "${AUTH}" }
                  }
                }
                EOF
                ls -l "${DOCKER_CFG_DIR}/config.json"
              '''
          }
        }
      }
    }

    stage('Build & Push (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
              /kaniko/executor \
                --context "${WORKSPACE}" \
                --dockerfile "${WORKSPACE}/Dockerfile" \
                --destination "${REGISTRY_IMAGE}:${IMAGE_TAG}" \
                --force \
                --use-new-run
            '''
        }
      }
    }
  }
}
