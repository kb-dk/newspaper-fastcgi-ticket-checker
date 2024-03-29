#!/usr/bin/env groovy


openshift.withCluster() { // Use "default" cluster or fallback to OpenShift cluster detection


    echo "Hello from the project running Jenkins: ${openshift.project()}"

    //Create template with maven settings.xml, so we have credentials for nexus
    podTemplate(
            inheritFrom: 'kb-jenkins-agent-perl',
            cloud: 'openshift', //cloud must be openshift
            envVars: [ //This fixes the error with en_US.utf8 not being found
                    envVar(key:"LC_ALL", value:"C.utf8")
            ],
            volumes: [ //mount the settings.xml
                       secretVolume(mountPath: '/etc/m2', secretName: 'maven-settings')
            ]) {

        //Stages outside a node declaration runs on the jenkins host

        String projectName = encodeName("${JOB_NAME}")
        echo "name=${projectName}"

        try {
            node(POD_LABEL) {
                //Do not use concurrent builds
                properties([disableConcurrentBuilds()])

                stage('checkout') {
                    checkout scm
                }
                
                stage('Unit test') {
                     sh "cd test && ./TestCheckTicket.pl"
                }

                stage('Create test project') {
                    recreateProject(projectName)

                    openshift.withProject(projectName) {


                        stage("Create memcached for tests") {
                            openshift.newApp("openshift/memcached")
                        }

                        stage("Create build and deploy application") { 
                            openshift.newBuild("--strategy source", "--binary", "-i kb-infra/kb-s2i-imageserver", "--name image-server")
                            openshift.startBuild("image-server", "--from-dir=.", "--follow")
                            openshift.newApp("image-server", "-e BUILD_NUMBER=latest")
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

                            def memcachedPod = openshift.selector("pod", [deployment : "memcached" ])
                            def memcachedIP =  memcachedPod.object().status.podIP
                            echo "memcached IP: ${memcachedIP}"

                            openshift.raw("rsh ${applicationPod.name()} /tmp/test/addTestTickets.pl ${memcachedIP}")

                            // Copy test files to memcached host, use that for running test
                            openshift.raw("rsync --no-perms=true test ${memcachedPod.name()}:/tmp/")
                            def testRun = openshift.raw("rsh ${memcachedPod.name()} /tmp/test/SimpleIntegrationtest.sh ${projectName}")

                            echo "${testRun.out}"


                        }
                    }
                }


                stage('Promote image') {
                    if (env.BRANCH_NAME == 'master') {
                        configFileProvider([configFile(fileId: "imagePromoter", variable: 'promoter')]) {
                            def promoter = load promoter
                            promoter.promoteImage("image-server", "${projectName}",  "medieplatform", "latest")
                        }
                    } else {
                        echo "Branch ${env.BRANCH_NAME} is not master, so no mvn deploy"
                    }
                }

                stage('Cleanup') {
                    try {
                        echo "Cleaning up test project"
                        openshift.selector("project/${projectName}").delete()
                    } catch (e) {
                         
                    }
                }
            }
        } catch (e) {
            currentBuild.result = 'FAILURE'
            throw e
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
    def org = jobTokens[0]
    if(org.contains('-')) {
        org = org.tokenize("-").collect{it.take(1)}.join("")
    } else {
        org = org.take(3)
    }

    // Repository have a very long name, lets shorten it further
    def repo = jobTokens[1]
    if(repo.contains('-')) {
        repo = repo.tokenize("-").collect{it.take(1)}.join("")
    } else {
        repo = repo.take(3)
    }


    def name = ([org, repo] + jobTokens.drop(2)).join("-")
            .replaceAll("\\s", "-")
            .replaceAll("_", "-")
            .replace("/", '-')
            .replaceAll("^openshift-", "")
            .toLowerCase()
    return name
}

