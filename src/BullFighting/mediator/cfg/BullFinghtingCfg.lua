local BullFinghtingCfg = {}

BullFinghtingCfg.innerEventComponent = nil
BullFinghtingCfg.InnerEvents = {
	DN_EVENT_GAMESTART = "DN_EVENT_GAMESTART", --斗牛游戏开局消息
	DN_EVENT_SHOWPOKER = "DN_EVENT_SHOWPOKER", --亮牌
	DN_EVENT_STARTBETSHOW = "DN_EVENT_STARTBETSHOW", --通知下注/ 亮牌
	DN_EVENT_BET = "DN_EVENT_BET", --响应玩家下注
	DN_EVENT_GAMEOVER = "DN_EVENT_GAMEOVER", --牌局结束
	DN_EVENT_INNORROOM = "DN_EVENT_INNORROOM", --响应进入房间
	DN_EVENT_NOTICEINOUT = "DN_EVENT_NOTICEINOUT", --通知进/出房间(随机、看牌新玩法)
	DN_EVENT_USERINFO_RESP = "DN_EVENT_USERINFO_RESP", --斗牛玩家信息
}


return BullFinghtingCfg