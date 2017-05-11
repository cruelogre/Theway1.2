-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  表情页面控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RoomChat_widget_Facial = class("RoomChat_widget_Facial",function ()
	return ccui.Layout:create()
end)


local Chat_expression = require("csb.hall.roomchat.Chat_expression")

local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")
local Toast = require("app.views.common.Toast")

local RoomChatProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ROOMCHAT)

function RoomChat_widget_Facial:ctor(size)
	wwlog("RoomChat_widget_Facial 创建")
	self.size = size --显示尺寸
	self.crtype = crtype --什么类型的房间
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.lineLayer = nil --竖线的节点
	self.facialData = {}
	self.facialCount = 0
	self:init()
	self.sendTimes = {}
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end
--设置牌局数据
--@param MatchID 比赛ID
--@param GamePlayID 对局ID
--@param InviteRoomID 私人房ID
function RoomChat_widget_Facial:setGameData(MatchID,GamePlayID,InviteRoomID)
	self.MatchID = MatchID
	self.GamePlayID = GamePlayID
	self.InviteRoomID = InviteRoomID
end

function RoomChat_widget_Facial:init()
	
	self.tableView = cc.TableView:create(self.size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.tableView:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.tableView:setDelegate()
    self:addChild(self.tableView,1)
	self.tableView:setVerticalFillOrder(0) --竖直方向 填充顺序 从上到下
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Facial.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Facial.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Facial.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Facial.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Facial.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Facial.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
--[[	self.lineLayer = cc.Node:create()
	self:addChild(self.lineLayer,2)--]]
	
end
--设置数据
function RoomChat_widget_Facial:setFacialData(facialData)
	self.facialData = facialData
	self.facialCount = table.maxn(self.facialData)
	
	if isLuaNodeValid(self.tableView) then
		self.tableView:reloadData()
--[[		self.lineLayer:removeAllChildren()
		for i=1,RoomChatCfg.facialMaxCount-1 do
			local x,y = self:cellSizeForTable()
			local sp = display.newSprite("#roomchat_expre_line2.png")
			local mSize = sp:getContentSize()
			sp:setAnchorPoint(cc.p(0.0,0.0))
			sp:setScaleX(4)
			
			sp:setScaleY(self.size.height/mSize.height)
			sp:setPosition(cc.p(x*i,0))
			self.lineLayer:addChild(sp)
			
		end--]]

	end
end

function RoomChat_widget_Facial:onEnter()
	
	print("RoomChat_widget_Facial:onEnter")

end


function RoomChat_widget_Facial:onExit()
	
	print("RoomChat_widget_Facial:onExit")
	--self.super.onExit(self)
	
end
function RoomChat_widget_Facial:active()

end
function RoomChat_widget_Facial:numberOfCellsInTableView(view)
	local count = math.ceil(table.maxn(self.facialData)/RoomChatCfg.facialMaxCount) 
	
	return count
end

function RoomChat_widget_Facial:scrollViewDidScroll(view)
	
end

function RoomChat_widget_Facial:scrollViewDidZoom(view)

end
function RoomChat_widget_Facial:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
	
end
function RoomChat_widget_Facial:cellSizeForTable(view,idx)

	return self.size.width/RoomChatCfg.facialMaxCount,self.size.height/3

	
end

function RoomChat_widget_Facial:createSinNode(view,cell,idx,i)
	local signNode = Chat_expression:create().root
	--signNode:setAnchorPoint(0.5,0.5)
	local img = signNode:getChildByName("Image_facial")
	img:setSwallowTouches(false)
	img:ignoreContentAdaptWithSize(true)
	local iwidth,iheight = self:cellSizeForTable(view,cell)
	signNode:setPositionX((i+0.5)*iwidth)
	signNode:setPositionY(20)
	--img:setTouchEnabled(false)
	img:addTouchEventListener(handler(self,self.touchEventListener))
	img:setTag((idx)*10000+i) --方便点击的时候计算位置
	--cell:addChild(signNode)
	
	
	signNode:setTag(i)
	return signNode
end


function RoomChat_widget_Facial:tableCellAtIndex(view,idx)
	print("tableCellAtIndex",idx)
    local cell = view:dequeueCell()
	local facialNode = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
		for i=0,RoomChatCfg.facialMaxCount-1 do
			local m2 =  self.facialCount
			local m1 = (idx)*RoomChatCfg.facialMaxCount+i+1
			if m1<=m2 then
				facialNode = self:createSinNode(view,cell,idx,i)
				
				cell:addChild(facialNode)
				
			end		
		end
--[[		if idx+1< self:numberOfCellsInTableView(view) then
			local sp = display.newSprite("#roomchat_expre_line1.png")
			sp:setAnchorPoint(cc.p(0.0,0.0))
			sp:setScaleY(4)
			sp:setPosition(cc.p(0,-15))
			cell:addChild(sp)
		end--]]

    else
		for i=0,RoomChatCfg.facialMaxCount-1 do
			local m2 = self.facialCount
			local m1 = (idx)*RoomChatCfg.facialMaxCount+i+1
			if m1>m2 then
				cell:removeChildByTag(i)
			else
				if not cell:getChildByTag(i) then
					facialNode = self:createSinNode(view,cell,idx,i)
					cell:addChild(facialNode)
				end
			end
			if cell:getChildByTag(i) then
				cell:getChildByTag(i):getChildByName("Image_facial"):setTag((idx)*10000+i)
			end
		end
        --signNode = cell:getChildByTag(1)
    end
	for i=0,RoomChatCfg.facialMaxCount-1 do
		facialNode = cell:getChildByTag(i)
		--当前显示的位置
		self:restoreView(facialNode)
		local showIndex = idx*RoomChatCfg.facialMaxCount+i+1
		local showData = self.facialData[showIndex]
		--showData.animFile
		--cc.SpriteFrameCache:getInstance():addSpriteFrames(showData.animFile..".plist")
		
		facialNode:getChildByName("Image_facial"):loadTexture(showData.showFrame,1)
		
		facialNode:getChildByName("Text_desc"):setString(showData.desc)
		
	end
    return cell
end
--重置界面内容 重用的时候 动画 颜色
function RoomChat_widget_Facial:restoreView(facialNode)
	
	if not isLuaNodeValid(facialNode) then
		return
	end
	
	facialNode:stopAllActions()
	facialNode:setScale(1)
end

function RoomChat_widget_Facial:touchEventListener(ref,eventType)
	self.contentOffset = self.tableView:getContentOffset()
	
	if not ref or self.tableView:isTouchMoved() then
		return
	end
	if not self.facialData then
		return
	end
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local tag = ref:getTag() 
		print(tag)
		-- tag = (idx)*10000+i
		local i = tag%10000
		local idx = math.floor(tag/10000)
		local showIndex = idx*RoomChatCfg.facialMaxCount+i+1
		
		local data = self.facialData[showIndex]
		if data then			
			local gameplayid = RoomChatManager:getGameData().GamePlayID
			if not gameplayid then
				gameplayid = self.GamePlayID or 0
			end
			local roomid = RoomChatManager:getGameData().InviteRoomID
			if not roomid then
				roomid = self.InviteRoomID or 0
			end
			--RoomChatProxy:sendChatData(data.shortcut,gameplayid,roomid)
			self:checkToSend(data.shortcut,gameplayid,roomid)
		
		end
		
	end
	

end

--检查发送 如果5s内发送超过3次 则提示
function RoomChat_widget_Facial:checkToSend(content,gameplayid,roomid)
	if table.maxn(self.sendTimes)>= RoomChatCfg.facialSer then
		local tableLen = table.maxn(self.sendTimes)
		local curTime = os.time()
		local diffTime = curTime - self.sendTimes[tableLen - RoomChatCfg.facialSer+1]
		if diffTime <= RoomChatCfg.facialDiffTime then --时间间隔小于阈值 弹出提示
			Toast:makeToast(i18n:get('str_roomchat','char_slow_down'),1):show()
		else
			for m=tableLen - RoomChatCfg.facialSer+1,1,-1 do
				table.remove(self.sendTimes,1)
			end
			table.insert(self.sendTimes,os.time())
			RoomChatProxy:sendChatData(content,gameplayid,roomid,RoomChatManager:getCurGameID())
			FSRegistryManager:currentFSM():trigger("back")
		end
	else
		table.insert(self.sendTimes,os.time())
		RoomChatProxy:sendChatData(content,gameplayid,roomid,RoomChatManager:getCurGameID())
		FSRegistryManager:currentFSM():trigger("back")
	end
end

function RoomChat_widget_Facial:eventComponent()
	return RoomChatCfg.innerEventComponent
end



return RoomChat_widget_Facial