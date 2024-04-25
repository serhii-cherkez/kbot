pipeline {
    agent any
    environment {
        REPO = 'https://github.com/serhii-cherkez/kbot'
        BRANCH = 'main'
    }
    
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Pick ARCH')
    }
    
    stages {
        stage('clone') {
            steps {
                echo 'CLONE REPOSITORY'
                git branch: '$BRANCH', url: '$REPO'
            }
        }
        stage('test') {
            steps {
                echo 'RUN TEST'
                sh make test
            }
        }
        stage('build') {
            steps {
                echo "BUILD FOR PLATFORM: ${params.OS} AND ARCH: ${params.ARCH}"
                sh make build
            }
        }
        stage('image') {
            steps {
                echo "MAKE IMAGE"
                sh make image
            }
        }
        stage('push') {
            steps {
                docker.withRegistry('', 'dockerhub')
                echo "PUSH IMAGE TO REPOSITORY"
                sh make push
            }
        }
    }
}