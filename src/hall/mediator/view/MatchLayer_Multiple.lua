-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛组队塞界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer_Multiple = class("MatchLayer_Multiple",require("hall.mediator.view.MatchLayer_WindowBase"))

local MatchLayer_Friend = import(".MatchLayer_Friend","hall.mediator.view.")
local MatchLayer_widget_detail = require("hall.mediator.view.widget.MatchLayer_widget_detail")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

function MatchLayer_Multiple:ctor(matchData)
	self.matchData = matchData
	self:setName("MatchLayer_Multiple")
	MatchLayer_Multiple.super.ctor(self,matchData.MatchID)
	self.logTag = "MatchLayer_Multiple.lua"
end

function MatchLayer_Multiple:init(matchid)
	MatchLayer_Multiple.super.init(self,matchid)
	self.matchid = matchid
	self:setOpacity(156)
	self.qualification = true --默认满足报名资格
	self.handleFriends = {}
	print("MatchLayer_Multiple init")
	self.node = require("csb.hall.match.MatchLayer_matchfriend"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	

	--testing
	self.clickItem = false
	self.signType = 0 --请求的类型
	self.signData = 0 --请求的数据
	self.timeCount = 0
	self.refreshToGame = false --是否进入游戏的刷新
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	

	self:popIn(self.imgId,Pop_Dir.Right)
	
	
end


function MatchLayer_Multiple:onEnter()
	-- body
	print("MatchLayer_Multiple onEnter")
	MatchLayer_Multiple.super.onEnter(self)
	self:initViewData()
	self:initLocalText()
	if self.matchData then
		self:reloadData()
	else
		MatchProxy:requestMatchDetail(self.matchid)
	end
	--MatchProxy:requestMatchDetail(self.matchid)
	if self:eventComponent() then
		local x1,handleFriend1 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND,handler(self,self.reloadFriend))
		local x2,handleFriend2 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_AGREE_INVITE,handler(self,self.reloadFriend))

		--组队成功 已经报名
		local x3,handleFriend3 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_INVITE_SUCCESS, handler(self, self.reloadFriend1))
		--组队成功 未报名
		local x4,handleFriend4 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER, handler(self, self.reloadFriend1))
		--组队的好友退赛了
		local x5,handleFriend5 = self:eventComponent():addEventListener(
		MatchCfg.InnerEvents.MATCH_EVENT_FRIEND_QUIT, handler(self, self.timeout))
		table.insert(self.handleFriends,handleFriend1)
		table.insert(self.handleFriends,handleFriend2)
		table.insert(self.handleFriends,handleFriend3)
		table.insert(self.handleFriends,handleFriend4)
		table.insert(self.handleFriends,handleFriend5)

	end
	
end
function MatchLayer_Multiple:reloadFriend1(event)
	print("组队成功，重新请求好友列表")
	local msgTable = event._userdata
	MatchProxy:requestFriend(4,msgTable.InstMatchID or 0)
	
end
function MatchLayer_Multiple:onExit()
	MatchLayer_Multiple.super.onExit(self)
	if self:eventComponent() and self.handleFriends then
		for _,v in ipairs(self.handleFriends) do
			self:eventComponent():removeEventListener(v)
		end
		removeAll(self.handleFriends)
	end
end

function MatchLayer_Multiple:refreshContent()
	--print("MatchLayer_Multiple refreshContent",self.timeCount)
	self.titleText:setString(tostring(self.matchData.Name))
	self:refreshTime(self.matchData,self.timeText)
	self:refreshIcon()
	self:refreshCost(self.signText,self.matchData)
end

--倒计时时间到
function MatchLayer_Multiple:timeout()
	self:stopAllActions()
	self.timeCount = 0
	MatchProxy:requestMatchDetail(self.matchid)
end

function MatchLayer_Multiple:matchNotify(event)
	local msgTable = event._userdata
	if not msgTable then
		return
	end
	print("MatchLayer_Multiple:matchNotify",event.msgId)
	if event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER or
	event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT then --报名成功
		--改变按钮状态
		--报名成功，退赛成功
		self:timeout()
		if msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS or
		msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS_HAS_STARTED or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_ING or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_NOT_EXISTS then
			self.clickItem = false
		end
--[[		if msgTable.Type==7 or msgTable.Type==2 or msgTable.Type==3 then
			MatchProxy:requestMatchDetail(self.matchid)
		end--]]
		
	end
