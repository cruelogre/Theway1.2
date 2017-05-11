-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.15
-- Last:    
-- Content:  大厅状态机对应周期函数实现
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIWhippedEggSceneState = class("UIWhippedEggSceneState",
	require("packages.statebase.UIState"),require("packages.mvc.Mediator")
	)
local WhippedEggCfg = import(".WhippedEggCfg","WhippedEgg.mediator.cfg.")

local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local gamedata = ww.WWGameData:getInstance()

function UIWhippedEggSceneState:onLoad(lastStateName,param)
	self:init()
	UIWhippedEggSceneState.super.onLoad(self,lastStateName,param)

	--显示大厅内容
	self:getWhippedEggSceneMediator():onSceneEnter()
	
		--是否方言
	local switchTag = gamedata:getBoolForKey(SettingCfg.ConstData.SETTING_SOUNDCARD_SWITCH,true)
	GameModel:setSoundRegionType(switchTag and 0 or 1)
end


function UIWhippedEggSceneState:init()
	-- body
	self.logTag = "UIWhippedEggSceneState"
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()

	--断线重连
    self:registerEventListener("loginSucceed",function ( ... )
        -- body
        self:registGroundListener()
    end)
end

function UIWhippedEggSceneState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	WhippedEggCfg.innerEventComponent = self._innerEventComponent
end

function UIWhippedEggSceneState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		WhippedEggCfg.innerEventComponent = nil
	end
end


function UIWhippedEggSceneState:onStateEnter()
	UIWhippedEggSceneState.super.onStateEnter(self)
	self:getWhippedEggSceneMediator():initLogic()
	
	wwlog("UIWhippedEggSceneState onStateEnter")

	self:registGroundListener()
end

function UIWhippedEggSceneState:registGroundListener( ... )
	-- body
	if not self.BackgroundListener then
		self.BackgroundListener = cc.EventListenerCustom:create("applicationDidEnterBackground", function ( ... )
			-- body
			GameManageFactory:getCurGameManage():stopDealCard()
			GameManageFactory:getCurGameManage():clearGameData()

			ww.WWMsgManager:getInstance():logout()

			wwlog(self.logTag,"收到应用切换到后台消息")

			--经典】即将进入结算界面时，按home键后台运行程序，进入结算界面后再启动程序，界面卡在了牌局界面
			if MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic then 
				MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE).GameLogic.applicationDidEnterBackground = true
			end
		end)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.BackgroundListener,1)
	end

	if not self.ForegroundListener then
		self.ForegroundListener = cc.EventListenerCustom:create("applicationWillEnterForeground", function ( ... )
			-- body
			ww.WWMsgManager:getInstance():checkToConnect()

			--如果第三方登录 SDK会把我们游戏自动推到后台 
			local netWorkProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().NET_WORK)
			if netWorkProxy._is_third_party_login then
				self:unregistGroundListener()
			end

			wwlog(self.logTag,"收到应用唤醒到前台消息")
		end)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.ForegroundListener,1)
	end
end

function UIWhippedEggSceneState:onStateExit()
	wwlog("UIWhippedEggSceneState onStateExit")
	self:unbindInnerEventComponent()
	
	GameManageFactory:getCurGameManage():onExit()
	self:getWhippedEggSceneMediator():onSceneExit()

	self:unregistGroundListener()
    self:unregisterEventListener("loginSucceed")
end

function UIWhippedEggSceneState:unregistGroundListener( ... )
	-- body
	if self.BackgroundListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.BackgroundListener)
		self.BackgroundListener = nil
	end

	if self.ForegroundListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.ForegroundListener)
		self.ForegroundListener = nil
	end
end

function UIWhippedEggSceneState:getWhippedEggSceneMediator()

	return MediatorMgr:retrieveMediator(MediatorMgr:getMediatorRegistry().WHIPPEDEGG_SCENE)
end

return UIWhippedEggSceneState