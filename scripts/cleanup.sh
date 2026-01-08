#!/bin/bash

# Kubernetes 清理腳本
# 用於刪除部署的所有資源

set -e

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

# 主函數
main() {
    print_header "🧹 Kubernetes 清理腳本"
    
    # 檢查命名空間是否存在
    if ! kubectl get namespace my-app &> /dev/null; then
        print_message "$YELLOW" "⚠️  命名空間 'my-app' 不存在"
        exit 0
    fi
    
    # 顯示當前資源
    print_header "📊 當前資源"
    kubectl get all -n my-app
    
    # 確認刪除
    echo ""
    print_message "$YELLOW" "⚠️  這將刪除命名空間 'my-app' 及其所有資源"
    read -p "確定要繼續嗎？(y/N) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "$BLUE" "取消清理操作"
        exit 0
    fi
    
    # 刪除資源
    print_header "🗑️  刪除資源"
    
    MANIFEST_DIR="$(dirname "$0")/../manifests"
    
    # 按相反順序刪除
    files=(
        "07-hpa.yaml"
        "06-ingress.yaml"
        "05-service.yaml"
        "04-deployment.yaml"
        "03-secret.yaml"
        "02-configmap.yaml"
        "01-namespace.yaml"
    )
    
    for file in "${files[@]}"; do
        filepath="$MANIFEST_DIR/$file"
        if [ -f "$filepath" ]; then
            print_message "$YELLOW" "刪除：$file"
            kubectl delete -f "$filepath" --ignore-not-found=true
        fi
    done
    
    # 等待命名空間完全刪除
    print_message "$BLUE" "等待命名空間刪除完成..."
    kubectl wait --for=delete namespace/my-app --timeout=60s || true
    
    print_header "✅ 清理完成"
    print_message "$GREEN" "所有資源已成功刪除"
    
    # 清理範例應用（如果存在）
    if kubectl get namespace nginx-example &> /dev/null; then
        echo ""
        print_message "$YELLOW" "發現範例應用 'nginx-example'"
        read -p "是否也要刪除？(y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete namespace nginx-example
            print_message "$GREEN" "範例應用已刪除"
        fi
    fi
}

# 執行主函數
main "$@"

