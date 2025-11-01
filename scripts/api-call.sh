#!/bin/bash

# GitHub定时API调用脚本
# 此脚本用于调用指定的API端点

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 检查必需的环境变量
check_environment_variables() {
    local required_vars=("API_URL" "REPO" "API_KEY" "BRANCH" "REF")
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "缺少必需的环境变量: ${missing_vars[*]}"
        exit 1
    fi
}

# 构建API URL
build_api_url() {
    local api_url="$1"
    local repo="$2"
    echo "${api_url}/${repo}/-/workspace/start"
}

# 执行API调用
execute_api_call() {
    local full_url="$1"
    local api_key="$2"
    local branch="$3"
    local ref="$4"

    log_info "准备调用API..."
    log_info "URL: $full_url"
    log_info "分支: $branch"
    log_info "引用: $ref"

    # 构建请求体
    local request_body="{\"branch\": \"$branch\", \"ref\": \"$ref\"}"

    # 执行curl请求
    local response
    response=$(curl -s -X POST "$full_url" \
        -H 'accept: application/json' \
        -H "Authorization: $api_key" \
        -H 'Content-Type: application/json' \
        -d "$request_body")

    local curl_exit_code=$?

    if [[ $curl_exit_code -ne 0 ]]; then
        log_error "curl请求失败，退出码: $curl_exit_code"
        return $curl_exit_code
    fi

    echo "$response"
}

# 分析API响应
analyze_response() {
    local response="$1"

    log_info "API响应:"
    echo "$response" | jq . 2>/dev/null || echo "$response"

    # 检查响应中是否包含错误信息
    if echo "$response" | grep -qi "error\|Error\|ERROR\|fail\|Fail\|FAIL"; then
        log_warning "API响应中可能包含错误信息"
        return 1
    else
        log_success "API调用成功完成"
        return 0
    fi
}

# 主函数
main() {
    log_info "开始执行API调用脚本"

    # 检查环境变量
    check_environment_variables

    # 构建API URL
    local full_url
    full_url=$(build_api_url "$API_URL" "$REPO")

    # 执行API调用
    local response
    response=$(execute_api_call "$full_url" "$API_KEY" "$BRANCH" "$REF")

    # 分析响应
    analyze_response "$response"

    log_info "脚本执行完成"
}

# 脚本入口点
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi