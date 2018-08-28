# Build and Containerize a Go application

Let's start with a simple Go web application called hello-echo which has three endpoints:

`/`: Returns a simple text string "Hello Gopher!"  
`/echo`: Dumps our request verbatim via httputil.DumpRequest  
`/host`: Returns the hostname of the machine via os.Hostname  

Lab 1: Build and Containerize a Go application
  Part 1: Build the application locally as a self-contained Go binary.
  Part 2: Build the application as part of a Docker multi-stage build using ACR Build.

## Lab 1, Part 1: Local Build and Test

In order to build the application locally, run `go build` like this:

    go build -o hello-echo main.go

To test, run `hello-echo`:

    ./hello-echo

Let's use ^Z and `bg` to background it:

    $ ./hello-echo
    Listening on :8080
    ^Z
    [1]+  Stopped                 ./hello-echo
    $ bg
    [1]+ ./hello-echo &
    $

Let's check out the endpoints and see what they say:

    $ curl localhost:8080
    $ curl localhost:8080/echo
    $ curl localhost:8080/host

Use `fg` to bring the app to the foreground again, then control-C out:

    $ fg
    ./hello-echo
    ^C

Congratulations; our application is working! Next, we'll build it inside a container.

## Lab 1, Part 2: Docker multi-stage build using Azure Container Registry (ACR) Build

In our [Dockerfile](Dockerfile) we are building our application in the `FROM golang:rc-alpine as builder` stage, and copying the `hello-echo` binary to a `FROM scratch` image in the second stage (note that we also build with `CGO_ENABLED=0` when using a `scratch` image).

In the snippet below we set the correct value for the RESOURCE_GROUP variable. This can be set manually as below, or via the `az group list` command with `jq` to select the name of the "first group that starts with Group-". If you're doing this lab on your own, **not at an event**, you will need to un-comment and **set the RESOURCE_GROUP variable manually**.

Our Azure Container Registry's name must also be globally unique, so we are also setting REGISTRY_NAME to 'acr2018' with 5 character random suffix.

Let's set our environment variables:

    # RESOURCE_GROUP='Group-...'
    RESOURCE_GROUP=$(az group list | jq -r '[.[].name|select(. | startswith("Group-"))][0]')
    LOCATION='eastus'
    RANDOM_SUFFIX=$(LC_CTYPE=C tr -cd 'a-z0-9' < /dev/urandom | head -c 5)
    REGISTRY_NAME='acr2018'$RANDOM_SUFFIX

If we're not yet logged in:

    az login

Create the resource group, if required:

    az group create --name $RESOURCE_GROUP --location $LOCATION

Now let's use the Azure CLI (az) to create an Azure Container Registry and build an image in the cloud.

    az acr create -g $RESOURCE_GROUP -l $LOCATION --name $REGISTRY_NAME --sku Basic

(The `az acr create` command may take a few minutes.)

To build using ACR Build, which will push our Dockerfile and code to the cloud, build the image, and store it in our Azure Container Registry, we use the [az acr build](https://docs.microsoft.com/en-us/cli/azure/acr?#az-acr-build) command:

    az acr build -r $REGISTRY_NAME -t hello-echo --file Dockerfile .

The fully-qualified name of the image in our Container Registry will then be `$REGISTRY_NAME'.azurecr.io/hello-echo:latest'`. Let's output this with:

    echo "${REGISTRY_NAME}.azurecr.io/hello-echo:latest"

Congratulations, you have compiled your Go application and built your first image inside Azure Container Registry, using ACR Build and Docker multi-stage builds. This can be used on local and remote machines via `az acr login -n $REGISTRY_NAME` and `docker run -it $REGISTRY_NAME'.azurecr.io/hello-echo:latest'` which we'll explore in a future tutorial.

Note: if we have Docker installed locally, we can run `docker build -t hello-echo .` and it would build our image locally and make it available on our local machine. This tutorial doesn't use local Docker, since we can use ACR Build instead.

Since Azure Container Registry (ACR) is completely private, we need to log in with `az acr login` in order to use the image we have built inside our registry. For public images, which we can access without authentication, we can use Docker Hub, where we have pushed a pre-built image available at: `aaronmsft/hello-echo`

Finally, Azure Container Registry enables you to automatically trigger image builds in the cloud [when you commit source code to a Git repository](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-build-task) or [when a container's base image is updated](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-base-image-update).

## Resources
- [How to Containerize Your Go Code](https://azure.microsoft.com/en-us/resources/how-to-containerize-your-go-code/en-us/) by Liz Rice ([@lizrice](https://twitter.com/lizrice))
- <https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-build>
- https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-build-task
