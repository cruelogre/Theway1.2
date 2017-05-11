-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛内容控件
-- Modify:
--		2016.11.25 修改倒计时
--		2016.12.02 在数据刷新之前 如果是进入要打开报名或者组队界面 当前tablview的动画要关闭，防止动画错乱
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer_widget_Content = class("MatchLayer_widget_Content",function ()
	return ccui.Layout:create()
end)
local RoomItem = require("csb.hall.match.Node_match_rmitem")


local MatchCfg = require("hall.mediator.cfg.MatchCfg")
local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
local ChooseRoomProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_CHOORSERM)

local Toast = require("app.views.common.Toast")

local MatchLayer_Single = import(".MatchLayer_Single","hall.mediator.view.")
local MatchLayer_Multiple = import(".MatchLayer_Multiple","hall.mediator.view.")

local WWNetSprite = require("app.views.customwidget.WWNetSprite")

local _scheduler = cc.Director:getInstance():getScheduler()

function MatchLayer_widget_Content:ctor(crtype,size)
	self.size = size --显示尺寸
	self.crtype = crtype --什么类型的房间
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.timeCount = 0 --计时器
	self.roomCount = 0
	self.clickItem = false
	self.currentSec = 0 --当前的秒
	self.isTopLayer = true
	self.needFresh = false --是否需要重新请求
	self.hasDataOnce = false --是否已经有数据返回过
	self.requestToShow = false --是否要请求打开比赛详情界面
	self.retainOffset = true --是否需要记录当前位置偏移
	self.roomList = {}
	self.contentOffset = cc.p(0,0)
	
	self.canAnim = true --创建的时候是否允许动画
	self.scrollTime = 0 --滚动次数
	
	self:init()
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end
function MatchLayer_widget_Content:init()
	
	self.tableView = cc.TableView:create(self.size)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    --self.tableView:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.tableView:setDelegate()
    self:addChild(self.tableView,1)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_Content.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_Content.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_Content.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_Content.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_Content.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,MatchLayer_widget_Content.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	-- local mask = display.newSprite("hall/choose/chooserm_mask_left.png")
	-- mask:setBlendFunc(cc.blendFunc(gl.ONE , gl.ONE_MINUS_SRC_ALPHA))
	-- mask:setPosition(cc.p(0,self.size.height * 0.5))
	-- self:addChild(mask,2)
	
	-- local mask = display.newSprite("hall/choose/chooserm_mask_right.png")
	-- mask:setBlendFunc(cc.blendFunc(gl.ONE , gl.ONE_MINUS_SRC_ALPHA))
	-- mask:setPosition(cc.p(self.size.width,self.size.height/2))
	-- self:addChild(mask,2)
	self.tableView:setTouchEnabled(false)
	
end


function MatchLayer_widget_Content:onEnter()
	
	print("MatchLayer_widget_Content:onEnter")
	self.canAnim = (MatchCfg.enterMatchId==0)
	local x1,handle1 = self:eventComponent():addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_ROOMLIST,handler(self,self.reloadData))
	local x2,handle2 = self:eventComponent():addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL,handler(self,self.getDetail))
	self.handle1 = handle1
	self.handle2 = handle2
	self.timeCount = 0
	MatchProxy:enterMatchList(self.crtype)
	MatchProxy:requstMatchList(true)
	self.retainOffset = false
	self.requestMatchId = 0
	
	self.m_sche = _scheduler:scheduleScriptFunc(handler(self, self.timeClick), 1, false)
end


function MatchLayer_widget_Content:onExit()

	print("MatchLayer_widget_Content:onExit")
	--self.super.onExit(self)
	_scheduler:unscheduleScriptEntry(self.m_sche)
	
	if self:eventComponent() then
		self:eventComponent():removeEventListener(self.handle1)
		self:eventComponent():removeEventListener(self.handle2)
		print("MatchLayer_widget_Content remove listener")
	end
	removeAll(self.roomList)
	if isLuaNodeValid(self.tableView) then
		self.tableView:removeFromParent()
	end
