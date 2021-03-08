pipeline {
    agent any
    stages { 
        stage('SCM') {
            steps{
                git credentialsId: 'github', url: 'https://github.com/rzerr/PyKMIP'
            }
         }
         stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'SonarQubeScanner'
            }
            steps{
                withSonarQubeEnv('SonarQubeServer') {
                    sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=PyKMIP"
                }
            }
         }
        stage('Quality Gate') {
            steps{
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                     error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }
	    stage('Build Docker image') {
            steps {
                sh 'sudo docker pull ubuntu:latest'
                sh 'sudo docker build -t image-$BUILD_NUMBER .'
            }
        }
        stage('Run container from image') {
		environment {
			MASTER_KEY = credentials('MASTER_KEY')
			HOST_KEY = credentials('HOST_KEY')
		}
            	steps {
                	sh 'sudo podman run -d -p 80:5696 -p 443:5696 -v /mnt:/tmp:Z --name container-$BUILD_NUMBER -e MASTER_KEY=$MASTER_KEY -e HOST_KEY=$HOST_KEY localhost/image-$BUILD_NUMBER'
            }
        }
    }
}

