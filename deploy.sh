#!/bin/bash
# login
az login

# Variables
resource_group_name="myResourceGroup"
cluster_name="myAKSCluster"

# create resources with Terraform
cd aks-deployment
terraform init -upgrade
terraform apply \
   -var="resource_group_name=$resource_group_name" 

# get generated resource group name and cluster name
aks_rg=$(terraform output -raw resource_group_name)
aks_name=$(terraform output -raw kubernetes_cluster_name)

echo $aks_rg
echo $aks_name

# connect the aks and app gateway vnets
nodeResourceGroup=$(az aks show -n $aks -g $rg -o tsv --query "nodeResourceGroup")
aksVnetName=$(az network vnet list -g $nodeResourceGroup -o tsv --query "[0].name")

aksVnetId=$(az network vnet show -n $aksVnetName -g $nodeResourceGroup -o tsv --query "id")
az network vnet peering create -n AppGWtoAKSVnetPeering -g $rg --vnet-name vnet1 --remote-vnet $aksVnetId --allow-vnet-access

appGWVnetId=$(az network vnet show -n vnet1 -g $rg -o tsv --query "id")
az network vnet peering create -n AKStoAppGWVnetPeering -g $nodeResourceGroup --vnet-name $aksVnetName --remote-vnet $appGWVnetId --allow-vnet-access

# enable AGIC
appgwId=$(az network application-gateway show -n appgateway -g $aks_rg -o tsv --query "id")
az aks enable-addons -n $aks_name  -g $aks_rg -a ingress-appgw --appgw-id $appgwId

# add cluster config to local kube config file
az aks get-credentials --resource-group $aks_rg --name $aks_name --overwrite-existing

# deploy app + service + ingress
kubectl apply -f ../k8s-templates/app.yaml

echo "Waiting 20 seconds for things to start"
sleep 20

# make sure we're up and running
