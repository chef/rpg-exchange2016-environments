def pod_label = "rpg-exchange2016-environment-${UUID.randomUUID().toString()}"
pipeline {
    agent {
        kubernetes {
            label pod_label
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: exchange2016-ci
    image: gcr.io/spaterson-project/jenkins-ruby-tf-gcloud-b3:latest
    command: ['cat']
    tty: true
    alwaysPullImage: true
"""
        }
    }
    stages {
        stage('Checking out required repos') {
            steps {
                sh 'mkdir compliance-remediation'
                dir('compliance-remediation') {
                    git([url: 'https://github.com/chef/compliance-remediation', branch: 'master', credentialsId: 'github-skp'])
                    sh 'pwd && ls -la'
                }
                sh 'mkdir cis-exchange2016-benchmark'
                dir('cis-exchange2016-benchmark') {
                    git([url: 'https://github.com/chef/cis-exchange2016-benchmark', branch: 'master', credentialsId: 'github-skp'])
                    sh 'pwd && ls -la'
                }
                sh 'mkdir rpg-exchange2016-environments'
                dir('rpg-exchange2016-environments') {
                    git([url: 'https://github.com/chef/rpg-exchange2016-environments', branch: 'master', credentialsId: 'github-skp'])
                    sh 'pwd && ls -la'
                }
            }
        }
        stage('Ruby Bundle Install') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        sh 'bundle install'
                        sh 'bundle exec inspec --version'
                    }
                }
            }
        }
        stage('Set Up Terraform') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'partner-engineering-aws-creds']]) {
                    container('exchange2016-ci') {
                        dir('rpg-exchange2016-environments') {
                            sh 'bundle exec rake rpg:setup_integration_tests'
                        }
                    }
                }
            }
        }
        stage('Run Breaking Script') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        sh 'bundle exec rake rpg:run_script'
                    }
                }
            }
        }
        stage('Run Scan Before Remediation') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        script {
                            try {
                                sh 'bundle exec rake rpg:run_scan'
                        } catch (Exception e) {
                                echo 'InSpec scan failed as not all controls passed - this is expected'
                            }
                        }
                    }
                }
            }
        }
        stage('Verify InSpec Results Before Remediation') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        script {
                            try {
                                sh 'ruby scripts/parse_results.rb -l 2016_inspec-output'
                                sh 'bundle exec rake rpg:check_results["2016_inspec-output","2016_non_remediated_inspec-output"]'
                                sh 'mv results/2016_inspec-output.txt results/2016_non_remediated_inspec_results.txt'
                                sh 'mv results/2016_inspec-output.json results/2016_non_remediated_inspec_results.json'
                        } catch (Exception e) {
                                sh 'mv results/2016_inspec-output.txt results/2016_non_remediated_inspec_results.txt'
                                sh 'mv results/2016_inspec-output.json results/2016_non_remediated_inspec_results.json'
                                sh 'bundle exec rake rpg:cleanup_integration_tests'
                                throw e
                            }
                        }
                    }
                }
            }
        }
        stage('Run Remediation') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        sh 'bundle exec rake rpg:run_remediation'
                    }
                }
            }
        }
        stage('Run Scan After Remediation') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        script {
                            try {
                                sh 'bundle exec rake rpg:run_scan >> scan_post_remediate'
                        } catch (Exception e) {
                                echo 'InSpec scan failed as not all controls passed - this is expected'
                            }
                        }
                    }
                }
            }
        }
        stage('Verify InSpec Results After Remediation') {
            steps {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        script {
                            try {
                                sh 'ruby scripts/parse_results.rb -l 2016_inspec-output'
                                sh 'bundle exec rake rpg:check_results["2016_inspec-output","2016_remediated_inspec-output"]'
                                sh 'mv results/2016_inspec-output.txt results/2016_remediated_inspec_results.txt'
                                sh 'mv results/2016_inspec-output.json results/2016_remediated_inspec_results.json'
                    } catch (Exception e) {
                                sh 'mv results/2016_inspec-output.txt results/2016_remediated_inspec_results.txt'
                                sh 'mv results/2016_inspec-output.json results/2016_remediated_inspec_results.json'
                                sh 'bundle exec rake rpg:cleanup'
                                throw e
                            }
                        }
                    }
                }
            }
        }

    }
    post {
        always {
            archiveArtifacts(artifacts: 'rpg-exchange2016-environments/results/*_results.txt,rpg-exchange2016-environments/results/*_results.json,rpg-exchange2016-environments/*_remediation_outputs.yaml,rpg-exchange2016-environments/test/integration/build/tfvars.json', allowEmptyArchive: true)
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'partner-engineering-aws-creds']]) {
                container('exchange2016-ci') {
                    dir('rpg-exchange2016-environments') {
                        //sh 'bundle exec rake rpg:cleanup_integration_tests'
                    }
                }
            }
        }
    }
    triggers {
        cron 'H 5 * * 1-5'
    }
    options {
        ansiColor('xterm')
    }
}
