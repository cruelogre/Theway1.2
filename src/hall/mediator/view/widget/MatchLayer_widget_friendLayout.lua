-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.10.09
-- Last: 
-- Content:  比赛显示好友列表的控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchLayer_widget_friendLayout = class("MatchLayer_widget_friendLayout",function ()
	return ccui.Layout:create()
end)

local FriendItem = require("csb.hall.match.Node_match_frienditem1")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

local Toast = require("app.views.common.Toast")

function MatchLayer_widget_friendLayout:ctor(size,matchid,InstMatchID)
	self.size = size --显示尺寸
	self.InstMatchID = InstMatchID
	self.matchid = matchid
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.0,0.0))
	self:setTouchEnabled(true)
	self.logTag = "MatchLayer_widget_friendLayout.lua"
	self.roomCount = 0
	
	self:init()
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function MatchLayer_widget_friendLayout:init()
	
	self.tableView = cc.TableView:create(self.size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.tableView:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView,1)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_friendLayout.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_friendLayout.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_friendLayout.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_friendLayout.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_friendLayout.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_friendLayout.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
end

function MatchLayer_widget_friendLayout:onEnter()
	


end

function MatchLayer_widget_friendLayout:reloadData(friendMap)
	print("刷新好友列表...........................")
	self.friendMap = clone(friendMap)
	
	self.friendCount = #self.friendMap
	self.tableView:reloadData()

	
end

function MatchLayer_widget_friendLayout:numberOfCellsInTableView(view)
	--根据返回的数据决定是多少行 4/5
	
	return math.ceil(#self.friendMap)
end

function MatchLayer_widget_friendLayout:scrollViewDidScroll(view)

end

function MatchLayer_widget_friendLayout:scrollViewDidZoom(view)

end
function MatchLayer_widget_friendLayout:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
end
function MatchLayer_widget_friendLayout:cellSizeForTable(view,idx)
	return 995,130.00 + 30
end
function MatchLayer_widget_friendLayout:tableCellAtIndex(view,idx)
	local cell = view:dequeueCell()
	local frienditem = nil
	if nil == cell then
		cell = cc.TableViewCell:new()
		local temp = FriendItem:create()
		frienditem = temp.root
		local img = frienditem:getChildByName("Image_bg")
		local invite = img:getChildByName("Button_invite")
		invite:setSwallowTouches(false)
		invite:addTouchEventListener(handler(self,self.touchEventListener))
		cell:addChild(frienditem)
		frienditem:setName("frienditem")
		frienditem:setPositionX(img:getContentSize().width/2+10)
		frienditem:setPositionY(img:getContentSize().height/2)
	else
		frienditem = cell:getChildByName("frienditem")
	end
	self:reSetItem(frienditem)
	--设置信息
	local friendInfo = self.friendMap[idx+1]
	if friendInfo then
		local img = frienditem:getChildByName("Image_bg")
		--设置是否在线
		ccui.Helper:seekWidgetByName(img,"Image_dot"):setVisible(friendInfo.OnlineFlag==1)
		ccui.Helper:seekWidgetByName(img,"Text_name"):setString(friendInfo.Nickname)
		--ccui.Helper:seekWidgetByName(img,"Image_head"):
		local param = {
			headFile=DataCenter:getUserdataInstance():getHeadIconByGender(friendInfo.Gender and tonumber(friendInfo.Gender) or 1),
			maskFile="#match_mate_bg_header2.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=60 ,
	        headIconType = friendInfo.IconID,
	        userID = friendInfo.UserID
	    }
		--
		local HeadSprite = WWHeadSprite:create(param)
		HeadSprite:setPosition(cc.p(60,60))
		ccui.Helper:seekWidgetByName(img,"Image_head"):addChild(HeadSprite,1)
		ccui.Helper:seekWidgetByName(img,"Button_invite"):setTag(idx)
		--没有被邀请的才可以邀请
		local inviteBtn = ccui.Helper:seekWidgetByName(img,"Button_invite")
		local canInvite = (friendInfo.OnlineFlag==1 and friendInfo.Param1<3)
		inviteBtn:setBright(canInvite)
		inviteBtn:setTitleColor(canInvite and cc.c3b(0x89,0x1E,0x0F) or cc.c3b(0x73,0x73,0x73))
	end
	return cell
	
end
--重置item信息
function MatchLayer_widget_friendLayout:reSetItem(frienditem)
	local img = frienditem:getChildByName("Image_bg")
	ccui.Helper:seekWidgetByName(img,"Image_dot"):setVisible(false)
	--Image_head
	ccui.Helper:seekWidgetByName(img,"Image_head"):removeAllChildren()
	ccui.Helper:seekWidgetByName(img,"Text_name"):setString("")
	ccui.Helper:seekWidgetByName(img,"Button_invite"):setBright(false)
	
end

function MatchLayer_widget_friendLayout:touchEventListener(ref,eventType)
	if not ref or self.tableView:isTouchMoved() then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		print("ref:getTag()",ref:getTag())
		local idx = ref:getTag()
		if ref:isBright() then
			playSoundEffect("sound/effect/anniu")
			local friendInfo = self.friendMap[idx+1]
			local mynickname = DataCenter:getUserdataInstance():getValueByKey("nickname")
			local myuserid = DataCenter:getUserdataInstance():getValueByKey("userid")
			local myIconID = DataCenter:getUserdataInstance():getValueByKey("IconID")
			local mygender = DataCenter:getUserdataInstance():getValueByKey("gender")
			
			local nickname = tostring(myuserid)
			if mynickname and string.len(mynickname)>0 then
				nickname = mynickname
			end
			
			Toast:makeToast(string.format(i18n:get('str_match','match_invite_wait'),addMoney), 1.0):show()
			
			MatchProxy:requestInviteOrRefuse(4,friendInfo.UserID,tonumber(myIconID),nickname,self.InstMatchID,self.matchid,mygender)
			--请求后重新刷新好友界面
			--MatchProxy:requestFriend(4,self.InstMatchID)
		end
		
	end
	
end
function MatchLayer_widget_friendLayout:onExit()
	--self:eventComponent():removeEventListener(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	
	removeAll(self.friendMap)
	
	self.friendMap = self.friendMap or {}
	if isLuaNodeValid(self.tableView) then
		self.tableView:removeFromParent()
		self.tableView =  nil
	end
end

return MatchLayer_widget_friendLayout