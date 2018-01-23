pipeline {
    agent any
    environment {
        PACKAGE_NAME = "package_${BUILD_ID}.tar.gz"
        BASE_DIR = '/downloads/accem/'
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
                
            }
            steps {
                echo "Sending package to ${env.BASE_DIR}dist/"
                sh "scp -BCp -P 979 ${env.PACKAGE_NAME} fabien@petitbilly:${env.BASE_DIR}dist/ && rm ${env.PACKAGE_NAME}"
                echo "Uncompress ${env.BASE_DIR}dist/${env.PACKAGE_NAME}"
                sh "ssh -l fabien -p 979 petitbilly \"tar -xzvf ${env.BASE_DIR}dist/${env.PACKAGE_NAME} -C ${env.BASE_DIR}dist/ && rm ${env.BASE_DIR}dist/${env.PACKAGE_NAME}\""
            }
        }
        stage('Test unload') {
            steps {
                echo 'Unload 31-01-2017'
                sh "ssh -l fabien -p 979 petitbilly \"rm ${env.BASE_DIR}unload_gorrion_*.tar.gz && ${env.BASE_DIR}dist/unload/scr/unload.sh '2017-01-31 00:00:00' '2017-01-31 23:59:59' \""
            }
        }
        stage('Test sync') {
            steps {
                echo 'Sync 31-01-2017'
                sh "ssh -l fabien -p 979 petitbilly \"${env.BASE_DIR}dist/sync/scr/main.sh '2017-01-31 00:00:00' '2017-01-31 23:59:59' \""
            }
        }
        stage('Test loader') {
            steps {
                echo 'Load 31-01-2017'
                sh "ssh -l fabien -p 979 petitbilly \"${env.BASE_DIR}dist/loader/scr/loader.sh \""
                echo 'Staging...'
                sh "ssh -l fabien -p 979 petitbilly \"${env.BASE_DIR}dist/loader/scr/execute-sql.sh ${env.BASE_DIR}dist/loader/sql/staging.sql\""
                echo 'Transform...'
                sh "ssh -l fabien -p 979 petitbilly \"${env.BASE_DIR}dist/loader/scr/execute-sql.sh ${env.BASE_DIR}dist/loader/sql/transform.sql\""
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