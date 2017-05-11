-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  sonic
-- Date:    2016.08.15
-- Last: 
-- Content:  签到模块
-- Modify :  2016-11-2 diyal.yin 修改签到补签的Bug 19314
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local signLayer = class("signLayer", require("app.views.uibase.PopWindowBase"))

local SignInProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SIGNIN)
local SignCfg = require("hall.mediator.cfg.SignCfg")

local SignNode = require("csb.hall.sign.SignNode")
local SignAwardNode = require("csb.hall.sign.signAwardNode")

local GoldDropDownAnim = require("app.utilities.GoldDropDownAnim")
local CommonDialog = require("app.views.customwidget.CommonDialog")

local Toast = require("app.views.common.Toast")

--[[local maxCountEveryRow = 7 --一行最大的数量
--月份中文
local monthTextArr = {"一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"}

local SignState = {
	SIGN_LAST_MONTH = 1, --上个月的
	SIGN_CHECKED = 2, --已签
	SIGN_MISS_CHECKED = 3, --漏签
	SIGN_UNCHECKED = 4, --未签 (将来的)
	SIGN_CURRENT = 5, --当前
}--]]

function signLayer:ctor()
	self.super.ctor(self)
	self:initData()
	self:init()
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
end

function signLayer:onEnter()
	-- body
	self.super.onEnter(self)
	self:registerListener()
	
	SignInProxy:requestSignInCalendar(true)
	
end
function signLayer:onExit()
	self.super.onExit(self)
	self.tableView = nil
	
end
function signLayer:initData()
	self.curDate = "" -- 当前时间 (YYY/MM/dd)
	self.cardCount = 0 --补签卡数量
	self.dayCount = 0 --当月天数
	self.dayIndex = 0 --当月第几天
	self.clickItem = true --是否可以点击签到按钮 防止连续点击
	
	self.firstDayInWeek = 0 --当月第一天是一周的第几天
	self.lastMonthDayCount = 31 --上个月最大天数
	
	self.keepSignCount = 1 --连续签到的最大记录
	
	self.curSelected = {x = 0,y = 0}  --当前选中的item
	self.signData = {}
	self.awardSign = {}
	local curWeekIndex = tonumber(os.date("%w"))
	local curdayIndex = tonumber(os.date("%d"))
	
	self.firstDayInWeek = curWeekIndex+curdayIndex%SignCfg.maxCountEveryRow - SignCfg.maxCountEveryRow
	print("self.firstDayInWeek",self.firstDayInWeek)
end

function signLayer:init()
	--WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "sign", false)
	local signLayerLayerBundle = require("csb.hall.sign.SignLayer"):create()
	if not signLayerLayerBundle then
		return
	end
	
	local root = signLayerLayerBundle["root"]
  	
	root:addTo(self)
	--FixUIUtils.stretchUI(root)
	FixUIUtils.setRootNodewithFIXED(root)
	

	
	self.imgId = root:getChildByName("Image_di")
	FixUIUtils.stretchUI(self.imgId)
	self.listView = ccui.Helper:seekWidgetByName(self.imgId,"ScrollView_1")
	
	
	--self.signNode:setVisible(false)
	--self:initListView()
	self:initTableView()
	self:popIn(self.imgId,Pop_Dir.Right)
	
	self.imgGift = ccui.Helper:seekWidgetByName(self.imgId,"Image_gift")
	
--[[	ccui.Helper:seekWidgetByName(self.imgId,"Button_7"):addClickEventListener(handler(self,self.btnClick))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_14"):addClickEventListener(handler(self,self.btnClick))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_21"):addClickEventListener(handler(self,self.btnClick))
	ccui.Helper:seekWidgetByName(self.imgId,"Button_off"):addClickEventListener(handler(self,self.btnClick))--]]
	
	self.textMonth = ccui.Helper:seekWidgetByName(self.imgId,"Text_month")
	self.textCardCount = ccui.Helper:seekWidgetByName(self.imgId,"Text_cardCount")
	self.btnSign = ccui.Helper:seekWidgetByName(self.imgId,"Button_sign")
	self.btnSign:addClickEventListener(handler(self,self.btnClick))
	
	self:setDisCallback(function ( ... )
		-- body
		self:unRegisterListener()
		FSRegistryManager:runWithFSM(FSMConfig.FSM_HALL):trigger("back")
	end)
end
function signLayer:registerListener()

	--HallSceneMediator:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshTitlePanel))
	local _,handle1 = SignCfg.innerEventComponent:addEventListener(SignCfg.InnerEvents.SIGN_EVENT_CALENDAR,handler(self,self.freshSignCalendar))
	local _,handle2 = SignCfg.innerEventComponent:addEventListener(SignCfg.InnerEvents.SIGN_EVENT_ISSUENOTIFY,handler(self,self.signIssueNotify))
	self.handle1 = handle1
	self.handle2 = handle2
