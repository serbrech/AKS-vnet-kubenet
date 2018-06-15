# AKS-vnet-kubenet
Scripts to deploy aks in a separate vnet with kubenet networking plugin


## Deploying AKS in a custom VNET

### [env.sh](scripts/env.sh)
To deploy, first open env.sh and edit as needed the commented out section :

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

if you want to use a new Service Principal for the deployment, you can ignore the `SPN_CLIENT_ID` and `SPN_PW` it will can created in the `[deploy-aks-cutom-vnet.sh](scripts/deploy-aks-cutom-vnet.sh)` :

### [deploy-aks-cutom-vnet.sh](scripts/deploy-aks-cutom-vnet.sh)

If you want to create a new SPN for the deployment uncomment th below line
```shell
# Uncomment if you want to create a new SPN for this deployment.
# create a SP and sets the env variable accordingly
# eval $(az ad sp create-for-rbac --skip-assignment | jq -r '"export SPN_PW=\(.password) && export SPN_CLIENT_ID=\(.appId)"')
```

Then run `./deploy-aks-cutom-vnet.sh`
This will source the `[env.sh](scripts/env.sh)` and run the deployment script.

### [deploy-jumpbox.sh](scripts/deploy-jumpbox.sh)

If you want a jumpbox to test the internal load balancer and internal subnet communication fro example, you can run `deploy-jumpbox.sh`

It will create an ubuntu jumpbox in the second subnet and enable ssh using your local `~/.ssh/id_rsa.pub` key (required).

### [enable_jumpbox_ssh_to_nodes.sh](scripts/enable_jumpbox_ssh_to_nodes.sh)

Still relying on the environment variables from `env.sh`, this will generate a `jumpbox_id_rsa` private/public key pair in the current folder, and scp them onto the jumpbox. It then resets the authorized ssh key for `azureuser` to `jumpbox_id_rsa.pub` for each AKS worker node.

After running this script, from your terminal :

```shell
me@local:~$ kubectl get node
NAME                       STATUS    ROLES     AGE       VERSION
aks-agentpool-33865844-0   Ready     agent     22m       v1.9.6
aks-agentpool-33865844-1   Ready     agent     22m       v1.9.6
aks-agentpool-33865844-2   Ready     agent     22m       v1.9.6
me@local:~$ ssh king@aks-jumpbox-${AKS_DATE}.${AKS_VNET_LOCATION}.cloudapp.azure.com
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.15.0-1013-azure x86_64)
...

king@aks-jumpbox:~$ ssh azureuser@aks-agentpool-33865844-2
The authenticity of host 'aks-agentpool-33865844-2 (10.201.4.6)' can\'t be established.
ECDSA key fingerprint is ....
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'aks-agentpool-33865844-2,10.201.4.6' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.13.0-1018-azure x86_64)
...

azureuser@aks-agentpool-33865844-2:~$ #on the node :)
```