local WhippedEggScene = class("WhippedEggScene",require("app.views.uibase.WWSceneBase"))
function WhippedEggScene:ctor(callback)
	WhippedEggScene.super.ctor(self,callback)
	self.logTag = self.__cname..".lua"
end

function WhippedEggScene:onEnter()
	WhippedEggScene.super.onEnter(self)
	wwlog(self.logTag,"游戏场景进入onEnter")
	--场景状态机初始化
	FSRegistryManager:runWithFSM(FSMConfig.FSM_WHIPPEDEGG):onEntry(self)
end

return WhippedEggScene