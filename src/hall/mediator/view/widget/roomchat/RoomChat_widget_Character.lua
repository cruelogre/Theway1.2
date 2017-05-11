-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.11
-- Last: 
-- Content:  表情页面控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local RoomChat_widget_Character = class("RoomChat_widget_Character",function ()
	return ccui.Layout:create()
end)


local Chat_character = require("csb.hall.roomchat.Chat_character")
local Chat_send = require("csb.hall.roomchat.Chat_send")

local RoomChatCfg = require("hall.mediator.cfg.RoomChatCfg")

local Toast = require("app.views.common.Toast")

local RoomChatProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ROOMCHAT)

function RoomChat_widget_Character:ctor(size)
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.charData = {}
	self.charCount = 0
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
function RoomChat_widget_Character:setGameData(MatchID,GamePlayID,InviteRoomID)
	self.MatchID = MatchID
	self.GamePlayID = GamePlayID
	self.InviteRoomID = InviteRoomID
end

function RoomChat_widget_Character:init()
	
	local sendNode = Chat_send:create().root
	local imgBg = sendNode:getChildByName("Image_bg")
	local bgSize = imgBg:getContentSize()
	sendNode:setPosition(cc.p(self.size.width/2,bgSize.height/2))
	self:addChild(sendNode,2)
	
	ccui.Helper:seekWidgetByName(imgBg,"Button_send"):addTouchEventListener(handler(self,self.touchEventListener))
	--TextField_1
	local textField = ccui.Helper:seekWidgetByName(imgBg,"TextField_1")
	--Button_send
	local fieldSize =cc.size(616,86)
	
	self.sendEditBox= ccui.EditBox:create(fieldSize, "roomchat_char_input.png",1)  --输入框尺寸，背景图片
	self.sendEditBox:setPosition(cc.p(textField:getPositionX()+fieldSize.width/2, textField:getPositionY()))
	self.sendEditBox:setAnchorPoint(cc.p(0.5,0.5))
	self.sendEditBox:setFontSize(36)
	self.sendEditBox:setPlaceholderFontSize(36)
	self.sendEditBox:setPlaceholderFontName("Arial")
	self.sendEditBox:setFontColor(cc.c3b(0x4e,0x43,0x27))
	self.sendEditBox:setMaxLength(RoomChatCfg.characterMaxCount)
	self.sendEditBox:setPlaceHolder(i18n:get('str_roomchat','char_input_placeholder'))
	self.sendEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) --输入键盘返回类型，done，send，go等
	self.sendEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE) --输入模型，如整数类型，URL，电话号码等，会检测是否符合\
	self.sendEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	self.sendEditBox:registerScriptEditBoxHandler(handler(self,self.editboxHandle))
	imgBg:addChild(self.sendEditBox)
	textField:removeFromParent()
	
	self.tableView = cc.TableView:create(cc.size(self.size.width,self.size.height-bgSize.height))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(cc.p(0,bgSize.height))
    self.tableView:setDelegate()
    self:addChild(self.tableView,1)
	self.tableView:setVerticalFillOrder(0) --竖直方向 填充顺序 从上到下
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Character.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Character.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Character.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Character.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Character.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,RoomChat_widget_Character.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	

	
	
end

function RoomChat_widget_Character:onEnter()
	
	print("RoomChat_widget_Character:onEnter")

end


function RoomChat_widget_Character:onExit()
	
	print("RoomChat_widget_Character:onExit")
	--self.super.onExit(self)
	
end

function RoomChat_widget_Character:active()

end

function RoomChat_widget_Character:editboxHandle(strEventName,sender)
	
	if strEventName=="began" then
		--sender:selectedAll() --光标进入，选中全部内容
	elseif strEventName=="ended" then --当编辑框失去焦点并且键盘消失的时候被调用
		
	elseif strEventName=="return" then -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		
	elseif strEventName=="changed" then
		
	end
end

