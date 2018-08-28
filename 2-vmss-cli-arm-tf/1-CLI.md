# Lab 2 Module 1: Deploy to Azure Virtual Machine Scale Set via CLI

We can use the Azure CLI to deploy our Virtual Machine Scale Set imperatively.

First, let us make sure we are in the correct directory for this lab, which includes our [cloud-init.sh](cloud-init.sh).

    cd 2-vmss-cli-arm-tf/

Set variables (valid both at an event or on your own):

    LOCATION='eastus'
    VMSS_NAME='scaleset1'

Set resource group, if **at an event**, where the environment was pre-configured:

    RESOURCE_GROUP=$(az group list | jq -r '[.[].name|select(. | startswith("Group-"))][0]')

Or, set resource group, if **not at an event**, if you're doing this lab on your own:

    RANDOM_SUFFIX=$(LC_CTYPE=C tr -cd 'a-z0-9' < /dev/urandom | head -c 5)
    RESOURCE_GROUP='Group-'$RANDOM_SUFFIX
    az group create --name $RESOURCE_GROUP --location $LOCATION

Use [az vmss create](https://docs.microsoft.com/en-us/cli/azure/vmss#az-vmss-create) to create our Virtual Machine Scale Set:

    az vmss create \
        --resource-group $RESOURCE_GROUP \
        --name $VMSS_NAME \
        --instance-count 1 \
        --vm-sku Standard_B1S \
        --image UbuntuLTS \
        --upgrade-policy-mode automatic \
        --custom-data cloud-init.sh \
        --admin-username azureuser \
        --generate-ssh-keys

Create a rule on our load balancer that forwards TCP port 80 to our pool of instances:

    az network lb rule create \
        --resource-group $RESOURCE_GROUP \
        --name lbRuleTcp80 \
        --lb-name $VMSS_NAME'LB' \
        --backend-pool-name $VMSS_NAME'LBBEPool' \
        --backend-port 80 \
        --frontend-ip-name loadBalancerFrontEnd \
        --frontend-port 80 \
        --protocol tcp

Show the public IP of our load balancer (and this uses [jq](https://stedolan.github.io/jq/)):

    IP_ADDRESS=$(az network public-ip show \
        --resource-group $RESOURCE_GROUP \
        --name $VMSS_NAME'LBPublicIP' \
        | jq -r .ipAddress)
    echo $IP_ADDRESS

Let's send requests to our application with curl:

    curl $IP_ADDRESS'/'
    curl $IP_ADDRESS'/host'
    curl $IP_ADDRESS'/echo'

Let's check out our single instance:

    az vmss list-instance-connection-info \
        --resource-group $RESOURCE_GROUP \
        --name $VMSS_NAME

We can scale up from a single instance to multiple instances with the [az vmss scale](https://docs.microsoft.com/en-us/cli/azure/vmss#az-vmss-scale) command. (This may take a few minutes.)

    az vmss scale \
        --resource-group $RESOURCE_GROUP \
        --name $VMSS_NAME \
        --new-capacity 2

Let's request the /host endpoint a few more times. Now that we have multiple instances, will show that we are reaching different hosts as a result of round-robin load balancing, as we repeat this curl command:

    curl $IP_ADDRESS'/host'


If we would like to SSH into a particular machine in our scale set we can list the connection info for the machines as follows:

    az vmss list-instance-connection-info \
        --resource-group $RESOURCE_GROUP \
        --name $VMSS_NAME

Our SSH command would look something like this, where X.X.X.X is the load balancer IP, and 5000x is the port assigned to the instance:

    ssh azureuser@X.X.X.X -p 5000x

Once sshed in, we can also look at the cloud-init logs:

    tail -f /var/log/cloud-init.log
    tail -f /var/log/cloud-init-output.log

## Optional Resource Cleanup

This isn't necessary if you're now finished with this lab at an event, but you may want to do this if you're playing along at home!

    $ az group delete --name $RESOURCE_GROUP --no-wait --yes

[Return to Lab 2 README](README.md)
