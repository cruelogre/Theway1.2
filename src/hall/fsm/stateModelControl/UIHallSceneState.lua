-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:
-- Date:    2016.08.15
-- Last:    
-- Content:  大厅状态机对应周期函数实现
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local UIHallSceneState = class("UIHallSceneState",
	require("packages.statebase.UIState"),
	require("packages.mvc.Controller"))

local HallCfg = require("hall.mediator.cfg.HallCfg")
local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local gamedata = ww.WWGameData:getInstance()
local GameModel = require("WhippedEgg.Model.GameModel")

function UIHallSceneState:ctor()
	self:initEvent()
	self.super.ctor(self)
	self.logTag = "UIHallSceneState.lua"
	wwlog(self.logTag,"UIHallSceneState ctor")
	
	
end

function UIHallSceneState:initEvent()
	-- body
	self._innerEventComponent = {}
	self._innerEventComponent.isBind = false
	self:bindInnerEventComponent()
end

function UIHallSceneState:bindInnerEventComponent()
	-- body
	self:unbindInnerEventComponent()

	cc.bind(self._innerEventComponent, "event")
	self._innerEventComponent.isBind = true
	HallCfg.innerEventComponent = self._innerEventComponent
end

function UIHallSceneState:unbindInnerEventComponent()
	-- body
	if self._innerEventComponent.isBind then 
		cc.unbind(self._innerEventComponent, "event")
		self._innerEventComponent.isBind = false
		HallCfg.innerEventComponent = nil
	end
end

function UIHallSceneState:onLoad(lastStateName,param)
		--显示大厅内容
--[[	local reslist = {
		"hall/plist/halltop.plist",
		"hall/plist/hallbottom.plist",
		"hall/plist/hallcontent.plist",
		"hall/animation/hall_plist1.plist",
	}
	for _,v in pairs(reslist) do
		cc.SpriteFrameCache:getInstance():addSpriteFrames(v)
	end--]]
	--cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/plist/halltop.plist")
	--cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/plist/hallbottom.plist")
	--cc.SpriteFrameCache:getInstance():addSpriteFrames("hall/plist/hallcontent.plist")
	
	UIHallSceneState.super.onLoad(self,lastStateName,param)
	self.param = param
	--是否方言
	local switchTag = gamedata:getBoolForKey(SettingCfg.ConstData.SETTING_SOUNDCARD_SWITCH,true)
	GameModel:setSoundRegionType(switchTag and 0 or 1)
	
	
	require("app.netMsgCfg.NetWorkCfg")
	import(".NetEventId", "app.netMsgCfg.")
end
function UIHallSceneState:onStateEnter()
	UIHallSceneState.super.onStateEnter(self)
	--self:getMainSceneMediator():showView()
	if isLuaNodeValid(self.viewNode) then
		self.viewNode:setContentVisible(FSRegistryManager:getJumpState() ==nil)
	end
	--self:getMainSceneMediator():setContentVisible(FSRegistryManager:getJumpState() ==nil)
	self:getMainSceneMediator():onSceneEnter()
	self:getMatchMediator():onSceneEnter()
	wwlog(self.logTag,"UIHallSceneState onStateEnter")
	-- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	local enterOK = true
	if self.param.data and self.param.data[1] == HALL_ENTERINTENT.ENTER_NETWORK_ERROR then
		enterOK = false
		--这里网络出问题了，直接发送网络不可用的消息
		self.rootNode:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.3),
		cc.CallFunc:create(function ()
			if NetWorkCfg.innerEventComponent then
				NetWorkCfg.innerEventComponent:dispatchEvent({
					name = NetWorkCfg.InnerEvents.NETWORK_EVENT_ERROR;
					_userdata = NetEventId.Event_onExceptionCaught 
				})
			end
		end))
		)
		
		
		
				
	elseif self.param.data and self.param.data[1] == HALL_ENTERINTENT.ENTER_LOGINING then
		enterOK = false
		LoadingManager:startLoading()
	end
	if enterOK then
		self.rootNode:runAction(cc.Sequence:create(
		cc.CallFunc:create(function ()
			if FSRegistryManager:getJumpState() ~=nil then
				local jumParam = FSRegistryManager:getJumpParam()
				if jumParam then
					jumParam.parentNode=display.getRunningScene()
				end
				wwlog(self.logTag,FSRegistryManager:getJumpState())
				FSRegistryManager:currentFSM():trigger(
				FSRegistryManager:getJumpState(),jumParam or {parentNode=display.getRunningScene(), zorder=3})
				FSRegistryManager:clearJumpState()
			end
			
			if HallCfg.enterView then
				wwlog(self.logTag,"------HallCfg.enterView---------------------")
				local enterView = HallCfg.enterView:create(HallCfg.enterViewData)
				display.getRunningScene():addChild(enterView,HallCfg.enterViewOrder)
				HallCfg.enterView = nil
			end
		end))
		)
	end
	self:refreshRedPoint()
	
	wwlog(self.logTag,cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end
function UIHallSceneState:refreshRedPoint()
	local recentSignKey = ww.WWGameData:getInstance():getIntegerForKey(COMMON_TAG.C_RECENTSIGN_DAY,0)
	local curTime = os.date("*t")
	curTime.min = 0
	curTime.sec = 0
	curTime.hour = 0
	local tt = os.time(curTime)
	WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "sign", recentSignKey~=tt)

	
end

function UIHallSceneState:onStateExit()
	UIHallSceneState.super.onStateExit(self)
	

	self:getMainSceneMediator():onSceneExit()
	self:getMatchMediator():onSceneExit()
	-- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end
function UIHallSceneState:onStateResume()

	UIHallSceneState.super.onStateResume(self)
	self:refreshRedPoint()
	--self:getMainSceneMediator():setContentVisible(FSRegistryManager:getJumpState() ==nil)
	local loginMsg = DataCenter:getData(COMMON_TAG.C_LOGIN_MESSAGE)
	if isLuaNodeValid(self.viewNode) and loginMsg and next(loginMsg) and loginMsg.hallversion then
		self.viewNode:setContentVisible(FSRegistryManager:getJumpState() ==nil)
		self:getMainSceneProxy():requestHallSceneList(1)
		self:getMainSceneProxy():requestHallSceneList(2)
		self:getMainSceneProxy():requestHallSceneList(3)
	end
end

function UIHallSceneState:onStatePause()
	UIHallSceneState.super.onStatePause(self)
	
end

function UIHallSceneState:getMainSceneProxy()
	return self:getProxy(self:getProxyRegistry().HALL_SCENE)
end

function UIHallSceneState:getMainSceneMediator()

	return self:getMediator(self:getMediatorRegistry().HALL_SCENE)
end
function UIHallSceneState:getMatchMediator()

	return self:getMediator(self:getMediatorRegistry().MATCH_SCENE)
end

return UIHallSceneState