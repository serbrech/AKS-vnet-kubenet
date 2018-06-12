# create nsg for nic
export VM_NIC_NSG=aks-jumpbox-nsg
export VM_NIC=aks-jumpbox-nic
export VM_NAME=aks-jumpbox

az network nsg create --name ${VM_NIC_NSG}  -l ${AKS_VNET_LOCATION} -g ${AKS_VNET_RG}

az network nsg rule create -g $AKS_VNET_RG --destination-port-range 22 --priority 1000 -n ssh_22 --nsg-name $VM_NIC_NSG

az network public-ip create -g ${AKS_VNET_RG} --dns-name ${VM_NAME}-${AKS_DATE} --location ${AKS_VNET_LOCATION} --name $VM_PIP

#create nic for vm
az network nic create \
--resource-group ${AKS_VNET_RG} \
--name ${VM_NIC} \
--vnet-name ${AKS_VNET_NAME} \
--subnet ${AKS_SUBNET1_NAME} \
--network-security-group ${VM_NIC_NSG} \
--public-ip-address ${VM_PIP}

az vm create \
--name ${VM_NAME} \
--image UbuntuLTS \
--ssh-key-value "~/.ssh/id_rsa.pub" \
-g ${AKS_VNET_RG} \
-l ${AKS_VNET_LOCATION} \
--admin-username king \
--nic ${VM_NIC}