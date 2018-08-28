# Use a Go proxy!

In this exercise you'll use the proxy created [previously](./README.md) or
<https://microsoftgoproxy.azurewebsites.net/> to cache and serve packaged Go
modules. If you created your own proxy, substitute its short name for
`microsoftgoproxy` in the URL hostname in this exercise.

* Browse <https://microsoftgoproxy.azurewebsites.net>  to see a basic page.
* Browse <https://microsoftgoproxy.azurewebsites.net/github.com/!azure/azure-sdk-for-go/@v/list> to see a list of available module versions for `github.com/Azure/azure-sdk-for-go`.
  * Notice that capital letters in the package path are lowered and preceded by a `!`.
  * Notice that all versions for this module are suffixed with `+incompatible`,
    since a go.mod file has not yet been added to this repo.
* Browse
  <https://microsoftgoproxy.azurewebsites.net/github.com/google/go-cloud/@latest>.
  This will return a JSON document describing the latest release of the
  go-cloud package.
* Browse
  <https://microsoftgoproxy.azurewebsites.net/github.com/google/go-cloud/@v/v0.1.1.zip>
  to download an archive with the module.

Now let's try our proxy with the `go` command. Make sure you have Go 1.11+ for module support.

* In a terminal:

```bash
git clone https://github.com/joshgav/go-sample
cd go-sample
GOPROXY=https://microsoftgoproxy.azurewebsites.net GO111MODULE=on go get -v
```

This will update dependencies via the specified proxy and create `go.mod` and
`go.sum` files. Check them out: `cat go.mod`.

## Extras

Browse to the [Azure Portal](https://portal.azure.com) and open your resource
group. Check out the CosmosDB databases and App Service web apps running your
proxy!
