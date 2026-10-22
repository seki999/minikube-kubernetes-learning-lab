# 21｜生命周期审计与可重复实验验收

> 审计方式：仓库文档和命令静态检查。**未在真实 Minikube 中执行，不能宣称各章 PASS。**
>
> 本次改造分为“通用闭环样板”和“章节个性化闭环”。样板测试只覆盖独立 Deployment，不替代每章集成测试。

## 验收标准

1. 确认当前 Kubernetes Context 与实验 Namespace；拒绝误操作其他集群。
2. 全新创建实验资源，验证 Ready / Endpoint / 业务结果。
3. 修改运行状态并验证真实变化。
4. 触发可控故障，再回滚或修复。
5. 删除并核查没有实验残留（PVC、PV、Job、ClusterRole 和 Minikube Profile 等需单独核查）。
6. 从干净状态重复两轮，结果一致，不影响其他实验。
7. 明确区分“静态检查”与真实运行验证；支持异步收敛的资源需等待再断言。

## 已实现的通用最小闭环

Windows PowerShell，从仓库根目录执行：

```powershell
./scripts/lifecycle-smoke.ps1 -Mode Check
./scripts/lifecycle-smoke.ps1 -Mode Run
```

脚本限定 `minikube` Context，强制新建 `lab-` 开头且不存在的 Namespace，完整运行两轮 Deployment 创建、扩容、镜像更新、回滚、删除、验证，最后删除专用 Namespace。遇到残留 Namespace 会拒绝操作，而不是自动删除用户资源。

若需保留测试空间用于检查，可在运行时添加 `-Keep`；保留后再次运行必须指定新的 Namespace。真实执行前请确认 Docker、网络和 Nginx 镜像拉取均可用。

## 各章审计状态

| 章节 | 创建 | 读取 | 修改/故障 | 恢复 | 删除 | 两轮实测 | 当前结论 |
|---|---|---|---|---|---|---|---|
| 02 Namespace | 有 | 有 | 待完善 | 待完善 | 新增步骤 | 未执行 | PARTIAL |
| 03 Pod | 有 | 有 | 删除观察 | 重建 | 有 | 未执行 | PARTIAL |
| 04 Deployment | 有 | 有 | 有 | 有 | 新增步骤 | 未执行 | PARTIAL |
| 05 Service | 有 | 有 | 删除 Pod 验证 | Controller 恢复 | 新增步骤 | 未执行 | PARTIAL |
| 06 ConfigMap / Secret | 有 | 有 | 待补动态更新验证 | 待完善 | 待完善 | 未执行 | PARTIAL |
| 07 PV/PVC | 有 | 有 | 重建 Pod | 数据保留 | 待完善 | 未执行 | PARTIAL |
| 08 Probe | 有 | 有 | 待补故障注入 | 待完善 | 待完善 | 未执行 | PARTIAL |
| 09 Resources | 有 | 有 | 待补压力验证 | 待完善 | 待完善 | 未执行 | PARTIAL |
| 10 HPA | 有 | 有 | 负载扩缩 | 停止负载 | 待完善 | 未执行 | PARTIAL |
| 11 Ingress | 有 | 有 | 待补修改规则 | 待完善 | 待完善 | 未执行 | PARTIAL |
| 12 RBAC | 有 | 有 | 权限验证 | 待完善 | 待完善 | 未执行 | PARTIAL |
| 13 Job/CronJob | 有 | 有 | 触发 Job | 待完善 | 待完善 | 未执行 | PARTIAL |
| 14 StatefulSet | 有 | 有 | 删除 Pod | 控制器恢复 | PVC 清理待验 | 未执行 | PARTIAL |
| 15 DaemonSet | 有 | 有 | 多 Node 观察 | 待完善 | Profile 清理待验 | 未执行 | PARTIAL |
| 16 NetworkPolicy | 有 | 有 | 访问控制实验 | 待完善 | Profile 清理待验 | 未执行 | PARTIAL |
| 18 综合实验 | 有 | 有 | 有 | 有 | 待完善 | 未执行 | PARTIAL |

## 风险清单

- YAML 中多个资源固定在 `learning` Namespace，不能简单使用 `-n` 就认为隔离；需要逐项检查 `metadata.namespace`。
- Service/Ingress/NetworkPolicy 等可能依赖其他章节的 Deployment，独立运行应先准备所需资源。
- PVC/PV 的 `reclaimPolicy` 与 StatefulSet `volumeClaimTemplates` 数据删除要分开判断。
- HPA 与手动 scale、`kubectl set image` 与 YAML `apply` 存在声明式/运行时状态差异。
- 不能把 `minikube delete --all` 作为普通章节清理步骤。
- 在本地无集群的环境中只能报告 `STATIC PASS` 或 `未执行`，不得伪报集成测试通过。

## 后续真正完成全章 PASS 的条件

针对每章建立隔离清单，补齐真实预期结果与最终删除断言，逐章在 Minikube 下连续执行两轮，并保存错误日志和复测证据。
