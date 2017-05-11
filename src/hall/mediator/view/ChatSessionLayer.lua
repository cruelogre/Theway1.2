-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  好友聊天界面
-- Modify: 
--			2017.2.7 添加最后一条消息的时间 显示规则和会话显示规则一样
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChatSessionLayer = class("ChatSessionLayer",
	require("app.views.uibase.PopWindowBase"),
	require("packages.mvc.Mediator"))

local PartnerSessionLayout = require("csb.hall.cardpartner.PartnerSessionLayout")
local NodeSessionItem1 = require("csb.hall.cardpartner.NodeSessionItem_1") --别人的
local NodeSessionItem2 = require("csb.hall.cardpartner.NodeSessionItem_2") --我自己的

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local UserDataCenter = DataCenter:getUserdataInstance()

local HallChatService = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
local UserInfoProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().UserInfoProxy)

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
local UserInfoCfg = require("hall.mediator.cfg.UserInfoCfg")

local Toast = require("app.views.common.Toast")

--初始化的时候需要知道聊天对象ID
function ChatSessionLayer:ctor(senderid)
	ChatSessionLayer.super.ctor(self)
	self.logTag = self.__cname..".lua"
	self.hasRequest = false --是否已经请求了
	self.senderid = senderid
	self.logCount = 0 --聊天数量
	self.logDatas = {} --聊天记录
	self.searchIndex = 0 --当前查询的起始位置
	self.handlers = {}
	local csbNode = PartnerSessionLayout:create()
	FixUIUtils.setRootNodewithFIXED(csbNode.root)
	
	self.imgId = csbNode.root:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	local imgContent = ccui.Helper:seekWidgetByName(self.imgId,"Image_content")
	local imgSend = ccui.Helper:seekWidgetByName(self.imgId,"Image_send")
	
	ccui.Helper:seekWidgetByName(self.imgId,"Button_send"):addTouchEventListener(handler(self,self.sendButtonListener))
	--Text_title
	self.title = ccui.Helper:seekWidgetByName(self.imgId,"Text_title")
	self.title:setString(tostring(senderid))
	local imgSize = imgContent:getContentSize()
	local imgSendSize = imgSend:getContentSize()
	
	self:initFriendLayout(imgContent,cc.size(imgSize.width,imgSize.height - imgSendSize.height -10),cc.p(0,imgSendSize.height +5))
	
	self:addChild(csbNode.root,1)
	
	self:popIn(self.imgId,Pop_Dir.Right)
	
end