end
function signLayer:signIssueNotify(event)
	if not event.msgTag then
		return
	end
	print("response ",event.msgTag)
	if self:isAllSign() then
		self.btnSign:setBright(false)
		self.btnSign:setTitleText(i18n:get('str_sign','sign_all_over'))
	end
	--这儿不直接请求刷新，要等待动画播放完成之后才刷新  刷新后动画会stop
	--SignInProxy:requestSignInCalendar()
	if event.msgTag==SignCfg.RequestType.SIGN_REQUEST_TODAY  then
		local x,y = self:getPositonByIdx(self.dayIndex)
		print("doday",x,y)
		self.curSelected.x = x
		self.curSelected.y = y
		if event.award and next(event.award) then
			for i,award in ipairs(event.award) do
				
				performWithDelay(self,function ()
					Toast:makeToast(string.format(i18n:get("str_sign","sign_today_ok"),award.name,award.count),1.0):show()
				end,1.0*(i-1))
				
			end
		end
		
		self:changeCurrentSelect(SignCfg.SignState.SIGN_CHECKED)
		self.signData[self.dayIndex].Status = 1
		self:refreshTitlePanel()
		GoldDropDownAnim:create():play(150)
		--记录签到日期
		local curTime = os.date("*t")
		curTime.min = 0
		curTime.sec = 0
		curTime.hour = 0
		local tt = os.time(curTime)
		ww.WWGameData:getInstance():setIntegerForKey(COMMON_TAG.C_RECENTSIGN_DAY,tt)
		--WWFacade:dispatchCustomEvent(COMMON_EVENTS.C_REFLASH_PERSONINFO, 2, "sign", false)
	elseif event.msgTag==SignCfg.RequestType.SIGN_REQUEST_COMPENSATE then		
		local x,y = self:getPositonByIdx(self:recentSignIndex())
		self.signData[self:recentSignIndex()].Status = 1
		self.cardCount = self.cardCount - 1
		self.cardCount  = math.max(self.cardCount ,0)
		DataCenter:getUserdataInstance():setUserInfoByKey("card",self.cardCount)
		
		self.curSelected.x = x
		self.curSelected.y = y
		if event.award and next(event.award) then
			for i,award in ipairs(event.award) do
				performWithDelay(self,function ()
					Toast:makeToast(string.format(i18n:get("str_sign","sign_comsume_card"),award.name,award.count),1.0):show()
				end,1.0*(i-1))
				
			end
			
		end
		
		self:changeCurrentSelect(SignCfg.SignState.SIGN_CHECKED)
		
		
		self:refreshTitlePanel()
		GoldDropDownAnim:create():play(150)
	elseif event.msgTag==SignCfg.RequestType.SIGN_REQUEST_ROW_AWARD then
		--event.msgNo
		for i,v in ipairs(self.awardSign) do
			if v.dayIndex ==event.msgNo and self.imgGift:getChildByTag(i) then
				local imgNode = self.imgGift:getChildByTag(i)
				local btnAward = imgNode:getChildByName("Button_award")
				btnAward:removeAllChildren()
				btnAward:setTouchEnabled(false)
				self.awardSign[i].AwardStatus = 2
				Toast:makeToast(string.format(i18n:get("str_sign","sign_award_ok"),event.msgNo,v.AwardDesc),1.5):show()
				
				--播放动画
				--暂时就直接设置
				self:refreshAwardPanel(i)
				
				break
			end
		end
		GoldDropDownAnim:create():play(150)
		self.clickItem = true
	end
	--self:jumpToCurPosition()
end

--刷新签到日历
function signLayer:freshSignCalendar(event)
	local calendar = DataCenter:getData(SignCfg.InnerEvents.SIGN_EVENT_CALENDAR)
	if not calendar or not next(calendar) then
		print("signLayer no sign data returned")
		return 
	end
	print("signLayer freshSignCalendar")
	--重新组织内容，刷新table显示
	self.curDate = calendar.CurDate -- 当前时间 (YYY/MM/dd)
	self.cardCount = calendar.CardCount --补签卡数量
	DataCenter:getUserdataInstance():setUserInfoByKey("card",self.cardCount)
	self.clickItem = true
	--self.dayCount = math.min(calendar.DayCount,31) --当月天数
	
	--self.dayIndex = calendar.DayIndex --当月第几天
--	dump(calendar)
	table.sort(calendar.signArr,function (a,b)
			return a.DayIndex<b.DayIndex
	end)
	
	self.signData = calendar.signArr
	self.dayCount = #self.signData
	print("self.dayCount",self.dayCount)
	print("self.curDate",self.curDate)
	table.sort(calendar.awardArr,function (a,b)
		if a.DayNo<=0 then
			return false
		elseif b.DayNo<=0 then
			return true
		else
			return a.DayNo<b.DayNo
		end
		
	end)
	
	self.awardData = calendar.awardArr

	--self:caculateSignCount()
	
	
		--刷新标题栏
	self:refreshTitlePanel()
	
