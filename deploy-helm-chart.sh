#!/bin/sh
kubectl version | brew install kubectx kubectl
kubectx | kubectx docker-desktop
kubectl delete namespace spicedb-operator || true
kubectl create namespace spicedb-operator
helm install spicedb-operator ./helm/spicedb-operator  --namespace spicedb-operator