end
function MatchLayer_widget_Content:getDetail(event)
	print("MatchLayer_widget_Content:getDetail")
	if not self.isTopLayer then
		return
	end
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local matchData = allMtchData[self.requestMatchId]
	if not matchData then
		return
	end
	--dump(matchData)
	print("MatchLayer_widget_Content  get  matchData",matchData.TeamWork)
	
	if not self.requestToShow then
		return
	end
	if tonumber(matchData.TeamWork)==1 and tonumber(matchData.MyEnterFlag)==1 then --团队战 并且我报了名
		self.isTopLayer = false
		local friendLayer = MatchLayer_Multiple:create(matchData)
		friendLayer:bindCloseCB(handler(self,self.frontClosed))
		cc.Director:getInstance():getRunningScene():addChild(friendLayer,5)
	else  --个人战
				
		self.isTopLayer = false
		local timeLayer = MatchLayer_Single:create(matchData)
		timeLayer:bindCloseCB(handler(self,self.frontClosed))
		cc.Director:getInstance():getRunningScene():addChild(timeLayer,5)
		--print("MatchLayer zorder",self:getLocalZOrder())
		--print("MatchLayer zorder",self:getParent():getLocalZOrder())
				
	end
end

function MatchLayer_widget_Content:reloadData(event)
	local troomList = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_ROOMLIST)
	
	if not troomList or not next(troomList) then
		return
	end
	--copyTable(troomList,self.roomList)
	self.roomList = clone(troomList)
	self.hasDataOnce = true
	--wwdump(self.roomList)
	
	--roomList.MatchList
	self.currentSec = os.time()
	self.needFresh = false
	if not event.resetTime then
		self.timeCount = 0
	end
	
	self.roomCount = #self.roomList.MatchList
	print("roomCount",self.roomCount)
	self.clickItem = false
	local x,y = self:cellSizeForTable()
	if self.roomCount*x < self.size.width then
		print("tableView.width",self.roomCount*x)
		print("self.size.width",self.size.width)
		self.tableView:setViewSize(cc.size(self.roomCount*x,self.size.height))
		self.tableView:setPositionX((self.size.width - self.roomCount*x )/2)
	end
	--self.tableView:getContentOffset()
	--在数据刷新之前 如果是进入要打开报名或者组队界面 当前tablview的动画要关闭，防止动画错乱
	if MatchCfg.enterMatchId~=0 then
		self.tableView:stopAllActions()
	end
	self.tableView:reloadData()
	--dump(self.contentOffset)
	local minOffset = self.tableView:minContainerOffset()
	local maxOffset = self.tableView:maxContainerOffset()
	self.contentOffset.x = math.min(self.contentOffset.x,maxOffset.x)
	self.contentOffset.x = math.max(self.contentOffset.x,minOffset.x)
	self.tableView:setContentOffset(self.contentOffset)
	
	--self:performEnter()
	
	performWithDelay(self,handler(self,self.performEnter),0.2)
end
--
function MatchLayer_widget_Content:performEnter()
	self.retainOffset = true
	if not self.tableView:isTouchEnabled() then
		self.tableView:setTouchEnabled(true)
	end
	--是否进入的时候就要打开某个比赛
	if MatchCfg.enterMatchId~=0 then
			--是否进来就触发了某个按钮
		local data = nil

		-- wwlog("MatchCfg.enterMatchId", MatchCfg.enterMatchId)
		for _,v in pairs(self.roomList.MatchList) do
			if v.MatchID==tonumber(MatchCfg.enterMatchId) then
				data = v
				break
			end
		end
		if data then
			--根据单人或者组队显示
			if self.clickItem and LoadingManager:isShowing() then
				return
			end
			self.requestToShow = true
			self.clickItem = true
			
			self.requestMatchId = data.MatchID
			MatchProxy:requestMatchDetail(data.MatchID)
			--self.tableView:stopAllActions()
		end
		
		MatchCfg.enterMatchId = 0
	end