--[[	local curWeekIndex = tonumber(os.date("%w"))
	local curdayIndex = tonumber(os.date("%d"))
	
	print("curWeekIndex",curWeekIndex)
	print("curdayIndex",curdayIndex)
	self.firstDayInWeek = curdayIndex%SignCfg.maxCountEveryRow - curWeekIndex
	
	if self.firstDayInWeek<0 then
		self.firstDayInWeek = self.firstDayInWeek+SignCfg.maxCountEveryRow
	end--]]
	local tempArr = string.split(self.curDate,"/")
	self.firstDayInWeek = SignCfg.getFirstDayInWeek(tonumber(tempArr[1]),tonumber(tempArr[2]),1)
	
	print("firstDayInWeek",self.firstDayInWeek)
	--self.dayIndex = 23

	--test
	removeAll(self.awardSign)
	local imgdiff = 0
	for _,v in ipairs(calendar.awardArr) do
		imgdiff = imgdiff +7
		local imgBg0 = string.format("%dday.png",7)
		if imgdiff<=21 then
			imgBg0 = string.format("%dday.png",imgdiff)
		else
			imgBg0 = "off2.png"
		end
		print(imgBg0)
		local tempTable = { dayIndex = v.DayNo, imgBg = imgBg0,award = {{1,10},{2,10}} }
		for ii,vv in pairs(v) do
			if not tempTable[ii] then
				tempTable[ii] = vv
			end
		end
		table.insert(self.awardSign,tempTable)
	end
	--self.awardSign[1] = { dayIndex = 7, imgBg = "7day.png",award = {{1,10},{2,10}} }
	--self.awardSign[2] = { dayIndex = 14, imgBg = "14day.png",award = {{1,10},{2,10}} }
	--self.awardSign[3] = { dayIndex = 21, imgBg = "21day.png",award = {{1,10},{2,10}} }
	--self.awardSign[4] = { dayIndex = -1, imgBg = "off2.png",award = {{1,10},{2,10}} }
	--刷新连续签到
	self:refreshAwardPanel()
	
	
	--刷新table显示
	self.tableView:reloadData()
	
	self:jumpToCurPosition()
	if self:isTodaySign() then
		--记录签到日期
		local curTime = os.date("*t")
		curTime.min = 0
		curTime.sec = 0
		curTime.hour = 0
		local tt = os.time(curTime)
		ww.WWGameData:getInstance():setIntegerForKey(COMMON_TAG.C_RECENTSIGN_DAY,tt)
	end
	
	
	if self:isAllSign() then
		self.btnSign:setBright(false)
		self.btnSign:setTitleText(i18n:get('str_sign','sign_all_over'))
	end
	
	
	
	print(self:numberOfCellsInTableView(self.tableView))
end
--跳转到最近一天未签到的位置
function signLayer:jumpToCurPosition()
	--滚动到当前的天数
	local recentSign = self:recentSignIndex0()
	local x,y =  self:getPositonByIdx(recentSign)
	local totalY = self:numberOfCellsInTableView()

	local orginOffset = self.tableView:getContentOffset()
	local newOffsetY = orginOffset.y*((totalY-y)/totalY)
	
	self.tableView:setContentOffset(cc.p(0,newOffsetY))
	--self.tableView:setContentOffset(cc.p(0,-100))
	
	print(recentSign,x,y,totalY,newOffsetY)
end
--计算连续签到天数
function signLayer:caculateSignCount()
	
	for i=1,self.dayCount do
		if self.signData[i].Status==1 then
			self.keepSignCount = i
		else
			break
		end
	end
	
end
--返回最近的未签到日期 不覆盖
function signLayer:recentSignIndex0()
	local recentIndex = self.dayIndex
	for i=self.dayIndex,1,-1 do
		if self.signData[i].Status==2 then
			recentIndex = i
			break
			
		end
	end
	return recentIndex
end

--返回最近的未签到日期
function signLayer:recentSignIndex()
	local recentIndex = self.dayIndex
	for i=self.dayIndex,1,-1 do
		recentIndex = i
		if self.signData[i].Status==2 then
			break
			
		end
	end
	return recentIndex
end
--判断这个月今天和之前的是否全部都签到了
function signLayer:isAllSign()
	local allSign = true
	local recentIndex = self.dayIndex
	for i=self.dayIndex,1,-1 do
		recentIndex = i
		if self.signData[i].Status==2 then
			allSign = false
			break
			
		end
	end
	return allSign
end
function signLayer:isTodaySign()
	if self.signData[self.dayIndex] then
		return self.signData[self.dayIndex].Status == 1
	else 
		return false
	end
	
