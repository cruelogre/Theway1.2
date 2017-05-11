-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  好友列表控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Friend_widget_Content = class("Friend_widget_Content",ccui.Layout,require("packages.mvc.Mediator"))

local NodePartnerFrienditem = require("csb.hall.cardpartner.NodePartnerFrienditem")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local UserDataCenter = DataCenter:getUserdataInstance()

local ChatSessionLayer = require("hall.mediator.view.ChatSessionLayer")

local HallChatService = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
function Friend_widget_Content:ctor(size)
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	
	self.cbFun = nil
	self.tableView = nil
	self.logTag = self.__cname..".lua"
	self.handlers = {}
	self.mateList = nil
	self.mateCount = 0 --好友的数量
	self.searchIndex = 1 --当前查找好友的索引值
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function Friend_widget_Content:initView()
	wwlog(self.logTag,"Friend_widget_Content:initView")
	
end

function Friend_widget_Content:initFriendLayout()
	self.tableView = cc.TableView:create(self.size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.tableView:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView,1)
    self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
		--tableview 中触摸移动
	self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.cellMoved),ww.TABLECELL_MOVED)
	-- tableview 中触摸取消
	self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.cellTouchEnded),ww.TABLECELL_TOUCHENDED)
	-- tableview 中长按
	self.tableView:registerScriptHandler(handler(self,Friend_widget_Content.longTouched),ww.TABLECELL_LONGTOUCHED)
	
end
function Friend_widget_Content:onEnter()
	wwlog(self.logTag,"Friend_widget_Content:onEnter")
	self.searchIndex = 1
	self:initView()
--[[	local tempFriends = {}
	tempFriends.mateList = {}
	for i=0,10 do
		table.insert(tempFriends.mateList,{OnlineFlag = 1,Nickname = "Nickname"..i,Gender = 1,UserID = 10000+i,IconID = 101,Param1 = 2})
	end
	
	DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND,tempFriends)
	self:reloadData()--]]
	--先默认请求前10个好友
	if self:eventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:eventComponent():addEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_PARTNERLIST,handler(self,self.reloadData))
		
	end
	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED,handler(self,self.deleteOK))
	SocialContactProxy:requestCardPartner(self.searchIndex,CardPartnerCfg.friendSearchLen)
end


function Friend_widget_Content:onExit()
	
	wwlog(self.logTag,"Friend_widget_Content:onExit")
	if isLuaNodeValid(self.tableView) then
		self.tableView:removeFromParent()
	end
	if self:eventComponent() and self.handlers then
		for _,v in ipairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
	end
	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_FRIEND_DELETED)
	self.searchIndex = 1
end

function Friend_widget_Content:eventComponent()
	return CardPartnerCfg.innerEventComponent
end
--好友删除成功
function Friend_widget_Content:deleteOK(event)
	if self.preTouchNode then
		self:scrollNodeBack(self.preTouchNode)
		self.preTouchNode = nil
	end
	--msgTable.kResult == 0
	local data = unpack(event._userdata)
	if not data or data.kResult == 0 then
		SocialContactProxy:requestCardPartner(self.searchIndex,CardPartnerCfg.friendSearchLen)
	end

end

function Friend_widget_Content:onResume()
	self:scrollNodeBack(self.preTouchNode)
	self.preTouchNode = nil
	SocialContactProxy:requestCardPartner(self.searchIndex,CardPartnerCfg.friendSearchLen)
end
function Friend_widget_Content:active()
	
end
--排序好友列表
function Friend_widget_Content:sortMate(mateList)

end

