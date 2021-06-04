#!/bin/bash
WLG="${ROMA_WLG:=1}"
CP="${ROMA_CP:=1}"
CPUW="${ROMA_CPUW:=6}"
GPUW="${ROMA_GPUW:=4}"

WL_SIZE="Standard_HB60rs"
CP_SIZE="Standard_HB60rs"
CPUW_SIZE="Standard_B4ms"
GPUW_SIZE="Standard_NV6_Promo"

echo "Workload generators: $WLG"
echo "Control planes: $CP"
echo "CPU workers: $CPUW"
echo "GPU workers: $GPUW"

echo "Creating resource group..."
az group create --resource-group roma2 --location westeurope

echo "Creating virtual network and subnet..."
az network vnet create --resource-group roma2 --name roma2_vnet --subnet-name roma2_net1

echo "Creating key folder"
mkdir -p key

echo "Workload generators"
for (( i = 1; i <= $WLG; i++ )) 
do
	echo "Creating control plane $i..."
	az vm create --resource-group roma2 --name WLG-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size $WL_SIZE --public-ip-address WLG-$i-ip --public-ip-address-allocation static --tags role=wlg
done

echo "Control planes"
for (( i = 1; i <= $CP; i++ )) 
do
	echo "Creating control plane $i..."
	az vm create --resource-group roma2 --name CP-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size $CP_SIZE --public-ip-address CP-$i-ip --public-ip-address-allocation static --tags role=cp
	echo "Opening ports for $i..."
	az vm open-port --port 6443,2379-2380,10250-10252,5000-5003,8000,8080 --resource-group roma2 --name CP-$i
done

echo "CPU workers"
for (( i = 1; i <= $CPUW; i++ )) 
do
	echo "Creating CPU worker $i..."
	az vm create --resource-group roma2 --name CPUW-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size $CPUW_SIZE --public-ip-address CPUW-$i-ip --public-ip-address-allocation static --tags role=cpuw
	echo "Opening ports for $i..."
	az vm open-port --port 10250,30000-32767 --resource-group roma2 --name CPUW-$i 
done

echo "GPU workers"
for (( i = 1; i <= $GPUW; i++ )) 
do
	echo "Creating GPU worker $i..."
	az vm create --resource-group roma2 --name GPUW-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size $GPUW_SIZE --public-ip-address GPUW-$i-ip --public-ip-address-allocation static --tags role=gpuw
	echo "Opening ports for $i..."
	az vm open-port --port 10250,30000-32767 --resource-group roma2 --name GPUW-$i 
	echo "Apply extension to $i for GPU drivers"
	az vm extension set --resource-group roma2 --vm-name GPUW-$i --name NvidiaGpuDriverLinux --publisher Microsoft.HpcCompute --version 1.3
done
