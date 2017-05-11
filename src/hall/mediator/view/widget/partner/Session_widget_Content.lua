-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  任务页面控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Session_widget_Content = class("Session_widget_Content",
	ccui.Layout,
	require("packages.mvc.Mediator"))

local NodePartnerSession = require("csb.hall.cardpartner.NodePartnerSession")
local ChatSessionLayer = require("hall.mediator.view.ChatSessionLayer")

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")

local HallChatService = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)

local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
local UserInfoProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)
local UserDataCenter = DataCenter:getUserdataInstance()

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

function Session_widget_Content:ctor(size)
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.sessionData = {}
	self.contentOffset = nil
	self.firstX = nil --第一个触摸移动时 需要记录的位置
	self.sameFirstX = nil --上一个
	self.originX = nil --item 背景原始的横坐标
	
	self.taskCount = 0
	self.preTouchNode = nil --之前触摸的节点
	self.imgDeleteSize = cc.size(0,0) --删除按钮的尺寸
	self.logTag = self.__cname..".lua"
	
	self.handlers = {}
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function Session_widget_Content:initView()
	wwlog(self.logTag,"Session_widget_Content:initView")
	
	
	self.tableView = cc.TableView:create(cc.size(self.size.width,self.size.height))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(cc.p(0,0))
    self.tableView:setDelegate()
    self:addChild(self.tableView,1)
	self.tableView:setVerticalFillOrder(0) --竖直方向 填充顺序 从上到下
    self.tableView:registerScriptHandler(handler(self,Session_widget_Content.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,Session_widget_Content.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,Session_widget_Content.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,Session_widget_Content.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,Session_widget_Content.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,Session_widget_Content.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableView:registerScriptHandler(handler(self,Session_widget_Content.scrollViewWillRecycle),cc.TABLECELL_WILL_RECYCLE)

	--tableview 中触摸移动
	self.tableView:registerScriptHandler(handler(self,Session_widget_Content.cellMoved),ww.TABLECELL_MOVED)
	-- tableview 中触摸取消
	self.tableView:registerScriptHandler(handler(self,Session_widget_Content.cellTouchEnded),ww.TABLECELL_TOUCHENDED)
	-- tableview 中长按
	self.tableView:registerScriptHandler(handler(self,Session_widget_Content.longTouched),ww.TABLECELL_LONGTOUCHED)
	--TABLECELL_WILL_RECYCLE
	
end
function Session_widget_Content:onEnter()
	wwlog(self.logTag,"Session_widget_Content:onEnter")
	self:initView()
	self:reigstMsg()
	self:reloadSession()
	
end
--上层界面关闭的回调
function Session_widget_Content:onResume()
	self:reloadSession()
end

function Session_widget_Content:reigstMsg()
	if self:getEventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:getEventComponent():addEventListener(
			CardPartnerCfg.InnerEvents.CP_EVENT_SESSION_LIST,handler(self,self.reloadSession))
		_,self.handlers[#self.handlers+1] = self:getEventComponent():addEventListener(
			CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED_ROOT,handler(self,self.reloadSession))
		_,self.handlers[#self.handlers+1] = self:getEventComponent():addEventListener(
			CardPartnerCfg.InnerEvents.CP_EVENT_REFUSE_FRINED_ROOT,handler(self,self.reloadSession))
		_,self.handlers[#self.handlers+1] = self:getEventComponent():addEventListener(
			CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED,handler(self,self.reloadSession))
		_,self.handlers[#self.handlers+1] = self:getEventComponent():addEventListener(
			CardPartnerCfg.InnerEvents.CP_EVENT_REFUSE_FRINED,handler(self,self.reloadSession))
	end
    self._handles = { } or self._handles
    local _ = nil
	if UserInfoCfg.innerEventComponent then
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(
			UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self.refreshInfo))
	else
		self:registerEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self.refreshInfo))
	end
end

function Session_widget_Content:unregistMsg()
	if self:getEventComponent() and self.handlers then
		for _,v in pairs(self.handlers) do
			self:getEventComponent():removeEventListener(v)
		end
	end
	if UserInfoCfg.innerEventComponent and self._handles then
		for _,v in pairs(self._handles) do
			UserInfoCfg.innerEventComponent:removeEventListener(v)
		end
	end
	removeAll(self._handles)
	removeAll(self.handlers)
	self:unregisterEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO)
end
function Session_widget_Content:reloadSession(event)
	local dataStruct = {}
	dataStruct.receiverid = tonumber(UserDataCenter:getValueByKey("userid"))
	self.sessionDatas = HallChatService:getSession(dataStruct)
	self.sessionCount = self.sessionDatas and #self.sessionDatas or 0
	
