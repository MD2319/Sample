resource "null_resource" "deploy-to-apigee" {

 triggers {
   key = "${uuid()}"
 }

 count = "${length(var.proxies_names)}"

 provisioner "local-exec" {
 command = "sh apigeeDeployment.sh ${var.org_name} ${var.apigee_env} ${var.appname}-${element(var.proxies_names, count.index)} ${var.appname}-${element(var.proxies_names, count.index)}.zip ${var.apigee_user_email} ${var.apigee_user_password} ${var.override} ${var.delay} ${var.createRevsion} ${var.promotion} ${var.promotionEnvironment}"

 }

}