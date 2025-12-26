package router

import (
	"Faber-AI/app/internal/auths"

	"github.com/gin-gonic/gin"
)

type AuthRouter struct {
}

// Register 负责注册用户相关的路由
func (u *AuthRouter) Register(engine *gin.Engine) {
	// 创建一个路由组
	userGroup := engine.Group("/api/v1/auth")
	{
		userHandler := auths.NewHandler()
		userGroup.GET("/register", userHandler.Register)
	}
}