function RoomChat_widget_Character:touchEventListener(ref,eventType)
	
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_send" then
			if string.len(self.sendEditBox:getText())==0 then
				Toast:makeToast(i18n:get('str_roomchat','char_input_empty'),1):show()
			else
				local data = {}
				data.content = self.sendEditBox:getText()
				local gameplayid = RoomChatManager:getGameData().GamePlayID
				if not gameplayid then
					gameplayid = self.GamePlayID or 0
				end
				local roomid = RoomChatManager:getGameData().InviteRoomID
				if not roomid then
					roomid = self.InviteRoomID or 0
				end
				self:checkToSend(data.content,gameplayid,roomid)
				--5s内 连续超过3次 弹出提示
				--RoomChatManager:playCharecter("1",data,{position=cc.p(400,400)}) --输入内容改变时调用
			end
			
			

		end
		
	end
	

end
--检查发送 如果5s内发送超过3次 则提示
function RoomChat_widget_Character:checkToSend(content,gameplayid,roomid)
	if table.maxn(self.sendTimes)>= RoomChatCfg.characterSer then
		local tableLen = table.maxn(self.sendTimes)
		local curTime = os.time()
		local diffTime = curTime - self.sendTimes[tableLen - RoomChatCfg.characterSer+1]
		if diffTime <= RoomChatCfg.characterDiffTime then --时间间隔小于阈值 弹出提示
			Toast:makeToast(i18n:get('str_roomchat','char_slow_down'),1):show()
		else
			for m=tableLen - RoomChatCfg.characterSer+1,1,-1 do
				table.remove(self.sendTimes,1)
			end
			table.insert(self.sendTimes,os.time())
			RoomChatProxy:sendChatData(content,gameplayid,roomid,RoomChatManager:getCurGameID())
			performWithDelay(self,function ()
				FSRegistryManager:currentFSM():trigger("back")
			end,0.1)
			
		end
	else
		table.insert(self.sendTimes,os.time())
		RoomChatProxy:sendChatData(content,gameplayid,roomid,RoomChatManager:getCurGameID())
		performWithDelay(self,function ()
			FSRegistryManager:currentFSM():trigger("back")
		end,0.1)
	end
end
--设置数据
function RoomChat_widget_Character:setCharData(charData)
	self.charData = charData
	self.charCount = table.maxn(self.charData)
	
	if isLuaNodeValid(self.tableView) then
		self.tableView:reloadData()
	end
end

function RoomChat_widget_Character:numberOfCellsInTableView(view)
	
	return self.charCount
end

function RoomChat_widget_Character:scrollViewDidScroll(view)

	
end

function RoomChat_widget_Character:scrollViewDidZoom(view)

end
function RoomChat_widget_Character:tableCellTouched(view,cell)
	print("tableCellTouched...",cell:getIdx())
	playSoundEffect("sound/effect/anniu")
	local tag = cell:getTag()
	local data = self.charData[tag+1]
	if data then
		--RoomChatManager:playCharecter("1",data,{position=cc.p(400,400)})
		local gameplayid = RoomChatManager:getGameData().GamePlayID
		if not gameplayid then
			gameplayid = self.GamePlayID or 0
		end
		local roomid = RoomChatManager:getGameData().InviteRoomID
		if not roomid then
			roomid = self.InviteRoomID or 0
		end
		self:checkToSend(data.content,gameplayid,roomid)
		if isLuaNodeValid(self.tableView) then
			self.tableView:setTouchEnabled(false)
		end
		--self.tableView:setTouchEnabled(false)
		--RoomChatProxy:sendChatData(data.content,gameplayid,roomid)
	end
	
end
function RoomChat_widget_Character:cellSizeForTable(view,idx)

	return 827.00,100

end
function RoomChat_widget_Character:createCharNode(view,cell,idx)
	local charNode = Chat_character:create().root
	--signNode:setAnchorPoint(0.5,0.5)

	charNode:setPositionX((0.5)*self.size.width)
	charNode:setPositionY(0)
	charNode:setName("Chat_character")
	charNode:setTag(idx)
	return charNode
end


function RoomChat_widget_Character:tableCellAtIndex(view,idx)
	
    local cell = view:dequeueCell()
	local ritem = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
		ritem = self:createCharNode(view,cell,idx)		
		cell:addChild(ritem)
	else
		ritem = cell:getChildByName("Chat_character")
    end
	cell:setTag(idx)
	ritem:setTag(idx)
	local textContent = ritem:getChildByName("Text_content")
	local data = self.charData[idx+1]
	textContent:setString(data.content or "")

    return cell
end

function RoomChat_widget_Character:eventComponent()
	return RoomChatCfg.innerEventComponent
end



return RoomChat_widget_Character