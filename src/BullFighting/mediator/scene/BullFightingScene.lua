local BullFightingScene = class("BullFightingScene",require("app.views.uibase.WWSceneBase"))
function BullFightingScene:ctor(callback)
	BullFightingScene.super.ctor(self,callback)
	self.logTag = self.__cname..".lua"
end

function BullFightingScene:onEnter()
	BullFightingScene.super.onEnter(self)
	wwlog(self.logTag,"游戏场景进入onEnter")
	--场景状态机初始化
	FSRegistryManager:runWithFSM(FSMConfig.FSM_BULLFIGHTING):onEntry(self)
end

return BullFightingScene