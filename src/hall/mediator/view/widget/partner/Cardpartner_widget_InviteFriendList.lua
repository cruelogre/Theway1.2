-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.23
-- Last: 
-- Content:  可邀请好友列表控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Cardpartner_widget_InviteFriendList = class("Cardpartner_widget_InviteFriendList",ccui.Layout,require("packages.mvc.Mediator"))

local Node_partner_IniviteFitem = require("csb.hall.cardpartner.Node_partner_IniviteFitem")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

local ChatSessionLayer = require("hall.mediator.view.ChatSessionLayer")

local HallChatService = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().HALL_CHAT_SERVICE)
local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")
local Toast = require("app.views.common.Toast")
local UserDataCenter = DataCenter:getUserdataInstance()
function Cardpartner_widget_InviteFriendList:ctor(size,inviteType,paramId)
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.inviteType = inviteType or 4 --邀请的类型 4 私人房 3 比赛
	self.paramId =paramId --参数的ID 如果是私人房就是roomID 如果是比赛就是比赛实例ID
	self.cbFun = nil
	self.tableView = nil
	self.searchIndex = 1
	self.logTag = self.__cname..".lua"
	self.handlers = {}
	self.mateList = nil
	self.mateCount = 0 --好友的数量
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function Cardpartner_widget_InviteFriendList:initView()
	wwlog(self.logTag,"Cardpartner_widget_InviteFriendList:initView")
	
end

function Cardpartner_widget_InviteFriendList:initFriendLayout()
	self.tableView = cc.TableView:create(self.size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.tableView:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView,1)
    self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	-- tableview 中触摸取消
	self.tableView:registerScriptHandler(handler(self,Cardpartner_widget_InviteFriendList.cellTouchEnded),ww.TABLECELL_TOUCHENDED)
end
function Cardpartner_widget_InviteFriendList:onEnter()
	wwlog(self.logTag,"Cardpartner_widget_InviteFriendList:onEnter")
	self:initView()
--[[	local tempFriends = {}
	tempFriends.mateList = {}
	for i=0,10 do
		table.insert(tempFriends.mateList,{OnlineFlag = 1,Nickname = "Nickname"..i,Gender = 1,UserID = 10000+i,IconID = 101,Param1 = 2})
	end
	
	DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_FOUNDMATES_ADDFRIEND,tempFriends)
	self:reloadData()--]]
	--先默认请求前10个好友

	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITE_FRIENDLIST,handler(self,self.reloadData))
	
	self:reloadData()
	self.searchIndex = 1
	SocialContactProxy:requestInvitePartner(self.inviteType,self.paramId,self.searchIndex,CardPartnerCfg.friendSearchLen)
	
	
end

--绑定切换的回调 切换到另外一个切页
function Cardpartner_widget_InviteFriendList:bindChangeFun(cbFun)
	self._cbFun = cbFun
end

function Cardpartner_widget_InviteFriendList:onExit()
	
	wwlog(self.logTag,"Cardpartner_widget_InviteFriendList:onExit")
	if isLuaNodeValid(self.actWevView) then
		self.actWevView:removeFromParent()
	end

	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITE_FRIENDLIST)
	self.searchIndex = 1
end


function Cardpartner_widget_InviteFriendList:active()
	
end
--排序好友列表
function Cardpartner_widget_InviteFriendList:sortMate(mateList)

end

function Cardpartner_widget_InviteFriendList:reloadData(event)
	print("MatchLayer_widget_friendList:reloadData")
	
	
	local hasFriend = false
	local allFriendLists = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_GAME_INVITE_FRIENDLIST)
	local friendLists =nil
	if allFriendLists then
		friendLists = allFriendLists[self.inviteType]
	end
	dump(friendLists)
	
	--有数据，有朋友
	if friendLists and friendLists.friendList and next(friendLists.friendList) then
		hasFriend = true
		local tempMateList = clone(friendLists.friendList)
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

--加载更多
--根据当前tableview的位置来判断是上拉刷新还是下拉刷新
function Cardpartner_widget_InviteFriendList:loadMore()
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
			SocialContactProxy:requestInvitePartner(self.inviteType,self.paramId,self.searchIndex,CardPartnerCfg.friendSearchLen)
			
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
				SocialContactProxy:requestInvitePartner(self.inviteType,self.paramId,self.searchIndex,CardPartnerCfg.friendSearchLen)
			else
				wwlog(self.logTag,"当前已经是最后了，没有更多了")
			end
		else
			wwlog(self.logTag,"我的帐号异常")
		end
	end