function Friend_widget_Content:reloadData(event)
	print("MatchLayer_widget_friendList:reloadData")
	
	
	local hasFriend = false
	local friendLists = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_PARTNERLIST)
	
	--dump(friendLists)
	
	--有数据，有朋友
	if friendLists and next(friendLists) then
		hasFriend = true
		local tempMateList = clone(friendLists)
		--sort mate list
		self:sortMate(tempMateList)
		self.mateList = tempMateList
		self.mateCount = #self.mateList
	end
	
	if hasFriend then
		--有朋友  显示好友
		if self.noFriend then
			self.noFriend:removeFromParent()
			self.noFriend = nil
		end
		if not isLuaNodeValid(self.tableView) then
			self:initFriendLayout()
		end
		self.tableView:reloadData()
		
		local contentSize = self.tableView:getContentSize()
		local viewSize = self.tableView:getViewSize()
		local curOffset = self.tableView:getContentOffset()
		
		performWithDelay(self,function ()
			--滑动
			self.tableView:setContentOffset(cc.p(0,viewSize.height - contentSize.height),true)
		end,0.1)
		
	else
		--没朋友 显示添加好友
		
		if isLuaNodeValid(self.tableView) then
			self.tableView:removeFromParent()
			self.tableView =  nil
		end
		self:removeAllChildren()
		self.noFriend = require("csb.hall.cardpartner.PartnetNoFriendLayout"):create().root
		FixUIUtils.setRootNodewithFIXED(self.noFriend)
		local panel1 = self.noFriend:getChildByName("Panel_1")
		
		FixUIUtils.stretchUI(panel1)
		self:addChild(self.noFriend,1)
		
		ccui.Helper:seekWidgetByName(panel1,"Button_add"):addTouchEventListener(handler(self,self.touchEventListener))
		
	end
	
	return hasFriend
end


function Friend_widget_Content:scrollNodeBack(cell)
	if not isLuaNodeValid(cell) then
		return
	end
	local preSNode = cell:getChildByName("frienditem")
	if isLuaNodeValid(preSNode) then
		local preImgBg = preSNode:getChildByName("Image_bg")
		if isLuaNodeValid(preImgBg) then
			--preImgBg:setPositionX(self.originX)
			preImgBg:runAction(cc.MoveTo:create(0.05,cc.p(self.originX,preImgBg:getPositionY())))
		end
	end	
end
function Friend_widget_Content:cellMoved(view,cell,x,y)
	--print("cellMoved...",cell:getIdx(),x,y)
	
	local sessionNode = cell:getChildByName("frienditem")
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
function Friend_widget_Content:cellTouchEnded(view,cell)
	--print("cellTouchEnded...",cell:getIdx())
	if self.originX then
		local sessionNode = cell:getChildByName("frienditem")
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
	--触摸结束的时候，通过计算当时的scrollview滚动的位置来判断
	self:loadMore()
end
function Friend_widget_Content:longTouched(view,cell)
	print("longTouched...",cell:getIdx())

end
--加载更多
--根据当前tableview的位置来判断是上拉刷新还是下拉刷新
function Friend_widget_Content:loadMore()
	local curOffset = self.tableView:getContentOffset()
	local contentSize = self.tableView:getContentSize()
	local viewSize = self.tableView:getViewSize()
	local cellWidth,cellHeight = self:cellSizeForTable()
	dump(curOffset,"当前位移量")
	dump(contentSize,"tableview内容大小")
	dump(viewSize,"tableview视图大小")
	dump(cellHeight,"tableview视图大小")
	
	if curOffset.y + cellHeight <= viewSize.height - contentSize.height then --下拉刷新
		wwlog(self.logTag,"下拉刷新了")
		if self.searchIndex > CardPartnerCfg.friendSearchLen then --只有下拉的时候，索引值大于长度才刷新 最低是1
			self.searchIndex = self.searchIndex - CardPartnerCfg.friendSearchLen
			LoadingManager:startLoading(0)
			SocialContactProxy:requestCardPartner(self.searchIndex,CardPartnerCfg.friendSearchLen)
			
		else
			wwlog(self.logTag,"当前已经是开头了，不需要重新请求")
		end
	elseif curOffset.y >=cellHeight then --上拉刷新
		wwlog(self.logTag,"上拉刷新了")
		
		local myuserid = tonumber(UserDataCenter:getValueByKey("userid"))
		if myuserid>0  then
			local friendCount = HallChatService:countFriend(myuserid) --我的好友数量
			if self.searchIndex + CardPartnerCfg.friendSearchLen < friendCount then --位置不超过长度时
				self.searchIndex = self.searchIndex + CardPartnerCfg.friendSearchLen
				LoadingManager:startLoading(0)
				SocialContactProxy:requestCardPartner(self.searchIndex,CardPartnerCfg.friendSearchLen)
			else
				wwlog(self.logTag,"当前已经是最后了，没有更多了")
			end
		else
			wwlog(self.logTag,"我的帐号异常")
		end
	end
