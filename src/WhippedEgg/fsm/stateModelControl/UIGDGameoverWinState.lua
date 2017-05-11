-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2017.1.5
-- Last:    
-- Content:  惯蛋结算状态机对应周期函数实现
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIGDGameoverWinState = class("UIGDGameoverWinState",
	require("packages.statebase.UIState")
	)
local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")

local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local gamedata = ww.WWGameData:getInstance()

function UIGDGameoverWinState:onLoad(lastStateName,param)
	
	UIGDGameoverWinState.super.onLoad(self,lastStateName,param)
	self:init()
	--显示大厅内容

end


function UIGDGameoverWinState:init()
	-- body

end


function UIGDGameoverWinState:onStateEnter()
	UIGDGameoverWinState.super.onStateEnter(self)

end


return UIGDGameoverWinState