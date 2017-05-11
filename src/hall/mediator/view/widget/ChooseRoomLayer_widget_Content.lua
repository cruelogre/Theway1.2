-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.26
-- Last: 
-- Content:  房间列表内容控件
-- Modify: 
--			2016/12/29 优化跳转条件
--			2017/1/3 跳转动画优化
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local ChooseRoomLayer_widget_Content = class("ChooseRoomLayer_widget_Content",function ()
	return ccui.Layout:create()
end)
local RoomItem = require("csb.hall.choose.ChooseRoomItem")


local ChooseRoomCfg = require("hall.mediator.cfg.ChooseRoomCfg")
local ChooseRoomProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_CHOORSERM)
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)

import(".WhippedEggEvent", "WhippedEgg.event.")
local Toast = require("app.views.common.Toast")

local BankruptLayer = require("app.views.customwidget.BankruptLayer")

function ChooseRoomLayer_widget_Content:ctor(crtype, gameid, playType, size)
	self.size = size --显示尺寸
	self.crtype = crtype --什么类型的房间
	self.gameid = gameid --游戏类型
	self.playType = playType --玩法类型

	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.logTag = "ChooseRoomLayer_widget_Content.lua"
	self.roomCount = 0
	self.clickItem = false
	self.canAnim = true --创建的时候是否允许动画
	self.scrollTime = 0
	
	self.handlers = {}
	
	self:init()
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end

function ChooseRoomLayer_widget_Content:init()
	
	self.tableView = cc.TableView:create(self.size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.tableView:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self.tableView,1)
    self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableView:registerScriptHandler(handler(self,ChooseRoomLayer_widget_Content.scrollViewWillRecycle),cc.TABLECELL_WILL_RECYCLE)
	self.mask1 = display.newSprite("hall/choose/chooserm_mask.png")
	self.mask1:setBlendFunc(cc.blendFunc(gl.ONE , gl.ONE_MINUS_SRC_ALPHA))
	self.mask1:setPosition(cc.p(self.size.width/2,0))
	self:addChild(self.mask1,2)
	self.mask2 = display.newSprite("hall/choose/chooserm_mask2.png")
	--self.mask2:setScaleY(-1)
	self.mask2:setBlendFunc(cc.blendFunc(gl.ONE , gl.ONE_MINUS_SRC_ALPHA))
	self.mask2:setPosition(cc.p(self.size.width/2,self.size.height))
	self:addChild(self.mask2,2)
	self.mask1:setVisible(false)
	self.mask2:setVisible(false)
	
	self.tableView:setTouchEnabled(false)
end

function ChooseRoomLayer_widget_Content:onEnter()
	if self:eventComponent() then
		local _ = nil
		_,self.handlers[#self.handlers+1] = self:eventComponent():addEventListener(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST,handler(self,self.reloadData))
		
	end
	
	ChooseRoomProxy:requestHallList(self.crtype, self.gameid, self.playType)

--[[	local event = {userTag = 2}
	local tempTable = {}
	tempTable[event.userTag] = {}
	tempTable[event.userTag].looptab1 = {}
	for i=0,10 do
		table.insert(tempTable[event.userTag].looptab1,{GameZoneID = i,Name = string.format("房间%d",i),Account = math.random(1,100),FortuneMin = math.random(1000,20000)})
	end
	DataCenter:cacheData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST,tempTable)
	self:reloadData(event)--]]
	self:reloadData({}) --先取缓存。。。还是算了吧
	self.mask1:setVisible(self.roomCount>0)
	self.mask2:setVisible(self.roomCount>0)
	
end
function ChooseRoomLayer_widget_Content:onExit()
	--self:eventComponent():removeEventListener(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	if self:eventComponent() then
		for _,v in ipairs(self.handlers) do
			self:eventComponent():removeEventListener(v)
		end
		removeAll(self.handlers)
	end
	
end

function ChooseRoomLayer_widget_Content:reloadData(event)
	if not self.handlers then
		return
	end
	if not event.userTag and not DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST) then
		return
	end
	
	local data = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)[event.userTag and event.userTag or 2]
	if not data then
		return
	end
	--dump(data)

	self.roomCount = #data.looptab1
	self.gameZone = data.looptab1
	self.gamePlayType = data.looptab1

	self.clickItem = false
	self.tableView:reloadData()
	
	self.mask1:setVisible(self.roomCount>0)
	self.mask2:setVisible(self.roomCount>0)
	
	--dump(ChooseRoomProxy:getRoomData(259))
	
end
function ChooseRoomLayer_widget_Content:scrollViewWillRecycle(view)
	self.canAnim = false