end

function Friend_widget_Content:numberOfCellsInTableView(view)
	
	return self.mateCount
end

function Friend_widget_Content:scrollViewDidScroll(view)

end

function Friend_widget_Content:scrollViewDidZoom(view)

end
function Friend_widget_Content:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
	--好友详情界面
	local reqUserId = self.mateList[cell:getTag()+1].UserID
	wwlog(self.logTag,"打开的用户ID:"..reqUserId)
	FSRegistryManager:currentFSM():trigger("userinfo",
	{parentNode = display.getRunningScene(), zorder = 4,userid = reqUserId,isFriend = true})
	self:scrollNodeBack(self.preTouchNode)
	self.preTouchNode = nil
end
function Friend_widget_Content:cellSizeForTable(view,idx)
	return 995,168.00 + 30
end
function Friend_widget_Content:tableCellAtIndex(view,idx)
	local cell = view:dequeueCell()
	local frienditem = nil
	if nil == cell then
		cell = cc.TableViewCell:new()
		frienditem = self:createFriendItem()
		cell:addChild(frienditem)

	else
		frienditem = cell:getChildByName("frienditem")
	end
	self:reSetItem(frienditem)
	local imgDelete = frienditem:getChildByName("Image_delete")
	imgDelete:setTag(idx)
	self.imgDeleteSize = imgDelete:getContentSize()
	
	cell:setTag(idx)
	--设置信息
	local friendInfo = self.mateList[idx+1]
	if friendInfo then
		local img = frienditem:getChildByName("Image_bg")
		--设置是否在线
		ccui.Helper:seekWidgetByName(img,"Image_dot"):setVisible(friendInfo.OnlineFlag==1)
		ccui.Helper:seekWidgetByName(img,"Text_name"):setString(friendInfo.Nickname)
		ccui.Helper:seekWidgetByName(img,"Text_gold"):setString(ToolCom.splitNumFix(tonumber(friendInfo.GameCash)))
		ccui.Helper:seekWidgetByName(img,"Text_diamond"):setString(ToolCom.splitNumFix(tonumber(friendInfo.Diamond)))
		--ccui.Helper:seekWidgetByName(img,"Image_head"):
		local param = {
			headFile=DataCenter:getUserdataInstance():getHeadIconByGender(friendInfo.Gender and tonumber(friendInfo.Gender) or 1),
			maskFile = "guandan/head_mask.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=60 ,
	        headIconType = friendInfo.IconID,
	        userID = friendInfo.UserID
	    }
		--
		local HeadSprite = WWHeadSprite:create(param)
		
		local imgHead = ccui.Helper:seekWidgetByName(img,"Image_head")
		imgHead:removeAllChildren()
		HeadSprite:setPosition(cc.p(imgHead:getContentSize().width/2,imgHead:getContentSize().height/2))
		imgHead:addChild(HeadSprite,1)
		ccui.Helper:seekWidgetByName(img,"Button_chat"):setTag(idx)
		ccui.Helper:seekWidgetByName(img,"Panel_chat"):setTag(idx)
		--没有被邀请的才可以邀请
