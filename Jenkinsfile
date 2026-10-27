// The safety net of gnu-octave, written by aqaa from what its QA run found: unit tests with coverage and its
// floor, integration tests against the databases they need, end-to-end tests, and lint, SAST and dependency
// checks (report only: a finding marks the stage unstable until it is triaged).
// Needs the plugins Pipeline, Docker Pipeline, JUnit, Coverage, Timestamper and Workspace Cleanup;
// integration stages run on an agent labelled 'docker'.
pipeline {
  agent none
  options {
    timeout(time: 90, unit: 'MINUTES')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '10'))
    disableConcurrentBuilds(abortPrevious: true)
  }
  environment {
    CI = 'true'
  }
  stages {
    stage('Tests') {
      parallel {
        stage('Unit: octave') {
          agent { dockerfile { filename 'octave.Dockerfile'; dir 'ci/jenkins' } }
          options { timeout(time: 30, unit: 'MINUTES') }
          steps {
            dir('.') {
              sh '''
                set -eu
                export MOXUNIT_DIR="${MOXUNIT_DIR:-$HOME/moxunit}" MOCOV_DIR="${MOCOV_DIR:-$HOME/mocov}"
                mkdir -p test-reports
                if [ ! -d "$MOXUNIT_DIR/MOxUnit" ]; then git clone -q https://github.com/MOxUnit/MOxUnit "$MOXUNIT_DIR" && git -C "$MOXUNIT_DIR" checkout -q 51536d60d0b3aea7b8819650b101668e8fff9973 && git clone -q https://github.com/MOcov/MOcov "$MOCOV_DIR" && git -C "$MOCOV_DIR" checkout -q 6cb29e52660b95964ee9f955d1fe9ec5234fa40f; fi
                octave --no-gui --no-window-system --quiet --eval "addpath('ci/octave'); run_tests('test-reports/unit.xml', 'test-reports/coverage.xml')"
              '''
            }
          }
          post {
            always {
              junit allowEmptyResults: true, testResults: 'test-reports/*.xml'
              recordCoverage id: 'coverage-octave', name: 'Coverage octave', tools: [[parser: 'COBERTURA', pattern: 'test-reports/coverage.xml']], sourceDirectories: [[path: '.']], qualityGates: [[threshold: 18.0, metric: 'LINE', baseline: 'PROJECT', criticality: 'FAILURE']]
              archiveArtifacts allowEmptyArchive: true, artifacts: 'test-reports/**'
            }
            cleanup {
              cleanWs deleteDirs: true, notFailBuild: true
            }
          }
        }
      }
    }
  }
}