end
function MatchLayer_Multiple:reloadData(event)
	
	print("MatchLayer_Multiple:reloadData")
	
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	self.matchData =allMtchData[self.matchid]
	if not self.matchData then
		return
	end
	self.hasDataOnce = true
	--dump(self.matchData)
	self:stopAllActions()
	self.signType = 0 --请求的类型
	self.signData = 0 --请求的数据
	self.timeCount = 0
	self.hasFriend = false --是否有组队的朋友
	self.clickItem = false
--	self:refreshTime(self.matchData,self.timeText)
	self:refreshContent()
	if self.refreshToGame then
		--MatchProxy:requestSign(self.matchid,self.signType,self.signData)
	end
	self:reloadFriend()
end

--刷新图标
function MatchLayer_Multiple:refreshIcon()
	--BeginType
	
	if tonumber(self.matchData.BeginType)==1 then
	--人数
		self.alarmImg:loadTexture("match_desc_person.png",1)
	else
	--时间
		self.alarmImg:loadTexture("match_desc_alarm.png",1)
	end
		local num = self:getMaxAwardCount(self.matchid)
	if tonumber(self.matchData.TeamWork)==1 then
		--num = num / 2
	end
		ccui.Helper:seekWidgetByName(self.imgId,"Text_condition"):setString(
	string.format(i18n:get('str_match','match_award_count'),num))
end


function MatchLayer_Multiple:reloadFriend(event)
	--self:timeout() --刷新
	local mateinfo = nil
	local friendLists = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND)
	--dump(friendLists)
	
	--有数据，有朋友
	if friendLists and friendLists.mateList and next(friendLists.mateList) then
		for _,mate in pairs(friendLists.mateList) do
			if mate.UserID== self.matchData.TeammateID then
				mateinfo = mate
				break
			end
		end
	end
	if mateinfo then
		self.hasFriend = true
		--self:refreshFriendView(mateinfo)
	else
		self.hasFriend = false
		--没朋友的
	end
	self:refreshFriendView(mateinfo)
	
end
--刷新好友的显示信息
function MatchLayer_Multiple:refreshFriendView(mateinfo)
	self.friendHead:removeAllChildren()
	if mateinfo then
		self.friendName:setString(tostring(mateinfo.Nickname))
		local param = {
			headFile= DataCenter:getUserdataInstance():getHeadIconByGender(mateinfo.Gender and tonumber(mateinfo.Gender) or 1),
			maskFile="#match_mate_bg_header.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=104,
	        headIconType = mateinfo.IconID,
	        userID = mateinfo.UserID
		}
		--

		local HeadSprite = WWHeadSprite:create(param)
		HeadSprite:setPosition(cc.p(104,104))
		self.friendHead:addChild(HeadSprite)
	else
		self.friendName:setString(i18n:get('str_match','match_invite_friend'))
	end
	
	
	
	
end

function MatchLayer_Multiple:initViewData()
	self.friendHead = ccui.Helper:seekWidgetByName(self.imgId,"Image_head2")
	self.friendHead:addTouchEventListener(handler(self,self.touchListener))
	self.friendName = ccui.Helper:seekWidgetByName(self.imgId,"Text_name2")
	
	ccui.Helper:seekWidgetByName(self.imgId,"Image_condition"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_rule"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Image_quit"):addTouchEventListener(handler(self,self.touchListener))
	self.titleText = ccui.Helper:seekWidgetByName(self.imgId,"Text_title")
	self.titleText:setString("")
	self.timeText = ccui.Helper:seekWidgetByName(self.imgId,"Text_time")
	self.alarmImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_alarm")
	--Text_title
	-----------------------------我的信息----------------------------
		--头像
	self.headImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_head1")
	
	local param = {
		headFile=DataCenter:getUserdataInstance():getHeadIcon(),
		maskFile="#match_mate_bg_header.png",
		frameFile = "common/common_userheader_frame_userinfo.png",
		headType=1,
		radius=104,
        headIconType = DataCenter:getUserdataInstance():getValueByKey("IconID"),
        userID = DataCenter:getUserdataInstance():getValueByKey("userid") 
	}
		--
	local HeadSprite = WWHeadSprite:create(param)
	HeadSprite:setPosition(cc.p(104,104))
	self.headImg:addChild(HeadSprite)
	--名字
	local mynickname = DataCenter:getUserdataInstance():getValueByKey("nickname")
	local myuserid = DataCenter:getUserdataInstance():getValueByKey("userid")
	
	local nameText = ccui.Helper:seekWidgetByName(self.imgId,"Text_name1")
	if mynickname and string.len(mynickname)>0 then
		nameText:setString(mynickname)
	else
		nameText:setString(tostring(myuserid))
	end
	
	-----------------------------组队队友的信息----------------------------
	--我报名了 并且有组队的好友
	if tonumber(self.matchData.MyEnterFlag)==1 and self.matchData.TeammateID~=0 then
		--先显示队友的ID 在更新头像和名字
		local mateinfo = nil --是否有这个好友
		local friendLists = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND)
		if friendLists and friendLists.mateList and next(friendLists.mateList) then
			for _,mate in pairs(friendLists.mateList) do
				if mate.UserID== self.matchData.TeammateID then
					mateinfo = mate
					
					break
				end
			end
		end
		if mateinfo then
			self.hasFriend = true
			self:refreshFriendView(mateinfo)
		else
			self.hasFriend = true
			self.friendName:setString(tostring(self.matchData.TeammateID))
			MatchProxy:requestFriend(4,self.matchData.InstID)
		end
		
	end
	
	self.signText = ccui.Helper:seekWidgetByName(self.imgId,"Text_sign")
	--这里用富文本来替换
	local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:addTo(self.signText:getParent())
	richText:setName("Text_sign")
	richText:setPosition(self.signText:getPositionX(),self.signText:getPositionY())
	self.textFontSize = self.signText:getFontSize()
	self.textFontColor = self.signText:getTextColor()
	self.signText:removeFromParent()
	self.signText = richText
	
	