--[[	--监测是否还有未读的消息 更新红点
	local hasRed = false
	for _,sessionData in pairs(self.sessionDatas) do
		if sessionData.isread > 0 then
			hasRed = true --有红点
			break
		end
	end--]]
	 --有红点 通知是否显示
	WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "cardPartner",HallChatService:hasUnreadMsg())
	
	
	
	
	local needScoll = false
	if self.contentOffset then
		needScoll = true
	end
	self.tableView:reloadData()
	if needScoll then --是否需要滚动，刷新保留之前的位置
		local minOffset = self.tableView:minContainerOffset()
		local maxOffset = self.tableView:maxContainerOffset()
		self.contentOffset.x = math.min(self.contentOffset.x,maxOffset.x)
		self.contentOffset.x = math.max(self.contentOffset.x,minOffset.x)
		self.tableView:setContentOffset(self.contentOffset)
	end
end

function Session_widget_Content:onExit()
	
	wwlog(self.logTag,"Session_widget_Content:onExit")
	self:unregistMsg()	
	if isLuaNodeValid(self.tableView) then
		self.tableView:removeFromParent()
	end
	
	removeAll(self._queryUserDatas)
end

function Session_widget_Content:active()
	
end

function Session_widget_Content:scrollNodeBack(cell)
	if not isLuaNodeValid(cell) then
		return
	end
	local preSNode = cell:getChildByName("sessionNode")
	if isLuaNodeValid(preSNode) then
		local preImgBg = preSNode:getChildByName("Image_bg")
		if isLuaNodeValid(preImgBg) then
			--preImgBg:setPositionX(self.originX)
			preImgBg:runAction(cc.MoveTo:create(0.05,cc.p(self.originX,preImgBg:getPositionY())))
		end
	end	
end
function Session_widget_Content:cellMoved(view,cell,x,y)
	--print("cellMoved...",cell:getIdx(),x,y)
	
	local sessionNode = cell:getChildByName("sessionNode")
	local tag= sessionNode:getTag()
	local sessionData = self.sessionDatas[tag+1]
	if sessionData and sessionData.sessionType==1 then --好友申请不能删除
		return
	end
	local imgbG = sessionNode:getChildByName("Image_bg")
	if not self.firstX and self.originX then
		self.firstX = x
		if not self.sameFirstX then
			self.sameFirstX = self.firstX
		end
		if isLuaNodeValid(self.preTouchNode) and self.preTouchNode~=cell then
			--还原
			self.sameFirstX = nil
			self:scrollNodeBack(self.preTouchNode)
			self.preTouchNode = nil
--[[			local preSNode = self.preTouchNode:getChildByName("sessionNode")
			if isLuaNodeValid(preSNode) then
				local preImgBg = preSNode:getChildByName("Image_bg")
				if isLuaNodeValid(preImgBg) then
					preImgBg:setPositionX(self.originX)
					self.preTouchNode = nil
				end
			end	--]]		
		end
	elseif not self.firstX then
		self.firstX = x
		if not self.sameFirstX then
			self.sameFirstX = self.firstX
		end
	end
	if not self.originX then
		self.originX = imgbG:getPositionX()
	end


	if self.preTouchNode == cell and x>=self.originX
		and self.sameFirstX - x <= self.imgDeleteSize.width * 0.95 then --会弹上一个的
		local diff = math.min(x - self.sameFirstX,0)
		local nexX = imgbG:getPositionX()
		imgbG:setPositionX(self.originX + diff)
		local nexX2 = imgbG:getPositionX()
		
	elseif x < self.firstX and self.firstX - x <= self.imgDeleteSize.width then
		local minX = math.max(self.originX + x - self.firstX,self.originX - self.imgDeleteSize.width)
		local nexX = imgbG:getPositionX()
		imgbG:setPositionX(minX)
		local nexX2 = imgbG:getPositionX()
		
	else
		
	end
