# Starting with

You will need two Service Principals, one for running all workflows and one for running the AKS Cluster with Role Based Access Control RBAC. These two can be the same.

step 1:
 az ad sp create-for-rbac -n "GitHubdeploySP" --sdk-auth --role contributor

 - This will create a SP with Contributor access to the default/active subscription - this way it has access to great a new Resource Group as needed for the Setup_Infrastructure to run. Alternativelly you could create first a Resource Group and then an SP with access rights only to that Resource Group -> In this case make sure you set RESOURSE_GROUP_NAME on Setup_Infrastructure env variable to the name of the Resource Group you created.

 Create the following SECRETS on GitHub:

 1. AZURE_CREDENTIALS: the result from step 1, entire JSON
 2. AKS_SERVICE_PRINCIPAL_ID: ClientId value from step 1
 3. AKS_SERVICE_PRINCIPAL_SECRET: clientSecret value from step 1

# SECRETS NEEDED
## PaaS

1. Four publishing profiles for Api gateway, Alerts microservice, Devices microservice, Back office microservice
    a. PAAS_PUBLISH_PROFILE_APIGW
    b. PAAS_PUBLISH_PROFILE_ALERTS
    c. PAAS_PUBLISH_PROFILE_DEVICES
    d. PAAS_PUBLISH_PROFILE_BACK_OFFICE