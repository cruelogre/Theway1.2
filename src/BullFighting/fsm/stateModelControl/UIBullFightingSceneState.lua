-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.15
-- Last:    
-- Content:  大厅状态机对应周期函数实现
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIBullFightingSceneState = class("UIBullFightingSceneState",
	require("packages.statebase.UIState")
	)

local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local gamedata = ww.WWGameData:getInstance()
local BullFinghtingCfg = require("BullFighting.mediator.cfg.BullFinghtingCfg")

function UIBullFightingSceneState:onLoad(lastStateName,param)
	UIBullFightingSceneState.super.onLoad(self,lastStateName,param)

	--显示大厅内容
	self:init()
	self:getBullFightingSceneMediator():onSceneEnter()
	
		--是否方言
	local switchTag = gamedata:getBoolForKey(SettingCfg.ConstData.SETTING_SOUNDCARD_SWITCH,true)
	-- GameModel:setSoundRegionType(switchTag and 0 or 1)

	self.getBackgroundListener = false
	self.getForegroundListener = true
end


function UIBullFightingSceneState:init()
	-- body
	self.logTag = "UIBullFightingSceneState"
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIBullFightingSceneState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	BullFinghtingCfg.innerEventComponent = self._innerEventComponent
end

function UIBullFightingSceneState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		BullFinghtingCfg.innerEventComponent = nil
	end
end


function UIBullFightingSceneState:onStateEnter()
	UIBullFightingSceneState.super.onStateEnter(self)
	self:getBullFightingSceneMediator():initLogic()
	
	wwlog("UIBullFightingSceneState onStateEnter")
	if not self.BackgroundListener then
		self.BackgroundListener = cc.EventListenerCustom:create("applicationDidEnterBackground", function ( ... )
			-- body
			if not self.getBackgroundListener then
				self.getBackgroundListener = true
				self.getForegroundListener = false
				wwlog(self.logTag,"收到牛牛应用切换到后台消息")
				BullFightingManage:clearGame()

				local BullFightingSceneMediator = MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().BULLFIGHTING_SCENE)
				if BullFightingSceneMediator and BullFightingSceneMediator:getLogic() then
					BullFightingSceneMediator:getLogic().innorRoomswitch = false
				end
			end
		end)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.BackgroundListener,1)
	end

	if not self.ForegroundListener then
		self.ForegroundListener = cc.EventListenerCustom:create("applicationWillEnterForeground", function ( ... )
			-- body
			if not self.getForegroundListener then
				self.getForegroundListener = true
				self.getBackgroundListener = false
				wwlog(self.logTag,"收到牛牛应用唤醒到前台消息")
				local BullFightingSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().BULLFIGHTING_SCENE)
				local BullFightingSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().BULLFIGHTING_SCENE)

				BullFightingSceneProxy:requestLobbyActionHandle(BullFightingSceneController.GameZoneID, 13)  --请求进入随机、看牌场房间
			end
		end)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.ForegroundListener,1)
	end
end

function UIBullFightingSceneState:onStateExit()
	wwlog("UIBullFightingSceneState onStateExit")
	self:unbindInnerEventComponent()
	
	BullFightingManage:onExit()
	self:getBullFightingSceneMediator():onSceneExit()

	if self.BackgroundListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.BackgroundListener)
		self.BackgroundListener = nil
	end

	if self.ForegroundListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.ForegroundListener)
		self.ForegroundListener = nil
	end
end

function UIBullFightingSceneState:getBullFightingSceneMediator()

	return MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().BULLFIGHTING_SCENE)
end

return UIBullFightingSceneState