end
function MatchLayer_widget_Content:timeClick()
	
	self.timeCount = self.timeCount +1
	--print("self.timeCount",self.timeCount)
	if self.timeCount >= MatchCfg.refreshInterval 
	
	and self.isTopLayer and self.hasDataOnce and not LoadingManager:isShowing() and math.abs(os.time() - self.currentSec)>1 then
		self.timeCount = 1
		self.roomCount = 0
		self.tableView:stopAllActions()
		--self.contentOffset = self.tableView:getContentOffset()
		MatchProxy:requstMatchList()
		self.retainOffset = false
		self.timeCount = math.min(self.timeCount,MatchCfg.refreshInterval)
	end
	
		
end


function MatchLayer_widget_Content:numberOfCellsInTableView(view)
	
	return math.ceil(self.roomCount)
end

function MatchLayer_widget_Content:scrollViewDidScroll(view)
	self.currentSec = os.time()
	if self.retainOffset then
		local oldOffset = self.tableView:getContentOffset()
		local diffX = oldOffset.x - self.contentOffset.x
		
		if math.abs(diffX)<MatchCfg.minPermitDiffX then
			self.contentOffset = self.tableView:getContentOffset()
			--dump(self.contentOffset)
		end
		
	end
	
	if self.canAnim then
		self.scrollTime = self.scrollTime +1
		if self.scrollTime > 1 then
			self.canAnim = false
			self.scrollTime = 0
		end
	end
	
end

function MatchLayer_widget_Content:scrollViewDidZoom(view)

end
function MatchLayer_widget_Content:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
	
end
function MatchLayer_widget_Content:cellSizeForTable(view,idx)
	if self:numberOfCellsInTableView(view) > 3 then
		return 500,612
	else
		return 482+98,612
	end
	
end

function MatchLayer_widget_Content:createItemIdx(view,idx)
	local ritem = RoomItem:create().root
				
	local img = ritem:getChildByName("Image_bg")
	img:setSwallowTouches(false)
	ccui.Helper:seekWidgetByName(img,"Image_tag"):setVisible(false)
	--重新设置渲染顺序
	ccui.Helper:seekWidgetByName(img,"Image_tag"):setLocalZOrder(2)
	ccui.Helper:seekWidgetByName(img,"Text_desc"):setLocalZOrder(3)
	ccui.Helper:seekWidgetByName(img,"Text_signup"):setLocalZOrder(4)
	
	local x,y = self:cellSizeForTable(view,idx)
	ritem:setPositionX(x/2)
	ritem:setPositionY(y/2)
	--img:setTouchEnabled(false)
	img:addTouchEventListener(handler(self,self.touchEventListener))
	img:setTag(idx) --方便点击的时候计算位置
	local text = ccui.Helper:seekWidgetByName(img,"Text_desc")
	
	local temp = iskindof(text,"ccui.RichText")
	if not temp then
		local richText = ccui.RichText:create()
		richText:ignoreContentAdaptWithSize(true)
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:addTo(text:getParent(),3)
		richText:setName("Text_desc")
		richText:setTag(idx)
		richText:setPosition(text:getPositionX(),text:getPositionY())
		text:removeFromParent()
	end
	local textsign = ccui.Helper:seekWidgetByName(img,"Text_signup")
	
	local temp2 = iskindof(textsign,"ccui.RichText")
	if not temp2 then
		local richText = ccui.RichText:create()
		richText:ignoreContentAdaptWithSize(true)
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:addTo(textsign:getParent(),4)
		richText:setName("Text_signup")
		richText:setPosition(textsign:getPositionX(),textsign:getPositionY())
		textsign:removeFromParent()
	end
    --richText:setContentSize(cc.size(100, 100))
	--richText:setContentSize(cc.size(100, 100))
	--print("img tag",img:getTag())
	--cell:addChild(ritem)
	--ritem:setName("ritem")
	if self.canAnim then
		ritem:setPositionX(display.width)
		ritem:runAction(cc.EaseSineOut:create(cc.MoveTo:create(0.1*(idx+1),cc.p(x/2,y/2))))
	end

	return ritem
