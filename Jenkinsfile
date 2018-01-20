pipeline {
    agent any

    stages {
        stage('Empaquetar') {
            steps {
                echo 'Empaquetando..'
                sh 'tar -cvf ${env.BUILD_ID}.tar.gz *'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}