--[[		local chatBtn = ccui.Helper:seekWidgetByName(img,"Button_chat")
		local canInvite = (friendInfo.OnlineFlag==1 and friendInfo.Param1<3)
		chatBtn:setBright(canInvite)
		chatBtn:setTitleColor(canInvite and cc.c3b(0x89,0x1E,0x0F) or cc.c3b(0x73,0x73,0x73))--]]
	end
	return cell
	
end
function Friend_widget_Content:createFriendItem()
	local temp = NodePartnerFrienditem:create()
	local frienditem = temp.root
	local img = frienditem:getChildByName("Image_bg")
	local chatBtn = ccui.Helper:seekWidgetByName(img,"Button_chat")
	local chatPanel = ccui.Helper:seekWidgetByName(img,"Panel_chat")
	--chatBtn:setSwallowTouches(false)
	img:setSwallowTouches(false)
	--chatPanel:setSwallowTouches(false)
	chatPanel:addTouchEventListener(handler(self,self.touchEventListener))
	chatBtn:addTouchEventListener(handler(self,self.touchEventListener))
	img:addTouchEventListener(handler(self,self.touchEventListener))
	frienditem:setName("frienditem")
	frienditem:setPositionX(img:getContentSize().width/2+10)
	frienditem:setPositionY(img:getContentSize().height/2)
	return frienditem
end

--重置item信息
function Friend_widget_Content:reSetItem(frienditem)
	local img = frienditem:getChildByName("Image_bg")
	ccui.Helper:seekWidgetByName(img,"Image_dot"):setVisible(false)
	--Image_head
	ccui.Helper:seekWidgetByName(img,"Image_head"):removeAllChildren()
	ccui.Helper:seekWidgetByName(img,"Text_name"):setString("")
	ccui.Helper:seekWidgetByName(img,"Button_chat"):setBright(false)
	local imgDelete = frienditem:getChildByName("Image_delete")
	imgDelete:setTouchEnabled(false) --默认不能够啊
end


function Friend_widget_Content:touchEventListener(ref,eventType)
	
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_chat" or ref:getName()=="Panel_chat" then
		--聊天界面
			local friendInfo = self.mateList[ref:getTag()+1]
			if friendInfo then
				local chatSLayer = ChatSessionLayer:create(friendInfo.UserID)
				chatSLayer:bindCloseCB(handler(self,self.onResume))
				display.getRunningScene():addChild(chatSLayer,7)
			else
				wwlog(self.logTag,"好友数据异常")
			end
			
		elseif ref:getName() == "Button_add" then
			--加好友去
			if self.cbFun then
				self.cbFun(3) --切换到添加好友界面
			end
		elseif ref:getName() == "Image_delete" then
			print("删除之")
			local friendInfo = self.mateList[ref:getTag()+1]
			if friendInfo then
				--dump(friendInfo)
				local deleteFun = function ()
					SocialContactProxy:deleteFriend(friendInfo.UserID)
				end
				local cancelFun = function ()
					if self.preTouchNode then
						self:scrollNodeBack(self.preTouchNode)
						self.preTouchNode = nil
					end
				end
				local para = {}
				para.leftBtnlabel = i18n:get('str_common','comm_no')
				para.rightBtnlabel = i18n:get('str_common','comm_yes')
				para.rightBtnCallback = deleteFun
				para.leftBtnCallback = cancelFun
				para.showclose = false  --是否显示关闭按钮
				para.content = i18n:get('str_cardpartner','partner_delete_confirm')

				local CommonDialog = import(".CommonDialog", "app.views.customwidget."):create( para ):show()
				
			else
				wwlog(self.logTag,"都不是好友，删除个毛啊")
				
			end
		end
		
	end
	
end
--绑定切换回调
function Friend_widget_Content:bindChangeCard(cbFun)
	self.cbFun = cbFun
end



return Friend_widget_Content