end

function MatchLayer_Multiple:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		wwlog(self.logTag,"别TM瞎点了00000%s,%s",tostring(self.clickItem),tostring(LoadingManager:isShowing()))
		if self.clickItem or LoadingManager:isShowing() then
			wwlog(self.logTag,"别TM瞎点了")
				return
			end
		self.clickItem = true
		
		local name = ref:getName()
		if name == "Image_head2" then
		--添加好友
		--没有组队的情况 如果组队了 就没有添加好友了
			if not self.hasFriend then
				print("没有朋友，去加好友")
				self.isTopLayer = false
				--传入比赛实例ID
				local detail = MatchLayer_Friend:create(self.matchid,self.matchData.InstID)
				detail:bindCloseCB(handler(self,self.frontClosed))
				cc.Director:getInstance():getRunningScene():addChild(detail,5)

				UmengManager:eventCount("AddFreind")
			else
				print("我有朋友的，不用添加了")
			end
			
		elseif name == "Image_condition" then
			--奖励条件
			print("奖励条件")
			self.isTopLayer = false
			local condition = MatchLayer_widget_detail:create(self:formatAward(self.matchData.MatchID))
			condition:setCid(2)
			condition:bindCloseCB(handler(self,self.frontClosed))
			cc.Director:getInstance():getRunningScene():addChild(condition,5)
		elseif name == "Button_rule" then
			--规则
			print("规则")
			self.isTopLayer = false
			local detail = MatchLayer_widget_detail:create(self.matchData.Desc)
			detail:setCid(5)
			detail:bindCloseCB(handler(self,self.frontClosed))
			cc.Director:getInstance():getRunningScene():addChild(detail,5)
		elseif name == "Image_quit" then
			--退赛
			--是否报名
			if tonumber(self.matchData.MyEnterFlag)==0 then --未报名
				if self.qualification then
					--满足报名条件
					local cost = {signType = self.signType,signData = self.signData}
					DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_COST,cost)
					
					self.refreshToGame = true
					self:stopAllActions()
					self.timeCount = 0
					MatchProxy:requestSign(self.matchid,self.signType,self.signData)
					--MatchProxy:requestMatchDetail(self.matchid)
				else
					--不满足报名条件
					self.isTopLayer = false
					
					local reward = MatchLayer_widget_detail:create(self.matchData.SignupTermDesc)
					reward:setCid(1)
					reward:bindCloseCB(handler(self,self.frontClosed))
					cc.Director:getInstance():getRunningScene():addChild(reward,5)
				end
			else
				--已经报名 退赛
				MatchProxy:quitSign(self.matchid)
			end
			--MatchProxy:quitSign(self.matchid)
		end
	end
	
	
	
end

--顶层关闭的回调
function MatchLayer_Multiple:frontClosed(force)
	print("MatchLayer_Multiple frontClosed",self.needFresh)
	self.isTopLayer = true
	self.clickItem = false
--[[	self.isTopLayer = true
	self.clickItem = false
	if self.needFresh or force then
		
		MatchProxy:requstMatchList()
		self.contentOffset = self.tableView:getContentOffset()
	end--]]
	
end

function MatchLayer_Multiple:initLocalText()
	
end

return MatchLayer_Multiple