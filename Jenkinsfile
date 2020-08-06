#!/usr/bin/env groovy


openshift.withCluster() { // Use "default" cluster or fallback to OpenShift cluster detection


    echo "Hello from the project running Jenkins: ${openshift.project()}"

    //Create template with maven settings.xml, so we have credentials for nexus
    podTemplate(
            inheritFrom: 'kb-jenkins-agent-perl',
            cloud: 'openshift', //cloud must be openshift
            label: 'perl-agent-with-settings.xml',
            name: 'perl-agent-with-settings.xml',
            volumes: [ //mount the settings.xml
                       secretVolume(mountPath: '/etc/m2', secretName: 'maven-settings')
            ]) {

        //Stages outside a node declaration runs on the jenkins host

        String projectName = encodeName("${JOB_NAME}")
        echo "name=${projectName}"

        try {
            //GO to a node with maven and settings.xml
            node('perl-agent-with-settings.xml') {
                //Do not use concurrent builds
                properties([disableConcurrentBuilds()])

//                def mvnCmd = "mvn -s /etc/m2/settings.xml --batch-mode"

                stage('checkout') {
                    checkout scm
                }
                
                stage('Unit test') {
                     sh "cd test && ./TestCheckTicket.pl"
                }

//                stage('Mvn clean package') {
//                    sh "${mvnCmd} -DskipTests clean package"
//                }

//                stage('Analyze build results') {            
//                    recordIssues aggregatingResults: true, 
//                        tools: [java(), 
//                                javaDoc(),
//                                mavenConsole(),
//                                taskScanner(highTags:'FIXME', normalTags:'TODO', includePattern: '**/*.java', excludePattern: 'target/**/*')]                
//                }

                stage('Create test project') {
                    recreateProject(projectName)

                    openshift.withProject(projectName) {


                        stage("Create memcached for tests") {
                            openshift.newApp("openshift/memcached")
                        }

                        stage("Create build and deploy application") { 
                            openshift.newBuild("--strategy source", "--binary", "-i kb-infra/kb-s2i-imageserver", "--name image-server")
                            openshift.startBuild("image-server", "--from-dir=.", "--follow")
                            openshift.newApp("image-server:latest")
                            openshift.create("route", "edge", "--service=image-server")
                        }

                        stage("Run integrationtests") {
                            def applicationPod = openshift.selector("pod", [deployment : "image-server" ])

                            timeout(5) { 
                                applicationPod.untilEach(1) {
                                    return (it.object().status.phase == "Running")
                                }
                            }

                            // Copy test data to image-server container
                            openshift.raw("rsync --no-perms=true test/tv-thumbnails ${applicationPod.name()}:/app/content/")
                            openshift.raw("rsync --no-perms=true test ${applicationPod.name()}:/tmp/") 
                            
                            sh 'env'
                            openshift.raw("rsh ${applicationPod.name()} /tmp/test/addTestTickets.pl")    
                        }
                    }
                }

//                stage('Push to Nexus (if Master)') {
//                    sh 'env'
//                    echo "Branch name ${env.BRANCH_NAME}"
//                    if (env.BRANCH_NAME == 'master') {
//	                sh "${mvnCmd} clean deploy -DskipTests=true"
//                    } else {
//	                echo "Branch ${env.BRANCH_NAME} is not master, so no mvn deploy"
//                    }
//                }

//                stage('Promote image') {
//                    if (env.BRANCH_NAME == 'master') {
//                        openshift.withCredentials( 'jenkins-image-promoter-secret' ) {
//                            openshift.raw("registry login")
//                            openshift.raw("image mirror default-route-openshift-image-registry.apps.ocp-devel.kb.dk/${projectName}/ticket-system-service:latest default-route-openshift-image-registry.apps.ocp-devel.kb.dk/medieplatform/ticket-system-service:latest")
//                        }
//                    } else {
//                        echo "Branch ${env.BRANCH_NAME} is not master, so no mvn deploy"
//                    }
//                }

//                stage('Cleanup') {
//                    try {
//                        echo "Cleaning up test project"
//                        openshift.selector("project/${projectName}").delete()
//                    } catch (e) {
                         
//                    }
                //}
            }
        } catch (e) {
            currentBuild.result = 'FAILURE'
            throw e
        } finally {
            configFileProvider([configFile(fileId: "notifier", variable: 'notifier')]) {  
                def notifier = load notifier             
                notifier.notifyInCaseOfFailureOrImprovement(true, "#playground")
            } 
        }
    }
}


private void recreateProject(String projectName) {
    echo "Delete the project ${projectName}, ignore errors if the project does not exist"
    try {
        openshift.selector("project/${projectName}").delete()

        openshift.selector("project/${projectName}").watch {
            echo "Waiting for the project ${projectName} to be deleted"
            return it.count() == 0
        }

    } catch (e) {

    }
//
//    //Wait for the project to be gone
//    sh "until ! oc get project ${projectName}; do date;sleep 2; done; exit 0"

    echo "Create the project ${projectName}"
    openshift.newProject(projectName)
}

/**
 * Encode the jobname as a valid openshift project name
 * @param jobName the name of the job
 * @return the jobname as a valid openshift project name
 */
private static String encodeName(groovy.lang.GString jobName) {
    def jobTokens = jobName.tokenize("/")
    def repo = jobTokens[0]
    if(repo.contains('-')) {
        repo = repo.tokenize("-").collect{it.take(1)}.join("")
    } else {
        repo = repo.take(3)
    }

    def name = ([repo] + jobTokens.drop(1)).join("-")
            .replaceAll("\\s", "-")
            .replaceAll("_", "-")
            .replace("/", '-')
            .replaceAll("^openshift-", "")
            .toLowerCase()
    return name
}

