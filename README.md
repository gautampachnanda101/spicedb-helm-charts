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
- kubectx
- make command
- Docker Desktop , with kubernetes cluster enabled
- traeffik ingress controller
- Postgres database
- Authzed tools installed for verification
- [spicedb-operator](https://github.com/authzed/spicedb-operator) build locally helm chart


Once you have docker-desktop running, with kubernetes cluster, you can install the spicedb-operator helm chart using the following steps:
This with assumption have dependencies installed and running.


**Setup a .env file with the following values:**

```.env
GITHUB_TOKEN=<github-token>
```

**To install the helm chart, run the following command:**

```makefile
make deploy-local
```

## To Do
Fix ingress/[traefik](https://traefik.io/) configuration to expose the service to the outside world.