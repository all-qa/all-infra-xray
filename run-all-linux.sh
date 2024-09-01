#!/bin/bash

infoMessage() {
  echo "$(tput setaf 4)$1$(tput sgr 0)"
}

infoMessage "Creating cluster"
curl -Lo ./k8s/kind/kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-linux-amd64
chmod +x ./k8s/kind/kind
./k8s/kind/kind create cluster --config k8s/kind/extra-mounts.yaml --image kindest/node:v1.25.0

infoMessage "Setting kind-kind context"
kubectl config use-context kind-kind

infoMessage "Creating namespaces"
kubectl create namespace selenium-grid
kubectl create namespace jenkins
kubectl create namespace jira

infoMessage "Creating k8s resources"
kubectl create -f k8s/selenium-grid/
kubectl create -f k8s/jenkins/
kubectl create -f k8s/jira/jira-postgres

infoMessage "Waiting postgres for jira rollout"
kubectl -n jira rollout status deployment postgres
kubectl create -f k8s/jira/

infoMessage "Waiting for services rollout"
kubectl -n selenium-grid rollout status deployment selenium-router
kubectl -n jenkins rollout status deployment jenkins
kubectl -n jira rollout status deployment jira

infoMessage "Port forwarding services"
kubectl -n selenium-grid port-forward service/selenium-router 4444:4444 >/dev/null 2>&1 &
kubectl -n jenkins port-forward service/jenkins 8080:8080 >/dev/null 2>&1 &
kubectl -n jira port-forward service/jira 8081:8080 >/dev/null 2>&1 &