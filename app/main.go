package main

import (
	"Faber-AI/app/internal/inits"

	"github.com/mszlu521/thunder/config"
	"github.com/mszlu521/thunder/logs"
	"github.com/mszlu521/thunder/server"
)

func main() {
	// 加载配置
	config.Init()
	conf := config.GetConfig()
	// 加载日志
	logs.Init(conf.Log)
	s := server.NewServer(conf)
	// 初始化模块
	inits.Init(s, conf)
	s.Start()
}