function ChatSessionLayer:initFriendLayout(parentNode,size,pos)
	self.tableView = cc.TableView:create(size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(pos)
	self.tableView:setAnchorPoint(cc.p(0.5,0))
    self.tableView:setDelegate()

    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
    parentNode:addChild(self.tableView,1)
    self.tableView:registerScriptHandler(handler(self,self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,self.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	-- tableview 中触摸取消
	self.tableView:registerScriptHandler(handler(self,self.cellTouchEnded),ww.TABLECELL_TOUCHENDED)
	
	local fieldSize =cc.size(616,86)
	local imgBg = ccui.Helper:seekWidgetByName(self.imgId,"Image_send")
	local textField = ccui.Helper:seekWidgetByName(imgBg,"TextField_send")
	self.sendEditBox= ccui.EditBox:create(fieldSize, "cp_chat_input_edit.png",1)  --输入框尺寸，背景图片
	self.sendEditBox:setPosition(cc.p(textField:getPositionX()+fieldSize.width/2, textField:getPositionY()))
	self.sendEditBox:setAnchorPoint(cc.p(0.5,0.5))
	self.sendEditBox:setFontSize(36)
	self.sendEditBox:setPlaceholderFontSize(36)
	self.sendEditBox:setPlaceholderFontName("Arial")
	self.sendEditBox:setFontColor(cc.c3b(0x4e,0x43,0x27))
	self.sendEditBox:setMaxLength(CardPartnerCfg.characterMaxCount)
	self.sendEditBox:setPlaceHolder(i18n:get('str_cardpartner','char_input_placeholder'))
	self.sendEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND ) --输入键盘返回类型，done，send，go等
	self.sendEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE) --单行
	self.sendEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	self.sendEditBox:registerScriptEditBoxHandler(handler(self,self.editboxHandle))
	imgBg:addChild(self.sendEditBox)
	textField:removeFromParent()
	
end

function ChatSessionLayer:editboxHandle(strEventName,sender)
	
	if strEventName=="began" then
		--sender:selectedAll() --光标进入，选中全部内容
	elseif strEventName=="ended" then --当编辑框失去焦点并且键盘消失的时候被调用
		
	elseif strEventName=="return" then -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		
	elseif strEventName=="changed" then
		
	end
end
--绑定关闭回调
function ChatSessionLayer:bindCloseCB(closeFun)
	self._closeFun = closeFun
	self:setDisCallback(function ( ... )
		-- body
		if self._closeFun and type(self._closeFun) == "function" then
			self._closeFun()
			self._closeFun = nil
		end
		self:removeFromParent()
	end)
end
function ChatSessionLayer:cellTouchEnded(view,cell)
	self:loadMore()
end
function ChatSessionLayer:numberOfCellsInTableView(view)
	
	return self.logCount
end

function ChatSessionLayer:scrollViewDidScroll(view)
	--dump(self.tableView:getContentOffset())
	
end

function ChatSessionLayer:scrollViewDidZoom(view)

end
function ChatSessionLayer:tableCellTouched(view,cell)

end
function ChatSessionLayer:cellSizeForTable(view,idx)
	return 995,self:getItemHeight(self.logDatas[idx+1] and string.trim(self.logDatas[idx+1].sendcontent) or "",36) + (idx == 0 and 100 or 0)
end
function ChatSessionLayer:tableCellAtIndex(view,idx)
	local cell = view:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
	end
	cell:removeAllChildren()
	local logData = self.logDatas[idx+1]
	if logData then
		local isSelf = (tostring(logData.senderid) == tostring(UserDataCenter:getValueByKey("userid")))
		local sessionNode = self:createSessionItem(isSelf)
		if isSelf then
			sessionNode:setPosition(cc.p(995,0))
		end

		
		cell:addChild(sessionNode)
		cell:setTag(idx)
		--设置信息
		
		
		local imgContent = sessionNode:getChildByName("Image_bg")
		
		local textContent = cc.Label:createWithSystemFont(ToolCom:wrapString(string.trim(logData.sendcontent),CardPartnerCfg.characterBubbleMaxLen),"", 36)
		if isSelf then
			textContent:setScaleX(-1)
		end
		--#21504a
		textContent:setColor(cc.c3b(0x21,0x50,0x4A))
		textContent:setAnchorPoint(cc.p(0.5,0.5))
		
		local textSize = textContent:getContentSize()
		local newSize = textSize
		newSize.width = textSize.width+80
		newSize.height = textSize.height+80
		imgContent:setContentSize(newSize)
		local imgSize = imgContent:getContentSize()
		sessionNode:setPositionY(newSize.height/2-33 + (idx==0 and 100 or 0))
		if isSelf then
			textContent:setPosition(cc.p(30+(imgSize.width-30)/2,33+(imgSize.height-33*2)/2))
		else
			textContent:setPosition(cc.p(30+(imgSize.width-30)/2,33+(imgSize.height-33*2)/2))
		end
		
		imgContent:addChild(textContent)
		
		local headicon = sessionNode:getChildByName("Image_icon")
		
		local gender = 1
		local iconType = 1
		if isSelf then
			gender = tonumber(DataCenter:getUserdataInstance():getValueByKey("gender"))
			iconType = tonumber(DataCenter:getUserdataInstance():getValueByKey("IconID"))
			headicon:setTag(0)	
		else
			headicon:setTag(tonumber(logData.senderid))
			local friendInfo = SocialContactProxy:getFriendInfo(tostring(logData.senderid))
			if friendInfo then
				gender = friendInfo.Gender or 1
				iconType = friendInfo.IconID or 1
			elseif self._queryUserDatas and self._queryUserDatas[tonumber(logData.senderid)] then
				local userinfo = self._queryUserDatas[tonumber(logData.senderid)]
				gender = userinfo.Gender or 1
				iconType = userinfo.IconID or 11
			else
				if not self.hasRequest then
					UserInfoProxy:requestUserInfo(tonumber(logData.senderid))
					self.hasRequest = true
				end
				
			end

		end
		
		local param = {
			headFile=DataCenter:getUserdataInstance():getHeadIconByGender(gender),
			maskFile = "guandan/head_mask.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=60,
	        headIconType = iconType,
	        userID = tostring(logData.senderid)
	    }
		--
		local HeadSprite = WWHeadSprite:create(param)
		headicon:addChild(HeadSprite)
		HeadSprite:setPosition(cc.p(headicon:getContentSize().width/2,headicon:getContentSize().height/2))
		
		--如果是最后一条，显示最后一条的时间
		if idx==0 and logData.sendtime and string.len(tostring(logData.sendtime))>0 then
			local lastTimeImg = ccui.ImageView:create()
			lastTimeImg:ignoreContentAdaptWithSize(true)
			lastTimeImg:loadTexture("cp_chat_time_bg.png",1)
			lastTimeImg:setCascadeColorEnabled(true)
			lastTimeImg:setCascadeOpacityEnabled(true)
			local cellWidth = self:cellSizeForTable(view,idx)
			if isSelf then
				lastTimeImg:setPosition(cc.p(-cellWidth / 2,-newSize.height/2 - 10))
			else
				lastTimeImg:setPosition(cc.p(cellWidth / 2,-newSize.height/2 - 10))
			end
			--"FZZhengHeiS-B-GB.ttf"
			local textTime = ccui.Text:create()
			textTime:ignoreContentAdaptWithSize(true)
			textTime:setTextAreaSize({width = 0, height = 0})
			textTime:setFontName("FZZhengHeiS-B-GB.ttf")
			textTime:setFontSize(32)
			textTime:setString(CardPartnerCfg.getshowTime(logData.sendtime))
			textTime:setCascadeColorEnabled(true)
			textTime:setCascadeOpacityEnabled(true)
			local timeImgSize = lastTimeImg:getContentSize()
			textTime:setPosition(timeImgSize.width/2, timeImgSize.height/2)
			textTime:setTextColor({r = 255, g = 255, b = 255})
			lastTimeImg:addChild(textTime)
			sessionNode:addChild(lastTimeImg)
		end
		
		
		
	end
	return cell
	
end

function ChatSessionLayer:refreshInfo(event)
	local data = unpack(event._userdata)
	if not data then
		data = event._userdata 
	end
	if not data or not next(data) then
		return --没有数据
	end
	wwdump(data,"对话界面收到个人信息")
	--本地存储个人信息数据
	self._queryUserDatas = self._queryUserDatas or {}
	self._queryUserDatas[data.UserID] = clone(data)
	if data.Nickname then
		self.title:setString(tostring(data.Nickname))
	end
	self:msgUpdate()
end

function ChatSessionLayer:createSessionItem(isSelf)
	local NodeSessionItem = isSelf and NodeSessionItem2 or NodeSessionItem1
	local temp = NodeSessionItem:create()
	local frienditem = temp.root
	frienditem:setName("frienditem")
	frienditem:getChildByName("Image_icon"):addTouchEventListener(handler(self,self.sendButtonListener))	
	return frienditem
end

--加载更多
--根据当前tableview的位置来判断是上拉刷新还是下拉刷新
function ChatSessionLayer:loadMore()
	local curOffset = self.tableView:getContentOffset()
	local contentSize = self.tableView:getContentSize()
	local viewSize = self.tableView:getViewSize()
	local cellWidth,cellHeight = self:cellSizeForTable(self.tableView,0)
	dump(curOffset,"当前位移量")
	dump(contentSize,"tableview内容大小")
	dump(viewSize,"tableview视图大小")
	dump(cellHeight,"tableview视图大小")
	
	if curOffset.y + cellHeight <= viewSize.height - contentSize.height then --下拉刷新
		wwlog(self.logTag,"下拉刷新了")
		local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
		--self.senderid
		if myuserid>0  then
			local dataparams = {}
			dataparams.senderid = tonumber(self.senderid)
			dataparams.receiverid = myuserid
			local friendCount = HallChatService:countLog(dataparams) --我们之间的聊天数量数量
			wwlog(self.logTag,"好友长度"..friendCount)
			if self.searchIndex + CardPartnerCfg.sessionSearchLen < friendCount then --位置不超过长度时
				self.searchIndex = self.searchIndex + CardPartnerCfg.sessionSearchLen
				
				self:queryLog(self.searchIndex,CardPartnerCfg.sessionSearchLen)
			else
				wwlog(self.logTag,"当前已经是最后了，没有更多了"..self.searchIndex)
			end
		else
			wwlog(self.logTag,"我的帐号异常")
		end

	elseif curOffset.y >=cellHeight then --上拉刷新
		wwlog(self.logTag,"上拉刷新了")
		
		if self.searchIndex >= CardPartnerCfg.sessionSearchLen then --只有下拉的时候，索引值大于长度才刷新 最低是1
			self.searchIndex = self.searchIndex - CardPartnerCfg.sessionSearchLen
			self:queryLog(self.searchIndex,CardPartnerCfg.sessionSearchLen)
			
		else
			wwlog(self.logTag,"当前已经是开头了，不需要重新请求"..self.searchIndex)
		end
	end
end

--获取日志 
--@param limitCount 限制取条数的长度 默认50
--@param offsetLen 从多少条开始 默认 0
function ChatSessionLayer:queryLog(offsetLen,limitCount)
	local dataparams = {}
	dataparams.senderid = self.senderid
	dataparams.receiverid = UserDataCenter:getValueByKey("userid")
	dataparams.limitCount = limitCount
	dataparams.offsetLen = offsetLen
	self.logDatas = HallChatService:getLog(dataparams)
	self.logCount = self.logDatas and #self.logDatas or 0
	self.tableView:reloadData()
	
	if self.tableView:getContentSize().height >= self.tableView:getViewSize().height then
		self.tableView:setContentOffset(cc.p(0,0))
	end

end
--聊天消息通知
function ChatSessionLayer:msgUpdate()
	self:queryLog(self.searchIndex,CardPartnerCfg.sessionSearchLen)
	self:updateSession()
end
--好友关系变动
function ChatSessionLayer:friendRelationChanged(event)
	--重新请求
	wwlog(self.logTag,"好友变动通知")
	--SocialContactProxy:requestCardPartner(1,CardPartnerCfg.friendSearchLen)
end

--更新和当前聊天对象的会话 为全部已经读取
function ChatSessionLayer:updateSession()
--@param dataStructParams 数据封装
--@key sendcontent 内容
--@key isread 是否已经阅读
	local dataStructParams = {}
	dataStructParams.isread = 0
	dataStructParams.senderid = self.senderid
	print("更新阅读状态......")
	HallChatService:updateSession(dataStructParams)
end
function ChatSessionLayer:sendButtonListener(ref,eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_send" then
			local friendInfo = HallChatService:checkFriend({userid =tostring(self.senderid),owerid =tonumber(UserDataCenter:getValueByKey("userid")) })
			
			if not friendInfo then --我们不是好友关系
				Toast:makeToast(i18n:get('str_cardpartner','partner_chat_not_friend'),1.0):show()
				return
			end
			local content = self.sendEditBox:getText()
			if string.len(content)>0 then
				local str = os.time(os.date("*t"))
				local dataparams = {}
				dataparams.senderid = UserDataCenter:getValueByKey("userid")
				dataparams.receiverid = self.senderid
				dataparams.sendcontent = content
				HallChatService:addLog(dataparams)
				--local friendInfo = SocialContactProxy:getFriendInfo(self.senderid)

				local dataparams2 = {}
				dataparams2.senderid = self.senderid
				dataparams2.title = tostring(self.senderid)
--[[				if friendInfo then
					dataparams2.title = tostring(friendInfo.Nickname)
				end--]]
				dataparams2.sendcontent = content
				dataparams2.isread = 0 --这里的session是度过的
				dataparams2.sessionType = 0 --会话类型 0 聊天
				--这里固定写我的
				dataparams2.receiverid =  tonumber(UserDataCenter:getValueByKey("userid"))
				HallChatService:addSession(dataparams2)
				self:queryLog(self.searchIndex,CardPartnerCfg.sessionSearchLen)
				SocialContactProxy:requestChat(self.senderid,content)
				self.sendEditBox:setText("")
			else
				Toast:makeToast(i18n:get('str_cardpartner','chat_content_empty'),1.0):show()
			end

		elseif ref:getName()== "Image_icon" then
			local tag = ref:getTag()
			local isFriend = false
			local reqUserId = nil
			if tag >0 then
				reqUserId = tag
				isFriend = HallChatService:checkFriend({userid =tostring(reqUserId),owerid =tonumber(UserDataCenter:getValueByKey("userid")) })
			end
			FSRegistryManager:currentFSM():trigger("userinfo",
			{parentNode = display.getRunningScene(), zorder = self:getLocalZOrder()+1,userid = reqUserId,isFriend = isFriend})
		end
		
	end
	
end

function ChatSessionLayer:onEnter()
	self:reigstMsg()
	self:queryLog(self.searchIndex,CardPartnerCfg.sessionSearchLen)
	local count = HallChatService:getSessionCount(self.senderid)
	if count > 0 then
		self:updateSession()
	end
	local friendInfo = SocialContactProxy:getFriendInfo(self.senderid)
	if friendInfo and isLuaNodeValid(self.title) and string.len(tostring(friendInfo.Nickname))>0 then
		self.title:setString(tostring(friendInfo.Nickname))
	end
end

function ChatSessionLayer:onExit()
	self.logCount = 0
	removeAll(self.logDatas)
	self:unregistMsg()
	--退出去的时候也重置一下和当前对象的聊天会话状态
	local count = HallChatService:getSessionCount(self.senderid)
	if count > 0 then
		self:updateSession()
	end
	--同时判断是否还有其他红点
	WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "cardPartner",HallChatService:hasUnreadMsg())
	
	removeAll(self._queryUserDatas)
	self.hasRequest = false
	self.searchIndex = 0 --当前查询的起始位置
end

function ChatSessionLayer:reigstMsg()
	if self:getEventComponent() then
		self.handlers = self.handlers or {}
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:getEventComponent():addEventListener(
			CardPartnerCfg.InnerEvents.CP_EVENT_FRIEND_CHAT_CONTENT,handler(self,self.msgUpdate))
	end

			
	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED, handler(self, self.friendRelationChanged))	
	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED_ROOT, handler(self, self.friendRelationChanged))	
	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED, handler(self, self.friendRelationChanged))	
    self._handles = { } or self._handles
    local _ = nil
	if UserInfoCfg.innerEventComponent then
		_, self._handles[#self._handles + 1] = UserInfoCfg.innerEventComponent:addEventListener(
			UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self.refreshInfo))
	else
		self:registerEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO, handler(self, self.refreshInfo))
	end
end
function ChatSessionLayer:unregistMsg()
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
	removeAll(self.handlers)
	removeAll(self._handles)
	self:unregisterEventListener(UserInfoCfg.InnerEvents.MESSAGE_EVENT_USERINFO)
	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED)
	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED_ROOT)
	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_AGREE_FRINED)
end
--通过文字计算每个item的高度
function ChatSessionLayer:getItemHeight(content,fontSize)
	local str = ToolCom:wrapString(content,CardPartnerCfg.characterBubbleMaxLen)
	local lineCount = string.split(str,"\n")
	local itemHeight = 130
	if lineCount then
		itemHeight = itemHeight + (#lineCount- 1)*fontSize*1.2
	end
	return itemHeight
end

function ChatSessionLayer:getEventComponent()
	return CardPartnerCfg.innerEventComponent
end
return ChatSessionLayer