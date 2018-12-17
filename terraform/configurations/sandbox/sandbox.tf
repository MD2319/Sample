# this determines the name of sgs, the chef node names, and the s3 key that remote state is stored.
environment="dev1"
//KUBERNETES_CLUSTER="dev1"
//hostname="cif.cluster.k8s.local"


appname="Sample"
appversion="0.1"
project="apigee"
region="us-west-2"
proxies_names = ["Printers-Preview","RFIDreadEvents"]

# The Following Will be used to set backend.tf
s3_bucket         = "devops-docker-cif-dev-env-bucket"
s3_folder_project = "devops"
s3_folder_region  = "us-west-2"
s3_folder_type    = "dev"
s3_tfstate_file   = "sample-hello-world-apigee-proxy.tfstate"

artifactory_server_url="ec2-54-201-29-152.us-west-2.compute.amazonaws.com:8081"
podrole = "arn:aws:iam::124864831979:role"
deploy_role_arn = "arn:aws:iam::124864831979:role/DevSecOpsAdminRolePolicy"


# Application Properties for Apigge Deployment
apigee_user_email="tim.pitta@zebra.com"
apigee_user_password="c^pG3mini"
org_name="zebra-prod"
apigee_env="mock"
override="true"
delay="5"
promotion="true"
promotionEnvironment="sandbox"
createRevsion="false"



tags {

  region              = "US-WEST"
  app_brev            = "DEV1"
  data_classification = "Non Sensitive"
  version             = "1.x"
  env_desc            = "Sample Mule Container"
  static              = "false"
}