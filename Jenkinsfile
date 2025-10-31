pipeline {
  agent {
    kubernetes {
      defaultContainer 'kaniko'
      yaml """
apiVersion: v1
kind: Pod
spec:
  restartPolicy: Never
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      args: ["sleep", "infinity"]
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
  volumes:
    - name: docker-config
      emptyDir: {}
"""
    }
  }

  environment {
    // Change these:
    REGISTRY_IMAGE = "ghcr.io/souzaxx/hextris"   // e.g., ghcr.io/desertcart/sample-app
    IMAGE_TAG = "${env.BUILD_NUMBER}"       // keep it simple
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Push (Kaniko → GHCR)') {
      steps {
        container('kaniko') {
          withCredentials([usernamePassword(
            credentialsId: 'ghcr',
            usernameVariable: 'GH_USER',
            passwordVariable: 'GH_PAT'
          )]) {
            sh '''
              set -eu
              mkdir -p /kaniko/.docker

              # Create minimal Docker auth for GHCR
              AUTH=$(printf "%s:%s" "$GH_USER" "$GH_PAT" | base64 | tr -d '\\n')
              cat > /kaniko/.docker/config.json <<EOF
              {
                "auths": {
                  "ghcr.io": { "auth": "${AUTH}" }
                }
              }
              EOF

              /kaniko/executor \
                --context "${WORKSPACE}" \
                --dockerfile "${WORKSPACE}/Dockerfile" \
                --destination "${REGISTRY_IMAGE}:${IMAGE_TAG}" \
                --use-new-run
            '''
          }
        }
      }
    }
  }
}
