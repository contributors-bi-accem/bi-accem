pipeline {
    agent any
    environment {
        PACKAGE_NAME = "package_${BUILD_ID}.tar.gz"
    }
    stages {
        stage('Empaquetar') {
            steps {
                echo "Empaquetando.. ${env.PACKAGE_NAME}"
                sh "tar -cvf ${env.PACKAGE_NAME} *"
            }
        }
        stage('Deploy') {
            environment {
                DIR = '/downloads/accem/dist/'
            }
            steps {
                echo "Sending package to ${env.DIR}"
                sh "scp -BCp -P 979 ${env.PACKAGE_NAME} fabien@petitbilly:${env.DIR}"
                echo ""
                sh 'ssh -l fabien -p 979 petitbilly "tar -xzvf ${env.DIR}${env.PACKAGE_NAME}"'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'

            }
        }
        stage('HouseKeeping') {
            steps {
                echo 'Tidying up....'
                cleanWs()
            }
        }
    }
}