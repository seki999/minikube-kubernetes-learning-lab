# 04｜Deployment：副本、自恢复、滚动更新与回滚

[← 上一章](03-pod.md) · [首页](../README.md) · [下一章：Service →](05-service.md)

## 1. 控制器关系

```mermaid
flowchart LR
    D[Deployment] --> RS[ReplicaSet]
    RS --> P1[Pod 1]
    RS --> P2[Pod 2]
    RS --> P3[Pod 3]
```

Deployment 管理 ReplicaSet，ReplicaSet 保证 Pod 数量满足期望值。

## 2. 创建 Deployment

```powershell
kubectl apply -f manifests/02-deployment/web-deployment.yaml
kubectl get deployments
kubectl get replicasets
kubectl get pods -l app=web -o wide
```

## 3. 验证自恢复

先持续观察：

```powershell
kubectl get pods -l app=web -w
```

另开终端删除一个 Pod：

```powershell
kubectl delete pod -l app=web --field-selector=status.phase=Running --wait=false
```

更稳妥地删除指定 Pod：

```powershell
$pod = kubectl get pod -l app=web -o jsonpath='{.items[0].metadata.name}'
kubectl delete pod $pod
```

你会看到旧 Pod 消失，新 Pod 被 ReplicaSet 创建。

```mermaid
sequenceDiagram
    participant U as User
    participant P as Pod
    participant RS as ReplicaSet Controller
    participant N as New Pod
    U->>P: delete
    P-->>RS: 实际副本 2，期望副本 3
    RS->>N: 创建替代 Pod
    N-->>RS: Running / Ready
```

## 4. 手动扩缩容

```powershell
kubectl scale deployment web --replicas=5
kubectl get pods -l app=web
kubectl scale deployment web --replicas=3
```

## 5. 滚动更新

```powershell
kubectl set image deployment/web nginx=nginx:1.28
kubectl rollout status deployment/web
kubectl rollout history deployment/web
```

```mermaid
flowchart LR
    O[旧 ReplicaSet: nginx 1.27] --> A[逐渐减少旧 Pod]
    N[新 ReplicaSet: nginx 1.28] --> B[逐渐增加新 Pod]
    A --> C[服务不中断]
    B --> C
```

## 6. 制造错误并回滚

```powershell
kubectl set image deployment/web nginx=nginx:not-exist
kubectl rollout status deployment/web --timeout=60s
kubectl get pods
kubectl describe pod -l app=web
```

回滚：

```powershell
kubectl rollout undo deployment/web
kubectl rollout status deployment/web
```

## Dashboard 检查

`Workloads → Deployments → web`：

- Desired / Current / Available Replicas
- ReplicaSet 历史
- Pod Events
- Image 版本

## 本章验收

```powershell
kubectl get deploy web
```

`READY` 应为 `3/3`。


## 生命周期补充：删除、恢复与第二轮

> 注意：`kubectl set image` 和 `kubectl scale` 修改的是集群中的期望状态。想严格恢复实验初始状态，不要只靠一次 `apply`；先删除本章 Deployment，再重建。

```powershell
kubectl config current-context
kubectl delete -f manifests/02-deployment/web-deployment.yaml --wait=true
kubectl get deployment web -n learning --ignore-not-found
kubectl apply -f manifests/02-deployment/web-deployment.yaml
kubectl rollout status deployment/web -n learning --timeout=180s
kubectl get deployment web -n learning
# 再次执行本章扩缩、滚动更新、故障、回滚步骤
kubectl delete -f manifests/02-deployment/web-deployment.yaml --wait=true
kubectl get pods -n learning -l app=web
```

删除 `web` 会影响依赖它的 Service/Ingress 等其他实验；请不要在其他章节正在使用同一个 Deployment 时清理。独立的、不会与现有 `learning` 资源冲突的自动双轮样板见 `scripts/lifecycle-smoke.ps1`。
