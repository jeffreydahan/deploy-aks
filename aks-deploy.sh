#!/bin/bash

rgname="aksrg"
location="westeurope"
vnetname="aksvnet"
vnetaddressprefix="10.0.0.0/16"
subnetnameaks="aksworkers"
subnetprefixaks="10.0.2.0/24"
subnetendpoints="Microsoft.Storage Microsoft.Sql Microsoft.AzureActiveDirectory Microsoft.AzureCosmosDB Microsoft.Web \
  Microsoft.KeyVault Microsoft.EventHub Microsoft.ServiceBus Microsoft.ContainerRegistry Microsoft.CognitiveServices"
clusternameaks="aks1"
minnodecountaks="2"
maxnodecountaks="2"
nodecountaks="2"
networkpluginaks="azure"
zonesaks="1 2 3"




# create RG
az group create --name $rgname --location $location

# create vnet and aks worker subnet
az network vnet create --resource-group $rgname --name $vnetname \
  --address-prefix $vnetaddressprefix
az network vnet subnet create --resource-group $rgname --vnet-name $vnetname \
  --name $subnetnameaks \
  --address-prefixes $subnetprefixaks \
  --service-endpoints $subnetendpoints
subnetidaks=$(az network vnet subnet list \
    --resource-group $rgname \
    --vnet-name $vnetname \
    --query "[0].id" --output tsv)
echo $subnetidaks

# create aks cluster
az aks create --resource-group $rgname --name $clusternameaks --enable-cluster-autoscaler \
  --node-count $nodecountaks --min-count $minnodecountaks --max-count $maxnodecountaks \
  --network-plugin $networkpluginaks --vnet-subnet-id $subnetidaks --zones $zonesaks \
  --generate-ssh-keys

# validate nodes
az aks get-credentials --resource-group $rgname --name $clusternameaks

