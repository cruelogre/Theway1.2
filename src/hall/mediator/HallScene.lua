-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author: cruelogre
-- Date:    2016.12.15
-- Last:
-- Content:  大厅场景
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local HallScene = class("HallScene",require("app.views.uibase.WWSceneBase"))
function HallScene:ctor(param)
	HallScene.super.ctor(self)
	self.param = param
	self.logTag = self.__cname..".lua"
end

function HallScene:onEnter()
	HallScene.super.onEnter(self)
	wwlog(self.logTag,"大厅场景进入onEnter")
	--场景状态机初始化
	FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):onEntry({parentNode = self, zorder = 2,data = self.param})
	
end

return HallScene