#!/bin/bash
set -x

# First, dissociate routes/nsg from Subnet
az network vnet subnet update \
-g ${AKS_VNET_RG} \
--route-table "" \
--network-security-group "" \
--vnet-name ${AKS_VNET_NAME} \
--name ${AKS_SUBNET2_NAME}

# then delete everything  :)
az group delete --name ${AKS_RG} -y
az group delete --name ${AKS_VNET_RG} -y --no-wait