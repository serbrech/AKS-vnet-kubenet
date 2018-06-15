####
#### This assumes that ssh king@${AKS_JUMPBOX} will get you onto the jumpbox
#### Should be OK if you deployed the jumpbox using deploy-jumpbox.sh
####

# generate the jumbox ssh key and push it on the jumpbox
ssh-keygen -b 2048 -t rsa -f ./jumpbox_id_rsa -q -N "" 0>&-
scp -q ./jumpbox_id_rsa.pub king@${AKS_JUMPBOX}:~/.ssh/id_rsa.pub 
scp -q ./jumpbox_id_rsa king@${AKS_JUMPBOX}:~/.ssh/id_rsa
ssh king@${AKS_JUMPBOX} chmod 600 /home/king/.ssh/id_rsa
ssh king@${AKS_JUMPBOX} chmod 644 ~/.ssh/id_rsa.pub

#get the RG where aks was deployed
AKS_MC_RG=$(az group list --query "[?starts_with(name, 'MC_${AKS_RG}')].name | [0]" --output tsv)

# Reset ssh login on each worker 

# better way below
# az aks get-credentials --name $AKS_NAME -g $AKS_NAME --file ./kubeconfig
# kubectl get node -o name \
# | cut -d "/" -f \ #remove the node/ prefix
# | while read $vm; \
#     do az vm user update --name $vm -g $AKS_MC_RG --username azureuser --ssh-key-value ./jumpbox_id_rsa.pub; \
# done;

az vm user update --username azureuser --ssh-key-value ./jumpbox_id_rsa.pub --ids $(az vm list -g $AKS_MC_RG --query "[].id" --output tsv)