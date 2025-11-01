#!/bin/bash

# 健康检查脚本
# 用于验证环境变量配置和API连接性

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查环境变量
check_env_vars() {
    log_info "检查环境变量..."

    local vars=("API_URL" "REPO" "API_KEY" "BRANCH" "REF")
    local all_set=true

    for var in "${vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            log_error "环境变量 $var 未设置"
            all_set=false
        else
            log_success "环境变量 $var 已设置"
        fi
    done

    if [[ "$all_set" == "false" ]]; then
        log_error "请设置所有必需的环境变量"
        exit 1
    fi
}

# 验证API URL格式
validate_api_url() {
    log_info "验证API URL格式..."

    if [[ ! "$API_URL" =~ ^https?:// ]]; then
        log_error "API_URL 必须以 http:// 或 https:// 开头"
        exit 1
    fi

    log_success "API URL 格式正确"
}

# 验证仓库格式
validate_repo_format() {
    log_info "验证仓库格式..."

    if [[ ! "$REPO" =~ ^[^/]+/[^/]+$ ]]; then
        log_error "REPO 格式应为 owner/repo"
        exit 1
    fi

    log_success "仓库格式正确"
}

# 构建完整URL
build_full_url() {
    local full_url="${API_URL}/${REPO}/-/workspace/start"
    log_info "完整API URL: $full_url"
    echo "$full_url"
}

# 测试API连接
test_api_connection() {
    log_info "测试API连接..."

    local full_url=$(build_full_url)

    # 只测试连接，不发送实际请求
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -X HEAD "$full_url" \
        -H 'accept: application/json' \
        -H "Authorization: $API_KEY" \
        --connect-timeout 10 \
        --max-time 30 2>/dev/null || echo "000")

    if [[ "$http_code" == "000" ]]; then
        log_warning "无法连接到API服务器，可能是网络问题或服务器不可用"
        return 1
    elif [[ "$http_code" =~ ^[45][0-9]{2}$ ]]; then
        log_warning "API服务器返回错误状态码: $http_code"
        return 1
    else
        log_success "API连接测试成功，状态码: $http_code"
        return 0
    fi
}

# 显示配置信息
show_config() {
    log_info "当前配置:"
    echo "  API URL: $API_URL"
    echo "  仓库: $REPO"
    echo "  分支: $BRANCH"
    echo "  引用: $REF"
    echo "  API Key: ${API_KEY:0:10}... (已隐藏)"
}

# 主函数
main() {
    log_info "开始健康检查..."

    show_config
    echo

    check_env_vars
    validate_api_url
    validate_repo_format

    echo
    test_api_connection

    echo
    log_success "健康检查完成"
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi