# Deploy your Go application on Azure

In this short lab, you're given a small echo server to deploy onto Azure. You'll learn how to
deploy an application with the Azure CLI as a standalone Azure Web App, in a container for Azure Web Apps for Containers, and deploying to Azure Container Instances. Along the way you'll learn the advantages and disadvantages of each deployment model. If you're willing to spend some more time with the lab, there is also a longer, individual article about deploying to Azure Kubernetes Service (AKS).

## The sample application

The sample application is contained in this directory as a `main.go` file. You can test it by running
locally and sending any HTTP request with a body to `localhost:8080/echo`. This echo server repeats back the POST body of the request, and then prints it locally on the server to stdout.

```bash
go run main.go &
curl -X POST --data 'Hello world!' http://localhost:8080/echo
kill %1
```

In the output, you should see `Hello world!` echoed back at you.

This is the same application that is used in one of the other labs, [Build and Containerize a Go Application](/1-app-hello-echo).
If you have already built and deployed the container to Azure Container Registry (ACR) from this earlier lab,
you'll be able to skip some steps here.

## Deploy directly to Azure Web Apps

Azure Web Apps allows you to deploy an application in a manner that requires little configuration on your behalf, and which automatically scales both "up" (the amount of resources available to an individual host) and "out" (the number of application hosts.) All you need to use Web Apps are the appropriate accounts on Azure, and your source code. The code can be
hosted in almost any location with the number of deployment options available.

The prerequisites for deploying to Azure Web Apps are:

* An Azure resource group
* An App Services plan

1. We've created a resource group for this lab, which you can get with the following CLI command:

    ```bash
    RESOURCE_GROUP=$(az group list | jq -r '[.[].name|select(. | startswith("Group-"))][0]')
    LOCATION='eastus'
    SUFFIX=$(LC_CTYPE=C tr -cd 'a-z0-9' < /dev/urandom | head -c 5)
    ```

2. Create an app services plan

    ```bash
    az appservice plan create -n deploy-lab -g $RESOURCE_GROUP --is-linux
    ```

3. Select the Web App deployment user with `az webapp deployment set`. If a user has not been created with the given user name in your tenant, one is created. The user name must be _universally unique_.

    ```bash
    WEBAPP_PASS=$(LC_CTYPE=C tr -cd 'A-Za-z0-9' < /dev/urandom | head -c 16)
    WEBAPP_USER="gopher$SUFFIX"
    az webapp deployment user set --user-name $WEBAPP_USER --password $WEBAPP_PASS
    ```

2. Create the application. This doesn't deploy it, but sets up the infrastructure in Azure and provides deployment information. For this lab, use `--deployment-local-git` which sets up a git repository on a resource in Azure that is used to build and deploy the application.

    Azure Web Apps requires that you provide a _universally unique_ application name inside of Azure, because of how applications are hosted and exposed. 

    ```bash
    APP_NAME="git-deploy-$SUFFIX"
    ```
    
    > :heavy_exclamation_mark: __IMPORTANT__
    > 
    > As of 8/21/18 the Go runtime for Azure Web Apps is currently in a closed preview, so it requires that there be an existing webapp runtime deployed
    > before being configured. This is why the runtime is initially set to `node|8.1`, to create the web app infrastructure that can
    > be reconfigured. When Azure Web Apps for Go is made publicly available, this restriction will be lifted.

    ```bash
    az webapp create --resource-group $RESOURCE_GROUP --plan deploy-lab \
        --name $APP_NAME --deployment-local-git --runtime "node|8.1"
    az webapp config set -g $RESOURCE_GROUP -n $APP_NAME --linux-fx-version "go|1"
    ```

3. Set up the redirect to port 80. Azure web apps only allow connections on ports 80 and 443.

    ```bash
    az webapp config appsettings set -g $RESOURCE_GROUP -n $APP_NAME --settings WEBSITES_PORT=8080
    ```

4. Clone the app to deploy.

    ```bash
    git clone https://github.com/aaronmsft/hello-echo.git
    ```

4. Push to the git remote for deployment. There's a local clone of the application already on
    the lab machine in the directory you're using in the directory `app`, so you can just add the remote and push.
    
    There is a hook which builds every time a push completes, and then deploys to all running instances if the build succeeds. This deploy operation is guaranteed to not interrupt availability.

    ```bash
    DEPLOY_URL=$(az webapp deployment source config-local-git -n $APP_NAME -g $RESOURCE_GROUP -o tsv)
    GIT_URL=$(echo $DEPLOY_URL | sed -e "s/$WEBAPP_USER/$WEBAPP_USER:$WEBAPP_PASS/")
    cd hello-echo
    git remote add $APP_NAME $GIT_URL 
    git push $APP_NAME master
    cd ..
    ```

5. Give a few moments for the build to complete, and then try sending an HTTP request to the endpoint.

    ```bash
    curl -X POST --data 'Hello world!' http://$APP_NAME.azurewebsites.net/echo
    ```

### Summary

Azure Web Apps is an easy way to deploy from a number of sources, but you do lose fine-grained control over the deployment. If you have a simple, lightweight API or a frontend application to deploy that still needs to scale, Azure Web Apps is a natural choice.

## Deploy as a container to Azure Web Apps

Azure Web Apps also supports deployment through containers. This section of the lab will demonstrate
how to deploy from an Azure Container Registry (ACR).

To deploy a container to Azure Web apps, you need:

* A resource group
* An Azure Web Apps plan using Linux hosts (created with `--is-linux`)
* A Docker image available from a container registry

