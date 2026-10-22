# 16｜NetworkPolicy：限制 Pod 间网络通信

[← 上一章](15-daemonset.md) · [首页](../README.md) · [下一章：Dashboard / Headlamp →](17-dashboard-headlamp.md)

## 默认网络模型

在没有策略时，Pod 通常可以彼此通信。NetworkPolicy 用标签选择 Pod，并规定允许的 Ingress / Egress。

```mermaid
flowchart LR
    A[allowed-client] -->|允许| W[web Pod]
    B[blocked-client] -.拒绝.-> W
```

## 重要前提

NetworkPolicy 必须由支持它的 CNI 网络插件执行。某些 Minikube 默认网络配置不会真正阻断流量。

可创建使用 Calico 的独立 profile：

```powershell
minikube start -p policy-lab --driver=docker --network-plugin=cni --cni=calico
```

## 创建实验

```powershell
kubectl apply -f manifests/14-networkpolicy/
```

策略前测试：

```powershell
kubectl exec allowed-client -- wget -qO- --timeout=3 http://network-web
kubectl exec blocked-client -- wget -qO- --timeout=3 http://network-web
```

应用策略后，只有带 `access=allowed` 标签的客户端可访问。

```mermaid
flowchart TD
    P[进入 web Pod 的请求] --> L{来源 Pod 标签 access=allowed?}
    L -- 是 --> Y[允许 TCP 80]
    L -- 否 --> N[拒绝]
```

## 验证策略是否被执行

```powershell
kubectl get networkpolicy
kubectl describe networkpolicy allow-labeled-clients
```

如果 blocked-client 仍能访问，通常不是 YAML 无效，而是当前 CNI 不执行 NetworkPolicy。

## 本章验收

理解 NetworkPolicy 是“允许列表”，并能识别 CNI 支持是生效前提。


## 纠正：真正的策略前后对照

上面的 YAML 目录可能同时包含 NetworkPolicy。要测量“应用前允许、应用后拒绝”，必须在添加 NetworkPolicy **之前**先创建 Web、Service、两个客户端并测通，不能先 `apply` 整个目录后才称为“策略前”。建议将策略资源与演示工作负载拆为不同 YAML，或逐一应用，并检查对象类型。

本章还需要在正确的 `policy-lab` Context 中验证，且确保该 Profile 使用支持 NetworkPolicy 的 CNI。操作前运行 `kubectl config current-context`；确认不再需要独立实验集群后，可手动运行 `minikube delete -p policy-lab`，不要使用 `minikube delete --all`。删除完切回 `minikube` 并检查 Context。**当前章节的前后对照和两轮真实集成验证仍待补齐，不应视为通过。**
