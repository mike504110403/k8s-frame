# 🚀 Kubernetes 快速開始指南

這是一個 5 分鐘快速上手指南，幫助你立即開始使用 Kubernetes。

## 前置需求檢查

```bash
# 1. 檢查 kubectl 是否已安裝
kubectl version --client

# 2. 檢查 K8s 集群是否運行
kubectl cluster-info

# 3. 查看節點
kubectl get nodes
```

### 如果還沒有本地 K8s 環境：

**macOS 用戶（推薦使用 Docker Desktop）：**
```bash
# 方法 1: Docker Desktop（最簡單）
# 1. 安裝 Docker Desktop from https://www.docker.com/products/docker-desktop
# 2. 打開 Docker Desktop > Settings > Kubernetes > Enable Kubernetes

# 方法 2: Minikube
brew install minikube
minikube start
```

**安裝 kubectl：**
```bash
brew install kubectl
```

## 🎯 第一步：部署你的第一個應用

### 選項 A：使用一鍵部署腳本（推薦）

```bash
# 部署主框架應用
./scripts/deploy.sh

# 檢查狀態
./scripts/check-status.sh
```

### 選項 B：手動部署

```bash
# 按順序部署
kubectl apply -f manifests/01-namespace.yaml
kubectl apply -f manifests/02-configmap.yaml
kubectl apply -f manifests/03-secret.yaml
kubectl apply -f manifests/04-deployment.yaml
kubectl apply -f manifests/05-service.yaml

# 或一次部署全部
kubectl apply -f manifests/
```

## 🌐 訪問你的應用

### 最簡單的方式：Port Forward

```bash
# 轉發服務到本地端口
kubectl port-forward -n my-app service/my-app 8080:80

# 然後在瀏覽器訪問
open http://localhost:8080
```

### 使用 NodePort

```bash
# 查看 NodePort
kubectl get svc my-app-nodeport -n my-app

# 訪問（如果使用 Docker Desktop）
open http://localhost:30080

# 如果使用 Minikube
minikube service my-app-nodeport -n my-app
```

## 📊 查看狀態

```bash
# 查看所有資源
kubectl get all -n my-app

# 查看 Pod
kubectl get pods -n my-app

# 查看日誌
kubectl logs -f -n my-app -l app=my-app

# 查看詳細信息
kubectl describe pod -n my-app <pod-name>
```

## 🎮 實驗功能

### 1. 擴展應用

```bash
# 擴展到 5 個副本
kubectl scale deployment/my-app --replicas=5 -n my-app

# 觀察變化
kubectl get pods -n my-app --watch
```

### 2. 更新應用

```bash
# 更新映像版本
kubectl set image deployment/my-app app=nginx:1.26-alpine -n my-app

# 觀察滾動更新
kubectl rollout status deployment/my-app -n my-app
```

### 3. 回滾

```bash
# 回滾到上一個版本
kubectl rollout undo deployment/my-app -n my-app
```

## 🎨 嘗試範例應用

### Nginx 範例（靜態網站）

```bash
# 部署
kubectl apply -f examples/nginx-app/deployment.yaml

# 訪問
kubectl port-forward -n nginx-example service/nginx-app 8081:80
open http://localhost:8081

# 清理
kubectl delete -f examples/nginx-app/deployment.yaml
```

### Node.js 範例（API 服務）

```bash
# 部署
kubectl apply -f examples/nodejs-app/deployment.yaml

# 訪問
kubectl port-forward -n nodejs-example service/nodejs-app 8082:80
open http://localhost:8082

# 測試 API
curl http://localhost:8082/api/info | jq

# 清理
kubectl delete -f examples/nodejs-app/deployment.yaml
```

## 🧹 清理資源

```bash
# 使用清理腳本
./scripts/cleanup.sh

# 或手動刪除
kubectl delete namespace my-app
```

## 📚 下一步學習

### 基礎概念（第 1 週）
1. ✅ 理解 Pod、Deployment、Service
2. ✅ 部署第一個應用
3. ⬜ 學習 kubectl 基本命令

### 進階功能（第 2-3 週）
4. ⬜ ConfigMap 和 Secret 管理
5. ⬜ 配置 Ingress 路由
6. ⬜ 實現滾動更新和回滾
7. ⬜ 設置健康檢查

### 生產級功能（第 4+ 週）
8. ⬜ 配置 HPA 自動擴展
9. ⬜ 使用 StatefulSet（有狀態應用）
10. ⬜ 配置持久化存儲（PV/PVC）
11. ⬜ 實現監控和日誌
12. ⬜ CI/CD 集成

## 🔍 常用命令速查

```bash
# 查看資源
kubectl get pods -n my-app                    # Pod 列表
kubectl get svc -n my-app                     # Service 列表
kubectl get deployments -n my-app             # Deployment 列表
kubectl get all -n my-app                     # 所有資源

# 查看詳情
kubectl describe pod <pod-name> -n my-app     # Pod 詳情
kubectl logs <pod-name> -n my-app             # 查看日誌
kubectl logs -f <pod-name> -n my-app          # 實時日誌

# 進入容器
kubectl exec -it <pod-name> -n my-app -- sh   # 進入 shell

# 端口轉發
kubectl port-forward -n my-app service/my-app 8080:80

# 擴展
kubectl scale deployment/my-app --replicas=3 -n my-app

# 更新
kubectl set image deployment/my-app app=nginx:1.26 -n my-app
kubectl rollout status deployment/my-app -n my-app
kubectl rollout undo deployment/my-app -n my-app

# 刪除
kubectl delete pod <pod-name> -n my-app
kubectl delete -f <file.yaml>
kubectl delete namespace my-app
```

## ❓ 常見問題

### Q: Pod 一直處於 Pending 狀態？
```bash
# 查看原因
kubectl describe pod <pod-name> -n my-app

# 常見原因：
# 1. 資源不足：調整 resources.requests
# 2. 映像拉取失敗：檢查映像名稱和網絡
# 3. 存儲問題：檢查 PVC 狀態
```

### Q: 無法訪問應用？
```bash
# 1. 檢查 Pod 是否運行
kubectl get pods -n my-app

# 2. 檢查 Service
kubectl get svc -n my-app

# 3. 使用 port-forward 測試
kubectl port-forward -n my-app service/my-app 8080:80

# 4. 查看日誌
kubectl logs -f -n my-app -l app=my-app
```

### Q: 如何查看資源使用情況？
```bash
# 需要先安裝 metrics-server
# Docker Desktop: 自動包含
# Minikube: minikube addons enable metrics-server

# 查看節點資源
kubectl top nodes

# 查看 Pod 資源
kubectl top pods -n my-app
```

## 🆘 需要幫助？

- 查看主 README：`cat README.md`
- 查看範例說明：`cat examples/*/README.md`
- 運行狀態檢查：`./scripts/check-status.sh`
- Kubernetes 官方文檔：https://kubernetes.io/docs/

## 🎉 恭喜！

你已經成功部署了第一個 Kubernetes 應用！繼續探索 manifests 目錄中的配置文件，了解更多 K8s 功能。

**提示：** 所有配置文件都包含詳細的中文註解，幫助你理解每個配置的作用。

