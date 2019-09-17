#!/usr/bin/env groovy

pipeline {
    agent {
        label 'docker'
    }
    environment {
            _DEPLOY_TO = "DEV-INT"
            _OCTOPUS_SERVER = "https://octopus.ema.emoneyadvisor.com"
            _OCTOPUS_PROJECT = "ApigeeDevPortal8"
            _PACKAGE_NAME = "ApigeeDevPortal8"
            _SEM_VERSION = "0.0.0"
            _ARTIFACTS_DIR = "_artifacts"
    }
    options { timeout(time: 2, unit: 'HOURS') }
    parameters {
        booleanParam(name: '_IS_PUBLISH', defaultValue: false, description: "Publish package")
        booleanParam(name: '_IS_DEPLOY', defaultValue: false, description: "Deploy to DEV")
    }
    stages {
        stage ('Set Environment Variables') {
            steps {
                setEnvironmentVariables()
                dumpEnvironmentVariables()
            }
        }
            stage ('Build1') {
                    agent {
                // node {
        //     //label 'composer-4_10_0 && php-7_3_9'
                //     label 'docker'
            
                //     //customWorkspace "workspace\\apigee-devportal-${env.BRANCH_NAME.replaceAll(~/[\^<>:"\/\\|?*]/, "-").take(20)}"
                // }
                dockerfile{
                    filename 'dockerfile'
                }
            }
            steps {
                    echo "Building project from ${env.BRANCH_NAME}"
                    echo "Create package ${env._PACKAGE_NAME}.${env._SEM_VERSION}.${env.BUILD_NUMBER}-${env.BRANCH_NAME}"

                    //bat "mkdir ${env._ARTIFACTS_DIR}"
                    //  - see ticket for further instructions amdp-13
                    echo "cd to root of source code"
                    // composer install (run) - if no composer we need to install it
                    dir("${WORKSPACE}"){
                    sh "composer install -v"
                        }

                }
            }
            stage ('Build2') {
                agent {
                    docker {
                        image 'node'
                    }
                }
                steps {
                    dir("${WORKSPACE}//web//themes//custom//emoney_apigee_kickstart") {
                        sh "mkdir ./npm"
                        sh "chown -R 1000:1000 ${WORKSPACE}"
                        sh "sudo npm install"
                        sh "npm run css"
                        }
                    //bat "xcopy drush.zip _artifacts" //-- we need to create this I suppose
                    //bat "xcopy Deploy.sh _artifacts" //-- need to test this as well
                    // bat "xcopy Rollback.sh _artifacts" - this not ready yet

                    dir("${WORKSPACE}//web//themes//custom//emoney_apigee_kickstart//node_modules") {deleteDir()}
                    dir("${WORKSPACE}//.git") {deleteDir()}

                    zip zipFile: "${env._PACKAGE_NAME}.${PACKAGE_VERSION}.zip", dir: "${WORKSPACE}"
                }
            }
        stage('Publish') {
            when {
                anyOf { 
                    expression { 
                        return params._IS_PUBLISH 
                        }; 
                    expression { 
                        return params._IS_DEPLOY 
                        }
                    branch 'develop'
                }
            }
            steps {
                dir("/usr/bin"){
                    echo "===== Publish package to repository"
                        withCredentials([string(credentialsId: 'octopus-api-key', variable: 'OctopusApiKey')]) {
                            sh "octo push --package ${env._PACKAGE_NAME}.${PACKAGE_VERSION}.zip  --server ${env._OCTOPUS_SERVER} --apiKey ${OctopusApiKey}"
                        }
                }
            }
        }
        
        stage('Deploy') {
            when {
                anyOf {
                    branch 'develop'
                    expression { return params._IS_DEPLOY }
                }
            }
            steps {
                dir("/usr/bin"){
                    echo "Deploying to ${env._DEPLOY_TO}"
                    withCredentials([string(credentialsId: 'octopus-api-key', variable: 'OctoApiKey')]) {
                        sh "octo create-release --project \"${env._OCTOPUS_PROJECT}\" --version ${PACKAGE_VERSION} --package \"Deploy Devportal\":${PACKAGE_VERSION} --server ${env._OCTOPUS_SERVER} --apiKey ${env.OctoApiKey}"
                        sh "octo deploy-release --project \"${env._OCTOPUS_PROJECT}\" --version ${PACKAGE_VERSION} --deployto \"${env._DEPLOY_TO}\" --channel Default --server ${env._OCTOPUS_SERVER} --apiKey ${env.OctoApiKey} --deploymenttimeout 00:10:00 --waitfordeployment --variable=UploadContent:false"
                    }
                }
            }
        }
    }

    post {
		always {
			script {
				echo 'Post build'
			}
		}
		success {
			script {
				echo 'Success'
			}
		}
		aborted {
			script {
				echo 'Aborted'
			}
		}
		failure {
			script {
				echo 'Failure'
			}
		}
		cleanup {
		 	cleanWorkspace()
        }
	}
}

def isMasterBranch() {
    return params.BranchName == 'master'
}

def isDevelopBranch() {
    return params.BranchName == 'develop'
}

def getPackageLabel() {
    if (isMasterBranch()) {
        return ""
    }
    return "-${env.BRANCH_NAME.replaceAll(~/[^0-9A-Za-z-]/, '-')}"
}

def getPackageVersion() {
    return "${env._SEM_VERSION}.${env.BUILD_NUMBER}${getPackageLabel()}"
}

def setEnvironmentVariables() {
    env.PACKAGE_VERSION = getPackageVersion()
}

def cleanWorkspace() {
    // only support long running working copies on master and develop so we don't run out of disk space
    if (isMasterBranch() || isDevelopBranch()) {
        return
    }

    try {
        cleanWs()
    }
    catch (e) {
        // if the git clean or checkout fails eat the exception trying to clean the WS as a node is not assigned yet
    }
}

def dumpEnvironmentVariables() {
    echo '============================ Environment Variables ============================='
    sh 'set > env'
    for (def variable : readFile('env').split('\r?\n')) {
        echo variable
    }
    echo '========================== End Environment Variables ==========================='
}
