# Try out a Go modules proxy

With the introduction of modules in Go 1.11 you can manage your dependencies
via a shared caching proxy. [Project Athens](https://github.com/gomods/athens)
is an open source project to provide just such a proxy :)

In these labs you'll deploy and test out a Go proxy hosted by Azure App Service.
App Service offers a managed platform for running functions, servers and
containers. We'll deploy the Athens proxy in a container.

After the app is ready, you'll try out your new proxy with go. Or just [skip to
trying things out](./USE.md) with Microsoft's preconfigured proxy.

1. [Set up a Go modules proxy](./DEPLOY.md)
2. [Use a Go modules proxy](./USE.md)

