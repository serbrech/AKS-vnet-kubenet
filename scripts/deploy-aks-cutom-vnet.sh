#!/bin/bash

. ./env.sh

#Uncomment if you want to create a new SPN for this deployment.
#create a SP and sets the env variable accordingly
#eval $(az ad sp create-for-rbac --skip-assignment | jq -r '"export SPN_PW=\(.password) && export SPN_CLIENT_ID=\(.appId)"')

az group create -n ${AKS_VNET_RG} -l ${AKS_VNET_LOCATION}
az group create -n ${AKS_RG} -l ${AKS_VNET_LOCATION}

az network vnet create \
--location ${AKS_VNET_LOCATION} \
-g ${AKS_VNET_RG} \
--name ${AKS_VNET_NAME} \
--address-prefixes ${AKS_VNET_RANGE} \
--subnet-name ${AKS_SUBNET1_NAME} \
--subnet-prefix ${AKS_SUBNET1_RANGE}

az network vnet subnet create \
-g ${AKS_VNET_RG} \
--name ${AKS_SUBNET2_NAME} \
--address-prefix ${AKS_SUBNET2_RANGE} \
--vnet-name ${AKS_VNET_NAME}

az role assignment create \
--role=Contributor \
--scope=/subscriptions/${AKS_SUB}/resourceGroups/${AKS_VNET_RG} \
--assignee ${SPN_CLIENT_ID}

# Create a deployment from a local template, using a parameter file and selectively overriding key/value pairs.

az group deployment create -g ${AKS_RG} \
--template-file aks-vnet-all.json \
--parameters @aks-vnet-all-parameters.json \
--parameters \
    resourceName=${AKS_NAME} \
    location=${AKS_VNET_LOCATION} \
    networkPlugin=kubenet \
    vnetSubnetID="/subscriptions/${AKS_SUB}/resourceGroups/${AKS_VNET_RG}/providers/Microsoft.Network/virtualNetworks/${AKS_VNET_NAME}/subnets/${AKS_SUBNET2_NAME}" \
    servicePrincipalClientId=${SPN_CLIENT_ID} \
    servicePrincipalClientSecret=${SPN_PW} \
    serviceCidr=${AKS_SVC_CIDR} \
    dnsServiceIP=${AKS_DNS_IP} \
    workspaceRegion=${OMS_LOCATION} \
    workspaceName=${OMS_WORKSPACE_NAME} \
    omsWorkspaceId=${OMS_WORKSPACE_ID} \
     
AKS_MC_RG=$(az group list --query "[?starts_with(name, 'MC_${AKS_RG}')].name | [0]" --output tsv)
ROUTE_TABLE=$(az network route-table list -g ${AKS_MC_RG} --query "[].id | [0]" -o tsv)
AKS_NODE_SUBNET_ID=$(az network vnet subnet show -g ${AKS_VNET_RG} --name ${AKS_SUBNET2_NAME} --vnet-name ${AKS_VNET_NAME} --query id -o tsv)

az network vnet subnet update \
-g $AKS_VNET_RG \
--route-table $ROUTE_TABLE \
--ids $AKS_NODE_SUBNET_ID