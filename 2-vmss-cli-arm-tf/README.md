# Deploy to Azure Virtual Machine Scale Set

In [Lab 1](../1-app-hello-echo/) we built and containerized our `hello-echo` application. We can start by deploying this single-binary application in a minimal configuration without adding the incidental complexity of containers.

Let's deploy it to an [Azure Virtual Machine Scale Set (VMSS)](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview), which enables us to create and manage a group of identical, load balanced VMs. Advanced capabilities of scale sets include [autoscale](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-autoscale-overview), which can automatically increase or decrease the number of VM instances in response to demand or a defined schedule, and [Low-priority VMs on scale sets](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-low-priority) which can take advantage of Azure's unutilized capacity at a significant cost savings.

We are going to launch a [B-series burstable virtual machine](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/b-series-burstable) which start at [$0.012/hour for a B1S](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/) with 1 Core and 1.00 GiB RAM (1 Linux and 1 Windows B1S VM are included in our [Azure free account](http://azure.microsoft.com/free)).

Since we are using a single virtual machine for testing purposes, we set the initial `--instance-count` to 1. However, we can scale this up for performance and/or resiliency reasons. We can even 'scale to zero' by setting the instance count to 0.

We will be using [cloud-init](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init) which is supported on our Ubuntu, CoreOS, CentOS, and RHEL images. We'll create a [systemd](https://wiki.ubuntu.com/SystemdForUpstartUsers) unit file to daemonize our hello-echo application. We have previously uploaded a copy of our `hello-echo` binary to <https://github.com/aaronmsft/hello-echo/releases/download/test/hello-echo> (so it's not required to have completed Lab 1). We'll use `cloud-init` to [run a bash script](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cloudinit-bash-script) that will deploy `hello-echo` to our virtual machine via `curl`.

## Azure CLI

We can use the Azure CLI to deploy our Virtual Machine Scale Set imperatively.

[Deploy to Virtual Machine Scale Set via CLI](1-CLI.md)


## Azure Resource Manager (ARM)

We can also take advantage of Azure's declarative method for deploying resources in Azure, [Azure Resource Manager (ARM)](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates).

[Deploy to Virtual Machine Scale Set via ARM](2-ARM.md)


## Terraform

Terraform is a very popular open source option for deploying resources declaratively in Azure.

[Deploy to Virtual Machine Scale Set via Terraform](3-Terraform.md)


## Resources
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-create-vmss
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment
- https://github.com/Azure/terraform-azurerm-vmss-cloudinit
- https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview
- [Making production deployments safe and repeatable using declarative infrastructure and Azure Resource Manager](https://channel9.msdn.com/Events/Build/2018/BRK2126) by [Vlad Joanovic](https://channel9.msdn.com/Events/Speakers/vlad-joanovic) and Brendan Burns ([@brendandburns](https://twitter.com/brendandburns))
- https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure?toc=/en-us/azure/terraform/toc.json&bc=/en-us/azure/bread/toc.json
- https://www.terraform.io/docs/configuration/
- https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html
- https://docs.microsoft.com/en-us/azure/terraform/terraform-create-vm-scaleset-network-disks-hcl
