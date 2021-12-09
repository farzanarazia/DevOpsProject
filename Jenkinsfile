try{
    node{
        def mvnHome
        def mvnCMD
        def dockerHome
        def dockerCMD
        def tagName = "bcjava1.0"
        
        
        stage('Initialize'){
            echo "The build has started.."
            emailext body: '''Build # $BUILD_NUMBER has started..''', recipientProviders: [developers()], subject: '$PROJECT_NAME - Build # $BUILD_NUMBER has started', to: 'sfarzanarazia@gmail.com'
            echo "Preparing jenkins for the required plugins/packages."
            mvnHome = tool name: 'maven3.8', type: 'maven'
            mvnCMD = "${mvnHome}/bin/mvn"
            dockerHome = tool name: 'docker1', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
            dockerCMD = "${dockerHome}/bin/docker"
        }
        
        
        stage('Checkout'){
            echo "Checking out the code from github repo.."
            git 'https://github.com/farzanarazia/devopsbootcamp10.git'
        }
        

        stage('Package'){
            echo "Testing and Building the Spring Boot application.."
            echo "packaging the Spring Boot application.."
            sh "$mvnCMD clean package"
        }
        
        
        stage('Static Code Analysis'){
            echo "Scanning the application for coverage, vulnerabilities, code smells..."
            withSonarQubeEnv('SonarQube') {
            sh "$mvnCMD sonar:sonar -Dsonar.host.url=http://35.200.201.23:9000/"
            }
        }
        
        stage('Quality gate'){
            echo "Quality gate check.. job continues with status OK"
            waitForQualityGate abortPipeline: true
        }
        
        stage('Publish Report'){
            echo " Publishing HTML report.."
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '', reportFiles: 'index.html', reportName: 'Bootcamp Report', reportTitles: ''])
        }
        
        stage('Image build'){
            echo "Building docker image for Bootcamp application .."
            sh "$dockerCMD build -t sfarzana/hubimages1:${tagName} ."
        }
        
        stage("Push Image"){
            echo "Pushing image to docker hub repository"
            withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'passdocker', usernameVariable: 'userdocker')]) {
            sh "$dockerCMD login -u ${userdocker} -p ${passdocker}"
            sh "$dockerCMD push ${userdocker}/hubimages1:${tagName}"
            }
        } 
        
        stage('Deploy'){
            echo "Reading the ansible playbook.."
            echo "Installing the required softwares.."
            echo "Bringing docker service up and running.."
            echo "Deploying the Bootcamp application in the slave node"
            ansiblePlaybook credentialsId: 'ansible-ssh', disableHostKeyChecking: true, installation: 'ansible2.9', inventory: '/etc/ansible/hosts', playbook: 'mainplaybook.yml'
        }
        
        stage('Clean up'){
            echo "Cleaning up the workspace..."
            cleanWs()
        }
    }
} 

catch(e){
    echo "An exception occured...check your job configuration, there happens to be some error.."
    (currentBuild.result= "FAILURE") {
    emailext body: '''An exception occurred...check your job configuration, there happens to be some error..
Check console output at $BUILD_URL to view the results.''', recipientProviders: [developers()], subject: '$PROJECT_NAME - Build # $BUILD_NUMBER', to: 'sfarzana@gmail.com'
throw e  
    }
}

finally {
    (currentBuild.result!= "FAILURE") && node("master") {
        echo "finally gets executed.. sending the build status via email.."
        emailext attachLog: true, body: '''Job $JOB_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS: 
$BUILD_URL has the result of the build.  
Check console output at $BUILD_URL to view the results.''', recipientProviders: [developers()], subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: 'sfarzana@gmail.com'
    }
    
}     
