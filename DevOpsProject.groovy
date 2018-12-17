#!/usr/bin/env groovy


// *****************************************
//   BUILD Callbacks
// *****************************************

//add custom build steps for a project to execute pre docker build
def beforeBuild(properties) {
    echo "Before Build"
}

//add custom build steps for a project to execute after post docker build
def afterBuild(properties) {
    echo "After Build"
}

//add custom build steps for a project to execute before test exection
def beforeTest(properties) {
    echo "Before Test"
}

//add custom build steps for a project to execute after test exection
def afterTest(properties) {
    echo "After Test"
}

//add custom build steps for a project to execute before docker/lambda push
def beforePush(properties) {
    echo "Before Push"
}

//add custom build steps for a project to execute after docker/lambda push
def afterPush(properties) {
    echo "After Push"
}


return this
