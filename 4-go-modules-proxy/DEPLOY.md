# Set up a Go modules proxy

With the introduction of modules in Go 1.11 you can manage your dependencies
via a shared caching proxy. [Project Athens](https://github.com/gomods/athens)
is an open source project to provide just such a proxy :)

In this lab you'll deploy and test out a Go proxy hosted by Azure App Service.
App Service offers a managed platform for running functions, servers and
containers. We'll deploy the Athens proxy in a container.

1. Open your terminal and run the following to set configuration:

    ```bash
    RESOURCE_GROUP=$(az group list | jq -r '[.[].name|select(. | startswith("Group-"))][0]')
    LOCATION='eastus'
    ```

1. You'll need a container registry to store and build your images. A container
   registry stores and maintains a library of container images. 

    Create an Azure Container Registry (ACR) registry as follows:

    ```bash
    REGISTRY_NAME="$(echo ${RESOURCE_GROUP} | sed 's/[- _]//g')registry"
    IMAGE_NAME=go-proxy
    IMAGE_TAG=latest

    az acr create \
      --name ${REGISTRY_NAME} --resource-group ${RESOURCE_GROUP} \
      --sku 'Standard' --admin-enabled 'true' --location $LOCATION
    ````

1. We'll need some metadata about this registry later, so run the following
   commands to capture it:

    ```
    REGISTRY_PREFIX=$(az acr show \
      --name ${REGISTRY_NAME} --resource-group ${RESOURCE_GROUP} --output tsv --query 'loginServer')

    REGISTRY_PASSWORD=$(az acr credential show \
      --name ${REGISTRY_NAME} --output tsv --query 'passwords[0].value')

    REGISTRY_USERNAME=$(az acr credential show \
      --name ${REGISTRY_NAME} --output tsv --query 'username')

    IMAGE_URI=${REGISTRY_PREFIX}/${IMAGE_NAME}:${IMAGE_TAG}
    ```

1. With your registry ready to go, time to add an image for the Go proxy. In
   Azure Container Registry, each image is stored in a repository. 

    ACR can also build your image based on a Dockerfile in your source code.
    We'll utilize that here to build an image and create an ACR repository for it
    at the same time.

    The `az acr build` command is comparable to `docker build`, only the build is
    executed by an agent in Azure rather than a local Docker daemon.

    ```bash
    git clone https://github.com/gomods/athens

    DOCKERFILE_RELATIVE_PATH=cmd/proxy/Dockerfile
    DOCKER_CONTEXT_PATH=athens

    az acr build \
       --registry ${REGISTRY_NAME} \
       --resource-group ${RESOURCE_GROUP} \
       --file ${DOCKERFILE_RELATIVE_PATH} \
       --image "${IMAGE_NAME}:${IMAGE_TAG}" \
       ${DOCKER_CONTEXT_PATH}
    ```

1. Create and configure an Azure App Service Web App to run your container.
   Every App Service app runs in a shared plan, which we'll configure first.

      ```bash
      APP_NAME=${RESOURCE_GROUP)-goproxy
      PLAN_NAME=go-proxy-plan

      az appservice plan create \
        --name ${PLAN_NAME} \
        --resource-group ${RESOURCE_GROUP} \
        --is-linux \
        --location $LOCATION

      az webapp create \
        --name ${APP_NAME} \
        --plan ${PLAN_NAME} \
        --resource-group ${RESOURCE_GROUP} \
        --deployment-container-image-name ${IMAGE_URI}
      ```

1. Because Azure Container Registry repositories are not publicly accessible we
   must provide credentials to the Web App. We'll also configure the app to
   update itself automatically whenever the associated container is updated,
   and turn on logging for good measure :).

    ```
    az webapp config container set \
    --name ${APP_NAME} --resource-group ${RESOURCE_GROUP} \
    --docker-custom-image-name ${IMAGE_URI} \
    --docker-registry-server-url "https://${REGISTRY_PREFIX}" \
    --docker-registry-server-user ${REGISTRY_USERNAME} \
    --docker-registry-server-password ${REGISTRY_PASSWORD}

    az webapp deployment container config \
    --name ${APP_NAME} --resource-group ${RESOURCE_GROUP} \
    --enable-cd 'true'

    az webapp log config \
    --name ${APP_NAME} --resource-group ${RESOURCE_GROUP} \
    --docker-container-logging filesystem \
    --level verbose
    ```

1. The Go proxy saves module data and metadata in one of several backends. In
    the lab we'll use Azure CosmosDB via its MongoDB API. We'll create a Cosmos
    account, add a database and a couple collections to it, and configure the
    web app with the CosmosDB/MongoDB connection string.

    ```bash
    COSMOSDB_ACCOUNT_NAME=${RESOURCE_GROUP}-go-proxy-cosmosdb
    DB_NAME=athens
    COLL_NAME=modules

    az cosmosdb create \
    --name ${COSMOSDB_ACCOUNT_NAME} \
    --resource-group ${RESOURCE_GROUP} \
    --kind MongoDB

    az cosmosdb database create \
    --db-name $DB_NAME --name ${COSMOSDB_ACCOUNT_NAME} --resource-group-name ${RESOURCE_GROUP}

    az cosmosdb collection create \
    --collection-name $COLL_NAME \
    --db-name $DB_NAME --name ${COSMOSDB_ACCOUNT_NAME} --resource-group-name ${RESOURCE_GROUP}

    MONGO_URL=$(az cosmosdb list-connection-strings \
    --name ${COSMOSDB_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} \
    --query "connectionStrings[0].connectionString" --output tsv)

    az webapp config appsettings set \
    --name ${APP_NAME} --resource-group ${RESOURCE_GROUP} \
    --settings \
      "ATHENS_STORAGE_TYPE=mongo" \
      "ATHENS_MONGO_CONNECTION_STRING=${MONGO_URL}"
    ```

1. Check if all is working!

    * Browse <https://${RESOURCE_GROUP}-goproxy.azurewebsites.net>  and see a basic page.

    It may take a few minutes for web apps to pull and load your container. If the
    site returns "Service Unavailable", try again 30 seconds later. If it seems to
    hang, just wait :).

    You can also view logs once the container begins to be deployed by browsing to
    <https://${RESOURCE_GROUP}-go-proxy.scm.azurewebsites.net/api/logs/docker>. The
    file ending in `_docker.log` contains the host's logs as it pulls and runs the
    container. The file ending in `_default_docker.log` is the runtime container's
    logs.

1. Now continue to [use your proxy with go](./USE.md)!
