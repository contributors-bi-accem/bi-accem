pipeline {
    agent any
    environment {
        PACKAGE_NAME = "package_${BUILD_ID}.tar.gz"
    }
    stages {
        stage('Empaquetar') {
            steps {
                echo "Empaquetando.. ${env.PACKAGE_NAME}"
                sh "tar -czvf ${env.PACKAGE_NAME} *"
            }
        }
        stage('Deploy') {
            environment {
                DIR = '/downloads/accem/dist/'
            }
            steps {
                echo "Sending package to ${env.DIR}"
                sh "scp -BCp -P 979 ${env.PACKAGE_NAME} fabien@petitbilly:${env.DIR} && rm ${env.PACKAGE_NAME}"
                echo "Uncompress ${env.DIR}${env.PACKAGE_NAME}"
                sh "ssh -l fabien -p 979 petitbilly \"tar -xzvf ${env.DIR}${env.PACKAGE_NAME} -C ${env.DIR} && rm ${env.DIR}${env.PACKAGE_NAME}\""
            }
        }
        stage('Test') {
            steps {
                echo 'Unload 31-01-2017'
                sh "ssh -l fabien -p 979 petitbilly \"/downloads/accem/dist/unload/scr/unload.sh '2017-01-31 00:00:00' '2017-01-31 23:59:59' \""

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