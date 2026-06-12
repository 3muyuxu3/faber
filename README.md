# Faber-AI

Faber-AI 是一个基于 Go 语言开发的智能 AI 代理平台，支持多模型接入、自定义工具集成、智能体管理等功能。项目采用微服务架构，提供完整的 AI 应用开发和管理能力。

## 核心特性

- **多模型支持**：集成 OpenAI、Ollama、Qwen、Claude、Gemini 等主流大语言模型
- **智能体管理**：创建、配置和管理 AI Agent，支持系统提示词、模型参数自定义
- **工具生态系统**：支持 MCP (Model Context Protocol) 工具和自定义工具集成
- **用户订阅系统**：提供分级订阅计划管理
- **认证授权**：基于 JWT 的用户认证和权限控制
- **向量搜索**：集成 Elasticsearch 实现智能检索
- **数据持久化**：使用 PostgreSQL + Redis 提供可靠的数据存储

## 技术栈

### 后端框架
- **Go**: 1.24.6
- **Web 框架**: Gin
- **ORM**: GORM
- **配置管理**: Viper
- **日志系统**: Thunder Logs

### AI/LLM 生态
- **Eino Framework**: CloudWeGo Eino - AI 应用开发框架
- **支持的模型提供商**:
  - OpenAI (GPT 系列)
  - Ollama (本地模型)
  - Qwen (通义千问)
  - Claude (Anthropic)
  - Gemini (Google)
  - DeepSeek
  - 百度千帆
  - 火山引擎
  - 腾讯云混元

### 数据存储
- **PostgreSQL 18**: 主数据库
- **Redis 7.2.4**: 缓存和会话管理
- **Elasticsearch 8.16.0**: 全文检索和向量搜索
- **Kibana 8.16.0**: ES 数据可视化

### 其他技术
- **JWT**: 身份认证
- **MCP Protocol**: Model Context Protocol 工具集成
- **Docker & Docker Compose**: 容器化部署

## 📝 配置说明

### 主要配置项

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| server.port | 服务端口 | 8888 |
| server.mode | 运行模式 (debug/release/test) | debug |
| db.postgres.host | PostgreSQL 主机 | 127.0.0.1 |
| db.redis.port | Redis 端口 | 6379 |
| jwt.secret | JWT 密钥 | faber-ai |
| jwt.expire | Token 过期时间 | 7h |

## 安全建议

1. **修改默认密钥**：更改 JWT secret 和数据库密码
2. **启用 HTTPS**：生产环境使用 SSL/TLS
3. **限制 CORS**：配置允许的域名白名单
4. **API 限流**：实施请求频率限制
5. **日志审计**：记录关键操作日志
