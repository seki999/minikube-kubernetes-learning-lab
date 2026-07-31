# Minikube Kubernetes 从零实践教程

> 在一台本地电脑上，从空白 Minikube 集群开始，逐步理解并搭建 Pod、Deployment、Service、ConfigMap、Secret、存储、探针、资源限制、HPA、Ingress、RBAC、Job、StatefulSet、DaemonSet 与 NetworkPolicy，并在 Dashboard / Headlamp 中逐项确认。

## 适合谁

- 已经安装 Minikube，希望系统学习 Kubernetes 的开发者
- 希望把命令行操作、YAML 和图形界面结合起来学习的人
- 希望得到一个可直接放到 GitHub 的实验项目的人

## 学习路线

```mermaid
flowchart LR
    A[确认本地环境] --> B[启动 Minikube]
    B --> C[理解集群架构]
    C --> D[Pod]
    D --> E[Deployment]
    E --> F[Service]
    F --> G[配置与 Secret]
    G --> H[持久化存储]
    H --> I[健康检查]
    I --> J[资源与 HPA]
    J --> K[Ingress]
    K --> L[RBAC]
    L --> M[Job / StatefulSet / DaemonSet]
    M --> N[NetworkPolicy]
    N --> O[Dashboard / Headlamp 验证]
    O --> P[综合实验与故障排查]
```

## 推荐学习方式

每一章都按同一个闭环执行：

```mermaid
flowchart LR
    A[先理解概念] --> B[阅读 YAML]
    B --> C[kubectl apply]
    C --> D[kubectl get / describe / logs]
    D --> E[浏览器访问应用]
    E --> F[Dashboard / Headlamp 确认]
    F --> G[主动制造变化或故障]
    G --> H[观察 Kubernetes 如何处理]
```

## 目录

| 阶段 | 章节 | 目标 |
|---|---|---|
| 准备 | [00 环境确认](docs/00-environment-check.md) | 确认 Minikube、kubectl、Docker/驱动可用 |
| 基础 | [01 架构与启动](docs/01-cluster-start-and-architecture.md) | 启动集群并理解控制面、Node、Pod |
| 基础 | [02 Namespace](docs/02-namespace.md) | 隔离实验资源 |
| 工作负载 | [03 Pod](docs/03-pod.md) | 创建最小运行单元 |
| 工作负载 | [04 Deployment](docs/04-deployment.md) | 副本、自恢复、滚动更新与回滚 |
| 网络 | [05 Service](docs/05-service.md) | 稳定入口与服务发现 |
| 配置 | [06 ConfigMap 与 Secret](docs/06-configmap-secret.md) | 配置和敏感数据解耦 |
| 存储 | [07 Volume、PV、PVC](docs/07-storage.md) | 理解临时与持久化数据 |
| 可靠性 | [08 健康检查](docs/08-probes.md) | Startup、Readiness、Liveness |
| 资源 | [09 Requests、Limits、QoS](docs/09-resources.md) | CPU/内存管理 |
| 扩缩容 | [10 HPA](docs/10-hpa.md) | 根据指标自动扩缩容 |
| 入口 | [11 Ingress](docs/11-ingress.md) | 基于域名和路径访问服务 |
| 安全 | [12 ServiceAccount 与 RBAC](docs/12-rbac.md) | 最小权限控制 |
| 批处理 | [13 Job 与 CronJob](docs/13-job-cronjob.md) | 一次性和定时任务 |
| 有状态 | [14 StatefulSet](docs/14-statefulset.md) | 稳定身份和独立存储 |
| 节点级 | [15 DaemonSet](docs/15-daemonset.md) | 每个 Node 运行一个 Pod |
| 网络安全 | [16 NetworkPolicy](docs/16-networkpolicy.md) | 限制 Pod 间通信 |
| 图形界面 | [17 Dashboard 与 Headlamp](docs/17-dashboard-headlamp.md) | 在 UI 中确认资源与状态 |
| 综合 | [18 综合实验](docs/18-capstone-lab.md) | 串联主要知识点 |
| 运维 | [19 故障排查与清理](docs/19-troubleshooting-cleanup.md) | 形成排错顺序并清理环境 |
| 速查 | [命令速查表](docs/20-command-cheatsheet.md) | 常用 kubectl / Minikube 命令 |

## 项目结构

```text
minikube-kubernetes-learning-lab/
├─ README.md
├─ docs/                 # 分章节教程
├─ manifests/            # 可直接 apply 的 YAML
│  ├─ 01-pod/
│  ├─ 02-deployment/
│  ├─ 03-service/
│  └─ ...
├─ scripts/              # Windows PowerShell 与 Bash 辅助脚本
├─ LICENSE
└─ .gitignore
```

## 一键开始

Windows PowerShell：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./scripts/start-lab.ps1
```

Bash：

```bash
chmod +x scripts/*.sh
./scripts/start-lab.sh
```

然后从 [00 环境确认](docs/00-environment-check.md) 开始。

## 版本与 Dashboard 说明

Kubernetes Dashboard 项目在 2026 年已经归档。为了保证教程可持续使用，本项目提供两条图形界面路线：

1. `minikube dashboard`：适合快速学习和本地确认。
2. Minikube Headlamp 插件：更推荐的新方案。

图形界面只是观察和辅助操作工具；真正需要掌握的仍然是 Kubernetes API 对象、YAML 与 `kubectl`。

## 安全提醒

本项目的 `cluster-admin` 示例只用于个人本地 Minikube 实验。不要在生产集群直接复制使用。
