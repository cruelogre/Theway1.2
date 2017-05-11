local MatchLayer_WindowBase = class("MatchLayer_WindowBase",require("app.views.uibase.PopWindowBase"))

local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local BankruptLayer = require("app.views.customwidget.BankruptLayer")

local _scheduler = cc.Director:getInstance():getScheduler()

function MatchLayer_WindowBase:ctor(matchid)
	MatchLayer_WindowBase.super.ctor(self)
	self:init(matchid)
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
	self.handles = {}
end
function MatchLayer_WindowBase:init(matchid)
	self.clickItem = false
end
--设置关闭回调
function MatchLayer_WindowBase:bindCloseCB(closeCB)
	self._closeCB = closeCB
	
	if self._closeCB and type(self._closeCB)=="function" then
		
		self:setDisCallback(function ( ... )
		-- body
			
			self._closeCB()
			self._closeCB = nil
			
			self:removeFromParent()
			
			
		end)
	end
end

function MatchLayer_WindowBase:timeClick()
	
	self.timeCount = self.timeCount +1
	self:refreshContent()
	if self.timeCount >= MatchCfg.refreshInterval
	and self.isTopLayer and self.hasDataOnce and not LoadingManager:isShowing() then
		self.timeCount = 0
		self.roomCount = 0
		self:timeout()
	end
	self.timeCount = math.min(self.timeCount,MatchCfg.refreshInterval)
		
end

function MatchLayer_WindowBase:refreshContent()
	
end
--倒计时时间到
function MatchLayer_WindowBase:timeout()

end
function MatchLayer_WindowBase:reloadData(event)

end
function MatchLayer_WindowBase:matchNotify(event)

end
--刷新时间
function MatchLayer_WindowBase:refreshTime(matchData,timeText)
	
	if tonumber(matchData.BeginType) == 1 then
	--定人赛
		local totoal = tonumber(matchData.Requirement)
		local currentCount = tonumber(matchData.EnterCount)
		timeText:setString(string.format("%d/%d",currentCount,totoal))
	else 
	--定时赛  --倒计时
		tostring(matchData.Requirement)
		--2016-09-13 21:40:53
		local times = string.split(tostring(matchData.Requirement)," ")
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
		local iCountdown = tonumber(matchData.Countdown)
		if iCountdown<0 then
			return
		end
		--todaySec = todaySec - iCountdown
		todaySec = iCountdown - todaySec
		iCountdown = iCountdown - self.timeCount
		local showString = nil
			
		if iCountdown < 0 then --已经开赛 刷新
			self:stopAllActions()
			--MatchProxy:requstMatchList()
			self:timeout()
			print("time out")
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
		matchData.matchTime = matchTime
		--print("showString",data.iCountdown,showString)
		--dump(currentTime)
		if showString then
			timeText:setString(showString)
		end
	end
end

function MatchLayer_WindowBase:refreshCost(signText,matchData)
	
	signText:removeAllElements()
	local showStr = ""
	local showNum = nil
	local needImg = false
	
	if tonumber(matchData.MyEnterFlag)==0 then --未报名
		--self.signImg:loadTexture("hall/match/match_mate_btn_yellow.png")
		if tonumber(self.matchData.EnterType)==0 then --免费报名
			showStr = i18n:get('str_match','match_free_sign')
		else
			--报名资格是否足够
			self.qualification = false
		
			local ed = MatchCfg.enterTypes[tonumber(matchData.EnterType)]
			local fid  = ed.fid
			local nNum
			local value = 0
			if matchData and (matchData.EnterType == 3) then --如果是比赛门票
				local splArrs = Split(matchData.EnterData, "/")
				nNum = splArrs[3]
				value = DataCenter:getUserdataInstance():getGoodsAttr(fid,"count")
			else
				nNum = matchData.EnterData
				local goods = getGoodsByFid(fid)
				if goods then
					value = DataCenter:getUserdataInstance():getValueByKey(goods.dataKey)
				end
				
				
			end
			
			self.qualification = (matchData.EnterEnough==1)
			if self.qualification then

			--fid = ed.fid

			--wwdump(self.matchData, nNum)

			--wwlog("diyal", goods.dataKey)
			if value and tonumber(value)<tonumber(nNum) then
			--满足
