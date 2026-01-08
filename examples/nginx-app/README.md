# Nginx 範例應用

這是一個簡單的 Nginx 靜態網站範例，展示如何在 Kubernetes 上部署 Web 應用。

## 部署步驟

### 1. 部署應用

```bash
kubectl apply -f deployment.yaml
```

### 2. 查看資源

```bash
# 查看所有資源
kubectl get all -n nginx-example

# 查看 Pod
kubectl get pods -n nginx-example

# 查看 Service
kubectl get svc -n nginx-example
```

### 3. 訪問應用

#### 方法 1：使用 NodePort

```bash
# 獲取 NodePort
kubectl get svc nginx-app -n nginx-example

# 如果使用 Minikube
minikube service nginx-app -n nginx-example

# 或直接訪問
# http://localhost:30081  # 或使用 minikube ip
```

#### 方法 2：使用 Port Forward

```bash
kubectl port-forward -n nginx-example service/nginx-app 8080:80

# 然後訪問 http://localhost:8080
```

#### 方法 3：使用 Ingress

```bash
# 確保 Ingress Controller 已安裝
# Minikube: minikube addons enable ingress

# 添加到 /etc/hosts
echo "127.0.0.1 nginx.local" | sudo tee -a /etc/hosts

# 訪問 http://nginx.local
```

### 4. 測試功能

```bash
# 查看日誌
kubectl logs -f -n nginx-example -l app=nginx-app

# 進入容器
kubectl exec -it -n nginx-example <pod-name> -- /bin/sh

# 測試負載均衡
for i in {1..10}; do curl http://localhost:8080; echo ""; done
```

### 5. 清理資源

```bash
kubectl delete -f deployment.yaml

# 或刪除整個命名空間
kubectl delete namespace nginx-example
```

## 配置說明

- **副本數**：2 個 Pod
- **資源限制**：
  - 請求：50m CPU, 32Mi 內存
  - 限制：100m CPU, 64Mi 內存
- **端口**：NodePort 30081
- **健康檢查**：配置了存活和就緒探針

## 自定義

你可以修改 ConfigMap 中的 `index.html` 來更改網站內容：

```bash
# 編輯 ConfigMap
kubectl edit configmap nginx-html -n nginx-example

# 重啟 Pod 以載入新配置
kubectl rollout restart deployment nginx-app -n nginx-example
```

