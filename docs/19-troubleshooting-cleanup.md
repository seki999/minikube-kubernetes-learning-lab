# 19｜故障排查顺序与环境清理

[← 上一章](18-capstone-lab.md) · [首页](../README.md) · [下一章：命令速查 →](20-command-cheatsheet.md)

## 通用排错漏斗

```mermaid
flowchart TD
    A[应用不可用] --> B[kubectl get: 资源存在吗?]
    B --> C[kubectl describe: Events 说了什么?]
    C --> D[kubectl logs: 应用报错吗?]
    D --> E[Pod Ready 吗?]
    E --> F[Service selector 匹配吗?]
    F --> G[EndpointSlice 有 Pod IP 吗?]
    G --> H[Ingress / DNS / Port 正确吗?]
    H --> I[Node / CNI / Storage / RBAC]
```

## 高频状态

| 状态 | 常见原因 | 首选命令 |
|---|---|---|
| Pending | 资源不足、PVC 未绑定、调度约束 | `kubectl describe pod` |
| ImagePullBackOff | 镜像名、Tag、网络、Registry 凭证 | `kubectl describe pod` |
| CrashLoopBackOff | 进程启动后退出、配置错误、探针错误 | `kubectl logs --previous` |
| Running 但不 Ready | Readiness Probe 失败 | `kubectl describe pod` |
| Service 无 Endpoint | selector 错误或 Pod 不 Ready | `kubectl get endpointslices` |
| OOMKilled | 内存 limit 太低或内存泄漏 | `kubectl describe pod` |

## 常用诊断命令

```powershell
kubectl get all
kubectl get events --sort-by=.lastTimestamp
kubectl describe pod <pod>
kubectl logs <pod>
kubectl logs <pod> --previous
kubectl exec -it <pod> -- sh
kubectl get pod <pod> -o yaml
kubectl auth can-i <verb> <resource>
minikube logs
```

## 清理单章资源

```powershell
kubectl delete -f manifests/08-hpa/
```

## 清理 learning Namespace

```powershell
kubectl delete namespace learning
kubectl create namespace learning
kubectl config set-context --current --namespace=learning
```

## 停止与删除 Minikube

保留集群数据并停止：

```powershell
minikube stop
```

彻底删除：

```powershell
minikube delete
```

删除所有 profile：

```powershell
minikube delete --all
```

## 最后的学习判断

真正掌握不是“所有命令都成功”，而是看到失败时能沿着：对象 → 状态 → Events → Logs → 网络/存储/权限 的顺序定位原因。


## 删除范围安全守则

- `kubectl delete namespace learning` 会删除该 Namespace 内所有实验及其他可能存在的资源，不是安全的单章清理方式。
- `minikube delete --all` 会删除**所有** Minikube Profiles，只能在明确要重置整个实验环境时手工使用。
- 清理前确认 `kubectl config current-context`，检查 `kubectl get all,configmaps,secrets,pvc,ingress,networkpolicy -n learning`。
- `kubectl get all` 不包含所有资源类型；PVC、Secret、ConfigMap、Ingress、RBAC、NetworkPolicy、PV 等需要额外查看。
- 单独实验优先使用新建的专属 Namespace，脚本不得删除原本存在的 Namespace。

### 自动双轮烟雾测试

从项目根目录运行：

```powershell
./scripts/lifecycle-smoke.ps1 -Mode Check
./scripts/lifecycle-smoke.ps1 -Mode Run
```

此脚本只为独立 Deployment 演示提供真实运行入口；其余章节的状态见 [生命周期审计](21-lifecycle-audit-report.md)。
