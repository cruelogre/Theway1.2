local UIStoreState = class("UIStoreState",require("packages.statebase.UIState"))
local StoreCfg = require("hall.mediator.cfg.StoreCfg")

function UIStoreState:onLoad(lastStateName,param)
	self:init()
	UIStoreState.super.onLoad(self,lastStateName,param)

	--计费场景ID判断
	wwlog("UploadChargeScene:", lastStateName)
	local sceneIDKey, umengFlg
	if lastStateName == "UISiRenRoomState" then
		sceneIDKey = "PrivateRoom"
		--分场景上报友盟,
	    UmengManager:eventCount("StorePrivate")
	elseif lastStateName == "UIChooseRoomState" then
		sceneIDKey = "CustomRoom"
		
		UmengManager:eventCount("StoreClassic")
	elseif lastStateName == "UIMatchState" then
		sceneIDKey = "MatchRoom"

		umengFlg = param.umengFlg
		
		if umengFlg == "InsufficientCost" then
			UmengManager:eventCount("InsufficientCost") --报名费不足 弹出商城
		else
			UmengManager:eventCount("StoreMatch")
		end
	elseif lastStateName == "UISignState" then
		sceneIDKey = "SignIn"
	else
		sceneIDKey = "Shop"
		
		UmengManager:eventCount("HallStore")
	end

	local sceneID = wwCsvCfg.csvTable.StatisticalReport[sceneIDKey].SceneID or wwConfigData.CHARGE_STATUE_DEFAULT --如果取不到SceneID则设置为默认的

	StoreCfg.SceneID = sceneID

	wwlog("UploadChargeScene 2:", StoreCfg.SceneID)

end


function UIStoreState:init()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIStoreState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	StoreCfg.innerEventComponent = self._innerEventComponent
end

function UIStoreState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		StoreCfg.innerEventComponent = nil
	end
end

function UIStoreState:onStateEnter()
	cclog("UIStoreState onStateEnter")
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	
end
function UIStoreState:onStateExit()
	cclog("UIStoreState onStateExit")
	self:unbindInnerEventComponent()
	--print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end

return UIStoreState