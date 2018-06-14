#!/bin/bash

export AKS_LOCATION=eastus

##### EDIT THESE ######
#
# If you don't have a SPN, uncomment the line that creates it in the setup-aks-vnet.sh script
#
# export SPN_PW=<YOUR_SPN_PW> # a service principal Service Principal
# export SPN_CLIENT_ID=<YOUR_SPN_CLIENT_ID>

# export AKS_SUB=<YOUR_AZURE_SUB_ID>

# export OMS_WORKSPACE_NAME=<WORKSPACE_NAME>
# export OMS_WORKSPACE_ID=<WORKSPACE_ID> # /subscriptions/<subId>/resourcegroups/<om_srg>/providers/Microsoft.OperationalInsights/workspaces/<OMS_WORKSPACE_NAME>
# export OMS_LOCATION=${AKS_LOCATION}


export AKS_DATE=$(date +%Y%m%d)f

export AKS_RG=aks-${AKS_DATE}
export AKS_NAME=aks-${AKS_DATE}

export AKS_VNET_RG=aks-shared-${AKS_DATE}
export AKS_VNET_LOCATION=${AKS_LOCATION}
export AKS_VNET_NAME=aks-vnet-${AKS_VNET_LOCATION}

export AKS_VNET_RANGE=10.201.0.0/16
export AKS_SUBNET1_NAME=VNET-Local
export AKS_SUBNET1_RANGE=10.201.0.0/22
export AKS_SUBNET2_NAME=AKS-Nodes
export AKS_SUBNET2_RANGE=10.201.4.0/22

####
####  NOTE : For now, changing the CIDR or the DNS IP will make your unable to scale your cluster
####
export AKS_SVC_CIDR=10.0.0.0/16 # Must not overlap with AKS_VNET_RANGE
export AKS_SUBNET=/subscriptions/${AKS_SUB}/resourceGroups/${AKS_VNET_RG}/providers/Microsoft.Network/virtualNetworks/${AKS_VNET_NAME}/subnets/${AKS_SUBNET2_NAME}
# export AKS_BRIDGE_IP=10.201.0.1/24 
export AKS_DNS_IP=10.0.0.10 # Must be within SVC_CIDR

