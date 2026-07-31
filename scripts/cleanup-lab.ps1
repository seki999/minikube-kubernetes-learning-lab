$ErrorActionPreference = "Continue"
kubectl delete namespace learning
kubectl create namespace learning
kubectl config set-context --current --namespace=learning
Write-Host "learning namespace recreated."
