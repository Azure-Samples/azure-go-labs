# REQUIREMENTS

- Windows 10 ([Insiders](https://insider.windows.com/en-us/previews-highlights/) "Fast Ring", build 18917 or higher)
- [Visual Studio Code (Insiders)](https://code.visualstudio.com/insiders)
- [Windows Terminal](https://github.com/microsoft/terminal) from the Microsoft Store
- [Windows Subsystem for Linux (WSL) 2](https://aka.ms/wsl2)
  - Open optional windows features and select `WSL` and `Virtual Machine Platform`.  NOTE: This will require a system reboot
- Ubuntu 18.04 for WSL in the [Microsoft Store](https://www.microsoft.com/en-us/p/ubuntu-1804-lts/9n9tngvndl3q)
    - for the lab set the username to "user" and password "user"
    - migrate this distro to WSL 2 from a cmd window by running  `wsl --set-version Ubuntu-18.04 2` 
- `tmux` (install via: `sudo apt install -y tmux`)
- [hey](https://github.com/rakyll/hey)
- [Remote (WSL)](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension for VS Code.
- In Ubuntu shell install utilities `sudo apt install cmatrix caca-utils htop`
- `Ubuntu Mono` font from <https://fonts.google.com/specimen/Ubuntu+Mono>

## Windows Subsystem for Linux (WSL) 2

For WSL 2 we will install [go-wsl2-host](https://github.com/shayne/go-wsl2-host) so we can open wsl.local.

You may need to run `services.msc` to ensure the service is starting and able to logon as a service with the user you have chosen. Afterwards, you can `cat C:\windows\System32\drivers\etc\hosts` to confirm the hosts entry has been added.

## Cleanup
- Close all running Terminal or Code windows
- Delete terminal profile file (see: [CLEANUP.sh](CLEANUP.sh)): 
  - ```C:\Users\[USERNAME]\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\profiles.json```
