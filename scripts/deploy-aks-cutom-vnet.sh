#!/bin/bash
set -x

. ./env.sh

# Uncomment if you want to create a new SPN for this deployment.
# create a SP and sets the env variable accordingly
# eval $(az ad sp create-for-rbac --skip-assignment | jq -r '"export SPN_PW=\(.password) && export SPN_CLIENT_ID=\(.appId)"')

az group create -n ${AKS_VNET_RG} -l ${AKS_VNET_LOCATION}
az group create -n ${AKS_RG} -l ${AKS_VNET_LOCATION}

#create the custom vnet where we will deploy AKS with a first subnet
az network vnet create \
--location ${AKS_VNET_LOCATION} \
-g ${AKS_VNET_RG} \
--name ${AKS_VNET_NAME} \
--address-prefixes ${AKS_VNET_RANGE} \
--subnet-name ${AKS_SUBNET1_NAME} \
--subnet-prefix ${AKS_SUBNET1_RANGE}

# add a subnet, this is the one we will deploy AKS into
az network vnet subnet create \
-g ${AKS_VNET_RG} \
--name ${AKS_SUBNET2_NAME} \
--address-prefix ${AKS_SUBNET2_RANGE} \
--vnet-name ${AKS_VNET_NAME}

# Give Contributor rights on the vnet RG to the SP we will use to create AKS 
az role assignment create \
--role=Contributor \
--scope=/subscriptions/${AKS_SUB}/resourceGroups/${AKS_VNET_RG} \
--assignee ${SPN_CLIENT_ID}

# Create a deployment from a local template, using a parameter file and 
# selectively overriding key/value pairs.
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

# We need to update the VNET with the Route Table and NSG from AKS
# First, find the resources we need : AKS RG, Route table, NSG and subnet id.     
AKS_MC_RG=$(az group list --query "[?starts_with(name, 'MC_${AKS_RG}')].name | [0]" --output tsv)
ROUTE_TABLE=$(az network route-table list -g ${AKS_MC_RG} --query "[].id | [0]" -o tsv)
AKS_NODE_SUBNET_ID=$(az network vnet subnet show -g ${AKS_VNET_RG} --name ${AKS_SUBNET2_NAME} --vnet-name ${AKS_VNET_NAME} --query id -o tsv)
AKS_NODE_NSG=$(az network nsg list -g ${AKS_MC_RG} --query "[].id | [0]" -o tsv)

# Update the Subnet
az network vnet subnet update \
-g $AKS_VNET_RG \
--route-table $ROUTE_TABLE \
--network-security-group $AKS_NODE_NSG \
--ids $AKS_NODE_SUBNET_ID