end
function MatchLayer_widget_Content:tableCellAtIndex(view,idx)
	
    local cell = view:dequeueCell()
	local ritem = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
		ritem = self:createItemIdx(view,idx)		
		cell:addChild(ritem)
				
    else
        ritem = cell:getChildByName("Node")
		ritem:getChildByName("Image_bg"):setTag(idx)
    end
	local imgBg = ritem:getChildByName("Image_bg")
	local data = self.roomList.MatchList[idx+1]
	ccui.Helper:seekWidgetByName(imgBg,"Text_desc"):setTag(idx)
	self:updateSignDesc(ccui.Helper:seekWidgetByName(imgBg,"Text_desc"),data,idx)
	self:updateBG(imgBg,data)
	self:updateSignText(ccui.Helper:seekWidgetByName(imgBg,"Text_signup"),data)
	self:updateSignFlag(ccui.Helper:seekWidgetByName(imgBg,"Image_tag"),data)
    return cell
end
--更新背景 http://pic2.51ias.com/test_a/sys_avatar/00c876e3521e12a4b68a64a2c9ca8a4a.png
function MatchLayer_widget_Content:updateBG(imgTag,data)
	if not data then
		return
	end
	--MatchCfg:getMatchImageURL(1, data.MatchID)
	local sp = WWNetSprite:create("#match_rm_item_bg1.png",
	MatchCfg:getMatchImageURL(1, data.MatchID), false)
	local size = imgTag:getContentSize()
	imgTag:removeChildByName("bg")
	sp:setName("bg")
	sp:setPosition(cc.p(size.width/2,size.height/2))
	
	imgTag:addChild(sp,1)
--[[	if tonumber(data.BeginType)==1 then --定人赛
		imgTag:loadTexture("hall/match/match_rm_item_bg2.png")
	else  --定时赛
		imgTag:loadTexture("hall/match/match_rm_item_bg3.png")
	end--]]
	
end
--更新标签 火热 最新等
function MatchLayer_widget_Content:updateSignFlag(imgTag,data)
	
	if data.Flag and string.len(data.Flag)>0 then
		imgTag:setVisible(true)
		ccui.Helper:seekWidgetByName(imgTag,"Text_hot"):setString(tostring(data.Flag))
	else
		imgTag:setVisible(false)
	end
end