We'll be using the App Services Plan created in the last section, so if you skipped it, go back and run the setup code to get the group and set up the plan. For containers, a deployment user is not necessary.

> :heavy_exclamation_mark: __NOTE__
>
> If you completed the [Build and Containerize a Go Application](/1-app-hello-echo) lab, then you can skip the steps
> 1 and 2, and use that container registry instead. If you don't have the environment variables for it
> available in your current terminal session, you can get the registry name again with: 
>
> ```bash
> REGISTRY_NAME=$(az acr list | jq -r '[.[].name|select(. | startswith("acr2018"))][0]')
> ```

1. Create an ACR to deploy the container image to.

```bash
REGISTRY_NAME="acr2018${SUFFIX}"
az acr create -g $RESOURCE_GROUP -l $LOCATION --name $REGISTRY_NAME --sku Basic --admin-enabled true
```

2. Build and deploy the container image in the repository.

```bash
az acr build -r $REGISTRY_NAME -t hello-echo --file Dockerfile .
```

3. Create the application. The same restrictions apply for containerized applications as others, namely the
application name must be _universally unique_. The Azure CLI also does not yet support deployment directly
from ACR, so a "scratch" container will be used for the initial creation.

    ```bash
    APP_NAME="container-deploy-$SUFFIX"
    az webapp create -g $RESOURCE_GROUP -p deploy-lab -n $APP_NAME \
        --deployment-container-image-name alpine
   ```

4. Deploy the ACR image.

    ```bash
   ACR_PASS=$(az acr credential show -g $RESOURCE_GROUP -n $REGISTRY_NAME -o tsv --query 'passwords[0].value')
   az webapp config container set --name $APP_NAME --resource-group $RESOURCE_GROUP \
        --docker-custom-image-name $REGISTRY_NAME.azurecr.io/hello-echo \
        --docker-registry-server-url https://$REGISTRY_NAME.azurecr.io \
        --docker-registry-server-user $REGISTRY_NAME \
        --docker-registry-server-password $ACR_PASS 
    ```

5. Configure the port redirect settings.

    ```bash
    az webapp config appsettings set -g $RESOURCE_GROUP -n $APP_NAME --settings  WEBSITES_PORT=8080
    ```

6. Wait a few moments for the container to deploy and restart. Then send a request to the remote application:

    ```bash
    curl -X POST --data 'Hello world!' http://$APP_NAME.azurewebsites.net/echo
    ```

### Summary

If you have an application which doesn't require a lot of manual configuration, is already containerized, and is reachable from a Docker registry, it's a good candidate for deployment with web apps. Using a private registry is possible but requires additional configuration. You can also set up a web app to support multiple containers with orchestration, but it is recommended that you set up your own AKS instance since this is a preview feature and subject to change.

You cannot use a free-tier app service plan, or a plan which allows for Windows hosts, when deploying a container as a web app.

## Deploy to Azure Container Instances (ACI)

If you have a container that you want to deploy like a web application, but have more control over its resource allocation and scaling, ACI may be the right option. Using ACI does __not__ require setting up any App Services plans.

The requirements for deploying with ACI are:

* An Azure resource group
* A Docker image available from a registry

For this lab you will use the ACR created in the last step, or if you did the previous [Build and Containerize a Go Application](/1-app-hello-echo) lab, the ACR from that. If you have not set up your environment or created an ACR, go back to the previous steps and create one.

1. Create the container instance and deploy. Unlike application names, ACI names only need to be unique within their resource group.

    ```bash
     az container create -g $RESOURCE_GROUP --name aci-deploy --image $REGISTRY_NAME.azurecr.io/hello-echo --registry-password $ACR_PASS --registry-username $REGISTRY_NAME --ip-address public --ports 8080
    ```

    Note that even if the container image specifies that certain ports should be exposed, they must additionally be exposed in the ACI creation. Container creation can take a few minutes while the instance spins up and runs the image.

2. Get the container's public IP address. You may need to wait a few moments for it to become available.

    ```bash
    PUBLIC_IP=$(az container show -g $RESOURCE_GROUP -n aci-deploy --query 'ipAddress.ip' --out tsv)
    ```

3. Connect to the running container.

    ```bash
    curl -X POST --data 'Hello world!' http://$PUBLIC_IP:8080/echo
    ```

### Summary

If you have a container that you want more direct management over, ACI may be the right deploy method for you. This gives you more flexibility with the resources consumed and the costs incurred, at the expense of requiring user intervention instead of selecting a pre-set plan from app services. Using ACI also requires a little more knowledge about the details of scaling on Azure to effectively manage, but is better for applications which need more than one port or which you want to keep private within the Azure infrastructure.

## Deploy to Azure Kubernetes Service (AKS)

The Azure Kubernetes Service (AKS) allows for spinning up a Kubernetes instance to deploy your application infrastructure to. Once this instance is available, you can deploy your application to Kubernetes using the `kubectl` command-line tool as you would with any other Kubernetes instance.

> :heavy_exclamation_mark: __IMPORTANT__
>
> In the interests of time and out of respect for your fellow attendees, please don't run this lab
> on-site at Gophercon. Deploying a cluster within AKS can take a significant amount of time,
> so we recommend returning to the lab content later. If you'd like to know more about AKS
> features and deployment, please ask a booth attendant.

Although the examples do not use Go, the general process of creating an AKS instance and deploying to it is universal. For that reason, we recommend that you take a look at the currently-available AKS deployment tutorial on [docs.microsoft.com]: [Deploy an Azure Kubernetes Service (AKS) cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough).
