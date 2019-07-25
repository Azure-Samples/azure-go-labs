# Containerize a Go application using Visual Studio Code

This lab teaches you how to use [Visual Studio Code](https://code.visualstudio.com/)'s [Docker](https://code.visualstudio.com/docs/azure/docker#_install-the-docker-extension) extension to build a Docker container for an existing Go web application.

## Prerequisites

If you are **not** at an event, please see [REQUIREMENTS](REQUIREMENTS.md) to install the prerequisites for this lab.

The [Docker](https://code.visualstudio.com/docs/azure/docker#_install-the-docker-extension) extension also supports Docker running natively inside the [Windows Subsystem for Linux (WSL) 2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install) when using the [Remote (WSL)](https://code.visualstudio.com/docs/remote/wsl) extension for VS Code.

## Open workspace and build a development container

1. Open the lab folder with Visual Studio Code:

    ```bash
    cd 1-vscode-go-docker
    code-insiders .
    ```

1. Run `Ctrl-Shift-P` and type `Add Docker files to Workspace`.
1. Following the prompts select `Go` and port `8080`.
1. Change the `#build stage` lines in the Dockerfile **from**:

    ```Dockerfile
    RUN go get -d -v ./...
    RUN go install -v ./...
    ```

    **to**:

    ```Dockerfile
    RUN go build -o /go//bin/app .
    ```

1. Right-click on `Dockerfile` and click `Build Image...` to build your image. You will be prompted for an image name.
1. You will also see that a Docker Compose file has been created for you. Right-click on `docker-compose.yml` and click `Compose up`.
1. Open <http://localhost:8000>, or <http://wsl.local:8080> if **using WSL 2** (see: [REQUIREMENTS.md](REQUIREMENTS.md)), in the browser to view the app.

## View Containers, Images, Registries, Networks and Volumes in the Docker extension

1.  Run `Ctrl-Shift-P` and type `View: Show Docker`, or click on the Docker logo on the right-hand side to open the Docker extension.
1. View the **Container** you have just run at the top left. Right-click on it, and click `View Logs` to view the logs, `Stop` to stop the running container.
1. Under **Images**, click on the name of the container image you have just built, right-click on the tag `:latest` and click `Run Interactive` to run it. Press `Ctrl+C` to exit the running container (it will be removed automatically, as it was started with the `--rm` flag).
1. Under **Registries**, you will see any container registries we are authenciated to, and we can connect to any container registry, such as the [Azure Container Registry](https://code.visualstudio.com/tutorials/docker-extension/create-registry), Docker Hub, or any other locally or remotely hosted container registry.
1. Finally, you will also **Networks**, which can be created manually, or automatically via `docker-compose`, and **Volumes** if any are present on your machine.