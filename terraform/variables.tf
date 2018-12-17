variable "s3_bucket" {}
variable "s3_folder_project" {}
variable "s3_folder_region" {}
variable "s3_folder_type" {}
variable "s3_tfstate_file" {}

variable "environment" {
 description = "The environment name, this will be appended to various environment specific variables/tags"
}

# Spit out by jenkins environment variables
variable "buildnames" {
 default = ""
}

variable "region" {
 description = "The region where the application is deployed"
}


variable "jobname" {
	description = "artifact name"
}

variable "artifact_type" {
	description = "artifact type"
}

variable "artifactory_server_url" {
  description = "Artifact server url"
}

variable "gitshortcode" {
	description = "artifact version"
}

variable "appversion" {
	description = "app version"
}

variable "appname" {
	description = "app name"
}

variable "apigee_user_email" {
	description = "apigee user id"
}

variable "apigee_user_password" {
	description = "apige user pass"
}

variable "org_name" {
	description = "apigee organization name"
}

variable "apigee_env" {
	description = "apigee organization env"
}

variable "override" {
	description = "Seamless deployment (zero downtime)"
}

variable "delay" {
	description = "pecifies a time interval, in seconds, before which the previous revision should be undeployed."
}

variable "promotion" {
	description = "no new deployment just promotion"
}

variable "promotionEnvironment" {
	description = "Environment to promote"
}

variable "createRevsion" {
	description = "Create Revision or not"
}

variable "proxies_names" {
	type = "list"
	description = "list of proxies to deploy"
}