--更新描述 事件 人数信息
function MatchLayer_widget_Content:updateSignDesc(label,data,idx)
	--定人赛
	--self.tableView:stopAllActions()
	if not data then
		return
	end
	label:removeAllElements()
	
	if tonumber(data.BeginType)==1 then
		
		label:setContentSize(cc.size(300,30))
		local totoal = tonumber(data.Requirement)
		local currentCount = tonumber(data.EnterCount)
		local re1 = ccui.RichElementText:create(1, cc.c3b(0xff, 0xff, 0xff),0xff, "满", "FZZhengHeiS-B-GB.ttf", 30)
		local re2 = ccui.RichElementText:create(2, cc.c3b(0xff, 0xff, 0x00),0xff, string.format("%d/%d",currentCount,totoal), "FZZhengHeiS-B-GB.ttf", 30)
		local re3 = ccui.RichElementText:create(3, cc.c3b(0xff, 0xff, 0xff),0xff, "人开赛", "FZZhengHeiS-B-GB.ttf", 30)
		label:pushBackElement(re1)
		label:pushBackElement(re2)
		label:pushBackElement(re3)
		
	else
	--定时赛
		tostring(data.Requirement)
		--2016-09-13 21:40:53
		local times = string.split(tostring(data.Requirement)," ")
		local matchTime = {year = 1998, month = 9, day = 16,hour = 23, min = 48, sec = 10}
		if #times==2 then
			local temp1 = string.split(times[1],"-")
			local temp2 = string.split(times[2],":")
			if #temp1==3 then --年月日
				matchTime.year = tonumber(temp1[1],10)
				matchTime.month = tonumber(temp1[2],10)
				matchTime.day = tonumber(temp1[3],10)
			end
			if #temp2==3 then --时分秒
				matchTime.hour = tonumber(temp2[1],10)
				matchTime.min = tonumber(temp2[2],10)
				matchTime.sec = tonumber(temp2[3],10)
			end
		end
		--今天过去的时间
		local todaySec = matchTime.hour*60*60+matchTime.min*60+matchTime.sec
		--data.Countdown --定时赛 倒计时
		local iCountdown = tonumber(data.Countdown)
		if iCountdown<0 then
			return
		end
		todaySec = iCountdown - todaySec
		
		iCountdown = iCountdown - self.timeCount
		local showString = nil
		self.tableView:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function ()
				if label:getTag() == idx then
					--wwlog("haha","idx:%d data.Countdown %d",idx,data.Countdown)
					self:updateSignDesc(label,data,idx)
				end
				
			end)))
			
		if iCountdown < 0 then --已经开赛 刷新
			self:stopAllActions()
			self.tableView:stopAllActions()
			if self.isTopLayer then
				self.roomCount = 1
				self.contentOffset = self.tableView:getContentOffset()
				MatchProxy:requstMatchList()
				self.retainOffset = false
			end
			self.needFresh = true
			return --返回
		elseif iCountdown < 60*60 then --一小时以内
			local minus =  math.floor(iCountdown/60)
			local secound = iCountdown%60
			showString = string.format("剩余 %s:%s",
			minus<10 and string.format("0%d",minus) or tostring(minus),
			secound<10 and string.format("0%d",secound) or tostring(secound))
			
		elseif iCountdown < 24*60*60 and iCountdown + todaySec < 24*60*60 then --今日
			showString = string.format("今日 %s:%s",
			matchTime.hour >9 and tostring(matchTime.hour) or string.format("0%d",matchTime.hour),
			matchTime.min >9 and tostring(matchTime.min) or string.format("0%d",matchTime.min))
		elseif iCountdown < 2*24*60*60 and iCountdown + todaySec > 24*60*60 then --明日
			showString = string.format("明日 %s:%s",
			matchTime.hour >9 and tostring(matchTime.hour) or string.format("0%d",matchTime.hour),
			matchTime.min >9 and tostring(matchTime.min) or string.format("0%d",matchTime.min))
		else --明日之后
			showString = string.format("%d日 %s:%s",matchTime.day,
			matchTime.hour >9 and tostring(matchTime.hour) or string.format("0%d",matchTime.hour),
			matchTime.min >9 and tostring(matchTime.min) or string.format("0%d",matchTime.min))
		end
		data.matchTime = matchTime
		--print("showString",data.iCountdown,showString)
		--dump(currentTime)
		
		local re1 = ccui.RichElementText:create(1, cc.c3b(0xff, 0xff, 0xff),0xff, showString, "FZZhengHeiS-B-GB.ttf", 30)
		
		label:pushBackElement(re1)
		local re2 = ccui.RichElementText:create(2, cc.c3b(0xff, 0xff, 0xff),0xff, "  "..i18n:get('str_match','match_has_signed')..":", "FZZhengHeiS-B-GB.ttf", 30)
		local re3 = ccui.RichElementText:create(3, cc.c3b(0xff, 0xff, 0x00),0xff, string.format("%d",data.EnterCount), "FZZhengHeiS-B-GB.ttf", 30)
		
		label:pushBackElement(re2)
		label:pushBackElement(re3)
		--dump(matchTime)
	end
	
end

