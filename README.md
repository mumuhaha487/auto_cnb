# GitHub定时API调用项目

本项目是一个自托管的GitHub Actions项目，用于定时调用指定的API端点。

## 功能特性

- 🕐 **定时执行**: 北京时间每天7点自动执行API调用
- 🔒 **安全配置**: 使用GitHub Environment Secrets管理敏感信息
- 🌍 **时区支持**: 自动设置时区为北京时间
- 📊 **日志记录**: 详细的执行日志和响应输出
- 🚀 **手动触发**: 支持手动触发工作流

## 环境变量配置

在GitHub仓库的Settings > Secrets and variables > Actions中配置以下secrets：

### 必需的环境变量

| 变量名 | 描述 | 示例值 |
|--------|------|--------|
| `API_URL` | API基础URL | `https://api.example.com` |
| `REPO` | 仓库路径 | `owner/repository` |
| `API_KEY` | API密钥 | `your_api_key_here` |
| `BRANCH` | 分支名称 | `main` |
| `REF` | Git引用 | `refs/heads/main` |

### 重要说明

**所有5个secrets都必须在GitHub仓库的Actions Secrets中设置**，包括：
- `API_URL`
- `REPO`
- `API_KEY`
- `BRANCH`
- `REF`

缺少任何一个secret都会导致工作流执行失败。

### 设置步骤

1. 进入GitHub仓库的 **Settings**
2. 选择 **Secrets and variables** > **Actions**
3. 点击 **New repository secret**
4. 依次添加上述5个secrets
5. 确保所有secrets都正确设置

### 配置示例

完整的API调用URL将构建为：
```
${API_URL}/${REPO}/-/workspace/start
```

示例：
```
https://api.example.com/owner/repository/-/workspace/start
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
2. 选择 **Secrets and variables** > **Actions**
3. 点击 **New repository secret**
4. 添加上述必需的5个secrets
5. 确保所有secrets都正确设置

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

**注意**: `Authorization` 头使用您设置的API密钥，请确保密钥的安全性。

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

2. **环境变量未设置或为空**
   - **这是最常见的问题！**
   - 确保所有必需的secrets都在Repository secrets中设置
   - 检查变量名称是否完全匹配（包括大小写）
   - 确认secrets值没有多余的前后空格

3. **API调用失败**
   - 检查API密钥是否有效
   - 验证API端点URL是否正确
   - 查看响应内容中的错误信息
   - 确认网络连接正常

4. **权限问题**
   - 确保GitHub Actions有权限访问仓库
   - 检查secrets权限设置
   - 确认API服务器可访问

### 环境变量调试

如果环境变量显示为空，请按以下步骤检查：

#### 1. 检查secrets设置
```
GitHub仓库 → Settings → Secrets and variables → Actions → Repository secrets
```
确保所有必需的secrets都已正确设置，包括API基础URL、仓库路径、API密钥、分支名称和Git引用。

#### 2. 运行调试工作流
项目包含一个专门的调试工作流 `.github/workflows/debug-secrets.yml`：
1. 在GitHub Actions页面选择 "调试环境变量" 工作流
2. 点击 "Run workflow" 手动触发
3. 查看输出，确认环境变量是否正确加载

#### 3. 常见的secrets问题
- **变量名错误**: 检查是否拼写错误或大小写不匹配
- **位置错误**: 确保变量设置在 **Repository secrets** 中，不是Environment secrets
- **值格式问题**: 确保API URL包含 `http://` 或 `https://`
- **权限问题**: 确保GitHub Actions有权限访问secrets
- **加密状态**: 确保secrets正确加密并保存
- **敏感信息泄露**: 检查是否在代码或文档中意外暴露了敏感信息

### 调试步骤

1. **先运行调试工作流**确认环境变量正确加载
2. 在GitHub Actions页面手动触发主工作流
3. 查看详细的执行日志
4. 检查环境变量是否正确加载
5. 验证API请求参数

### 如果问题仍然存在

1. 删除并重新创建secrets
2. 检查GitHub仓库的权限设置
3. 确认secrets的加密状态
4. 尝试在Environment secrets中设置（如果Repository secrets不工作）
5. 检查GitHub Actions的权限设置
6. 确保没有在代码或文档中暴露敏感信息
7. 验证API端点的网络连接性

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
