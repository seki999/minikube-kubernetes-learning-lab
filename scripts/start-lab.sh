#!/usr/bin/env bash
set -euo pipefail
minikube version
kubectl version --client
minikube start --driver=docker --cpus=4 --memory=6144
minikube addons enable metrics-server
minikube addons enable ingress
kubectl create namespace learning --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=learning
kubectl get nodes -o wide
kubectl get pods -A
echo "Ready. Open README.md and begin chapter 00."
