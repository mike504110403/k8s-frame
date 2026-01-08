# Kubernetes (K8s) 學習框架

這是一個簡單但完整的 Kubernetes 學習框架，涵蓋最常用的資源類型和實踐。

## 📚 目錄

- [什麼是 Kubernetes？](#什麼是-kubernetes)
- [核心概念](#核心概念)
- [快速開始](#快速開始)
- [框架結構](#框架結構)
- [使用指南](#使用指南)
- [常用命令](#常用命令)

## 什麼是 Kubernetes？

Kubernetes (K8s) 是一個開源的容器編排平台，用於自動化容器化應用程式的部署、擴展和管理。

### 為什麼使用 K8s？

- **自動化部署**：自動在集群中部署容器
- **自我修復**：自動重啟失敗的容器
- **水平擴展**：根據負載自動擴展應用程式
- **服務發現和負載均衡**：自動分配流量
- **滾動更新和回滾**：零停機時間更新應用程式

## 核心概念

### 1. **Pod** 🏠
- K8s 中最小的部署單位
- 包含一個或多個容器
- 共享網絡和存儲資源

### 2. **Deployment** 🚀
- 管理 Pod 的副本數量
- 處理滾動更新和回滾
- 確保指定數量的 Pod 始終運行

### 3. **Service** 🌐
- 為 Pod 提供穩定的網絡端點
- 負載均衡流量到多個 Pod
- 類型：ClusterIP、NodePort、LoadBalancer

### 4. **ConfigMap** ⚙️
- 存儲非敏感的配置數據
- 將配置與應用程式代碼分離

### 5. **Secret** 🔒
- 存儲敏感信息（密碼、token、密鑰）
- Base64 編碼

### 6. **Ingress** 🚪
- 管理外部訪問集群內服務的 HTTP/HTTPS 路由
- 提供負載均衡、SSL 終止、基於名稱的虛擬主機

### 7. **Namespace** 📦
- 提供資源隔離的邏輯分組
- 適合多團隊或多環境（dev、staging、prod）

## 快速開始

### 前置需求

1. **安裝 kubectl**：K8s 命令行工具
   ```bash
   # macOS
   brew install kubectl
   
   # Linux
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   ```

2. **本地 K8s 環境**（選擇一個）：
   - **Minikube**：單節點集群
     ```bash
     brew install minikube
     minikube start
     ```
   - **Docker Desktop**：內建 K8s 支持
   - **Kind**：Docker 中的 K8s
     ```bash
     brew install kind
     kind create cluster
     ```

### 驗證安裝

```bash
# 檢查 kubectl 版本
kubectl version --client

# 檢查集群連接
kubectl cluster-info

# 查看節點
kubectl get nodes
```

## 框架結構

```
k8s-frame/
├── README.md                          # 本文件
├── manifests/                         # K8s 配置文件
│   ├── 01-namespace.yaml             # 命名空間
│   ├── 02-configmap.yaml             # 配置映射
│   ├── 03-secret.yaml                # 密鑰
│   ├── 04-deployment.yaml            # 部署
│   ├── 05-service.yaml               # 服務
│   ├── 06-ingress.yaml               # 入口
│   └── 07-hpa.yaml                   # 水平自動擴展
├── examples/                          # 實際應用範例
│   ├── nginx-app/                    # Nginx 範例
│   └── nodejs-app/                   # Node.js 範例
└── scripts/                           # 實用腳本
    ├── deploy.sh                     # 部署腳本
    ├── cleanup.sh                    # 清理腳本
    └── check-status.sh               # 狀態檢查腳本
```

## 使用指南

### 步驟 1：創建命名空間

```bash
kubectl apply -f manifests/01-namespace.yaml
```

命名空間提供資源隔離，適合區分不同環境。

### 步驟 2：創建 ConfigMap 和 Secret

```bash
kubectl apply -f manifests/02-configmap.yaml
kubectl apply -f manifests/03-secret.yaml
```

- **ConfigMap**：存儲應用程式配置
- **Secret**：存儲敏感信息

### 步驟 3：部署應用程式

```bash
kubectl apply -f manifests/04-deployment.yaml
```

Deployment 會創建指定數量的 Pod 副本。

### 步驟 4：創建 Service

```bash
kubectl apply -f manifests/05-service.yaml
```

Service 為 Pod 提供穩定的網絡訪問。

### 步驟 5：配置 Ingress（可選）

```bash
kubectl apply -f manifests/06-ingress.yaml
```

Ingress 提供外部 HTTP/HTTPS 訪問。

### 一鍵部署所有資源

```bash
kubectl apply -f manifests/
```

或使用提供的腳本：

```bash
./scripts/deploy.sh
```

## 常用命令

### 查看資源

```bash
# 查看所有 Pod
kubectl get pods -n my-app

# 查看 Pod 詳細信息
kubectl describe pod <pod-name> -n my-app

# 查看 Pod 日誌
kubectl logs <pod-name> -n my-app

# 實時查看日誌
kubectl logs -f <pod-name> -n my-app

# 查看所有 Deployment
kubectl get deployments -n my-app

# 查看所有 Service
kubectl get services -n my-app

# 查看所有資源
kubectl get all -n my-app
```

### 進入容器

```bash
# 執行命令
kubectl exec <pod-name> -n my-app -- ls /app

# 進入容器 shell
kubectl exec -it <pod-name> -n my-app -- /bin/bash
```

### 更新和回滾

```bash
# 更新 Deployment 映像
kubectl set image deployment/my-app app=my-app:v2 -n my-app

# 查看滾動更新狀態
kubectl rollout status deployment/my-app -n my-app

# 查看更新歷史
kubectl rollout history deployment/my-app -n my-app

# 回滾到上一個版本
kubectl rollout undo deployment/my-app -n my-app
```

### 擴展

```bash
# 手動擴展副本數
kubectl scale deployment/my-app --replicas=5 -n my-app

# 自動擴展（需要 metrics-server）
kubectl autoscale deployment/my-app --min=2 --max=10 --cpu-percent=80 -n my-app
```

### 刪除資源

```bash
# 刪除特定資源
kubectl delete -f manifests/04-deployment.yaml

# 刪除命名空間（會刪除該命名空間下所有資源）
kubectl delete namespace my-app

# 使用清理腳本
./scripts/cleanup.sh
```

### 調試

```bash
# 查看集群事件
kubectl get events -n my-app --sort-by='.lastTimestamp'

# 查看節點資源使用
kubectl top nodes

# 查看 Pod 資源使用
kubectl top pods -n my-app

# 端口轉發（本地訪問）
kubectl port-forward service/my-app 8080:80 -n my-app
```

## 實踐建議

### 1. 資源管理
- 始終為容器設置資源請求（requests）和限制（limits）
- 使用命名空間隔離不同環境

### 2. 配置管理
- 使用 ConfigMap 存儲配置
- 使用 Secret 存儲敏感信息
- 不要在映像中硬編碼配置

### 3. 健康檢查
- 配置 livenessProbe（存活探針）
- 配置 readinessProbe（就緒探針）
- 配置 startupProbe（啟動探針）用於慢啟動應用

### 4. 標籤和選擇器
- 使用有意義的標籤組織資源
- 使用標籤進行資源過濾和管理

### 5. 高可用性
- 部署多個副本
- 使用 Pod 反親和性避免單點故障
- 配置適當的滾動更新策略

## 學習路徑

### 初級
1. ✅ 理解 Pod、Deployment、Service 概念
2. ✅ 部署簡單應用
3. ✅ 查看日誌和排除故障

### 中級
4. ⬜ 配置 ConfigMap 和 Secret
5. ⬜ 設置 Ingress 和 SSL
6. ⬜ 實現滾動更新和回滾
7. ⬜ 配置健康檢查

### 高級
8. ⬜ 配置水平自動擴展（HPA）
9. ⬜ 使用 StatefulSet 管理有狀態應用
10. ⬜ 配置網絡策略
11. ⬜ 使用 Helm 管理應用
12. ⬜ 實現 CI/CD 流水線

## 資源連結

- [Kubernetes 官方文檔](https://kubernetes.io/docs/)
- [kubectl 速查表](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes 最佳實踐](https://kubernetes.io/docs/concepts/configuration/overview/)

## 下一步

1. 嘗試部署 `examples/` 目錄中的範例應用
2. 修改配置文件，觀察變化
3. 實驗不同的 Service 類型
4. 學習如何調試失敗的 Pod

祝你學習順利！🎉
