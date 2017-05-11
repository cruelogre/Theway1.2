-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.13
-- Last: 
-- Content:  比赛界面中的好友列表
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchLayer_widget_friendList = class("MatchLayer_widget_friendList",ccui.Layout)
local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local MatchLayer_widget_friendLayout = require("hall.mediator.view.widget.MatchLayer_widget_friendLayout")

function MatchLayer_widget_friendList:ctor(size,matchid,InstMatchID)
	self.size = size
	self.InstMatchID = InstMatchID
	self.matchid = matchid
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.logTag = self.__cname..".lua"
	self:init()
	
	wwlog(self.logTag,"好友列表 比赛ID matchid=%s 实例ID InstMatchID=%s",tostring(matchid),tostring(InstMatchID))
end

function MatchLayer_widget_friendList:init()
	print("MatchLayer_widget_friendList:init")
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
	


	
end 
--绑定切换的回调 切换到另外一个切页
function MatchLayer_widget_friendList:bindChangeFun(cbFun)
	self._cbFun = cbFun
end

function MatchLayer_widget_friendList:initView(...)
	
	
	
end

--刷新内容
function MatchLayer_widget_friendList:freshContent(content)
	
	
end


function MatchLayer_widget_friendList:eventComponent()
	return MatchCfg.innerEventComponent
end

function MatchLayer_widget_friendList:onEnter()
	
	local x1,handle1 = self:eventComponent():addEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND,handler(self,self.reloadData))
	local x2,handle2 = self:eventComponent():addEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER,handler(self,self.matchNotify))
	local x3,handle3 = self:eventComponent():addEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT,handler(self,self.matchNotify))
	local x4,handle4 = self:eventComponent():addEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_REFUSE_INVITE,handler(self,self.matchNotify))
	local x5,handle5 = self:eventComponent():addEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_FACE,handler(self,self.matchNotify))
	local x6,handle6 = self:eventComponent():addEventListener(
	MatchCfg.InnerEvents.MATCH_EVENT_START_DATA,handler(self,self.matchNotify))
	--MatchCfg.InnerEvents.MATCH_EVENT_AGREE_INVITE
	
	self.handle1 = handle1
	self.handle2 = handle2
	self.handle3 = handle3
	self.handle4 = handle4
	self.handle5 = handle5
	self.handle6 = handle6
	
	self:requestFriend()
	--MatchProxy:requstMatchList()
	
	--每隔30s 刷新一次
	local seq = cc.Sequence:create(cc.DelayTime:create(MatchCfg.mateRequestInterval),
		cc.CallFunc:create(handler(self,self.requestFriend)))
	self:runAction(cc.RepeatForever:create(seq))
	
end


function MatchLayer_widget_friendList:matchNotify(event)
	local msgTable = event._userdata
	if not msgTable then
		return
	end
	dump(msgTable)
	--重新请求一次好友列表
	self:requestFriend()
	if event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER or
	event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT then --报名成功
		--改变按钮状态
		--报名成功，退赛成功
		self:stopAllActions()
		if msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS or
		msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS_HAS_STARTED or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_ING or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_NOT_EXISTS then
			
		end
--[[		if msgTable.Type==7 or msgTable.Type==2 or msgTable.Type==3 then
			MatchProxy:requestMatchDetail(self.matchid)
		end--]]
		
	end
end

--请求数据
function MatchLayer_widget_friendList:requestFriend()
	--请求的时间到了 这里，如果比赛已经开始了，或者取消了 就不再请求了
	MatchProxy:requestFriend(4,self.InstMatchID)
end

function MatchLayer_widget_friendList:reloadData(event)
	print("MatchLayer_widget_friendList:reloadData")
	
	
	local hasFriend = false
	local friendLists = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND)
	
	dump(friendLists)
	
	--有数据，有朋友
	if friendLists and friendLists.mateList and next(friendLists.mateList) then
		hasFriend = true
	end
	
	if hasFriend then
		--有朋友  显示好友
		if self.friend then
			self.friend:removeFromParent()
			self.friend = nil
		end
		if not isLuaNodeValid(self.friendlayout) then
			self.friendlayout = MatchLayer_widget_friendLayout:create(self.size,self.matchid,self.InstMatchID)
		
			self:addChild(self.friendlayout,1)
		end
		self.friendlayout:reloadData(friendLists.mateList)
	else
		--没朋友 显示添加好友
		
		if isLuaNodeValid(self.friendlayout) then
			self.friendlayout:removeFromParent()
			self.friendlayout =  nil
		end
		self:removeAllChildren()
		self.friend = require("csb.hall.match.MatchLayer_widget_noFriend"):create().root
		FixUIUtils.setRootNodewithFIXED(self.friend)
		local panel1 = self.friend:getChildByName("Panel_1")
		
		FixUIUtils.stretchUI(panel1)
		self:addChild(self.friend,1)
		
		ccui.Helper:seekWidgetByName(panel1,"Button_add"):addTouchEventListener(handler(self,self.touchListener))
		
	end
	
	return hasFriend
end

function MatchLayer_widget_friendList:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		if name == "Button_add" then
		--添加好友
			--激活另一个切页
			if self._cbFun then
				self._cbFun()
			end
		end
	end
	
	
	
end

function MatchLayer_widget_friendList:onExit()
	--self._cbFun = nil
	if self:eventComponent() then
		self:eventComponent():removeEventListener(self.handle1)
		self:eventComponent():removeEventListener(self.handle2)
		self:eventComponent():removeEventListener(self.handle3)
		self:eventComponent():removeEventListener(self.handle4)
		self:eventComponent():removeEventListener(self.handle5)
		self:eventComponent():removeEventListener(self.handle6)
	end
	if isLuaNodeValid(self.friendlayout) then
		self.friendlayout:removeFromParent()
		self.friendlayout =  nil
	end
	self:stopAllActions()
end
function MatchLayer_widget_friendList:active()
	print("MatchLayer_widget_friendList active")
	--激活的时候，先显示好友，在请求
	
	if not self:reloadData() then --如果没有好友，就请求一次
		MatchProxy:requestFriend(4,self.InstMatchID)
	end
end

return MatchLayer_widget_friendList