end
function Session_widget_Content:cellTouchEnded(view,cell)
	--print("cellTouchEnded...",cell:getIdx())
	if self.originX then
		local sessionNode = cell:getChildByName("sessionNode")
		local tag= sessionNode:getTag()
		local sessionData = self.sessionDatas[tag+1]
		if sessionData and sessionData.sessionType==1 then --好友申请不能删除
			return
		end
		local imgbG = sessionNode:getChildByName("Image_bg")
		local imgDelete = sessionNode:getChildByName("Image_delete")
		local curPosX = imgbG:getPositionX()
		--print(math.abs(math.abs(self.originX - curPosX) - self.imgDeleteSize.width))
		if math.abs(math.abs(self.originX - curPosX) - self.imgDeleteSize.width) <=30 then
			imgbG:stopAllActions()
			imgbG:runAction(cc.MoveTo:create(0.05,cc.p(self.originX - self.imgDeleteSize.width +30,imgbG:getPositionY())))
			--这里需要停止会弹了 可以删除
			print("可以删除了")
			imgDelete:setTouchEnabled(true) --这里可以点击了
			imgDelete:addTouchEventListener(handler(self,self.touchEventListener))
			self.preTouchNode = cell
		else
			--回弹之
			print("回弹之")
			if self.preTouchNode ~= cell then
				self:scrollNodeBack(self.preTouchNode)
				self.preTouchNode = nil
			end

			
			imgbG:stopAllActions()
			imgbG:runAction(cc.MoveTo:create(0.05,cc.p(self.originX,imgbG:getPositionY())))
			--imgbG:setPositionX(self.originX)
		end
		
	end
	self.firstX = nil
	--self.originX = nil
end
function Session_widget_Content:longTouched(view,cell)
	print("longTouched...",cell:getIdx())
end

function Session_widget_Content:scrollViewWillRecycle(view)
	
end
function Session_widget_Content:numberOfCellsInTableView(view)
	
	return self.sessionCount
end

function Session_widget_Content:scrollViewDidScroll(view)
	self.contentOffset = self.tableView:getContentOffset()
end

function Session_widget_Content:scrollViewDidZoom(view)
	
end
function Session_widget_Content:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
	
	local sessionData = self.sessionDatas[cell:getIdx()+1]
	if sessionData then
		if sessionData.sessionType == 0 then --如果会话类型是聊天
			local chatSLayer = ChatSessionLayer:create(sessionData.senderid)
			chatSLayer:bindCloseCB(handler(self,self.onResume))
			display.getRunningScene():addChild(chatSLayer,7)
		elseif sessionData.sessionType == 1 then --好友申请
			print("处理好友申请")
			dump(sessionData)
			
			
		end
		
	end
	
end
function Session_widget_Content:cellSizeForTable(view,idx)

	return 827.00,220

end

function Session_widget_Content:createSessionNode(view,cell,idx)
	
	local sessionNode = NodePartnerSession:create().root
	--signNode:setAnchorPoint(0.5,0.5)
	sessionNode:setPositionX((0.5)*self.size.width)
	sessionNode:setPositionY(0)
	sessionNode:setName("sessionNode")
	sessionNode:setTag(idx)	
	--	
	local imgDelete = sessionNode:getChildByName("Image_delete")
	imgDelete:setTouchEnabled(false) --默认不能够啊
	imgDelete:addTouchEventListener(handler(self,self.touchEventListener))
	local sessionData = self.sessionDatas[idx+1]
	
	return sessionNode
end


