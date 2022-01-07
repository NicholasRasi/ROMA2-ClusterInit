# ROMA2 Cluster Init
This repository contains all the required resources for the [ROMA2](https://github.com/NicholasRasi/ROMA2) cluster initialization.

The infrastructure and VMs configuration are performed with a set of IaaC scripts, Ansible Playbooks and/or Terraform. 

### Cluster Infrastructure
##### Creation
This tool allow to allocate and initialize:
- workload generators
- control planes
- CPU workers
- GPU workers (with NVIDIA driver extension)

##### Ports
During the configuration the following ports will be opened:
- https://kubernetes.io/docs/reference/ports-and-protocols/
- 22 on the control planes

### Cluster Configuration
The Ansible playbooks allow to setup:
- Docker
- Kubernetes
- NVIDIA Docker

## Usage
### Project Setup
```
virtualenv env
source env/bin/activate
pip install -r requirements.txt
ansible-galaxy install -r collections.yml
```

### Infrastructure Initialization
The infrastructure (hosted on Azure) can be created using one of the following tools:
- single script (based on AZ CLI)
- Terraform

##### Single Script
1. Login into AZ with
``az login``
2. Set the number of nodes, e.g., for a cluster with 1 control plane, 2 CPU workers and 2 GPU workers
``export ROMA_WLG=1 && export ROMA_CP=1 && export ROMA_CPUW=2 && export ROMA_GPUW=2``
3. Start the infrastructure creation
``./cli/create.sh``

##### Terraform
1. CD to terraform dir ``cd terraform``
2. Login into AZ with
``az login``
3. Initialize Terraform with ```terraform init```
3. Edit the ``terraform.tfvars.example`` and rename it ``terraform.tfvars``
4. Start the plan with ``terraform plan``
5. Apply the plan with ``terraform apply``

### VMs Configuration
When the infrastructure is ready and the drivers are installed (the NvidiaGpuDriverLinux extension is provisioned successfully, i.e., ```nvidia-smi``` command can be executed) on all GPU nodes, the cluster can be configured with:
```
ansible-playbook -i playbooks/inventory_azure_rm.yml -u azureuser --private-key key/roma2_key playbooks/start.yml
```

### Infrastructure Deletion
The cluster can be deleted with:
- ``./cli/delete.sh``
- or with ``terraform destroy``
