#---------------------------------------- Config Part -----------------------------------------------------------#
# Resource Group and Azure Region variables
$resourceGroupName = 'ntestiacpaas' # $env:env_pipeline_variable_rg_name
$azureRegion = 'westeurope' # $env:env_pipeline_variable_location''
Write-Host "(Got from ENV): RG: " $resourceGroupName " location: "  $azureRegion 
Write-Host "Environment Azure CL: " az --version

# Azure Container Registry variables
$acrName = $resourceGroupName + 'acr'

# Application Insights Instances variables
$apiGwAiName = 'aks-apigwai'
$alertsAiName = 'aks-alertsai'
$devicesAiName = 'aks-devicesai'
$backofficeAiName = 'aks-backofficeai'

# AKS variables
$SUBNET_NAME= $resourceGroupName +'aks-subnet'
$VNET_NAME= $resourceGroupName + 'aks-vnet'
$AKS_CLUSTER_NAME=$resourceGroupName +'-aks'

# Monitor
$WORKSPACE=$resourceGroupName +'-LogsWorkspace'

#---------------------------------------- Execution Part -----------------------------------------------------------#

# Create Application Insights for Web Apps and Functions
az extension add --name application-insights

# Create Application Insights for each Microservice
Write-Host 'About to create AI for apiwgw: ' $apiGwAiName -ForegroundColor Green
az monitor app-insights component create -a $apiGwAiName -l $azureRegion -g $resourceGroupName
$apiGwAiKey = az monitor app-insights component show --app $apiGwAiName -g $resourceGroupName --query 'instrumentationKey'
Write-Host 'Got app insights key for Api GW: ' $apiGwAiKey -ForegroundColor Yellow

Write-Host 'About to create AI for alerts: ' $alertsAiName -ForegroundColor Green
az monitor app-insights component create -a $alertsAiName -l $azureRegion -g $resourceGroupName
$alertsAiKey = az monitor app-insights component show --app $alertsAiName -g $resourceGroupName --query 'instrumentationKey'
Write-Host 'Got app insights key for Api GW: ' $alertsAiKey -ForegroundColor Yellow

# Create Application Insights for Azure Functions
Write-Host 'About to create AI for devices: ' $devicesAiName -ForegroundColor Green
az monitor app-insights component create -a $devicesAiName -l $azureRegion -g $resourceGroupName
$devicesAiKey = az monitor app-insights component show --app $devicesAiName -g $resourceGroupName --query 'instrumentationKey'
Write-Host 'Got app insights key for Devices: ' $devicesAiKey -ForegroundColor Yellow

Write-Host 'About to create AI for back office: ' $functionBackOfficeAiName -ForegroundColor Green
az monitor app-insights component create -a $backofficeAiName -l $azureRegion -g $resourceGroupName
$backofficeAiKey = az monitor app-insights component show --app $backofficeAiName -g $resourceGroupName --query 'instrumentationKey'
Write-Host 'Got app insights key for Back Office: ' $backofficeAiKey -ForegroundColor Yellow

# AKS Part

# Create Vnet
Write-Host 'About to create Vnet: ' $VNET_NAME -ForegroundColor Green
az network vnet create --resource-group $resourceGroupName --location $azureRegion --name $VNET_NAME --address-prefixes 10.0.0.0/8 --subnet-name $SUBNET_NAME --subnet-prefixes 10.240.0.0/16

# Get Subnet Id
$SUBNET_ID=$(az network vnet subnet show --resource-group $resourceGroupName --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)

# Get AKS version
$VERSION=$(az aks get-versions --location $azureRegion --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' --output tsv)

# Create AKS Cluster
Write-Host 'About to create AKS Cluster: ' $AKS_CLUSTER_NAME -ForegroundColor Green
az aks create --resource-group $resourceGroupName --name $AKS_CLUSTER_NAME --vm-set-type VirtualMachineScaleSets --node-count 2 --load-balancer-sku standard --location $azureRegion --kubernetes-version $VERSION --network-plugin azure --vnet-subnet-id $SUBNET_ID --service-cidr 10.2.0.0/24 --dns-service-ip 10.2.0.10 --docker-bridge-address 172.17.0.1/16 --generate-ssh-keys

# Attach Azure Container Registry
az aks update --name $AKS_CLUSTER_NAME --resource-group $resourceGroupName --attach-acr $acrName

az resource create --resource-type Microsoft.OperationalInsights/workspaces --name $WORKSPACE --resource-group $resourceGroupName --location $azureRegion --properties '{}' -o table

$WORKSPACE_ID=$(az resource show --resource-type Microsoft.OperationalInsights/workspaces --resource-group webinar_oct20_rg --name $WORKSPACE --query "id" -o tsv)

az aks enable-addons --resource-group $resourceGroupName --name $AKS_CLUSTER_NAME --addons monitoring --workspace-resource-id $WORKSPACE_ID