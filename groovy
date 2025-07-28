pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jaiswaladi246/Petclinic.git'
            }
        }
        stage('Code Compile') {
            steps {
                sh "mvn clean compile"
            }
        }
        stage('Unit Test') {
            steps {
                sh "mvn test"
            }
        }
        stage('Sonar Analysis') {
            steps {
            withSonarQubeEnv('sonarqube-server') {
                sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petclinic \
                -Dsonar.java.binaries=. \
                -Dsonar.projectKey=Petclinic '''
    
               }
            }
        }
    }
}
