# ROMA2 Cluster Init
This repository contains a set of scripts and Ansible Playbooks for ROMA2 cluster initialization.

It allocates VMs from Azure and initializes:

- control planes
- CPU workers
- GPU workers (with NVIDIA driver extension)

It will setup:

- Docker
- Kubernetes
- NVIDIA Docker

### Usage
#### Setup
```
virtualenv env
source env/bin/activate
pip install -r requirements.txt
ansible-galaxy install -r collections.yml
```

#### Cluster Allocation
Set the number of nodes, e.g., for a cluster with 1 control plane, 2 CPU workers and 2 GPU workers:
```
export ROMA_CP=1 && export ROMA_CPU_W=2 && export ROMA_GPU_W=2
./create.sh
```

#### Cluster Initialization
When the allocation is completed and the drivers are installed (the NvidiaGpuDriverLinux extension is provisioned successfully, i.e., ```nvidia-smi``` command can be executed) on all GPU nodes, the cluster can be created with:
```
ansible-playbook -i playbooks/inventory_azure_rm.yml -u azureuser --private-key key/roma2_key playbooks/start.yml
```

A Pod example with GPU

#### Cluster Deletion
The cluster can be deleted with:
```
./delete.sh
```
