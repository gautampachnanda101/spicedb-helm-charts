#!/bin/sh
set -e -x
function install_mkcert() {
  brew install mkcert
  brew install nss
  mkcert -install && mkcert "*.localhost" localhost 127.0.0.1 ::1
}
function install_traefik() {
    helm uninstall traefik -n traefik || true
    if ! helm repo list | grep -q 'https://traefik.github.io/charts'; then
            helm repo add traefik https://traefik.github.io/charts
    fi
    helm repo update
    kubectl delete namespace traefik || true
    kubectl create namespace traefik
    kubectl -n traefik create secret tls zerossl-ca  \
    --key "$(mkcert -CAROOT)"/rootCA-key.pem \
    --cert "$(mkcert -CAROOT)"/rootCA.pem
    kubectl apply -f ./traefik/helm/templates/traefik-certs.yaml -n traefik
    helm install traefik traefik/traefik --namespace traefik --values ./traefik/helm/values.yaml
    kubectl get pods -n traefik
    kubectl get svc -n traefik
    kubectl get ingress -n traefik
}
function add_cert_manager() {
    helm uninstall cert-manager -n cert-manager || true
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    kubectl delete namespace cert-manager || true
    kubectl create namespace cert-manager
    helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.10.0 --set installCRDs=true
    kubectl get pods --namespace cert-manager
}
function install_spicedb() {
  helm uninstall spicedb -n spicedb || true
  kubectl delete namespace spicedb || true
  kubectl create namespace spicedb
  # Validate the Helm chart
  helm dependency update ./spicedb/helm
  helm lint ./spicedb/helm --values ./spicedb/helm/values.yaml
  helm template ./spicedb/helm --values ./spicedb/helm/values.yaml > template.yaml
  helm install spicedb ./spicedb/helm --namespace spicedb -f ./spicedb/helm/values.yaml
}
function install_cluster_issuer() {
  kubectl delete secret cluster-ca-secret -n cert-manager || true
  kubectl create secret tls cluster-ca-secret \
  --key "$(mkcert -CAROOT)"/rootCA-key.pem \
  --cert "$(mkcert -CAROOT)"/rootCA.pem -n cert-manager
  kubectl apply -f ./cluster-issuer/cluster-issuer-mkcert.yaml
}
function install_spicedb_operator() {
  helm uninstall spicedb-operator -n spicedb-operator || true
  kubectl delete namespace spicedb-operator || true
  kubectl create namespace spicedb-operator
  helm install spicedb-operator ./helm/spicedb-operator  --namespace spicedb-operator
}
function install_spicedb_postgres() {
  helm uninstall spicedb-postgres -n spicedb-postgres || true
  kubectl delete namespace spicedb-postgres || true
  kubectl create namespace spicedb-postgres
  # Validate the Helm chart
  helm dependency update ./db/helm
  helm dependency build ./db/helm
  helm install spicedb-postgres ./db/helm  --namespace spicedb-postgres
}
function install_otel_lgtm() {
  helm uninstall otel-lgtm -n otel-lgtm || true
  kubectl delete namespace otel-lgtm || true
  kubectl create namespace otel-lgtm
  helm install otel-lgtm ./otel-lgtm/helm  --namespace otel-lgtm
}
kubectl version | brew install kubectl
kubectx -h  | brew install kubectx
kubectx | kubectx docker-desktop
install_mkcert
add_cert_manager
install_cluster_issuer
install_traefik
install_otel_lgtm
install_spicedb_operator
install_spicedb_postgres
install_spicedb