end
function signLayer:unRegisterListener()
	SignCfg.innerEventComponent:removeEventListener(self.handle1)
	SignCfg.innerEventComponent:removeEventListener(self.handle2)
	--HallSceneMediator:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
end


function signLayer:btnClick(ref)
	
	if ref:getName() == "Button_sign" then
		if self:isAllSign() then
			print("this month all sign")
			return
		end
		if not self.clickItem then
			print("can not click yet")
			return
		end
		self.clickItem  = false
		playSoundEffect("sound/effect/anniu")
		--播放动画-->改变状态
		if self:isTodaySign() then --今日已经签到
		print("recentIndex",self:recentSignIndex())
			if self:recentSignIndex() ~= self.dayIndex then
				--判断是否还有补签卡
				if self.cardCount>0 then
					UmengManager:eventCount("ReSigninAct")

					SignInProxy:requestSignType(SignCfg.RequestType.SIGN_REQUEST_COMPENSATE,self:recentSignIndex())
				else
					--提示补签卡不足
					print("card count not enough")
					local para = {}
					para.rightBtnlabel = i18n:get('str_common','comm_sure')
					para.leftBtnlabel = i18n:get('str_common','comm_cancel')
					para.rightBtnCallback = function ()
						--打开商店
						
						FSRegistryManager:currentFSM():trigger("store", 
							{parentNode=display.getRunningScene(), zorder=4, store_openType=4})
						self.clickItem  = true
					end
					para.leftBtnCallback = function ()
						self.clickItem  = true
					end
					--para.rightBtnCallback = handler(self, self.taskHandler)
					para.content = i18n:get('str_sign','sign_card_not_enough')
					CommonDialog:create(para):show()
				end
			else
				--没有可补签的拉，都签了
				
			end
		else
			print("request today sign")
			UmengManager:eventCount("SigninAct")

			SignInProxy:requestSignType(SignCfg.RequestType.SIGN_REQUEST_TODAY)
		end
		
		--SignInProxy:requestSignType(SignCfg.RequestType.SIGN_REQUEST_TODAY)
		
	elseif ref:getName() == "Button_award" then
		if not self.clickItem then
			print("can not click yet")
			return
		end
		self.clickItem  = false
		
		playSoundEffect("sound/effect/anniu")
		if ref:getTag()>0 and ref:getTag()<=#self.awardSign then
			--ref:removeAllChildren()
			--ref:getTag()
			--ref:setBright(false)
			--防止重复点击？？
			if self.awardSign[ref:getTag()].AwardStatus==1 then
				SignInProxy:requestSignType(SignCfg.RequestType.SIGN_REQUEST_ROW_AWARD,self.awardSign[ref:getTag()].dayIndex)
			elseif self.awardSign[ref:getTag()].AwardStatus==0 then --还不能领取
				--self.awardSign[ref:getTag()].dayIndex
				self.clickItem  = true
				Toast:makeToast(string.format(i18n:get('str_sign','sign_award_failed'),self.awardSign[ref:getTag()].dayIndex),1.5):show()
				
				--已经领取过或者不满足领取条件
				print("can not get award")
				--dump(self.awardSign[ref:getTag()])
				
				--SignInProxy:requestSignType(SignCfg.RequestType.SIGN_REQUEST_ROW_AWARD,self.awardSign[ref:getTag()].dayIndex)
			end
			
		else
			wwlog("error Button_award tag:%s",ref:getTag())
			self.clickItem  = true
		end
		
	end
end

