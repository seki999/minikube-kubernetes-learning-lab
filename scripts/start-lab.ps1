$ErrorActionPreference = "Stop"
Write-Host "[1/5] Checking tools..."
minikube version
kubectl version --client
Write-Host "[2/5] Starting Minikube..."
minikube start --driver=docker --cpus=4 --memory=6144
Write-Host "[3/5] Enabling addons..."
minikube addons enable metrics-server
minikube addons enable ingress
Write-Host "[4/5] Creating namespace..."
kubectl create namespace learning --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=learning
Write-Host "[5/5] Cluster status..."
kubectl get nodes -o wide
kubectl get pods -A
Write-Host "Ready. Open README.md and begin chapter 00."
