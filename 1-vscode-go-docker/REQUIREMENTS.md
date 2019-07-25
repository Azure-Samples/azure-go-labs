# REQUIREMENTS

- [Visual Studio Code](https://code.visualstudio.com/) (Insiders)
- [Docker](https://www.docker.com/products/docker-desktop) including [docker-compose](#Linux) on Linux.
- [Docker extension](https://code.visualstudio.com/docs/azure/docker#_install-the-docker-extension) for Visual Studio Code
- (Optional) [Windows Subsystem for Linux (WSL) 2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install) with the [Remote (WSL)](https://code.visualstudio.com/docs/remote/wsl) extension.

## Linux

On Linux systems, such as the Windows Subsytem for Linux (WSL) 2, you will need to [install](https://docs.docker.com/compose/install/) `docker-compose`, which can be done via the following command:

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Windows Subsystem for Linux (WSL) 2

For WSL 2 we will install [go-wsl2-host](https://github.com/shayne/go-wsl2-host) so we can open wsl.local.

You may need to run `services.msc` to ensure the service is starting and able to logon as a service with the user you have chosen. Afterwards, you can `cat C:\windows\System32\drivers\etc\hosts` to confirm the hosts entry has been added.
