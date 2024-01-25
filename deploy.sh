#!/bin/bash
# login
az login

# Variables
service_principal=deployment-sp

# create service principal
spCreds=$(az ad sp create-for-rbac --name $service_principal --skip-assignment)
appId=$(echo $spCreds | jq -r .appId)
password=$(echo $spCreds | jq -r .password)

# create resources with Terraform
cd aks-deployment
terraform init -upgrade
terraform apply \
   -var="appId=$appId" \
   -var="password=$password" 

# # get generated resource group name and cluster name
aks_rg=$(terraform output -raw resource_group_name)
aks_name=$(terraform output -raw kubernetes_cluster_name)

# enable AGIC
echo @@ enabling AGIC @@
appgwId=$(az network application-gateway show -n appgateway -g $aks_rg -o tsv --query "id")
az aks enable-addons -n $aks_name  -g $aks_rg -a ingress-appgw --appgw-id $appgwId

# connect the aks and app gateway vnets
echo @@ peering AGIC and AKS @@
nodeResourceGroup=$(az aks show -n $aks_name -g $aks_rg -o tsv --query "nodeResourceGroup")
aksVnetName=$(az network vnet list -g $nodeResourceGroup -o tsv --query "[0].name")

aksVnetId=$(az network vnet show -n $aksVnetName -g $nodeResourceGroup -o tsv --query "id")
az network vnet peering create -n AppGWtoAKSVnetPeering -g $aks_rg --vnet-name vnet1 --remote-vnet $aksVnetId --allow-vnet-access

appGWVnetId=$(az network vnet show -n vnet1 -g $aks_rg -o tsv --query "id")
az network vnet peering create -n AKStoAppGWVnetPeering -g $nodeResourceGroup --vnet-name $aksVnetName --remote-vnet $appGWVnetId --allow-vnet-access

# add cluster config to local kube config file
echo @@ add cluster config @@
az aks get-credentials --resource-group $aks_rg --name $aks_name --overwrite-existing

# deploy app + service + ingress
echo @@ deploy app @@
kubectl apply -f ../k8s-templates/app.yaml

echo "@@ waiting 20 seconds for things to start @@"
sleep 20

# make sure we're up and running
publicIp=$(kubectl get ingress bitcoin-tracker-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl "http://$publicIp/service-A"