end
function ChooseRoomLayer_widget_Content:numberOfCellsInTableView(view)
	--根据返回的数据决定是多少行 4/5
	
	return math.ceil(self.roomCount/ChooseRoomCfg.maxCountEveryRow)
end

function ChooseRoomLayer_widget_Content:scrollViewDidScroll(view)
	if self.canAnim then
		self.scrollTime = self.scrollTime +1
		if self.scrollTime > 1 then
			self.canAnim = false
			self.scrollTime = 0
		end
	end
end

function ChooseRoomLayer_widget_Content:scrollViewDidZoom(view)

end
function ChooseRoomLayer_widget_Content:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
end
function ChooseRoomLayer_widget_Content:cellSizeForTable(view,idx)
	return 850,300
end

function ChooseRoomLayer_widget_Content:createItemIdx(view,cell,idx,i)
	local ritem = RoomItem:create().root
				
	local img = ritem:getChildByName("Image_bg")
	img:setSwallowTouches(false)
	local cellSizeX = self:cellSizeForTable(view,cell)
	local x = (i)*self:cellSizeForTable(view,cell) +cellSizeX/2
	local y = img:getContentSize().height/2+50
	ritem:setPositionX(x)
	ritem:setPositionY(y)
	--img:setTouchEnabled(false)
	img:addTouchEventListener(handler(self,ChooseRoomLayer_widget_Content.touchEventListener))
	img:setTag((idx)*10000+i) --方便点击的时候计算位置
	print("img tag",img:getTag())
	--cell:addChild(ritem)
	ritem:setTag(i)
	
	if self.canAnim then
		if i%2==0 then
			ritem:setPositionX(-x)
		else
			ritem:setPositionX(2*x)
		end
		ritem:runAction(cc.EaseSineOut:create(cc.MoveTo:create(0.1*(idx+1),cc.p(x,y))))
		self.tableView:setTouchEnabled(true)
	else
		self.tableView:setTouchEnabled(true)
	end

	return ritem
end
function ChooseRoomLayer_widget_Content:tableCellAtIndex(view,idx)
	print("tableCellAtIndex",idx)
    local cell = view:dequeueCell()
	local ritem = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
		local mSize = cc.size(0,0)
		for i=0,ChooseRoomCfg.maxCountEveryRow-1 do
			local m1 = (idx)*ChooseRoomCfg.maxCountEveryRow+i+1
			
			if m1<=self.roomCount then
				ritem = self:createItemIdx(view,cell,idx,i)
				mSize.width = mSize.width + ritem:getChildByName("Image_bg"):getContentSize().width
				mSize.height = math.max(mSize.height,ritem:getChildByName("Image_bg"):getContentSize().height)
				cell:addChild(ritem)
			end
		end
		cell:setContentSize(mSize)
		
    else
        for i=0,ChooseRoomCfg.maxCountEveryRow-1 do
			local m1 = (idx)*ChooseRoomCfg.maxCountEveryRow+i+1
			if m1>self.roomCount then
				cell:removeChildByTag(i)
				
			else
				if not cell:getChildByTag(i) then
					 ritem = self:createItemIdx(view,cell,idx,i)
					 cell:addChild(ritem)
				end
			end
			if cell:getChildByTag(i) then
				cell:getChildByTag(i):getChildByName("Image_bg"):setTag((idx)*10000+i)
			end
			
		end
    end
	
	for i=0,ChooseRoomCfg.maxCountEveryRow-1 do
		ritem = cell:getChildByTag(i)
		
		local zoneData = self.gameZone[idx*ChooseRoomCfg.maxCountEveryRow+i+1]
		if ritem and zoneData then
			ritem:setScale(1.0)
			ritem:getChildByName("Text_name"):setString(zoneData.Name)
			ritem:getChildByName("Text_mode"):setString(zoneData.Description)
			
			ritem:getChildByName("Text_online_count"):setString(string.format("%d%s",math.floor(zoneData.Account),i18n:get('str_chooserm','chooserm_account')))
			ritem:getChildByName("Text_condition"):setString(string.format("%d%s",math.floor(zoneData.fortuneBase),i18n:get('str_chooserm','chooserm_minscore')))
			
		end
	end
	
    return cell
end

function ChooseRoomLayer_widget_Content:touchEventListener(ref,eventType)

	if ref then
		if not ref or self.tableView:isTouchMoved() or not self.tableView:canGetTouch() then
			if ref and ref:getParent() then
				ref:getParent():setScale(1.00)
			end
			return
		end
			
		local parent = ref:getParent()
		if parent then
			if eventType==ccui.TouchEventType.ended then
				parent:runAction(cc.ScaleTo:create(0.05,1.0))
			elseif eventType == ccui.TouchEventType.began then
				parent:setScale(1.05)
				playSoundEffect("sound/effect/anniu")
			elseif eventType == ccui.TouchEventType.canceled then
				parent:runAction(cc.ScaleTo:create(0.05,1.0))
			end
			
		--边缘触摸计算 
