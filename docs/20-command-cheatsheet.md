# 20｜Minikube 与 kubectl 命令速查

[← 上一章](19-troubleshooting-cleanup.md) · [首页](../README.md)

## Minikube

```powershell
minikube start --driver=docker --cpus=4 --memory=6144
minikube status
minikube addons list
minikube addons enable metrics-server
minikube addons enable ingress
minikube dashboard
minikube ip
minikube service <service> --url -n learning
minikube tunnel
minikube logs
minikube stop
minikube delete
```

## 查看资源

```powershell
kubectl get nodes -o wide
kubectl get pods -A
kubectl get all -n learning
kubectl get deploy,rs,pod,svc,ingress
kubectl get events --sort-by=.lastTimestamp
kubectl api-resources
kubectl explain deployment.spec.template.spec.containers
```

## 创建与删除

```powershell
kubectl apply -f file.yaml
kubectl apply -f directory/
kubectl delete -f file.yaml
kubectl delete pod <name>
kubectl delete namespace learning
```

## 调试

```powershell
kubectl describe pod <name>
kubectl logs <name>
kubectl logs <name> --previous
kubectl logs -f <name>
kubectl exec -it <name> -- sh
kubectl port-forward service/web-service 8080:80
kubectl top pods
```

## Deployment

```powershell
kubectl scale deployment web --replicas=5
kubectl set image deployment/web nginx=nginx:1.28
kubectl rollout status deployment/web
kubectl rollout history deployment/web
kubectl rollout undo deployment/web
kubectl rollout restart deployment/web
```

## 输出技巧

```powershell
kubectl get pods -o wide
kubectl get pod <name> -o yaml
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -l app=web
kubectl get pods --show-labels
```

## 权限

```powershell
kubectl auth can-i list pods
kubectl auth can-i --list
kubectl auth can-i delete pods --as=system:serviceaccount:learning:pod-reader -n learning
```