--更新是否报名
function MatchLayer_widget_Content:updateSignText(label,data)
	if not data then
		return
	end
	label:removeAllElements()
	if tonumber(data.MyEnterFlag)==1 then --报名了
		local re1 = ccui.RichElementText:create(1, cc.c3b(0xff, 0xf1, 0x0a),0xff, i18n:get('str_match','match_has_signed'), "FZZhengHeiS-B-GB.ttf", 48)
		label:pushBackElement(re1)
	else -- 还没报名
		if data.EnterType==0 then
			--免费报名
			local re1 = ccui.RichElementText:create(1, cc.c3b(0xff, 0xff, 0xff),0xff, i18n:get('str_match','match_free_sign'), "FZZhengHeiS-B-GB.ttf", 48)
			label:pushBackElement(re1)
		else 
			--EnterData
			local endEnterData
			local splArrs
			local numberStr
			if data.EnterType and (data.EnterType == 3) then --如果是比赛门票
				splArrs = Split(data.EnterData, "/")
				endEnterData = splArrs[3]
				numberStr = string.format("x%s",ToolCom.splitNumFix(tonumber(endEnterData)))
			else
				endEnterData = data.EnterData
				numberStr = string.format("%s",ToolCom.splitNumFix(tonumber(endEnterData)))
			end
			local re0 = ccui.RichElementText:create(0, cc.c3b(0xff, 0xff, 0xff),0xff, i18n:get('str_match','match_sign_fee_s').."  ", "FZZhengHeiS-B-GB.ttf", 40)			
			label:pushBackElement(re0)
			
			
			local re1 = ccui.RichElementText:create(1, cc.c3b(0xff, 0xff, 0xff),0xff,numberStr, "FZZhengHeiS-B-GB.ttf", 40)
			
			label:pushBackElement(re1)
			
			local x = label:getContentSize().width
			local y = label:getContentSize().height
			local ed = MatchCfg.enterTypes[data.EnterType]

			if ed and cc.FileUtils:getInstance():isFileExist(ed.spfile) then
				local sp = display.newSprite(ed.spfile)
				sp:setAnchorPoint(cc.p(0.5,1))
				local re2 = ccui.RichElementCustomNode:create(2,cc.c3b(0xff,0xff,0xff),0xff,sp)

				
				if data.EnterType and (data.EnterType == 3) then --如果是比赛门票
					label:insertElement(re2,label:getElementCount()-1)
					--label:pushBackElement(re2)
				else
					label:pushBackElement(re2)
				end
				
			
			end
			
		end
	end
end

function MatchLayer_widget_Content:touchEventListener(ref,eventType)
	self.contentOffset = self.tableView:getContentOffset()
	
	if not ref or self.tableView:isTouchMoved() then
		return
	end
	if not self.roomList or not self.roomList.MatchList then
		return
	end
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local idx = ref:getTag() 
		print(idx)
		local data = self.roomList.MatchList[idx+1]
		if data then
			--根据单人或者组队显示
			if self.clickItem and LoadingManager:isShowing() then
				return
			end
			self.clickItem = true
			self.requestToShow = true
			self.requestMatchId = data.MatchID
			MatchProxy:requestMatchDetail(data.MatchID)
--[[			if tonumber(data.Multiple)==1 then
				self.isTopLayer = false
				local friendLayer = MatchLayer_Multiple:create(data.MatchID)
				friendLayer:bindCloseCB(handler(self,self.frontClosed))
				self:getParent():addChild(friendLayer,2)
			else
				
				self.isTopLayer = false
				local timeLayer = MatchLayer_Single:create(data)
				timeLayer:bindCloseCB(handler(self,self.frontClosed))
				self:getParent():addChild(timeLayer,2)
				
			end--]]
			
			--统计 比赛房间选择  参数2 为比赛名称
			UmengManager:eventCount2("MatchChoose", data.MatchName)
		end
		
	end
end
--顶层关闭的回调
function MatchLayer_widget_Content:frontClosed(force)
	print("MatchLayer_widget_Content frontClosed",self.needFresh)
	self.isTopLayer = true
	self.clickItem = false
	self.requestToShow = false
	if self.needFresh or force then
		self.roomCount = 0
		MatchProxy:requstMatchList()
		self.retainOffset = false
		self.tableView:stopAllActions()
		--self.contentOffset = self.tableView:getContentOffset()
	else
		--self:reloadData({resetTime = 1})
	end
	
	--self.roomCount = 0
	--MatchProxy:requstMatchList()
end
function MatchLayer_widget_Content:eventComponent()
	return MatchCfg.innerEventComponent
end



return MatchLayer_widget_Content