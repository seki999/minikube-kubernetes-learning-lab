# 18｜综合实验：搭建一个可扩缩、可配置、可观察的 Web 应用

[← 上一章](17-dashboard-headlamp.md) · [首页](../README.md) · [下一章：故障排查与清理 →](19-troubleshooting-cleanup.md)

## 最终架构

```mermaid
flowchart TB
    U[Browser] --> I[Ingress]
    I --> S[Service]
    S --> P1[Web Pod 1]
    S --> P2[Web Pod 2]
    S --> P3[Web Pod N]
    CM[ConfigMap] --> P1
    CM --> P2
    SEC[Secret] --> P1
    SEC --> P2
    H[HPA] --> D[Deployment]
    D --> P1
    D --> P2
    M[Metrics Server] --> H
    PVC[(PVC)] --> P1
```

## 阶段 1：创建

```powershell
kubectl config set-context --current --namespace=learning
kubectl apply -f manifests/04-config/
kubectl apply -f manifests/05-storage/pvc.yaml
kubectl apply -f manifests/02-deployment/web-deployment.yaml
kubectl apply -f manifests/03-service/web-service.yaml
kubectl apply -f manifests/09-ingress/
```

> 部分示例资源是独立教学用途，名称可能不同。综合实验重点是自己根据前面章节把配置、探针和资源字段加入 Deployment。

## 阶段 2：验证资源链

```powershell
kubectl get deploy,rs,pod,svc,ingress,cm,secret,pvc
kubectl get endpointslices
kubectl get events --sort-by=.lastTimestamp
```

## 阶段 3：自恢复实验

```powershell
$pod = kubectl get pod -l app=web -o jsonpath='{.items[0].metadata.name}'
kubectl delete pod $pod
kubectl get pods -l app=web -w
```

记录：删除前 Pod 名、删除后新 Pod 名、恢复时间、Service 是否中断。

## 阶段 4：滚动升级与回滚

```powershell
kubectl set image deployment/web nginx=nginx:1.28
kubectl rollout status deployment/web
kubectl set image deployment/web nginx=nginx:not-found
kubectl rollout status deployment/web --timeout=45s
kubectl rollout undo deployment/web
```

## 阶段 5：在 UI 中复核

- Deployment 副本变化
- ReplicaSet 历史
- Pod Image 与 Restart Count
- Service Endpoint
- Ingress Backend
- Events 中的拉取失败和回滚结果

## 完成标准

```mermaid
flowchart LR
    A[命令执行成功] --> B[资源状态正确]
    B --> C[应用可以访问]
    C --> D[故障后可恢复]
    D --> E[UI 与 kubectl 看到相同事实]
    E --> F[能够解释每个控制器为何采取动作]
```


## 重要：生命周期验收与清理

本章目前仍需读者自行合并 YAML，因此**不能视为全自动、可独立双轮执行的完整实验**。完成验证后，须逐项确认本轮创建的资源：Ingress、Service、Deployment、ConfigMap、Secret、PVC、HPA，以及任何临时 Pod。

先运行：

```powershell
kubectl config current-context
kubectl get deployments,pods,services,ingress,configmaps,secrets,pvc,hpa -n learning
```

不要直接删除共享 Namespace，也不要为了清理综合实验删除其他章节仍在使用的对象。确认为本轮独占的清单时，可按反向依赖顺序运行相应的 `kubectl delete -f manifests/...`，并再次 `kubectl get` 确认。数据卷另外检查 PV 回收策略。第二轮从干净状态重新执行阶段 1–5。完整双轮自动样板见 `scripts/lifecycle-smoke.ps1`。