end
function Cardpartner_widget_InviteFriendList:cellTouchEnded(view,cell)
	self:loadMore()
end
function Cardpartner_widget_InviteFriendList:numberOfCellsInTableView(view)
	
	return self.mateCount
end

function Cardpartner_widget_InviteFriendList:scrollViewDidScroll(view)

end

function Cardpartner_widget_InviteFriendList:scrollViewDidZoom(view)

end
function Cardpartner_widget_InviteFriendList:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
	--好友详情界面
--[[	local reqUserId = self.mateList[cell:getTag()+1].UserID
	wwlog(self.logTag,"打开的用户ID:"..reqUserId)
	FSRegistryManager:currentFSM():trigger("userinfo",
	{parentNode = display.getRunningScene(), zorder = 4,userid = reqUserId,isFriend = true})--]]
end
function Cardpartner_widget_InviteFriendList:cellSizeForTable(view,idx)
	return 995,168.00 + 30
end
function Cardpartner_widget_InviteFriendList:tableCellAtIndex(view,idx)
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
	cell:setTag(idx)
	--设置信息
	local friendInfo = self.mateList[idx+1]
	if friendInfo then
		local img = frienditem:getChildByName("Image_bg")
		--设置是否在线
		ccui.Helper:seekWidgetByName(img,"Image_dot"):setVisible(friendInfo.OnlineFlag==1)
		ccui.Helper:seekWidgetByName(img,"Text_name"):setString(friendInfo.Nickname)

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
		local inviteBtn = ccui.Helper:seekWidgetByName(img,"Button_invite")
		inviteBtn:setTag(idx)
		--没有被邀请的才可以邀请
		--OnlineFlag 在线标识 0 不在线 1 在线
		--Param1 0 可邀请 1 邀请过多 2 已在私人房
		local canInvite = (friendInfo.OnlineFlag==1 and friendInfo.Param1==0)
		inviteBtn:setBright(canInvite)
		inviteBtn:setTouchEnabled(canInvite)
		if canInvite then
			inviteBtn:addTouchEventListener(handler(self,self.touchEventListener))
		end
		
		inviteBtn:setTitleColor(canInvite and cc.c3b(0x89,0x1E,0x0F) or cc.c3b(0x73,0x73,0x73))
	end
	return cell
	
end
function Cardpartner_widget_InviteFriendList:createFriendItem()
	local temp = Node_partner_IniviteFitem:create()
	local frienditem = temp.root
	local img = frienditem:getChildByName("Image_bg")
	local inviteBtn = img:getChildByName("Button_invite")
	--chatBtn:setSwallowTouches(false)
	img:setSwallowTouches(false)
	inviteBtn:addTouchEventListener(handler(self,self.touchEventListener))
	frienditem:setName("frienditem")
	frienditem:setPositionX(img:getContentSize().width/2+10)
	frienditem:setPositionY(img:getContentSize().height/2)
	return frienditem
end

--重置item信息
function Cardpartner_widget_InviteFriendList:reSetItem(frienditem)
	local img = frienditem:getChildByName("Image_bg")
	ccui.Helper:seekWidgetByName(img,"Image_dot"):setVisible(false)
	--Image_head
	ccui.Helper:seekWidgetByName(img,"Image_head"):removeAllChildren()
	ccui.Helper:seekWidgetByName(img,"Text_name"):setString("")
	ccui.Helper:seekWidgetByName(img,"Button_invite"):setBright(false)
	
end


function Cardpartner_widget_InviteFriendList:touchEventListener(ref,eventType)
	
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_invite" then
		--发送好友邀请
			local mateInfo = self.mateList[ref:getTag()+1]
			if mateInfo then
				dump(mateInfo)
				print("mateInfo.UserID",mateInfo.UserID)
				Toast:makeToast(i18n:get('str_cardpartner','partner_invite_wait'),1.0):show()
				
				if self.inviteType == 4  then --邀请的类型 4 私人房 3 比赛
					SocialContactProxy:inviteIntoSiren(self.paramId,mateInfo.UserID)
				elseif self.inviteType == 3 then
					print("比赛邀请不走这儿")
				end


			end
		elseif ref:getName() == "Button_add" then
			--加好友去
			if self._cbFun then
				self._cbFun(2) --切换到添加好友界面
			end
		end
		
	end
	
end
--[[--绑定切换回调
function Cardpartner_widget_InviteFriendList:bindChangeCard(cbFun)
	self.cbFun = cbFun
end--]]



return Cardpartner_widget_InviteFriendList