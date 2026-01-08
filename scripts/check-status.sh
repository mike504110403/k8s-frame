#!/bin/bash

# Kubernetes 狀態檢查腳本
# 用於快速查看應用程式的運行狀態

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_message "$BLUE" "================================"
    print_message "$BLUE" "$1"
    print_message "$BLUE" "================================"
}

# 檢查命名空間
check_namespace() {
    if ! kubectl get namespace my-app &> /dev/null; then
        print_message "$RED" "❌ 命名空間 'my-app' 不存在"
        print_message "$YELLOW" "請先運行：./scripts/deploy.sh"
        exit 1
    fi
    print_message "$GREEN" "✅ 命名空間存在"
}

# 主函數
main() {
    print_header "📊 Kubernetes 狀態檢查"
    
    # 檢查先決條件
    if ! command -v kubectl &> /dev/null; then
        print_message "$RED" "❌ kubectl 未安裝"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_message "$RED" "❌ 無法連接到集群"
        exit 1
    fi
    
    check_namespace
    
    # 集群信息
    print_header "🌐 集群信息"
    kubectl cluster-info
    echo ""
    kubectl get nodes
    
    # 命名空間資源摘要
    print_header "📦 命名空間資源摘要"
    kubectl get all -n my-app
    
    # Pod 詳細信息
    print_header "🏠 Pods 狀態"
    kubectl get pods -n my-app -o wide
    
    # 檢查 Pod 健康狀態
    echo ""
    print_message "$BLUE" "Pod 健康狀態："
    pod_count=$(kubectl get pods -n my-app --no-headers 2>/dev/null | wc -l)
    ready_count=$(kubectl get pods -n my-app --no-headers 2>/dev/null | grep "Running" | grep -E "([0-9]+)/\1" | wc -l)
    
    if [ "$pod_count" -eq "$ready_count" ] && [ "$pod_count" -gt 0 ]; then
        print_message "$GREEN" "✅ 所有 Pods 正常運行 ($ready_count/$pod_count)"
    else
        print_message "$YELLOW" "⚠️  部分 Pods 未就緒 ($ready_count/$pod_count)"
    fi
    
    # Services
    print_header "🌐 Services"
    kubectl get svc -n my-app
    
    # Deployments
    print_header "🚀 Deployments"
    kubectl get deployments -n my-app
    
    # ConfigMaps
    print_header "⚙️  ConfigMaps"
    kubectl get configmaps -n my-app
    
    # Secrets
    print_header "🔒 Secrets"
    kubectl get secrets -n my-app
    
    # Ingress
    print_header "🚪 Ingress"
    if kubectl get ingress -n my-app &> /dev/null; then
        kubectl get ingress -n my-app
    else
        print_message "$YELLOW" "沒有 Ingress 資源"
    fi
    
    # HPA
    print_header "📈 水平自動擴展 (HPA)"
    if kubectl get hpa -n my-app &> /dev/null; then
        kubectl get hpa -n my-app
    else
        print_message "$YELLOW" "沒有 HPA 資源"
    fi
    
    # 最近的事件
    print_header "📋 最近的事件"
    kubectl get events -n my-app --sort-by='.lastTimestamp' | tail -10
    
    # 資源使用情況（如果 metrics-server 可用）
    print_header "💻 資源使用情況"
    if kubectl top nodes &> /dev/null; then
        print_message "$BLUE" "節點資源："
        kubectl top nodes
        echo ""
        print_message "$BLUE" "Pod 資源："
        kubectl top pods -n my-app
    else
        print_message "$YELLOW" "⚠️  Metrics Server 未安裝，無法顯示資源使用情況"
        print_message "$YELLOW" "安裝方式："
        echo "  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
        echo "  或 (Minikube): minikube addons enable metrics-server"
    fi
    
    # 訪問提示
    print_header "🌐 訪問應用"
    echo ""
    print_message "$BLUE" "快速訪問方式："
    echo ""
    echo "1. Port Forward (推薦用於測試)："
    print_message "$GREEN" "   kubectl port-forward -n my-app service/my-app 8080:80"
    echo "   訪問: http://localhost:8080"
    echo ""
    echo "2. NodePort："
    print_message "$GREEN" "   kubectl get svc my-app-nodeport -n my-app"
    echo "   訪問: http://localhost:30080"
    echo ""
    echo "3. 查看日誌："
    print_message "$GREEN" "   kubectl logs -f -n my-app -l app=my-app"
    echo ""
    echo "4. 進入 Pod："
    print_message "$GREEN" "   kubectl exec -it -n my-app <pod-name> -- /bin/sh"
    
    print_header "✅ 狀態檢查完成"
}

# 執行主函數
main "$@"