--[[		local x = ref:getTag()%10000 --当前点击的item中在横向的位置
		local y = math.floor(ref:getTag()/10000) --当前点击的item在第几列
		local width,height = self:cellSizeForTable()
		local offsetPos = self.tableView:getContentOffset()
		local minOffset = self.tableView:minContainerOffset()
		if height*(y-1) > self.size.height+offsetPos.y or height*y < math.abs(minOffset.y - offsetPos.y) then
			return
		end--]]
			
		end
		
	end

	if eventType==ccui.TouchEventType.began then
		
	elseif eventType==ccui.TouchEventType.ended then
		if self.clickItem then
			return 
		end
		self.clickItem = true
		
		--分别取横，纵坐标  下标从0开始
		local x = ref:getTag()%10000 --当前点击的item中在横向的位置
		local y = math.floor(ref:getTag()/10000) --当前点击的item在第几列
		local zoneData = self.gameZone[y*ChooseRoomCfg.maxCountEveryRow+x+1]
		local zoneDataPlayType = self.gamePlayType[y*ChooseRoomCfg.maxCountEveryRow+x+1]
		local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey('GameCash'))
		if myCash < zoneData.FortuneMin then
			--金币不足
			self:tipCash(myCash,zoneData.FortuneMin)
		elseif zoneData.FortuneMax>0 and myCash >zoneData.FortuneMax then
			--你很牛逼了
			if self.clickItem then
				--return
			end

			self.clickItem = true
			Toast:makeToast(i18n:get('str_chooserm','chooserm_gold_too_many'),1.0):show()
			local enterData,playTypeData = self:getMaxEnterRoomData(myCash)
			if enterData then
				performWithDelay(self,function ()
					self:gotoGameScene(zoneDataPlayType, gameType, zoneData)
					wwlog(self.logTag,"发送进入游戏大厅事件1")
				end,0.5)

			else
				--
				wwlog(self.logTag,"太TM牛逼了，所有房间对于您都太low了")
				self.clickItem = false
			end
		else
			--金币够啦
			performWithDelay(self,function ()
				self:gotoGameScene(zoneDataPlayType, gameType, zoneData)
				wwlog(self.logTag,"发送进入游戏大厅事件2")
			end,0.5)
			
		end
		--进入游戏
		--self.curSelected.x = x
		--self.curSelected.y = y
		--requestEnterGame   
	end
end

--发送具体玩法场事件
function ChooseRoomLayer_widget_Content:gotoGameScene(zoneDataPlayType, gameType, zoneData)
	if self.gameid == wwConfigData.GAME_ID then --掼蛋
		ChooseRoomProxy:requestEnterGame(zoneData.GameZoneID)


		local gameType = Game_Type.ClassicalPromotion
		if zoneDataPlayType.PlayType == Play_Type.PromotionGame then
			gameType = Game_Type.ClassicalPromotion
		elseif zoneDataPlayType.PlayType == Play_Type.RandomGame then
			gameType = Game_Type.ClassicalRandomGame
		elseif zoneDataPlayType.PlayType == Play_Type.RcircleGame then
			gameType = Game_Type.ClassicalRcircleGame
		end

		wwlog(self.logTag, "gotoGameScene"..gameType)

		UmengManager:eventCount2("ClassicChoose", zoneData.Name or "None")
		WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY, gameType, zoneData.GameZoneID, zoneData.fortuneBase)
	elseif self.gameid == wwConfigData.GAMELOGICPARA.BULLFIGHT.GAME_ID then --斗牛
		WWFacade:dispatchCustomEvent(BULLFIGHTING_SCENE_EVENTS.MAIN_ENTRY, gameType, zoneData.GameZoneID, zoneData.fortuneBase)
	else
		self.clickItem = false
		wwlog(self.logTag,"异常了，异常了，gameid不对"..tostring(self.gameid))
	end
	
end


