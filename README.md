# GitHub定时API调用项目

本项目是一个自托管的GitHub Actions项目，用于定时调用指定的API端点。

## 功能特性

- 🕐 **定时执行**: 北京时间每天7点自动执行API调用
- 🔒 **安全配置**: 使用GitHub Environment Secrets管理敏感信息
- 🌍 **时区支持**: 自动设置时区为北京时间
- 📊 **日志记录**: 详细的执行日志和响应输出
- 🚀 **手动触发**: 支持手动触发工作流

## 环境变量配置

在GitHub仓库的Settings > Environments > production中配置以下环境变量：

### 必需的环境变量

| 变量名 | 描述 | 示例值 |
|--------|------|--------|
| `API_URL` | API基础URL | `https://api.cnb.cool` |
| `REPO` | 仓库路径 | `software_test/codetest` |
| `API_KEY` | API密钥 | `9KS4p2Ofxa1246PR9BsQt7epGsD` |
| `BRANCH` | 分支名称 | `main` |
| `REF` | Git引用 | `refs/heads/main` |

### 配置示例

完整的API调用URL将构建为：
```
${API_URL}/${REPO}/-/workspace/start
```

示例：
```
https://api.cnb.cool/software_test/codetest/-/workspace/start
```

## 项目结构

```
project/
├── .github/
│   └── workflows/
│       └── api-call.yml          # GitHub Actions工作流
├── scripts/
│   └── api-call.sh              # API调用脚本
├── config/
│   └── config.json              # 配置文件
├── .env.example                 # 环境变量示例
└── README.md                    # 项目文档
```

## 使用说明

### 1. Fork或克隆此项目

```bash
git clone <repository-url>
cd project
```

### 2. 配置环境变量

在GitHub仓库中：

1. 进入仓库的 **Settings**
2. 选择 **Environments**
3. 创建名为 `production` 的环境
4. 在环境变量中添加上述必需的环境变量

### 3. 验证工作流

- **自动执行**: 工作流将在北京时间每天7点自动执行
- **手动执行**: 在GitHub Actions页面可以手动触发工作流

### 4. 查看执行日志

执行日志可以在GitHub Actions页面查看，包含：
- 执行时间
- API请求详情
- 响应内容
- 错误信息（如果有）

## API调用详情

### 请求方法
- **Method**: POST
- **Content-Type**: application/json
- **Accept**: application/json

### 请求头
```http
Authorization: ${API_KEY}
accept: application/json
Content-Type: application/json
```

### 请求体
```json
{
  "branch": "${BRANCH}",
  "ref": "${REF}"
}
```

## 故障排除

### 常见问题

1. **时区问题**
   - 工作流已配置为使用北京时间
   - 检查 `sudo timedatectl set-timezone Asia/Shanghai` 是否正常执行

2. **环境变量未设置**
   - 确保所有必需的环境变量都在production环境中设置
   - 检查变量名称是否正确

3. **API调用失败**
   - 检查API密钥是否有效
   - 验证API端点URL是否正确
   - 查看响应内容中的错误信息

4. **权限问题**
   - 确保GitHub Actions有权限访问仓库
   - 检查环境变量权限设置

### 调试步骤

1. 在GitHub Actions页面手动触发工作流
2. 查看详细的执行日志
3. 检查环境变量是否正确加载
4. 验证API请求参数

## 自定义配置

### 修改执行时间

编辑 `.github/workflows/api-call.yml` 文件中的 `schedule` 部分：

```yaml
schedule:
  # 北京时间每天HH点MM分执行 (UTC时间HH+8点MM分)
  - cron: 'MM HH * * *'
```

### 修改API参数

可以通过修改环境变量来调整API调用参数，无需修改代码。

## 贡献

欢迎提交Issue和Pull Request来改进此项目。

## 许可证

本项目采用MIT许可证。