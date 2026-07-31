#!/usr/bin/env bash
set -euo pipefail
kubectl delete namespace learning --ignore-not-found
kubectl create namespace learning
kubectl config set-context --current --namespace=learning
