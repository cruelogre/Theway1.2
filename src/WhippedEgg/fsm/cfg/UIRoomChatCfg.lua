-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.15
-- Last:    
-- Content:  大厅状态机根配置
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local registry = {
	enter = {
		{eventName="win";stateName="UIGDGameoverWinState"},
		{eventName="lose";stateName="UIGDGameoverLoseState"},
	};

}
local tempRegistry = {}
table.merge(tempRegistry,require("hall.fsm.cfg.UIRoomChatCfg"))
table.merge(tempRegistry.enter,registry.enter)
return tempRegistry