--@param animIndex 播放动画的索引
function signLayer:refreshAwardPanel(animIndex)
	for _,v in pairs(self.imgGift:getChildren()) do
		if v:getName()~="Text_desc" then
			v:removeFromParent()
		end
	end
	for index,awardSign in pairs(self.awardSign) do
		local signAwardBundle = SignAwardNode:create()
		local signaward = signAwardBundle.root
		local imgDay = signaward:getChildByName("Image_day")
		signaward:setTag(index)
		if awardSign.dayIndex >= self.dayCount then
			signaward:getChildByName("Text_day"):setString(i18n:get('str_sign','sign_full'))
		else
			signaward:getChildByName("Text_day"):setString(string.format(i18n:get('str_sign','sign_day'),tonumber(awardSign.dayIndex)))
		end
		
		--print(string.format("%s.png",awardSign.dayIndex>0 and tostring(awardSign.dayIndex) or "off"))
		imgDay:loadTexture(string.format("sign_icon_tag%s.png",(index-1)%4+1),1)
		local awardBtn = signaward:getChildByName("Button_award")
		awardBtn:setTag(index)
		awardBtn:loadTextureNormal(awardSign.imgBg,1)
		awardBtn:setScale(1)
		if awardSign.AwardStatus==2 then --已经领取完毕
			awardBtn:setTouchEnabled(false)
		end
		awardBtn:addClickEventListener(handler(self,self.btnClick))
		signaward:setPosition(cc.p((index-1)*awardBtn:getContentSize().width*0.88+145,204))
		self.imgGift:addChild(signaward,#self.awardSign-index)
		
		awardBtn:getChildByName("Text_number"):setString(awardSign.AwardDesc or "")
		--是否满足可以领取条件
		--test
		--if self.keepSignCount>=self.dayCount or ( awardSign.dayIndex>0 and self.keepSignCount>=awardSign.dayIndex ) then
		if awardSign.AwardStatus == 1 then
			local isFull = awardSign.dayIndex>0 and awardSign.dayIndex < self.dayCount
			local frameAnimSp = cc.Sprite:createWithSpriteFrameName(isFull and "sign_btn_frameAnim.png" or "sign_btn_frameAnim2.png")
			frameAnimSp:setPosition(cc.p(awardBtn:getContentSize().width/2,awardBtn:getContentSize().height/2-4))
			local act1 = cc.FadeTo:create(35/SignCfg.frameRate,0)
			local act2 = cc.FadeTo:create(35/SignCfg.frameRate,255)
			frameAnimSp:runAction(cc.RepeatForever:create(cc.Sequence:create(act1,act2)))
			awardBtn:addChild(frameAnimSp)
		elseif awardSign.AwardStatus == 2 then
			--Image_gift
			if animIndex==index then
				signaward:runAction(signAwardBundle.animation)
				signAwardBundle.animation:play("animation0",false)
				signAwardBundle.animation:setFrameEventCallFunc(function (frame)
					local eventFrame = tolua.cast(frame,"ccs.EventFrame")
					if eventFrame then
						print("frameName",eventFrame:getEvent())
						if eventFrame:getEvent()=="showEvent" then
							local giftImg = signaward:getChildByName("Image_gift")
							giftImg:ignoreContentAdaptWithSize(true)
							giftImg:loadTexture("sign_get_check.png",1)
							signAwardBundle.animation:play("animation1",false)
						end
					end

				end)
			else
				local giftImg = signaward:getChildByName("Image_gift")
				giftImg:setScale(1)
				giftImg:ignoreContentAdaptWithSize(true)
				giftImg:loadTexture("sign_get_check.png",1)
			end

		else
			local giftImg = signaward:getChildByName("Image_gift")
			print("Image_gift",giftImg:getScale(),signaward:getScale())
			giftImg:setScale(1)
			giftImg:ignoreContentAdaptWithSize(true)
			giftImg:loadTexture("digt2.png",1)
		end
		--
	end
	
end

--刷新顶部区域
function signLayer:refreshTitlePanel()
	--刷新月份
	local tempArr = string.split(self.curDate,"/")
	if tempArr and type(tempArr)=="table" and #tempArr>=3 then
		local index = tonumber(tempArr[2],10)
		index = math.min(index,#SignCfg.monthTextArr)
		index = math.max(0,index)
		print("index",index)
		
		self.textMonth:setString(SignCfg.monthTextArr[index])
		
		self.dayIndex = tonumber(tempArr[3],10)
		
		--fix server data error 
		self.dayIndex = math.min(self.dayIndex,self.dayCount)
	end
	--刷新补签卡数量
	--str_sign sign_card_number
	
	self.textCardCount:setString(string.format(i18n:get('str_sign','sign_card_number'),self.cardCount))
	
	--self.btnSign:setTitleText("")
	if self:isTodaySign() and self:recentSignIndex()~=self.dayIndex then
		self.btnSign:setTitleText(i18n:get('str_sign','sign_before'))
		
	else
		--
		self.btnSign:setTitleText(i18n:get('str_sign','sign_today'))
	end
end

function signLayer:refreshTopInfo()

	--刷新补签卡数量
	
	SignInProxy:requestSignInCalendar()
end
function signLayer:initTableView()
	
	
	local signPanel = ccui.Helper:seekWidgetByName(self.imgId,"Image_sign")
	local listView = ccui.Helper:seekWidgetByName(self.imgId,"ScrollView_1")
	
	self.tableView = cc.TableView:create(listView:getContentSize())
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(cc.p(listView:getPositionX(),listView:getPositionY()))
    self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    signPanel:addChild(self.tableView)
    self.tableView:registerScriptHandler(handler(self,signLayer.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self,signLayer.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self,signLayer.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self,signLayer.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self,signLayer.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:registerScriptHandler(handler(self,signLayer.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	listView:removeFromParent()
end

function signLayer:scrollViewDidScroll(view)
	--dump(view:getContentOffset())
end

function signLayer:scrollViewDidZoom(view)

end
function signLayer:tableCellTouched(view,cell)
	--print("tableCellTouched...",cell:getIdx())
end
function signLayer:cellSizeForTable(view,idx)
	return 140,117
end
function signLayer:createSinNode(view,cell,idx,i)
	local signNode = SignNode:create().root
	--signNode:setAnchorPoint(0.5,0.5)
	local img = signNode:getChildByName("Image_bg")
	img:setSwallowTouches(false)
	signNode:setPositionX((i+0.5)*self:cellSizeForTable(view,cell))
	signNode:setPositionY(img:getContentSize().height/2)
	--img:setTouchEnabled(false)
	img:addTouchEventListener(handler(self,signLayer.touchEventListener))
	img:setTag((idx)*10000+i) --方便点击的时候计算位置
	--cell:addChild(signNode)
	signNode:setTag(i)
	return signNode
end

function signLayer:tableCellAtIndex(view,idx)
	local strValue = string.format("%d",idx)
    local cell = view:dequeueCell()
	local signNode = nil
    if nil == cell then
        cell = cc.TableViewCell:new()
		for i=0,SignCfg.maxCountEveryRow-1 do
			local m2 = self.firstDayInWeek + self.dayCount
			local m1 = (idx)*SignCfg.maxCountEveryRow+i+1
			if m1<=m2 then
				signNode = self:createSinNode(view,cell,idx,i)
				
				cell:addChild(signNode)
			end		
		end
    else
		for i=0,SignCfg.maxCountEveryRow-1 do
			local m2 = self.firstDayInWeek + self.dayCount
			local m1 = (idx)*SignCfg.maxCountEveryRow+i+1
			if m1>m2 then
				cell:removeChildByTag(i)
			else
				if not cell:getChildByTag(i) then
					signNode = self:createSinNode(view,cell,idx,i)
					cell:addChild(signNode)
				end
			end
			if cell:getChildByTag(i) then
				cell:getChildByTag(i):getChildByName("Image_bg"):setTag((idx)*10000+i)
			end
		end
        --signNode = cell:getChildByTag(1)
    end
	for i=0,SignCfg.maxCountEveryRow-1 do
		signNode = cell:getChildByTag(i)
		self:restoreView(signNode)
		if isLuaNodeValid(signNode) then
			
			if idx==0 and i<self.firstDayInWeek then  --上个月的

				self:changeSignState(self:constructHolder(signNode),SignCfg.SignState.SIGN_LAST_MONTH,self.lastMonthDayCount - (self.firstDayInWeek - i - 1))
			else	--本月的
				--今天在日历中的位置
				local curIndex = self.dayIndex + self.firstDayInWeek
				--当前显示的位置
				local showIndex = idx*SignCfg.maxCountEveryRow+i+1
				
				if showIndex==curIndex then --今天
					self:changeSignState(self:constructHolder(signNode),SignCfg.SignState.SIGN_CURRENT,showIndex-self.firstDayInWeek)
				elseif showIndex<curIndex then --昨天
				--首先要知道之前的签到里边 哪些是已经签到 哪些是漏掉的签到
					local signStatus = self.signData[showIndex-self.firstDayInWeek].Status
					
					
					self:changeSignState(self:constructHolder(signNode),self:getStatus(signStatus),showIndex-self.firstDayInWeek)
				elseif showIndex>curIndex then   --未来
					self:changeSignState(self:constructHolder(signNode),SignCfg.SignState.SIGN_UNCHECKED,showIndex-self.firstDayInWeek)
				end
			--	Text_day:setString(string.format("%d",idx*7+i+1-self.firstDayInWeek))
			end
		end
	end


    return cell
end
function signLayer:getStatus(signStatus)
	--0=未签，1=已签，2=漏签
	local status = nil
	if signStatus ==0 or signStatus ==2 then
		status = SignCfg.SignState.SIGN_MISS_CHECKED
	elseif signStatus == 1 then
		status = SignCfg.SignState.SIGN_CHECKED
	end
	return status
end

function signLayer:getPositonByIdx(index)
	--self.firstDayInWeek
	--tonumber(os.date("%w"))
--[[	local x = 0 --(self.firstDayInWeek+index%SignCfg.maxCountEveryRow)%SignCfg.maxCountEveryRow - 1
	x = index%SignCfg.maxCountEveryRow
	if x==0 or x > SignCfg.maxCountEveryRow - self.firstDayInWeek then
		x = self.firstDayInWeek + x-8
	end
	
	local y = math.ceil(index/SignCfg.maxCountEveryRow) - 1--]]
	return (index+self.firstDayInWeek-1)%SignCfg.maxCountEveryRow,math.floor((index+self.firstDayInWeek-1)/SignCfg.maxCountEveryRow)
	--return x,y + (x<self.firstDayInWeek and 1 or 0)
end
--重置界面内容 重用的时候 动画 颜色
function signLayer:restoreView(signNode)
	
	if not isLuaNodeValid(signNode) then
		return
	end
	
	local Image_bg = signNode:getChildByName("Image_bg")
	local Image_checked = signNode:getChildByName("Image_checked")
	local Image_resignTag = signNode:getChildByName("Image_resignTag")
	local Text_day = signNode:getChildByName("Text_day")
	local Text_event = signNode:getChildByName("Text_event")
	Image_bg:setTouchEnabled(true)
	Image_bg:setVisible(true)
	Image_bg:removeAllChildren()
	Image_bg:setSwallowTouches(false)
	Image_checked:setVisible(true)
	Image_resignTag:setVisible(true)	
				
	Text_event:setVisible(false)
	
	Text_day:setVisible(true)
	Text_day:setColor(cc.c3b(0xFF,0xFF,0xFF))
	Text_event:setColor(cc.c3b(0xFF,0xFF,0xFF))
	
	signNode:stopAllActions()
	signNode:setScale(1)
end

function signLayer:constructHolder(signNode)
	local Image_bg = signNode:getChildByName("Image_bg")
	local Image_checked = signNode:getChildByName("Image_checked")
	local Image_resignTag = signNode:getChildByName("Image_resignTag")
	local Text_day = signNode:getChildByName("Text_day")
	local Text_event = signNode:getChildByName("Text_event")
	Image_bg:setTouchEnabled(true)
	Image_bg:setVisible(true)
	Image_bg:removeAllChildren()
	Image_bg:setSwallowTouches(false)
	Image_checked:setVisible(true)
	Image_resignTag:setVisible(true)	
				
	Text_event:setVisible(false)
	
	Text_day:setVisible(true)
	Text_day:setColor(cc.c3b(0xFF,0xFF,0xFF))
	Text_event:setColor(cc.c3b(0xFF,0xFF,0xFF))
	local viewHolder = {}
	viewHolder.Image_bg = Image_bg
	viewHolder.Image_checked = Image_checked
	viewHolder.Image_resignTag = Image_resignTag
	viewHolder.Text_event = Text_event
	viewHolder.Text_day = Text_day
	return viewHolder
end

--改变签到状态显示
--	@param viewHolder 承载了所有item中的元素
--  @param state 切换至状态
--	@param ... 参数
function signLayer:changeSignState(viewHolder,state,...)
	if state == SignCfg.SignState.SIGN_LAST_MONTH then
		self:handleLastMonth(viewHolder,...)
	elseif state == SignCfg.SignState.SIGN_MISS_CHECKED then
		self:handleMiss(viewHolder,...)
	elseif state == SignCfg.SignState.SIGN_CHECKED then
		self:handleChecked(viewHolder,...)
	elseif state == SignCfg.SignState.SIGN_UNCHECKED then
		self:handleUncheck(viewHolder,...)
	elseif state == SignCfg.SignState.SIGN_CURRENT then
		self:handleCurrent(viewHolder,...)
	end
	
end
--处理今天的状态
--	@param viewHolder 承载了所有item中的元素
--	@param ... 参数
function signLayer:handleCurrent(viewHolder,...)
	local arg = { ... }
	viewHolder.Image_bg:loadTexture("sign_current_bg.png",1)
	viewHolder.Image_resignTag:setVisible(false)
	viewHolder.Image_checked:setVisible(false)	
	
	
	if arg and #arg>=1 then
		--7F 62 62
		viewHolder.Text_event:setVisible(false)
		
		viewHolder.Text_day:setString(tostring(arg[1]))
		
		--判断今天是否签到
		if self.signData[arg[1]].Status==1 then --已签
			viewHolder.Image_bg:removeAllChildren()
			
			viewHolder.Image_bg:loadTexture("day2.png",1)
			viewHolder.Image_checked:setVisible(true)	
		else --未签到
			viewHolder.Text_event:setColor(cc.c3b(0x7F,0x62,0x62))
			viewHolder.Text_day:setColor(cc.c3b(0x7F,0x62,0x62))
			local animSp = cc.Sprite:create()
			local imgbgSize = viewHolder.Image_bg:getContentSize()
			animSp:setPosition(cc.p(imgbgSize.width/2,imgbgSize.height/2))
			animSp:setScale(1.7)
			animSp:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA))
			animSp:runAction(cc.RepeatForever:create(WWAnimatePackerLua:getAnimate("hall/sign/animation/sign_item_anim")))
			viewHolder.Image_bg:addChild(animSp)
		end
	end
	
end
--处理过去未签到的状态
--	@param viewHolder 承载了所有item中的元素
--	@param ... 参数
function signLayer:handleMiss(viewHolder,...)
	local arg = { ... }
	viewHolder.Image_checked:setVisible(false)	
	viewHolder.Image_bg:loadTexture("day3.png",1)
	if arg and #arg>=1 then
		viewHolder.Text_event:setVisible(false)
		viewHolder.Text_event:setColor(cc.c3b(0x7F,0x62,0x62))
		viewHolder.Text_day:setColor(cc.c3b(0x7F,0x62,0x62))
		viewHolder.Text_day:setString(tostring(arg[1]))
	end
	
end
--处理未来状态
--	@param viewHolder 承载了所有item中的元素
--	@param ... 参数
function signLayer:handleUncheck(viewHolder,...)
	local arg = { ... }
	viewHolder.Image_bg:loadTexture("day3.png",1)
	viewHolder.Image_resignTag:setVisible(false)
	viewHolder.Image_checked:setVisible(false)	
	if arg and #arg>=1 then
		--7F 62 62
		viewHolder.Text_event:setVisible(false)
		viewHolder.Text_event:setColor(cc.c3b(0x7F,0x62,0x62))
		viewHolder.Text_day:setColor(cc.c3b(0x7F,0x62,0x62))
		viewHolder.Text_day:setString(tostring(arg[1]))
	end
end
--处理过去已经签到的状态
--	@param viewHolder 承载了所有item中的元素
--	@param ... 参数
function signLayer:handleChecked(viewHolder,...)	
	local arg = { ... }
	
	viewHolder.Image_resignTag:setVisible(false)
	--viewHolder.Text_event:setVisible(false)	
	
	if arg and #arg>=1 then --普通显示
		viewHolder.Image_bg:loadTexture("day2.png",1)
		viewHolder.Text_day:setString(tostring(arg[1]))
	else --切换，需要动画
		viewHolder.Image_checked:setVisible(false)
		
		self:runOpenAnim(viewHolder.Image_bg:getParent(),function ()
			viewHolder.Image_bg:getParent():setScale(0)
			viewHolder.Image_bg:loadTexture("day2.png",1)
			viewHolder.Image_checked:setVisible(true)
			
			self:runOpenAnim2(viewHolder.Image_bg:getParent())
		end)
	end
end
--处理上个月的状态
--	@param viewHolder 承载了所有item中的元素
--	@param ... 参数
function signLayer:handleLastMonth(viewHolder,...)
	viewHolder.Image_checked:setVisible(false)
	viewHolder.Image_resignTag:setVisible(false)				
	viewHolder.Text_event:setVisible(false)
	viewHolder.Image_bg:loadTexture("day1.png",1)
	viewHolder.Image_bg:setTouchEnabled(false) --上个月的就不让点了
	
	local arg = { ... }
	if arg and #arg>=1 then
		viewHolder.Text_day:setColor(cc.c3b(0x7F,0x62,0x62))
		viewHolder.Text_event:setColor(cc.c3b(0x7F,0x62,0x62))
		viewHolder.Text_day:setString(tostring(arg[1]))
	end
	
end

function signLayer:numberOfCellsInTableView(view)
	--根据返回的数据决定是多少行 4/5
	return self.dayCount >0 and math.ceil((self.firstDayInWeek + self.dayCount)/SignCfg.maxCountEveryRow) or 0

end

function signLayer:touchEventListener(ref,eventType)
	if not ref or self.tableView:isTouchMoved() then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		--分别取横，纵坐标  下标从0开始
		local x = ref:getTag()%10000 --当前点击的item中在一周的索引
		local y = math.floor(ref:getTag()/10000) --当前点击的item在第几列
		print(x,y)
		--self.curSelected.x = x
		--self.curSelected.y = y
		
	end
end

function signLayer:runOpenAnim(node,animCB)
	local act1 = cc.ScaleTo:create(4.0/SignCfg.frameRate,1.25)
	local act2 = cc.ScaleTo:create(3.0/SignCfg.frameRate,0.1)
	local act3 = cc.ScaleTo:create(1.0/SignCfg.frameRate,0)
	if animCB and type(animCB)=="function" then
		node:runAction(cc.Sequence:create(act1,act2,act3,cc.CallFunc:create(animCB)))
	else
		node:runAction(cc.Sequence:create(act1,act2,act3))
	end
	
end
function signLayer:runOpenAnim2(node)
	local act1 = cc.ScaleTo:create(4.0/SignCfg.frameRate,1.0)
	local act2 = cc.ScaleTo:create(2.0/SignCfg.frameRate,1.1)
	local act3 = cc.ScaleTo:create(2.0/SignCfg.frameRate,1.0)
	local act4 = cc.ScaleTo:create(2.0/SignCfg.frameRate,1.05)
	local act5 = cc.ScaleTo:create(2.0/SignCfg.frameRate,1.0)
	local act6 = cc.CallFunc:create(handler(self,self.refreshTopInfo))
	node:runAction(cc.Sequence:create(act1,act2,act3,act4,act5,act6))
end

function signLayer:changeCurrentSelect(signState)
	
	local cell = self.tableView:cellAtIndex(self.curSelected.y)
	if cell then
		local signNode = cell:getChildByTag(self.curSelected.x)
		if not signNode then
			--数据异常
			wwlog("current select item error:%d,%d",self.curSelected.x,self.curSelected.y)
			return
		end

		--修改状态
		self:changeSignState(self:constructHolder(signNode),signState)
		end
end

return signLayer