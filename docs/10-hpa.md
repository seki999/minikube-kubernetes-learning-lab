# 10｜HPA：根据指标自动扩缩容

[← 上一章](09-resources.md) · [首页](../README.md) · [下一章：Ingress →](11-ingress.md)

## 工作原理

```mermaid
flowchart LR
    M[Metrics Server] --> H[HPA Controller]
    H --> D[Deployment scale 子资源]
    D --> R[ReplicaSet]
    R --> P[Pods]
    P --> M
```

简化理解：

```text
期望副本数 ≈ 当前副本数 × 当前指标 / 目标指标
```

## 1. 确认 Metrics Server

```powershell
minikube addons enable metrics-server
kubectl top nodes
```

## 2. 创建应用、Service 与 HPA

```powershell
kubectl apply -f manifests/08-hpa/
kubectl get deploy,svc,hpa
```

持续观察：

```powershell
kubectl get hpa -w
```

## 3. 制造负载

另开终端：

```powershell
kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
```

观察：

```powershell
kubectl get hpa
kubectl get pods -l run=php-apache
```

停止负载：

```powershell
kubectl delete pod load-generator
```

缩容有稳定窗口，不会立刻降下来。

```mermaid
sequenceDiagram
    participant L as Load
    participant P as Pods
    participant M as Metrics Server
    participant H as HPA
    participant D as Deployment
    L->>P: 请求增加
    P->>M: CPU 使用率升高
    M->>H: 提供指标
    H->>D: replicas 增加
    D->>P: 创建更多 Pod
```

## Dashboard / Headlamp 检查

查看 HPA 当前指标、目标值、最小/最大副本和 Deployment 副本变化。

## 常见失败

`TARGETS` 显示 `<unknown>`：

- Metrics Server 尚未准备好
- Pod 没有设置 CPU request
- 指标采集需要等待

## 本章验收

在负载下看到副本数从 1 增加，停止负载后最终回落。


## 生命周期检查：清理与重复

本章创建的 HPA 演示 Deployment/Service/HPA 应执行“创建 → 状态验证 → 修改/观察 → 恢复 → 删除 → 确认删除 → 再创建”两轮。删除临时 load-generator，再删除 HPA 及其专用 Deployment；metrics-server 属于共享插件，不作为每轮实验默认删除。

从项目根目录、确认当前 Context 为 `minikube` 且实验对象归本章所有后，使用下列清理样板：

```powershell
kubectl config current-context
kubectl delete -f manifests/08-hpa/ --ignore-not-found --wait=true
kubectl apply -f manifests/08-hpa/
# 按本章上文执行状态检查及业务验证，再次运行同样的清理命令
```

**注意：**这只是清单对应资源的删除/重建示例，不代表完成了全章集成测试。若清单依赖其他章节的资源，应先检查依赖；对集群外进程、动态创建的 PVC/Job/Pod、以及同 Namespace 的共享对象，应逐项检查归属和残留。请参阅 [生命周期审计](21-lifecycle-audit-report.md)，其中所有尚未实际运行的章节仍标记为 PARTIAL。
