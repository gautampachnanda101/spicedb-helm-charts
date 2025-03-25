# spicedb-helm-charts
Repo to create helm chart for spicedb using bundle

You can the make command to create the helm chart for [spicedb-operator](https://github.com/authzed/spicedb-operator)


```makefile
make build-chart
```
## Installation
Pre-requisite:
- Helm v3
- Kubernetes cluster (Docker Desktop)
- kubectl
- [spicedb-operator](https://github.com/authzed/spicedb-operator) build locally helm chart
- kubectx

```makefile
make deploy-chart
```