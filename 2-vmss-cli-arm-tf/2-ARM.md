# Lab 2 Module 2: Deploy to Azure Virtual Machine Scale Set via Azure Resource Manager (ARM)

We can take advantage of Azure's declarative method for deploying resources in Azure, [Azure Resource Manager (ARM)](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates).

An ARM template typically consists of up to 4 sections:

1) [Parameters](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-templates-parameters), which are defined at runtime and can have optional default values

3)   [Variables](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-templates-variables) which can be re-used throughout the template

3) [Resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-templates-resources), where our infrastructure components are defined

4) [Outputs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-templates-outputs), where values can be output for further use

[Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates#functions) are often used throughout the template, in conjunction with Parameters and Variables.

After manually running the Azure CLI commands, we could export an [Azure Resource Manager template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates) of our existing deployment using the "Automation script" under the Resource Group in the Azure Portal or via the Azure CLI's [az group deployment export](https://docs.microsoft.com/en-us/cli/azure/group/deployment?#az-group-deployment-export) command.

The [Azure/azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates/) repository has a very large number of ARM templates for almost every purpose. Here we are using [201-vmss-linux-nat](https://github.com/Azure/azure-quickstart-templates/blob/master/201-vmss-linux-nat/azuredeploy.json) as a base template with some additional tweaks (made easier by Visual Studio Code's [excellent support for ARM template authoring](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-quickstart-create-templates-use-visual-studio-code)). After these tweaks, we are left with [azuredeploy.json](azuredeploy.json), in this directory, which can be used to deploy our infrastructure.

One of the advantages ARM templates have is the wide range of deployment options. These include the Azure Resource Manager REST API, by way of SDKs such as the [Azure SDK for Go](https://github.com/Azure-Samples/azure-sdk-for-go-samples/blob/master/resources/deployment.go), the Azure CLI, and even the Azure Portal, which we can pass a template by URL reference and requires little to no knowledge of ARM templates.

First, let us make sure we are in the correct directory for this lab, which includes our [azuredeploy.json](azuredeploy.json).

    cd 2-vmss-cli-arm-tf/

We have one final tweak to make to [azuredeploy.json](azuredeploy.json) before we deploy. Instead of passing our [cloud-init.sh](cloud-init.sh) bash script via the `--custom-data` flag, we must inject it as a parameter which gets encoded via the [base64](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-string#base64) function. This would typically be passed in at runtime as a parameter, or via a stand-alone azuredeploy.parameters.json, but here we can easily use `jq` to include it as the default value for `customData` in [azuredeploy.json](azuredeploy.json), `.parameters.customData.defaultValue`

    cat azuredeploy.json | jq --arg v "$(cat cloud-init.sh)" '.parameters.customData.defaultValue=$v' > azuredeploy.json

We will now deploy our ARM template, [azuredeploy.json](azuredeploy.json), via the Azure CLI's [az deployment create](https://docs.microsoft.com/en-us/cli/azure/group/deployment?#az-group-deployment-create) command.

In the snippet below we set the correct value for the RESOURCE_GROUP variable. This can be set manually as below, or via the `az group list` command with `jq` to select the name of the "first group that starts with Group-". If you're doing this lab on your own, **not at an event**, you will need to un-comment and **set the RESOURCE_GROUP variable manually**.

    # RESOURCE_GROUP='Group-...'
    RESOURCE_GROUP=$(az group list | jq -r '[.[].name|select(. | startswith("Group-"))][0]')
    LOCATION='eastus'

Create the resource group, if required:

    az group create --name $RESOURCE_GROUP --location $LOCATION

Then we'll run the `az group deployment create` command.

    az group deployment create -g $RESOURCE_GROUP --mode Complete --template-file azuredeploy.json

We can also run the command *and* extract the public IP Address via:

    RESULT=$(az group deployment create -g $RESOURCE_GROUP --mode Complete --template-file azuredeploy.json)
    IP_ADDRESS=$(echo $RESULT | jq -r .properties.outputs.publicIPAddress.value)

Finally, if we want to delete all of the resources inside our Resource Group, we can deploy any empty ARM template, [empty.json](empty.json), with the `--mode Complete` flag, instead of the default deployment mode, `Incremental`, which will not delete existing resources.

    az group deployment create -g $RESOURCE_GROUP --mode Complete --template-file empty.json

Once we have created an ARM template, one of the easiest way to enable others to deploy is to make it available via a publicly accessible URL (such as a GitHub repository, or an Azure Blob Storage account that is optionally protected by a Shared Access Signature), and generate that passes the URL to the Azure Portal's template deployment experience. You will often see theses links as "Deploy to Azure" buttons in the [Azure/azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-linux-nat) repository.

Here is how we can create such a link using `bash` and `jq`:

    TEMPLATE_URL='https://gist.githubusercontent.com/asw101/1af0101328bc52cfd94aa11b3b6b01fd/raw/d48f0cbf532a18a4850ce0e165f814927c242776/180800-azuredeploy.json'
    OUTPUT_URL='https://portal.azure.com/#create/Microsoft.Template/uri/'$(echo $TEMPLATE_URL | jq -s -R -r @uri )
    echo $OUTPUT_URL

It will output a link as follows:

<https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgist.githubusercontent.com%2Fasw101%2F1af0101328bc52cfd94aa11b3b6b01fd%2Fraw%2Fd48f0cbf532a18a4850ce0e165f814927c242776%2F180800-azuredeploy.json%0A>

Click on the above to deploy the ARM template via the Azure Portal's UI. You will see that you are prompted for the Resource Group to deploy to, as well as any parameters the template requires. 

Note: If you have multiple directories, or a preview URL, you may wish to open `portal.azure.com` first, and then copy and paste the link into your address bar.

[Return to Lab 2 README](README.md)