--[[				if self.signType == 0 then
					self.signType = tonumber(self.matchData.EnterType)
					self.signData = tonumber(self.matchData.EnterData)
				end--]]
				
				self.qualification = false
				
			end
		end
			if self.qualification then

				--TODO 显示比赛消耗
				showStr = string.format(i18n:get('str_match','match_sign_fee_s'))
				if matchData and (matchData.EnterType == 3) then --如果是比赛门票
					showNum  = string.format("x%s",ToolCom.splitNumFix(tonumber(nNum)))
				else
					showNum  = string.format("%s",ToolCom.splitNumFix(tonumber(nNum)))
				end
				needImg = true
				
				--if self.signType == 0 then
					self.signType = tonumber(matchData.EnterType)
					self.signData = tonumber(nNum)
				--end
							
			else
				--match_sign_not_enough
				if string.len(matchData.SignupTermDesc) >0 then
					showStr = i18n:get('str_match','match_sign_not_enough')

				else
					showStr = string.format(i18n:get('str_match','match_sign_fee_s'))
					if matchData and (matchData.EnterType == 3) then --如果是比赛门票
						showNum  = string.format("x%s",ToolCom.splitNumFix(tonumber(nNum)))
					else
						showNum  = string.format("%s",ToolCom.splitNumFix(tonumber(nNum)))
					end
					needImg = true
				end
				
			end
		
		
		
		end
		
		local showColor = self.textFontColor
		if not self.qualification and string.len(matchData.SignupTermDesc) == 0 then
			showColor = cc.c3b(0xff,0x00,0x00)
		end
		local re1 = ccui.RichElementText:create(1, showColor,0xff, showStr.."  ", "FZZhengHeiS-B-GB.ttf", self.textFontSize)

		signText:pushBackElement(re1)
		
		if showNum then 
			local re11 = ccui.RichElementText:create(1, showColor,0xff, showNum, "FZZhengHeiS-B-GB.ttf", self.textFontSize)
			signText:pushBackElement(re11)
		end

		if needImg then

			local ed = MatchCfg.enterTypes[tonumber(matchData.EnterType)]
			local fid 
			local nNum
			if matchData and (matchData.EnterType == 3) then --如果是比赛门票
				local splArrs = Split(matchData.EnterData, "/")
				nNum = splArrs[3]
			else
				nNum = matchData.EnterData
			end
			fid = ed.fid
			
			local ed = MatchCfg.enterTypes[tonumber(matchData.EnterType)]
			if ed and cc.FileUtils:getInstance():isFileExist(ed.spfile) then
				local re2 = ccui.RichElementImage:create(2,cc.c3b(0xff,0xff,0xff),0xff,ed.spfile)
				
				if matchData and (matchData.EnterType == 3) then --如果是比赛门票
					signText:insertElement(re2,signText:getElementCount()-1)
				else
					signText:pushBackElement(re2)
				end
				if self.signTextY then
					signText:setPositionY(self.signTextY+5)
				end
			end
		end
	else --已经报名了 显示退赛
		--self.signImg:loadTexture("hall/match/match_mate_btn_green.png")
		showStr = i18n:get('str_match','match_sign_quit')
		local re1 = ccui.RichElementText:create(1,  cc.c3b(0xff, 0xff, 0xff),0xff, showStr, "FZZhengHeiS-B-GB.ttf", 42)
		signText:pushBackElement(re1)
	end
	
end

--格式化奖励内容
function MatchLayer_WindowBase:formatAward(mid)
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local tempmatchData =allMtchData[mid]
	
	local awardListStr = function (magicList)
		local retStr = ""
		table.walk(magicList,function (v,k)
			retStr = retStr..v.MagicName.."*"..v.MagicCount
			
			if k<table.maxn(magicList) then
				retStr = retStr.."   "
			end
		end)
		return retStr
	end
	if tempmatchData and tempmatchData.awardList then
		wwdump(tempmatchData.awardList,"",5)
		local content = '[font color="000000" size="45"]'
		for k,v in pairs(tempmatchData.awardList) do
			local str = ""
			if v.BeginRankNo == v.EndRankNo then
				str = string.format("第%d名    %s[br/]",v.BeginRankNo,awardListStr(v.magicList))
			else
				str = string.format("第%d-%d名  %s[br/]",v.BeginRankNo,v.EndRankNo,awardListStr(v.magicList))
			end
			
			content = content..str
		end
		content = content.."[/font]"
		return content
	end
	return ""
end


