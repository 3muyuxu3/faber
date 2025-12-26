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
