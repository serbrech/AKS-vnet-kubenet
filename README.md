# AKS-vnet-kubenet
Scripts to deploy aks in a separate vnet with kubenet networking plugin


## Deploying AKS in a custom VNET

to deploy, first open env.sh and edit as needed the commented out section : 

```shell
##### EDIT THESE ######
#
# If you don't have a SPN, uncomment the line that creates it in the deploy-aks-cutom-vnet.sh script
#
# export SPN_PW=<YOUR_SPN_PW> # a service principal Service Principal
# export SPN_CLIENT_ID=<YOUR_SPN_CLIENT_ID>

# export AKS_SUB=<YOUR_AZURE_SUB_ID>

# export OMS_WORKSPACE_NAME=<WORKSPACE_NAME>
# export OMS_WORKSPACE_ID=<WORKSPACE_ID> # /subscriptions/<subId>/resourcegroups/<om_srg>/providers/Microsoft.OperationalInsights/workspaces/<OMS_WORKSPACE_NAME>
# export OMS_LOCATION=${AKS_LOCATION}
```

if you want to use a new Service Principal, you can ignore the `SPN_CLIENT_ID` and `SPN_PW` and uncomment the line creating it for you in the `deploy-aks-cutom-vnet.sh` :

```shell
#Uncomment if you want to create a new SPN for this deployment.
#create a SP and sets the env variable accordingly
#eval $(az ad sp create-for-rbac --skip-assignment | jq -r '"export SPN_PW=\(.password) && export SPN_CLIENT_ID=\(.appId)"')
```

Then run `./deploy-aks-cutom-vnet.sh`

## Deploying a Jumpbox

If you want a jumpbox to test the internal load balancer and internal subnet communication, you can run `deploy-jumpbox.sh`

It will create an ubuntu jumpbox in the second subnet and enable ssh using your local `~/.ssh/id_rsa.pub` key (required).
