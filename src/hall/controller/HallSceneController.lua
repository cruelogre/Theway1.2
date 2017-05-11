local HallSceneController = class("HallSceneController", require("packages.mvc.Controller"))

import(".HallEvent", "hall.event.")

import(".wwGameConst","app.config.")
import(".wwConst","app.config.")
import(".wwConfigData","app.config.")

function HallSceneController:init()

	--注册大厅进入事件
	self:registerEventListener(HALL_SCENE_EVENTS.MAIN_ENTRY, handler(self, self.onSceneEntry))
end

--进入场景
function HallSceneController:onSceneEntry(event)

	self.Scenename = "HallScene"
	
	wwlog(self.Scenename, "进入大厅场景......")

	--初始化大厅组件构造
	self:getMainSceneMediator():onCreate(event._userdata)
	
end

function HallSceneController:getMainSceneProxy()
	return self:getProxy(self:getProxyRegistry().HALL_SCENE)
end

function HallSceneController:getMainSceneMediator()

	return self:getMediator(self:getMediatorRegistry().HALL_SCENE)
end

return HallSceneController
