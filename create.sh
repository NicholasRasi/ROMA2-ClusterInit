#!/bin/bash
CP="${ROMA_CP:=1}"
CPU_W="${ROMA_CPU_W:=1}"
GPU_W="${ROMA_GPU_W:=1}"

echo "Control planes: $CP"
echo "CPU workers: $CPU_W"
echo "GPU workers: $GPU_W"

echo "Creating resource group..."
az group create --resource-group roma2 --location westeurope

echo "Creating virtual network and subnet..."
az network vnet create --resource-group roma2 --name roma2_vnet --subnet-name roma2_net1

echo "Creating key folder"
mkdir -p key

echo "Control planes"
for (( i = 1; i <= $CP; i++ )) 
do
	echo "Creating control plane $i..."
	az vm create --resource-group roma2 --name CP-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size Standard_HB60rs --public-ip-address CPW-$i-ip --public-ip-address-allocation static --tags role=cp
	echo "Opening ports for $i..."
	az vm open-port --port 6443,2379-2380,10250-10252 --resource-group roma2 --name CP-$i
done

echo "CPU workers"
for (( i = 1; i <= $CPU_W; i++ )) 
do
	echo "Creating CPU worker $i..."
	az vm create --resource-group roma2 --name CPUW-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size Standard_B4ms --public-ip-address CPUW-$i-ip --public-ip-address-allocation static --tags role=cpuw
	echo "Opening ports for $i..."
	az vm open-port --port 10250,30000-32767 --resource-group roma2 --name CPUW-$i 
done

echo "GPU workers"
for (( i = 1; i <= $GPU_W; i++ )) 
do
	echo "Creating GPU worker $i..."
	az vm create --resource-group roma2 --name GPUW-$i --location westeurope --image Canonical:UbuntuServer:18.04-LTS:latest --admin-username azureuser --generate-ssh-keys --ssh-key-values ./key/roma2_key.pub --vnet-name roma2_vnet --subnet roma2_net1 --size Standard_NV6_Promo --public-ip-address GPUW-$i-ip --public-ip-address-allocation static --tags role=gpuw
	echo "Opening ports for $i..."
	az vm open-port --port 10250,30000-32767 --resource-group roma2 --name GPUW-$i 
	echo "Apply extension to $i for GPU drivers"
	az vm extension set --resource-group roma2 --vm-name GPUW-$i --name NvidiaGpuDriverLinux --publisher Microsoft.HpcCompute --version 1.3
done
