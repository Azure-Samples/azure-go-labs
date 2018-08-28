# Lab 2 Module 3: Deploy to Azure Virtual Machine Scale Set via Terraform

Terraform is a very popular open source option for deploying resources declaratively in Azure. Terraform supports multiple providers, and the [azurerm](https://www.terraform.io/docs/providers/azurerm/) provider enables first-class support for Azure resources. In Terraform these declarative templates are called [configurations](https://www.terraform.io/docs/configuration/). These configurations are usually written in [Hashicorp Configuration Language (HCL)](https://www.terraform.io/docs/configuration/syntax.html) which is more human friendly to read and edit than [JSON](https://www.terraform.io/docs/configuration/syntax.html#json-syntax), which is also supported.

Terraform is a CLI tool, written in Go. It ships as a [single binary](https://www.terraform.io/downloads.html) and also uses our [Azure SDK for Go](https://github.com/Azure/azure-sdk-for-go/) extensively. This lab assumes version 0.11.8 or newer:

    $ terraform version
    Terraform v0.11.8

In production, we would often have Terraform authenticate with an Azure AD Service Principal which you can see in our [Install and configure Terraform](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure?toc=%2Fen-us%2Fazure%2Fterraform%2Ftoc.json&bc=%2Fen-us%2Fazure%2Fbread%2Ftoc.json#set-up-terraform-access-to-azure) quickstart. However, in this tutorial we will take advantage of Terraform's ability to re-use our Azure CLI token from the `az login` command.

We have included a configuration that is roughly equivalent to our ARM template ([azuredeploy.json](azuredeploy.json)) under the [2-vmss-cli-arm-tf/terraform/](terraform/) folder in this repo. 
We have built and extended these files from our tutorial, [Use Terraform to create an Azure virtual machine scale set](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-vm-scaleset-network-disks-hcl), in our Azure docs.

`variables.tf`: Here we define the variables used in our Terraform configuration.  
`vmss.tf`: All of the resources required to deploy our Virtual Machine Scale Set from the `resource_group`, to `random_string` resources for unique domain names and an admin password, networking resources, and finally, our `azurerm_virtual_machine_scale_set`  
`output.tf`: Contains the outputs from our Terraform configuration.  

We have defined most of our variables in `variables.tf`. However, when running these commands we are going to [override one variable](https://www.terraform.io/intro/getting-started/variables.html#assigning-variables), `resource_group_name` using the environment variable `TF_VAR_resource_group_name` (we could also pass `-var resource_group_name=$RESOURCE_GROUP` to our `plan`, `apply` and `destroy` commands).

First, let us make sure we are in the same directory as our Terraform configuration:

    cd 2-vmss-cli-arm-tf/terraform/

Set resource group, if **at an event**, where the environment was pre-configured:

    export TF_VAR_resource_group_name=$(az group list | jq -r '[.[].name|select(. | startswith("Group-"))][0]')

Or, set resource group, if **not at an event**, if you're doing this lab on your own:

    RANDOM_SUFFIX=$(LC_CTYPE=C tr -cd 'a-z0-9' < /dev/urandom | head -c 5)
    export TF_VAR_resource_group_name='Group-'$RANDOM_SUFFIX


Next, we will run [terraform init](https://www.terraform.io/docs/commands/init.html) command which prepares a working directory containing Terraform configuration files: 

    terraform init

We can optionally use [terraform plan](https://www.terraform.io/docs/commands/plan.html) will create an execution plan and show you the changes that your Terraform configuration will make to your environment before running them.

    terraform plan
    
When we are ready to apply these changes, we use [terraform apply](https://www.terraform.io/docs/commands/apply.html) which will "apply the changes required to reach the desired state of the configuration".

    terraform apply

We'll need to confirm that we want to run this:

    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value: 

We'll see output that tells us the current state:

```
azurerm_virtual_machine_scale_set.vmss: Still creating... (2m10s elapsed)
azurerm_virtual_machine_scale_set.vmss: Creation complete after 2m10s (ID: /subscriptions/12345678-1234-1234-1234-...pute/virtualMachineScaleSets/scaleset1)

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

vmss_admin_password = 1234567890abcdABCD1234abcdABCDab
vmss_public_ip = xxxxxx.eastus.cloudapp.azure.com
$
```

## Testing Our Terraform-created VMSS

Set our IP, replacing 'xxxxxx' with the value for your session:

    FQDN='xxxxxx.eastus.cloudapp.azure.com'

Let's send requests to our application with curl:
 
    curl $FQDN'/'
    curl $FQDN'/host'
    curl $FQDN'/echo'

 If we try `/hosts` a few times we'll see it load-balancing.

## Cleanup

Once we are ready to clean up, [terraform destroy](https://www.terraform.io/docs/commands/destroy.html) will destroy all of the resources specified in our configuration, so we want to be sure!

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

[Return to Lab 2 README](README.md)
