#!/bin/sh
function install_traefik() {
    helm repo add traefik https://traefik.github.io/charts
    helm repo update
    kubectx docker-desktop
    kubectl create namespace traefik
    helm install traefik traefik/traefik --namespace traefik
    kubectl get pods -n traefik
    kubectl get svc -n traefik
}
function add_cert_manager() {
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    kubectl create namespace cert-manager
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.10.0 --set installCRDs=true
    kubectl get pods --namespace cert-manager
}
function install_spicedb() {
  kubectl delete namespace spicedb || true
  kubectl create namespace spicedb
  # Validate the Helm chart
  pwd
  helm dependency update ./spicedb/helm
  helm lint ./spicedb/helm --values ./spicedb/helm/values.yaml
  helm install spicedb ./spicedb/helm --namespace spicedb -f ./spicedb/helm/values.yaml
}
function install_cluster_issuer() {
  brew install mkcert
  brew install nss
  mkcert -install && mkcert "*.localhost" localhost 127.0.0.1 ::1
  kubectl create secret tls cluster-ca-secret \
  --key "$(mkcert -CAROOT)"/rootCA-key.pem \
  --cert "$(mkcert -CAROOT)"/rootCA.pem -n cert-manager
  kubectl apply -f ./cluster-issuer/cluster-issuer-mkcert.yaml
}
function install_spicedb_operator() {
  kubectl delete namespace spicedb-operator || true
  kubectl create namespace spicedb-operator
  helm install spicedb-operator ./helm/spicedb-operator  --namespace spicedb-operator
}
kubectl version | brew install kubectx kubectl
kubectx | kubectx docker-desktop
install_traefik
add_cert_manager
install_cluster_issuer
install_spicedb_operator
install_spicedb