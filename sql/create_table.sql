-- 用户表
CREATE TABLE users
(
    -- Id: uuid 类型，主键，默认生成随机 UUID
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Username: 唯一，非空
    username        text         NOT NULL,
    -- Password: 文本
    password        text,
    -- Avatar: 文本
    avatar          text,
    -- Status: 字符串
    status          smallint         DEFAULT 3,
    -- LastLoginTime: 带时区的时间戳 (推荐) 或 不带时区
    last_login_time timestamptz,
    -- CurrentPlan: 默认为 'free'
    current_plan    varchar(20)      DEFAULT 'free',
    -- Email: 变长字符，唯一，非空
    email           varchar(100) NOT NULL,
    -- EmailVerified: 布尔值，默认为 false
    email_verified  boolean          DEFAULT false,
    -- 约束条件
    CONSTRAINT uni_users_username UNIQUE (username),
    CONSTRAINT uni_users_email UNIQUE (email)
);

-- 添加注释 (可选)
COMMENT ON COLUMN users.id IS '用户ID(UUID)';
COMMENT ON COLUMN users.username IS '用户名';
COMMENT ON COLUMN users.current_plan IS '当前订阅计划';
COMMENT ON COLUMN users.email IS '邮箱';
COMMENT ON COLUMN users.email_verified IS '邮箱是否验证';


-- 智能体管理
CREATE TABLE agents
(
    -- BaseModel 部分
    id                  UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at          TIMESTAMPTZ,

    -- Agent 字段
    creator_id          UUID         NOT NULL,
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    icon                VARCHAR(512),

    -- Postgres 使用 TEXT 代替 longtext
    system_prompt       TEXT,

    model_provider      VARCHAR(50)  NOT NULL DEFAULT 'openai',
    model_name          VARCHAR(100) NOT NULL,

    -- 推荐使用 JSONB
    model_parameters    JSONB,

    opening_dialogue    TEXT,
    suggested_questions JSONB,

    -- 去掉 unsigned，使用 CHECK 约束保证正数
    version             INTEGER      NOT NULL DEFAULT 1 CHECK (version >= 0),

    -- 【修改点】: 使用 VARCHAR 代替 ENUM
    status              VARCHAR(20)  NOT NULL DEFAULT 'draft',
    visibility          VARCHAR(20)  NOT NULL DEFAULT 'private',

    -- 去掉 unsigned，使用 CHECK 约束
    invocation_count    BIGINT       NOT NULL DEFAULT 0 CHECK (invocation_count >= 0),

    published_at        TIMESTAMPTZ
);

-- 3. 索引
CREATE INDEX idx_agents_deleted_at ON agents (deleted_at);
CREATE INDEX idx_agents_creator_id ON agents (creator_id);
-- 针对状态字段建索引（如果是 varchar，建索引也是很常见的）
CREATE INDEX idx_agents_status ON agents (status);


--
CREATE TABLE provider_configs
(
    -- BaseModel
    id          UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMPTZ,

    -- 业务字段
    user_id     UUID         NOT NULL,
    name        VARCHAR(255) NOT NULL,
    provider    VARCHAR(50)  NOT NULL,
    description TEXT,
    api_key     VARCHAR(255),
    api_base    VARCHAR(255),
    status      VARCHAR(20)           DEFAULT 'active'
);

-- 索引
CREATE INDEX idx_provider_configs_deleted_at ON provider_configs (deleted_at);
CREATE INDEX idx_provider_configs_user_id ON provider_configs (user_id);
CREATE INDEX idx_provider_configs_provider ON provider_configs (provider);

