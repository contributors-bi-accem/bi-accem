pipeline {
    agent any

    stages {
        stage('Empaquetar') {
            steps {
                script {
                    env.RELEASE_DEPLOY= input message: 'User input required', ok: 'Deploy!',
                            parameters: [choice(name: 'RELEASE_DEPLOY', choices: 'Yes\nNo', description: 'Deploy?')]
                }
                echo "${env.RELEASE_DEPLOY}"
                echo 'Empaquetando..'
                PACKAGE_NAME = '$JOB_NAME_$BUILD_ID.tar.gz'
                sh 'tar -cvf $PACKAGE_NAME *'
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