function Session_widget_Content:tableCellAtIndex(view,idx)
	
    local cell = view:dequeueCell()
	local sitem = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
	else
		sitem = cell:getChildByName("sessionNode")
    end
	cell:removeAllChildren()
	sitem = self:createSessionNode(view,cell,idx)
	local imgDelete = sitem:getChildByName("Image_delete")
	imgDelete:setTag(idx)
	self.imgDeleteSize = imgDelete:getContentSize()
	cell:addChild(sitem)
	cell:setTag(idx)
	sitem:setTag(idx)
	local sessionData = self.sessionDatas[idx+1]
	local imgBg = sitem:getChildByName("Image_bg")
	if sessionData then
		--Image_unread
		ccui.Helper:seekWidgetByName(imgBg,"Image_unread"):setVisible(sessionData.isread > 0) --是否已经度过了

			local btnAgree = ccui.Helper:seekWidgetByName(imgBg,"Button_agree")
			local btnRefuse = ccui.Helper:seekWidgetByName(imgBg,"Button_refuse")
		if tonumber(sessionData.sessionType) == 1 then --好友申请（系统消息下行）
			ccui.Helper:seekWidgetByName(imgBg,"Image_time"):setVisible(false)
			btnAgree:setVisible(true)
			btnRefuse:setVisible(true)
			btnAgree:setTouchEnabled(true)
			btnRefuse:setTouchEnabled(true)
			btnAgree:setTag(idx)
			btnRefuse:setTag(idx)
			btnAgree:addTouchEventListener(handler(self,self.touchEventListener))
			btnRefuse:addTouchEventListener(handler(self,self.touchEventListener))
		elseif tonumber(sessionData.sessionType) == 0 then --0=好友聊天(上下行)
			btnAgree:setVisible(false)
			btnRefuse:setVisible(false)
			ccui.Helper:seekWidgetByName(imgBg,"Image_time"):setVisible(true)
			ccui.Helper:seekWidgetByName(imgBg,"Text_time"):setString(CardPartnerCfg.getshowTime(sessionData.recenttime))
			if sessionData.isread > 0 then
				local showNumber = sessionData.isread > 99 and "99+" or tostring(sessionData.isread) --超过99显示 99+
				local showFontSize = sessionData.isread > 99 and 12 or 16
				ccui.Helper:seekWidgetByName(imgBg,"Text_number"):setString(showNumber)
				ccui.Helper:seekWidgetByName(imgBg,"Text_number"):setFontSize(showFontSize)
			end
		end

		ccui.Helper:seekWidgetByName(imgBg,"Text_content"):setString(subHanziStr(sessionData.content,16))
		local friendInfo = SocialContactProxy:getFriendInfo(sessionData.senderid)
		if friendInfo and string.len(tostring(friendInfo.Nickname))>0 then
			ccui.Helper:seekWidgetByName(imgBg,"Text_name"):setString(tostring(friendInfo.Nickname))
		else
			ccui.Helper:seekWidgetByName(imgBg,"Text_name"):setString(sessionData.title)
		end
	
		local gender  = 1
		local iconType = 11
		local friendInfo = SocialContactProxy:getFriendInfo(tonumber(sessionData.senderid))
		if friendInfo then
			gender = friendInfo.Gender or 1
			iconType = friendInfo.IconID or 11
		elseif self._queryUserDatas and self._queryUserDatas[tonumber(sessionData.senderid)] then
			local userinfo = self._queryUserDatas[tonumber(sessionData.senderid)]
			gender = userinfo.Gender or 1
			iconType = userinfo.IconID or 11
			ccui.Helper:seekWidgetByName(imgBg,"Text_name"):setString(tostring(userinfo.Nickname))
		else
			--请求
			UserInfoProxy:requestUserInfo(tonumber(sessionData.senderid))
		end			
		local param = {
			headFile=DataCenter:getUserdataInstance():getHeadIconByGender(gender),
			maskFile = "guandan/head_mask.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=60,
	        headIconType = iconType,
	        userID = tostring(sessionData.senderid)
	    }
		--
		local HeadSprite = WWHeadSprite:create(param)
		local imgHead = ccui.Helper:seekWidgetByName(imgBg,"Image_head")
		imgHead:removeAllChildren()
		HeadSprite:setPosition(cc.p(imgHead:getContentSize().width/2,imgHead:getContentSize().height/2))
		imgHead:addChild(HeadSprite,1)
	end
	
    return cell
end


function Session_widget_Content:refreshInfo(event)
	local data = unpack(event._userdata)
	if not data then
		data = event._userdata 
	end
	if not data or not next(data) then
		return --没有数据
	end
	wwdump(data,"会话界面收到个人信息")
	--本地存储个人信息数据
	self._queryUserDatas = self._queryUserDatas or {}
	self._queryUserDatas[data.UserID] = clone(data)
	self:reloadSession()
end
function Session_widget_Content:touchEventListener(ref,eventType)
	
	--print("eventType",eventType)
	
	if not ref or self.tableView:isTouchMoved() or not self.tableView:canGetTouch() then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_agree" then
			local sessionData = self.sessionDatas[ref:getTag()+1]
			if sessionData then
				SocialContactProxy:agreeAddBuddy(sessionData.senderid,sessionData.extraData)
			else
				wwlog(self.logTag,"会话数据item异常")
			end
		elseif ref:getName()=="Button_refuse" then
			local sessionData = self.sessionDatas[ref:getTag()+1]
			if sessionData then
				SocialContactProxy:refuseAddBuddy(sessionData.senderid,sessionData.extraData)
			else
				wwlog(self.logTag,"会话数据item异常")
			end
		elseif ref:getName()=="Image_delete" then
			print("删除之")
			local sessionData = self.sessionDatas[ref:getTag()+1]
			if sessionData then
				HallChatService:removeSession(tonumber(sessionData.senderid),tonumber(sessionData.sessionType))
				self:reloadSession()
			else
				wwlog(self.logTag,"会话数据item异常")
			end
			
		end
		
	end
	

end

function Session_widget_Content:getEventComponent()
	return CardPartnerCfg.innerEventComponent
end
return Session_widget_Content