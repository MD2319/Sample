#!/bin/bash

###############################################################################################
##################################### FUNCTIONS  BEGIN ########################################
###############################################################################################

installApplication()
{
 
echo ""
echo "***********************************************************************"
echo "***********************************************************************"
echo "$applicationName application is not available in Apigee. Performing fresh installation"
echo "***********************************************************************"
echo "***********************************************************************"
echo ""

if [ ! -f "$artifactName" ]
then
    echo "******************************************************************"
    echo "Artifact $artifactName doesn't exist. Halting the deployment operation !!!!"
    echo "******************************************************************"
    exit 1
fi

createApplicationResponse=`/bin/sh -c "curl -s -o /dev/null -w '%{http_code}' -k -X POST -u $apigee_user_email:$apigee_user_password -H \
\"Content-Type: application/octet-stream\" -T $artifactName \"$apigeeBaseUrl/v1/o/$orgName/apis?action=import&name=$applicationName\""`

sleep 40
  
  
  if [ "$createApplicationResponse" -eq 201 ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application created in Apigee"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application creation failed"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

  deployApplicationResponse=`/bin/sh -c "curl -k -X POST -u $apigee_user_email:$apigee_user_password \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/revisions/1/deployments\""`

  echo "full response"
  echo "$deployApplicationResponse"

  applicationStatus=`/bin/echo $deployApplicationResponse |  jq '.state' |  sed -e 's:\"::g'`
  deployedAPIProxy=`/bin/echo $deployApplicationResponse |  jq '.aPIProxy' |  sed -e 's:\"::g'`

  if [ "$applicationStatus" = "deployed" ] && [ "$deployedAPIProxy" = "$applicationName" ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application deployment is successfull."
    echo "applicationStatus=$applicationStatus || deployedAPIProxy=$deployedAPIProxy"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application deployment did not kick start. Please review the logs"
    echo "applicationStatus=$applicationStatus || deployedAPIProxy=$deployedAPIProxy"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

}
    
updateApplication()
{
 
echo ""
echo "***********************************************************************"
echo "***********************************************************************"
echo "$applicationName application is available in Apigee. Performing Performing redeployment/update"
echo "***********************************************************************"
echo "***********************************************************************"
echo ""

if [ ! -f "$artifactName" ]
then
    echo "******************************************************************"
    echo "Artifact $artifactName doesn't exist. Halting the redeployment/update operation !!!!"
    echo "******************************************************************"
    exit 1
fi

createApplicationResponse=`/bin/sh -c "curl -s -o /dev/null -w '%{http_code}' -k -X POST -u $apigee_user_email:$apigee_user_password \
-H \"Content-Type: application/octet-stream\" -T $artifactName \"$apigeeBaseUrl/v1/o/$orgName/apis?action=import&name=$applicationName\""`

sleep 40
  
  
  if [ "$createApplicationResponse" -eq 201 ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application created in Apigee"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application creation failed"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

  revisionJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \"$apigeeBaseUrl/v1/o/$orgName/apis/$applicationName\""`

  echo "full response get revision"
  echo "$revisionJsonResponse"

  revisionToDeploy=`/bin/echo $revisionJsonResponse |  jq '.revision | last' |  sed -e 's:\"::g'`

  deployedRevisionJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/deployments\""`

  echo "full response get revision"
  echo "$deployedRevisionJsonResponse"

  deployedRevision=`/bin/echo $deployedRevisionJsonResponse |  jq '.revision[].name' |  sed -e 's:\"::g'`

  undeployApplicationResponse=`/bin/sh -c "curl -k -X DELETE -u $apigee_user_email:$apigee_user_password \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/revisions/$deployedRevision/deployments\""`

  undeployApplicationStatus=`/bin/echo $undeployApplicationResponse |  jq '.state' |  sed -e 's:\"::g'`
  undeployedAPIProxy=`/bin/echo $undeployApplicationResponse |  jq '.aPIProxy' |  sed -e 's:\"::g'`

  echo "full response get undeploy status"
  echo "$undeployApplicationResponse"

  if [ "$undeployApplicationStatus" = "undeployed" ] && [ "$undeployedAPIProxy" = "$applicationName" ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application undeployment is successfull."
    echo "applicationStatus=$undeployApplicationStatus || deployedAPIProxy=$undeployedAPIProxy"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application undeployment did not kick start. Please review the logs"
    echo "applicationStatus=$undeployApplicationStatus || deployedAPIProxy=$undeployedAPIProxy"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi


  deployApplicationResponse=`/bin/sh -c "curl -k -X POST -u $apigee_user_email:$apigee_user_password \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/revisions/$revisionToDeploy/deployments\""`

  echo "full response get deploy status"
  echo "$deployApplicationResponse"

  deployedApplicationStatus=`/bin/echo $deployApplicationResponse |  jq '.state' |  sed -e 's:\"::g'`
  deployedAPIProxy=`/bin/echo $deployApplicationResponse |  jq '.aPIProxy' |  sed -e 's:\"::g'`

  if [ "$deployedApplicationStatus" = "deployed" ] && [ "$deployedAPIProxy" = "$applicationName" ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application deployment is successfull."
    echo "applicationStatus=$deployedApplicationStatus || deployedAPIProxy=$deployedAPIProxy"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application deployment did not kick start. Please review the logs"
    echo "applicationStatus=$deployedApplicationStatus || deployedAPIProxy=$deployedAPIProxy"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

}

updateApplicationSeamless()
{
 
echo ""
echo "***********************************************************************"
echo "***********************************************************************"
echo "$applicationName application is available in Apigee. Performing Performing redeployment/update"
echo "***********************************************************************"
echo "***********************************************************************"
echo ""

if [ ! -f "$artifactName" ]
then
    echo "******************************************************************"
    echo "Artifact $artifactName doesn't exist. Halting the redeployment/update operation !!!!"
    echo "******************************************************************"
    exit 1
fi

createApplicationResponse=`/bin/sh -c "curl -s -o /dev/null -w '%{http_code}' -k -X POST -u $apigee_user_email:$apigee_user_password \
-H \"Content-Type: application/octet-stream\" -T $artifactName \"$apigeeBaseUrl/v1/o/$orgName/apis?action=import&name=$applicationName\""`

sleep 40
  
  
  if [ "$createApplicationResponse" -eq 201 ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application created in Apigee"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application creation failed"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

  revisionJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \"$apigeeBaseUrl/v1/o/$orgName/apis/$applicationName\""`

  echo "full response get revision"
  echo "$revisionJsonResponse"


  revisionToDeploy=`/bin/echo $revisionJsonResponse |  jq '.revision | last' |  sed -e 's:\"::g'`

  echo "revisionToDeploy : $revisionToDeploy"

  deployApplicationResponse=`/bin/sh -c "curl -k -X POST -u $apigee_user_email:$apigee_user_password -H \"Content-Type: application/x-www-form-urlencoded\" \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/revisions/$revisionToDeploy/deployments?override=true&delay=$1\""`

  echo "full response get deploy status"
  echo "$deployApplicationResponse"

 
  deployedAPIProxy=`/bin/echo $deployApplicationResponse |  jq '.aPIProxy' |  sed -e 's:\"::g'`

  if  [ "$deployedAPIProxy" = "$applicationName" ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application deployment is successfull."
    echo "deployedAPIProxy=$deployedAPIProxy"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application deployment did not kick start. Please review the logs"
    echo "deployedAPIProxy=$deployedAPIProxy"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

}


updateApplicationSeamlessNoRivision()
{
 
echo ""
echo "***********************************************************************"
echo "***********************************************************************"
echo "$applicationName application is available in Apigee. Performing Performing redeployment/update"
echo "***********************************************************************"
echo "***********************************************************************"
echo ""

if [ ! -f "$artifactName" ]
then
    echo "******************************************************************"
    echo "Artifact $artifactName doesn't exist. Halting the redeployment/update operation !!!!"
    echo "******************************************************************"
    exit 1
fi

  deployedRevisionJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/deployments\""`
  echo "full response get revision"
  echo "$deployedRevisionJsonResponse"

  revisionToDeploy=`/bin/echo $deployedRevisionJsonResponse |  jq '.revision[].name' |  sed -e 's:\"::g'`

  createApplicationResponse=`/bin/sh -c "curl -s -o /dev/null -w '%{http_code}' -k -X POST -u $apigee_user_email:$apigee_user_password \
  -H \"Content-Type: application/octet-stream\" -T $artifactName \
  \"$apigeeBaseUrl/v1/o/$orgName/apis/$applicationName/revisions/$revisionToDeploy?action=import&name=$applicationName\""`

sleep 40
  
  
  if [ "$createApplicationResponse" -eq 200 ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application created in Apigee"
    echo "createApplicationResponse status code : $createApplicationResponse"
  
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application creation failed"
    echo "createApplicationResponse staus code : $createApplicationResponse"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

}

promoteApplication()
{
 
echo ""
echo "***********************************************************************"
echo "***********************************************************************"
echo "$applicationName application is available in Apigee $apigeeEnv. Performing Permotion to $pormotionEnvironment"
echo "***********************************************************************"
echo "***********************************************************************"
echo ""

  deployedRevisionJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$apigeeEnv/apis/$applicationName/deployments\""`

  echo "full response get revision"
  echo "$deployedRevisionJsonResponse"

  revisionToDeploy=`/bin/echo $deployedRevisionJsonResponse |  jq '.revision[].name' |  sed -e 's:\"::g'`

  deployApplicationResponse=`/bin/sh -c "curl -k -X POST -u $apigee_user_email:$apigee_user_password -H \
  \"Content-Type: application/x-www-form-urlencoded\" \
  \"$apigeeBaseUrl/v1/o/$orgName/environments/$promoteEnv/apis/$applicationName/revisions/$revisionToDeploy/deployments?override=true&delay=$1\""`

  echo "full response get deploy status"
  echo "$deployApplicationResponse"

  #deployedApplicationStatus=`/bin/echo $deployApplicationResponse |  jq '.environment[0].state' |  sed -e 's:\"::g'`
  deployedAPIProxy=`/bin/echo $deployApplicationResponse |  jq '.aPIProxy' |  sed -e 's:\"::g'`

  if  [ "$deployedAPIProxy" = "$applicationName" ]; then
    echo ""
    echo "-----------------------------------------------------------------------"
    echo "$applicationName application deployment is successfully to higer environment"
    echo "applicationStatus= deployed || deployedAPIProxy=$deployedAPIProxy"
    echo "-----------------------------------------------------------------------"
    echo ""
  else
    echo ""
    echo "*********************************************************************"
    echo "$applicationName application deployment did not kick start. Please review the logs"
    echo "applicationStatus= not deployed || deployedAPIProxy=$deployedAPIProxy"
    echo "*********************************************************************"
    echo ""
    exit 1
  fi

}




 
###############################################################################################
##################################### FUNCTIONS  END ##########################################
###############################################################################################
  
if [ "$#" -lt 9 ]; then
    echo "************************************************************************"
    echo "Usage"
    echo "sh apigeeDeployment.sh <org_name> <environment> <app_name_apigee> <artifactName> <apigee_user_email> \
    <apigee_user_password> <override> <delay> <promotion> <promoteEnv>"
    echo "ex : ./apigeeDeployment.sh vrnvikas1994-eval prod helloworld-json-1.0 helloworld-json-1.0.zip abc@gmail.com xyz@123 true 5 true prod"
    echo "************************************************************************"
    exit 1
fi
  
###############################################################################################
######################################### VARIABLES  ##########################################
###############################################################################################
  
# GLOBAL VARIABLES
export apigeeBaseUrl="https://api.enterprise.apigee.com"
export orgName=$1
export apigeeEnv=$2
export applicationName=$3
export artifactName=$4
export apigee_user_email=$5
export apigee_user_password=$6
export override=$7
export delay=$8
export createRevsion=$9
export promotion=$10
export promoteEnv=$11
  
echo "*********************************************************************"
echo "-----------------------------------------------------------------------"
echo "Performing Apigee operations on $apigeeEnv environment"
echo "-----------------------------------------------------------------------"
echo "*********************************************************************"
echo ""
  
echo "curl -k -X GET -u $apigee_user_email:$apigee_user_password '$apigeeBaseUrl/v1/o/$orgName/environments'"

fetchEnvironmentJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \
 '$apigeeBaseUrl/v1/o/$orgName/environments'"`
  
echo "-----------------------------------------------------------------------"
echo "Below is the fetchEnvironmentJsonResponse"
echo "-----------------------------------------------------------------------"
echo "$fetchEnvironmentJsonResponse"
echo ""
   
if [ -z "$fetchEnvironmentJsonResponse" ]; then
   echo "*********************************************************************"
   echo "Incorrect Apigee Access credentials specified or Incorrect parameters. Please validate."
   echo "*********************************************************************"
   echo ""
   exit 1
else
   response=`/bin/echo $fetchEnvironmentJsonResponse |  jq "contains([\"$apigeeEnv\"])" |  sed -e 's:\"::g'`
fi


echo "-----------------------------------------------------------------------"
echo "Environment Check Response : $response"
echo "-----------------------------------------------------------------------"
echo ""


if [ "$response" = "true" ]; then
  echo "Environment Check Done"
else
  echo "Environment Check Failed"
  exit 1
fi


fetchApplicationStatusJsonResponse=`/bin/sh -c "curl -k -X GET -u $apigee_user_email:$apigee_user_password \
 '$apigeeBaseUrl/v1/o/$orgName/apis'"`

if [ -z "$fetchApplicationStatusJsonResponse" ]; then
   echo "*********************************************************************"
   echo "Incorrect Apigee Access credentials specified or Incorrect parameters. Please validate."
   echo "*********************************************************************"
   echo ""
   exit 1
else
   responseApp=`/bin/echo $fetchApplicationStatusJsonResponse |  jq "contains([\"$applicationName\"])" |  sed -e 's:\"::g'`
fi

echo "-----------------------------------------------------------------------"
echo "Application Check Response : $responseApp"
echo "-----------------------------------------------------------------------"
echo ""

if [ "$responseApp" = "true" ] && [ "$createRevsion" = "true" ] && [ "$promotion" = "false" ]; then
  echo "updateApplicationSeamless called"
  updateApplicationSeamless "$delay"
  rm -f $artifactName
  exit 0
elif [ "$responseApp" = "true" ] && [ "$createRevsion" = "false" ] && [ "$promotion" = "false" ]; then
  echo "updateApplicationSeamlessNoRivision called"
  updateApplicationSeamlessNoRivision "$delay"
  rm -f $artifactName
  exit 0
elif [ "$responseApp" = "true" ] && [ "$createRevsion" = "false" ] && [ "$promotion" = "true" ]; then
  echo "promoteApplication called"
  promoteApplication "$delay"
  rm -f $artifactName
  exit 0
else
  echo "installApplication called"
  installApplication
  rm -f $artifactName
  exit 0
fi