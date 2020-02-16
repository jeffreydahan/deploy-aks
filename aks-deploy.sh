#!/bin/bash

rgname="aksrg"
location="westeurope"
vnetname="aksvnet"
vnetaddressprefix="10.0.0.0/16"
subnetnameaks="aksworkers"
subnetprefixaks="10.2.0.0/24"
subnetendpoints="Microsoft.Storage Microsoft.Sql Microsoft.AzureActiveDirectory Microsoft.AzureCosmosDB Microsoft.Web \
  Microsoft.KeyVault Microsoft.EventHub Microsoft.ServiceBus Microsoft.ContainerRegistry Microsoft.CognitiveServices"
clusternameaks="aks1"
minnodecountaks="2"
maxnodecountaks="2"
networkpluginaks="azure"



# create RG
az group create --name $rgname --location $location

# create vnet and aks worker subnet
az network vnet create --resource-group $rgname --name $vnetname \
  --address-prefix $vnetaddressprefix \
  --subnet-name $subnetname subnetnameaks \
  --subnet-prefix $subnetprefixaks #\
  # --service-endpoints $subnetendpoints
subnetidaks=$(az network vnet subnet list \
    --resource-group $rgname \
    --vnet-name $vnetname \
    --query "[0].id" --output tsv)
echo $subnetidaks

# create aks cluster
az aks create --resource-group $rgname --name $clusternameaks --attach-acr --enable-cluster-autoscaler \
  --min-count $minnodecountaks --max-count $maxnodecountaks --network-plugin $networkpluginaks \
  --vnet-subnet-id $subnetidaks --generate-ssh-keys