--返回最大的获奖名次
function MatchLayer_WindowBase:getMaxAwardCount(mid)
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local tempmatchData =allMtchData[mid]
	if tempmatchData and tempmatchData.awardList and next(tempmatchData.awardList) then
		local temp1 = {}
		copyTable(tempmatchData.awardList,temp1)
		table.sort(temp1,function (a,b)
			return a.EndRankNo > b.EndRankNo
	end)
		return temp1[1].EndRankNo
	end
	return 0
end
--返回名次奖励
function MatchLayer_WindowBase:getAwardDesc(mid,rank)
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local tempmatchData =allMtchData[mid]
	local rankAward = ""
	if tempmatchData and next(tempmatchData.awardList) then
--[[		local temp1 = {}
		copyTable(tempmatchData.awardList,temp1)
		table.sort(temp1,function (a,b)
			return a.EndRankNo < b.EndRankNo
		end)--]]
		for _,award in ipairs(tempmatchData.awardList) do
			if award.EndRankNo>=rank and award.BeginRankNo <= rank then
				print(award.BeginRankNo,rank,award.EndRankNo)
				rankAward = award.Award
				break
			end
			
		end
	
	end
	return rankAward
end

function MatchLayer_WindowBase:getAwardImg(mid,rank)
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	local tempmatchData =allMtchData[mid]
	local rankImg = nil
	if tempmatchData and next(tempmatchData.awardList) then

		for _,award in ipairs(tempmatchData.awardList) do
			if award.EndRankNo>=rank and award.BeginRankNo <= rank then
				if award.magicList then
					table.walk(award.magicList,function (v,k)
						print("v.FID",v.FID,"v.MagicID",v.MagicID)
						local imgFile = string.format("common/goods/item_%d.png",tonumber(v.FID))
						if not rankImg and cc.FileUtils:getInstance():isFileExist(imgFile) then
							rankImg = imgFile	
						end
					end)
				end
				
				
				break
			end
			
		end
	
	end
	return rankImg
end

function MatchLayer_WindowBase:showBankRupt(needMoney)
	local para = {}		
	para.money = tonumber(needMoney)
	para.layerType = 2  --界面类型  1金币不足 2 破产
	para.sceneTag = 1 --在哪个场景
	para.upCloseOnClick = true

	para.upCallback = function ()
		--购买金币  打开商城
		print("购买金币")
		self.isTopLayer = false

		local sIDKey 
		if para.layerType == 1 then --金币不足
			sIDKey = "GoldEnough"
		elseif para.layerType == 2 then --破产 then --破产
			sIDKey = "Bankrupt"
		end

		FSRegistryManager:currentFSM():trigger("store", 
		{parentNode=display.getRunningScene(), zorder=self:getLocalZOrder()+1,store_openType=2, sceneIDKey = sIDKey})
			
	end --上面按钮响应
	para.downCloseOnClick = false --下边的按钮点击不自动关闭
    para.downCallback = function ()
		
		if para.layerType==2 then
			print("领取救济金")
			HallSceneProxy:requestBankruptAward()
		else
			print("去低倍场次")
		end
	end --下面按钮响应
	
	local bankrupt = BankruptLayer:create(para)
	bankrupt:setOpacity(156)
	bankrupt:bindCloseFun(function ()
		self.isTopLayer = true
		self.clickItem = false
	end)
	bankrupt:show(self:getLocalZOrder()+1)
end

function MatchLayer_WindowBase:onEnter()
	if self:eventComponent() then
		local _ = nil
		
		_,self.handles[#self.handles+1] = self:eventComponent():addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL,handler(self,self.reloadData))
		_,self.handles[#self.handles+1] = self:eventComponent():addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER,handler(self,self.matchNotify))
		_,self.handles[#self.handles+1] = self:eventComponent():addEventListener(MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT,handler(self,self.matchNotify))
		self.timeCount = 0

	end
	
	self.isTopLayer = true
	self.hasDataOnce = false
	self.m_sche = _scheduler:scheduleScriptFunc(handler(self, self.timeClick), 1, false)
		
end
function MatchLayer_WindowBase:onExit()
	MatchLayer_WindowBase.super.onExit(self)
	self:unregisterScriptHandler()
	self:removeListener()
	self.isTopLayer = false
	if self.m_sche then
		_scheduler:unscheduleScriptEntry(self.m_sche)
	end

	
end
function MatchLayer_WindowBase:removeListener()
	if self:eventComponent() then
		for _,v in pairs(self.handles) do
			self:eventComponent():removeEventListener(v)
		end
	end
end

function MatchLayer_WindowBase:eventComponent()
	return MatchCfg.innerEventComponent
end
return MatchLayer_WindowBase