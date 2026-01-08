#!/bin/bash

# Kubernetes 部署腳本
# 用於部署 manifests 目錄中的所有資源

set -e  # 遇到錯誤立即退出

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 打印帶顏色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 打印標題
print_header() {
    echo ""
    print_message "$BLUE" "================================"
    print_message "$BLUE" "$1"
    print_message "$BLUE" "================================"
}

# 檢查 kubectl 是否安裝
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_message "$RED" "❌ kubectl 未安裝。請先安裝 kubectl。"
        exit 1
    fi
    print_message "$GREEN" "✅ kubectl 已安裝"
}

# 檢查集群連接
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_message "$RED" "❌ 無法連接到 Kubernetes 集群"
        print_message "$YELLOW" "請確保："
        print_message "$YELLOW" "  1. Kubernetes 集群正在運行（minikube、Docker Desktop 等）"
        print_message "$YELLOW" "  2. kubectl 配置正確"
        exit 1
    fi
    print_message "$GREEN" "✅ 集群連接正常"
}

# 主函數
main() {
    print_header "🚀 Kubernetes 部署腳本"
    
    # 檢查先決條件
    print_message "$BLUE" "檢查先決條件..."
    check_kubectl
    check_cluster
    
    # 顯示集群信息
    print_header "📊 集群信息"
    kubectl cluster-info
    echo ""
    kubectl get nodes
    
    # 部署資源
    print_header "📦 部署資源"
    
    MANIFEST_DIR="$(dirname "$0")/../manifests"
    
    if [ ! -d "$MANIFEST_DIR" ]; then
        print_message "$RED" "❌ manifests 目錄不存在：$MANIFEST_DIR"
        exit 1
    fi
    
    print_message "$BLUE" "從目錄部署：$MANIFEST_DIR"
    
    # 按順序部署（確保依賴順序正確）
    files=(
        "01-namespace.yaml"
        "02-configmap.yaml"
        "03-secret.yaml"
        "04-deployment.yaml"
        "05-service.yaml"
        "06-ingress.yaml"
        "07-hpa.yaml"
    )
    
    for file in "${files[@]}"; do
        filepath="$MANIFEST_DIR/$file"
        if [ -f "$filepath" ]; then
            print_message "$YELLOW" "部署：$file"
            kubectl apply -f "$filepath"
            echo ""
        else
            print_message "$YELLOW" "⚠️  跳過不存在的文件：$file"
        fi
    done
    
    # 等待部署完成
    print_header "⏳ 等待 Pod 就緒"
    print_message "$BLUE" "等待 Pod 啟動..."
    kubectl wait --for=condition=ready pod -l app=my-app -n my-app --timeout=120s || true
    
    # 顯示部署結果
    print_header "📊 部署結果"
    
    print_message "$BLUE" "命名空間："
    kubectl get namespace my-app
    echo ""
    
    print_message "$BLUE" "Pods："
    kubectl get pods -n my-app
    echo ""
    
    print_message "$BLUE" "Services："
    kubectl get svc -n my-app
    echo ""
    
    print_message "$BLUE" "Deployments："
    kubectl get deployments -n my-app
    echo ""
    
    print_message "$BLUE" "Ingress："
    kubectl get ingress -n my-app
    echo ""
    
    print_message "$BLUE" "HPA："
    kubectl get hpa -n my-app
    
    # 提示訪問方式
    print_header "🌐 訪問應用"
    
    print_message "$GREEN" "✅ 部署完成！"
    echo ""
    print_message "$YELLOW" "訪問方式："
    echo ""
    print_message "$BLUE" "1. 使用 Port Forward："
    echo "   kubectl port-forward -n my-app service/my-app 8080:80"
    echo "   然後訪問 http://localhost:8080"
    echo ""
    print_message "$BLUE" "2. 使用 NodePort："
    echo "   kubectl get svc my-app-nodeport -n my-app"
    echo "   訪問 http://localhost:30080"
    echo ""
    print_message "$BLUE" "3. 使用 Ingress（需要配置 /etc/hosts）："
    echo "   echo \"127.0.0.1 my-app.local\" | sudo tee -a /etc/hosts"
    echo "   訪問 http://my-app.local"
    echo ""
    print_message "$YELLOW" "查看日誌："
    echo "   kubectl logs -f -n my-app -l app=my-app"
    echo ""
    print_message "$YELLOW" "查看詳細信息："
    echo "   kubectl describe pod -n my-app <pod-name>"
    
    print_header "🎉 部署成功"
}

# 執行主函數
main "$@"

