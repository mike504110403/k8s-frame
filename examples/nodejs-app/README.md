# Node.js 範例應用

這是一個簡單的 Node.js HTTP 服務範例，展示如何在 Kubernetes 上部署 API 服務。

## 功能特點

- ✅ RESTful API 端點
- ✅ 健康檢查端點
- ✅ 顯示 Pod 信息
- ✅ 測試負載均衡
- ✅ 水平自動擴展
- ✅ 多個訪問方式

## 部署步驟

### 1. 部署應用

```bash
kubectl apply -f deployment.yaml
```

### 2. 查看資源

```bash
# 查看所有資源
kubectl get all -n nodejs-example

# 查看 Pod
kubectl get pods -n nodejs-example -o wide

# 查看 Service
kubectl get svc -n nodejs-example

# 查看 HPA
kubectl get hpa -n nodejs-example
```

### 3. 訪問應用

#### 方法 1：Port Forward（推薦）

```bash
kubectl port-forward -n nodejs-example service/nodejs-app 8080:80

# 訪問 http://localhost:8080
```

#### 方法 2：NodePort

```bash
# 直接訪問 NodePort
# http://localhost:30082

# 或使用 Minikube
minikube service nodejs-app-nodeport -n nodejs-example
```

#### 方法 3：Ingress

```bash
# 添加到 /etc/hosts
echo "127.0.0.1 nodejs.local" | sudo tee -a /etc/hosts

# 訪問 http://nodejs.local
```

## API 端點

### GET /
- 顯示 Web 界面
- 包含 Pod 信息和互動功能

### GET /api/info
- 返回詳細的服務信息
- JSON 格式

```bash
curl http://localhost:8080/api/info
```

響應範例：
```json
{
  "app": "Kubernetes Node.js App",
  "hostname": "nodejs-app-7d8f9c5b6d-x7k2m",
  "uptime": "123s",
  "nodeVersion": "v18.x.x",
  "platform": "linux",
  "memory": {
    "used": "25MB",
    "total": "32MB"
  }
}
```

### GET /health
- 健康檢查端點
- 用於 liveness 和 readiness probe

```bash
curl http://localhost:8080/health
```

## 測試功能

### 1. 查看日誌

```bash
# 查看所有 Pod 的日誌
kubectl logs -f -n nodejs-example -l app=nodejs-app

# 查看特定 Pod 的日誌
kubectl logs -f -n nodejs-example <pod-name>
```

### 2. 測試負載均衡

```bash
# 多次請求，觀察不同的 Pod 響應
for i in {1..10}; do
  curl http://localhost:8080/api/info | jq '.hostname'
done
```

或在瀏覽器中點擊「測試負載均衡」按鈕。

### 3. 測試自動擴展

```bash
# 生成負載（需要安裝 apache2-utils）
ab -n 10000 -c 100 http://localhost:8080/

# 或使用 K8s 內的負載生成器
kubectl run -i --tty load-generator \
  --rm --image=busybox --restart=Never \
  -n nodejs-example -- /bin/sh -c \
  "while sleep 0.01; do wget -q -O- http://nodejs-app/api/info; done"

# 觀察 HPA 擴展
kubectl get hpa -n nodejs-example --watch

# 觀察 Pod 數量變化
kubectl get pods -n nodejs-example --watch
```

### 4. 進入容器

```bash
kubectl exec -it -n nodejs-example <pod-name> -- /bin/sh

# 在容器內
# 查看進程
ps aux

# 測試網絡
wget -O- http://nodejs-app/health

# 查看環境變數
env | grep -E "APP_|NODE_|PORT"
```

## 擴展和縮減

### 手動擴展

```bash
# 擴展到 5 個副本
kubectl scale deployment nodejs-app --replicas=5 -n nodejs-example

# 查看擴展狀態
kubectl get pods -n nodejs-example
```

### 自動擴展

HPA 已配置為：
- **最小副本數**：2
- **最大副本數**：10
- **CPU 閾值**：70%
- **內存閾值**：80%

```bash
# 查看 HPA 狀態
kubectl describe hpa nodejs-app-hpa -n nodejs-example
```

## 更新應用

### 滾動更新

如果你想更新應用代碼，可以修改 Deployment 並應用：

```bash
# 編輯 Deployment
kubectl edit deployment nodejs-app -n nodejs-example

# 或修改 YAML 並重新應用
kubectl apply -f deployment.yaml

# 觀察滾動更新
kubectl rollout status deployment/nodejs-app -n nodejs-example
```

### 回滾

```bash
# 查看更新歷史
kubectl rollout history deployment/nodejs-app -n nodejs-example

# 回滾到上一個版本
kubectl rollout undo deployment/nodejs-app -n nodejs-example

# 回滾到特定版本
kubectl rollout undo deployment/nodejs-app --to-revision=2 -n nodejs-example
```

## 調試

### 查看事件

```bash
kubectl get events -n nodejs-example --sort-by='.lastTimestamp'
```

### 查看資源使用

```bash
# 需要 metrics-server
kubectl top pods -n nodejs-example
kubectl top nodes
```

### 描述資源

```bash
kubectl describe pod <pod-name> -n nodejs-example
kubectl describe deployment nodejs-app -n nodejs-example
kubectl describe svc nodejs-app -n nodejs-example
```

## 清理

```bash
# 刪除所有資源
kubectl delete -f deployment.yaml

# 或刪除整個命名空間
kubectl delete namespace nodejs-example
```

## 架構說明

```
Internet
    ↓
Ingress (nodejs.local)
    ↓
Service (ClusterIP/NodePort)
    ↓
[Pod 1] [Pod 2] [Pod 3] ← HPA 自動擴展
    ↑
ConfigMap & Secret
```

## 學習要點

這個範例展示了：

1. **無狀態應用部署**：多個 Pod 副本運行相同代碼
2. **配置管理**：使用 ConfigMap 和 Secret
3. **服務發現**：通過 Service 訪問 Pod
4. **負載均衡**：Service 自動分配流量
5. **健康檢查**：liveness 和 readiness probe
6. **資源限制**：requests 和 limits
7. **自動擴展**：基於 CPU/內存的 HPA
8. **滾動更新**：零停機部署

## 下一步

- 嘗試修改環境變數並觀察變化
- 實驗不同的副本數量
- 添加持久化存儲（PVC）
- 配置 Prometheus 監控
- 實現 CI/CD 流水線