--提示金币不足
function ChooseRoomLayer_widget_Content:tipCash(myCash,fortuneMin)
	local minData = self:getMinEnterRoomData()
	--zoneData.FortuneMin
	local para = {}		
		
	para.layerType = myCash< minData.FortuneMin  and 2 or 1  --界面类型  1金币不足 2 破产
	para.sceneTag = 1 --在哪个场景
	para.money = fortuneMin - myCash
	para.upCloseOnClick = true
	para.upCallback = function ()
		--购买金币  打开商城
		self.clickItem = false

		local sIDKey 
		if para.layerType == 1 then --金币不足
			sIDKey = "GoldEnough"
		elseif para.layerType == 2 then --破产 then --破产
			sIDKey = "Bankrupt"
		end
		FSRegistryManager:currentFSM():trigger("store", 
		{parentNode=display.getRunningScene(), zorder=4,store_openType=2, sceneIDKey = sIDKey})
			
	end --上面按钮响应
	para.downCloseOnClick = false --下边的按钮点击不自动关闭
    para.downCallback = function ()
		
		if para.layerType==2 then
			HallSceneProxy:requestBankruptAward()
		else
			self:fstartEnter()
		end
		self.clickItem = false
	end --下面按钮响应
	
	local bankrupt = BankruptLayer:create(para)
	bankrupt:bindCloseFun(function ()
		self.clickItem = false
	end)
	bankrupt:show(3)
	
end
--快速开始
function ChooseRoomLayer_widget_Content:fstartEnter()
	local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey('GameCash'))
	local allData = DataCenter:getData(ChooseRoomCfg.InnerEvents.CR_EVENT_HALLNETLIST)
	print("myCash",myCash)
	if not allData or not allData[self.crtype] or not next(allData[self.crtype].looptab1) then
		--
		print("房间数据还未获取到")
		return
	end
	local tempGameZone = allData[self.crtype].looptab1
	local tempGameZonePlayType = allData[self.crtype].looptab2

	UmengManager:eventCount("ClassicStart") 

	local gamezone = {}
	copyTable(tempGameZone,gamezone)
	table.sort(gamezone,function (ga,gb)
		return ga.FortuneMin > gb.FortuneMin
	end)
	local enterGamedata = nil
	local maxFor = 0
	for _,gamedata in pairs(gamezone) do
		maxFor = gamedata.FortuneMax
		
		if myCash >= gamedata.FortuneMin and (maxFor <= 0 and true or myCash<=maxFor) then
			enterGamedata = gamedata
			break
		end
	end

	local idx = 1
	for k,v in pairs(tempGameZone) do
		if enterGamedata and enterGamedata == v then
			idx = k
			break
		end
	end

	if enterGamedata then
		wwlog(self.logTag,"发送进入游戏大厅事件")
		self.tableView:setTouchEnabled(false)
		ChooseRoomProxy:requestEnterGame(enterGamedata.GameZoneID)
		FSRegistryManager:clearFSM()
		local gameType = Game_Type.ClassicalPromotion
		if tempGameZonePlayType[idx].PlayType == Play_Type.PromotionGame then
			gameType = Game_Type.ClassicalPromotion
		elseif tempGameZonePlayType[idx].PlayType == Play_Type.RandomGame then
			gameType = Game_Type.ClassicalRandomGame
		elseif tempGameZonePlayType[idx].PlayType == Play_Type.RcircleGame then
			gameType = Game_Type.ClassicalRcircleGame
		end
		WWFacade:dispatchCustomEvent(WHIPPEDEGG_SCENE_EVENTS.MAIN_ENTRY,gameType,enterGamedata.GameZoneID,enterGamedata.fortuneBase)
	else
		--破产了
		print("没钱了，连最低场都不能进")
	end
end
--获取能进入的最大的房间
--@param myCash 我的金币
function ChooseRoomLayer_widget_Content:getMaxEnterRoomData(myCash)
	local gamezone = {}
	copyTable(self.gameZone,gamezone)
	table.sort(gamezone,function (ga,gb)
			return ga.FortuneMin > gb.FortuneMin --倒序
	end)
	local enterGamedata = nil
	for _,gamedata in pairs(gamezone) do
		if gamedata.FortuneMax <=0 then
			enterGamedata = gamedata
			break
		end
		if myCash >= gamedata.FortuneMin and myCash <= gamedata.FortuneMax then
			enterGamedata = gamedata
			break
		end
	end

	local idx = 1
	for k,v in pairs(self.gameZone) do
		if enterGamedata and enterGamedata == v then
			idx = k
			break
		end
	end

	return enterGamedata,self.gamePlayType[idx]
end

--获取能进入的最小的房间
--@param myCash 我的金币
function ChooseRoomLayer_widget_Content:getMinEnterRoomData()
	local gamezone = {}
	copyTable(self.gameZone,gamezone)
	table.sort(gamezone,function (ga,gb)
		return ga.FortuneMin < gb.FortuneMin --顺序
	end)
	return gamezone[1]
end

function ChooseRoomLayer_widget_Content:eventComponent()
	return ChooseRoomCfg.innerEventComponent
end



return ChooseRoomLayer_widget_Content