-- 注释
COMMENT ON TABLE provider_configs IS '大模型厂商配置表';
COMMENT ON COLUMN provider_configs.id IS '唯一标识ID';
COMMENT ON COLUMN provider_configs.user_id IS '用户ID';
COMMENT ON COLUMN provider_configs.name IS '配置名称(如: 我的OpenAI)';
COMMENT ON COLUMN provider_configs.provider IS '厂商标识(openai, ollama, qwen)';
COMMENT ON COLUMN provider_configs.description IS '描述信息';
COMMENT ON COLUMN provider_configs.api_key IS 'API密钥';
COMMENT ON COLUMN provider_configs.api_base IS 'API地址(Endpoint)';
COMMENT ON COLUMN provider_configs.status IS '状态: active, inactive';


-- ==========================================
-- Table: llms (大语言模型)
-- ==========================================
CREATE TABLE llms
(
    -- BaseModel
    id                 UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at         TIMESTAMPTZ,

    -- 业务字段
    user_id            UUID         NOT NULL,
    name               VARCHAR(255) NOT NULL,
    description        TEXT,

    -- 关联配置 (修正为 UUID)
    provider_config_id UUID,

    model_name         VARCHAR(255) NOT NULL,
    model_type         VARCHAR(20)           DEFAULT 'chat',
    config             JSONB, -- 关键配置使用 JSONB
    status             VARCHAR(20)           DEFAULT 'active'

);

-- 索引
CREATE INDEX idx_llms_deleted_at ON llms (deleted_at);
CREATE INDEX idx_llms_user_id ON llms (user_id);
CREATE INDEX idx_llms_provider_config_id ON llms (provider_config_id);

-- 注释
COMMENT ON TABLE llms IS '自定义大语言模型表';
COMMENT ON COLUMN llms.id IS '唯一标识ID';
COMMENT ON COLUMN llms.user_id IS '用户ID';
COMMENT ON COLUMN llms.name IS '模型显示名称';
COMMENT ON COLUMN llms.description IS '描述';
COMMENT ON COLUMN llms.provider_config_id IS '关联的厂商配置ID';
COMMENT ON COLUMN llms.model_name IS '实际模型标识(如 gpt-4-turbo)';
COMMENT ON COLUMN llms.model_type IS '模型类型: chat, embedding, vision';
COMMENT ON COLUMN llms.config IS '模型参数配置(JSONB): maxTokens, temperature等';
COMMENT ON COLUMN llms.status IS '状态: active, inactive';


-- 2. 创建 tools 表
CREATE TABLE IF NOT EXISTS tools
(
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id        UUID         NOT NULL,
    name              VARCHAR(255) NOT NULL,
    description       TEXT,
    tool_type         VARCHAR(50)  NOT NULL,
    is_enable         BOOLEAN          DEFAULT TRUE,
    parameters_schema JSONB,
    mcp_config        JSONB,
    created_at        TIMESTAMPTZ,
    updated_at        TIMESTAMPTZ,
    deleted_at        TIMESTAMPTZ
);

-- 创建索引以加速查询
CREATE INDEX IF NOT EXISTS idx_tools_creator_id ON tools (creator_id);
CREATE INDEX IF NOT EXISTS idx_tools_name ON tools (name);
CREATE INDEX IF NOT EXISTS idx_tools_tool_type ON tools (tool_type);

-- 3. 创建 agent_tools 表 (关联表)
CREATE TABLE IF NOT EXISTS agent_tools
(
    agent_id   UUID NOT NULL,
    tool_id    UUID NOT NULL,
    status     VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ,

    -- 设置复合主键，防止同一个 Agent 重复关联同一个 Tool
    PRIMARY KEY (agent_id, tool_id),

    -- 外键约束 (假设 agents 表存在，如果还没创建 agents 表，请先创建或删除下面这行)
    -- CONSTRAINT fk_agent_tools_agent FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,

    -- 外键约束指向 tools
    CONSTRAINT fk_agent_tools_tool FOREIGN KEY (tool_id) REFERENCES tools (id) ON DELETE CASCADE
);

-- 为 tool_id 创建索引，优化反向查询（查找某个工具被哪些 agent 使用）
CREATE INDEX IF NOT EXISTS idx_agent_tools_tool_id ON agent_tools (tool_id);

