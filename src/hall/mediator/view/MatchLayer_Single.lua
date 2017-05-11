-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.10
-- Last: 
-- Content:  比赛单人赛界面
-- Modify: 2016-11-2 diyal.yin 第一名，奖励放大（300/200） 全改成200x200
--		   2016-11-18 cruelogre 多奖励时，比赛详情展示修改，改成默认展示第一个本地资源
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local MatchLayer_Single = class("MatchLayer_Single",require("hall.mediator.view.MatchLayer_WindowBase"))

local MatchLayer_widget_detail = require("hall.mediator.view.widget.MatchLayer_widget_detail")

local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local MatchProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_MATCH)

local WWNetSprite = require("app.views.customwidget.WWNetSprite")


function MatchLayer_Single:ctor(matchData)
	self.matchData = matchData
	MatchLayer_Single.super.ctor(self,matchData.MatchID)
	self.logTag = "MatchLayer_Single.lua"
end

--@param data 比赛的数据
--@param revSec 数据发送的时间
function MatchLayer_Single:init(matchid)
	MatchLayer_Single.super.init(self,matchid)
	self.matchid = matchid
	self:setName("MatchLayer_Single")
	self:setOpacity(156)
	self.qualification = true --默认满足报名资格
	self.signType = 0 --请求的类型
	self.signData = 0 --请求的数据
	print("MatchLayer_Single init")
	self.node = require("csb.hall.match.MatchLayer_time_desc"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	--self.clickItem = false
	self.refreshToGame = false --是否进入游戏的刷新
	--testing
	
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	
	
	local prizeGroup = ccui.Helper:seekWidgetByName(self.imgId,"Image_podium")
	
	for x=1,3 do
		local fnode = prizeGroup:getChildByName(string.format("FileNode_%d",x))
		if fnode then
			--
			
			fnode:getChildByName("Image_prize"):ignoreContentAdaptWithSize(true)
			local showRrise = self:getAwardDesc(matchid,x)
			local rankImg = self:getAwardImg(matchid,x)
			if string.len(showRrise)>0 then
				fnode:getChildByName("Image_prize"):loadTexture("match_desc_prize1.png",1)
			else
				fnode:getChildByName("Image_prize"):setVisible(false)
			end
			fnode:getChildByName("Image_prize"):setVisible(false)
			local px = fnode:getChildByName("Image_prize"):getPositionX()
			local py = fnode:getChildByName("Image_prize"):getPositionY()
			--http://pic2.51ias.com/test_a/sys_avatar/00c876e3521e12a4b68a64a2c9ca8a4a.png
			--MatchCfg:getMatchImageURL(2,matchid,x)
			local sp = WWNetSprite:create(rankImg or "#match_desc_prize1.png"
				,MatchCfg:getMatchImageURL(2,matchid,x), false)

			if x == 1 then
				sp:setScale(sp:getScale()*300/200)
			end
			
			sp:setPosition(cc.p(px/2,py/2))
			fnode:addChild(sp)
			--self.matchData
			--Text_prize
			
			fnode:getChildByName("Text_prize"):setString(showRrise)
			
			fnode.animation:play("animation0",true)
		end
	end
	
	self:popIn(self.imgId,Pop_Dir.Right)
	
	
end


function MatchLayer_Single:onEnter()
	-- body
	MatchLayer_Single.super.onEnter(self)
	self:initLocalText()
	self:initViewData()
	self.timeCount = 0
	if self.matchData then
		self:reloadData()
	else
		MatchProxy:requestMatchDetail(self.matchid)
	end
	--MatchProxy:requestMatchDetail(self.matchid)
	
	
end
function MatchLayer_Single:onExit()
	MatchLayer_Single.super.onExit(self)
	
end
function MatchLayer_Single:refreshContent()
	self:refreshCost(self.signText,self.matchData)
	self:refreshIcon()

	ccui.Helper:seekWidgetByName(self.imgId,"Text_title"):setString(tostring(self.matchData.Name))
	self:refreshTime(self.matchData,self.timeText)
	local oldX = self.alarmImg:getPositionX()
	local newX = self.timeText:getPositionX()- self.timeText:getContentSize().width - 40
	if math.abs(newX - oldX)>10 then
		self.alarmImg:setPositionX(newX)
	end
end
--倒计时时间到
function MatchLayer_Single:timeout()
	self:stopAllActions()
	self.timeCount = 0
	MatchProxy:requestMatchDetail(self.matchid)
	
end

--[[function MatchLayer_Single:timeCounting()
	self.timeCount = self.timeCount + 1
	self:refreshContent()
end
--]]
function MatchLayer_Single:reloadData(event)
	
	local allMtchData = DataCenter:getData(MatchCfg.InnerEvents.MATCH_EVENT_DETAIL)
	self.matchData =allMtchData[self.matchid]
	print("self.matchid",self.matchid)
	if not self.matchData then
		return
	end
	--wwdump(self.matchData,"self.matchData",5)
	print("MatchLayer_Single:reloadData")
	self:stopAllActions()
	self.timeCount = 0
	self.hasDataOnce = true
	self.clickItem = false
	self:refreshContent()
	if self.refreshToGame then
	--	MatchProxy:requestSign(self.matchid,self.signType,self.signData)
	end
	--local awardlist = MatchProxy:getMatchAward(self.matchData.MatchID,1)
	--dump(awardlist)
end

function MatchLayer_Single:matchNotify(event)
	local msgTable = event._userdata
	if not msgTable then
		return
	end
	wwlog(self.logTag,"MatchLayer_Single:matchNotify",event.msgId,msgTable.Type)
	if event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER or 
	event.msgId == MatchCfg.InnerEvents.MATCH_EVENT_NOTIFYUSER_QUIT then --报名成功
		--改变按钮状态
		--报名成功，退赛成功
		self:timeout()
		if msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS or
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_SUCCESS_HAS_STARTED or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_ING or 
		 msgTable.Type==MatchCfg.NotifyType.MATCH_QUIT_FAILED_NOT_EXISTS then
			--self.clickItem = false
		end
--[[		if msgTable.Type==7 or msgTable.Type==2 or msgTable.Type==3 then
			MatchProxy:requestMatchDetail(self.matchid)
		end--]]
		
	end
end

function MatchLayer_Single:initViewData()
	ccui.Helper:seekWidgetByName(self.imgId,"Text_title"):setString("")
	self.alarmImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_alarm")
	self.timeText = ccui.Helper:seekWidgetByName(self.imgId,"Text_time")
	
	self.signImg = ccui.Helper:seekWidgetByName(self.imgId,"Image_signup")
	self.signText = ccui.Helper:seekWidgetByName(self.imgId,"Text_sign")
	--这里用富文本来替换
	local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true)
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:addTo(self.signText:getParent())
	richText:setName("Text_sign")
	self.signTextY = self.signText:getPositionY()
	richText:setPosition(self.signText:getPositionX(),self.signText:getPositionY())
	self.textFontSize = self.signText:getFontSize()
	self.textFontColor = self.signText:getTextColor()
	self.signText:removeFromParent()
	self.signText = richText
	
	ccui.Helper:seekWidgetByName(self.imgId,"Button_rule"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Image_condition"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.imgId,"Image_signup"):addTouchEventListener(handler(self,self.touchListener))
end
--刷新图标
function MatchLayer_Single:refreshIcon()
	--BeginType
	
	if tonumber(self.matchData.BeginType)==1 then
	--人数
		if ToolCom.isSpriteFrameValid("match_desc_person.png") then
			self.alarmImg:loadTexture("match_desc_person.png",1)
		end
		
	else
	--时间
		if ToolCom.isSpriteFrameValid("match_desc_alarm.png") then
			self.alarmImg:loadTexture("match_desc_alarm.png",1)
		end
	end
	local num = self:getMaxAwardCount(self.matchid)
	if tonumber(self.matchData.TeamWork)==1 then
		--num = num / 2
	end
	ccui.Helper:seekWidgetByName(self.imgId,"Text_condition"):setString(
	string.format(i18n:get('str_match','match_award_count'),num))
end

function MatchLayer_Single:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		playSoundEffect("sound/effect/anniu")
		wwlog(self.logTag,"别TM瞎点了00000%s,%s",tostring(self.clickItem),tostring(LoadingManager:isShowing()))
		if self.clickItem or LoadingManager:isShowing() then
				wwlog(self.logTag,"别TM瞎点了")
				return
			end
		self.clickItem = true
			
		if name == "Button_rule" then
		--显示比赛详情
			
			self.isTopLayer = false
			local detail = MatchLayer_widget_detail:create(self.matchData.Desc)
			detail:setCid(5)
			detail:bindCloseCB(handler(self,self.frontClosed))
			cc.Director:getInstance():getRunningScene():addChild(detail,5)
		elseif name == "Image_condition" then
		--显示奖励列表
			self.isTopLayer = false
			
			local condition = MatchLayer_widget_detail:create(self:formatAward(self.matchData.MatchID))
			condition:setCid(2)
			condition:bindCloseCB(handler(self,self.frontClosed))
			cc.Director:getInstance():getRunningScene():addChild(condition,5)
		elseif name=="Image_signup" then
			--是否报名
			if tonumber(self.matchData.MyEnterFlag)==0 then --未报名
				if self.qualification then
					--满足报名条件
					local cost = {signType = self.signType,signData = self.signData}
					DataCenter:cacheData(MatchCfg.InnerEvents.MATCH_EVENT_COST,cost)
					
					self:stopAllActions()
					self.timeCount = 0
					if tonumber(self.matchData.BeginType) == 1 then --人数
						self.refreshToGame = true
						--MatchProxy:requestMatchDetail(self.matchid)
						MatchProxy:requestSign(self.matchid,self.signType,self.signData)
					else
						MatchProxy:requestSign(self.matchid,self.signType,self.signData)
					end
					
					
				else
					--不满足报名条件
					--先判断是否破产 并且是金币
					local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey('GameCash'))
					if DataCenter:getUserdataInstance():getValueByKey("bankrupt") 
					and self.matchData.EnterType==1 then
						
						self:showBankRupt(self.matchData.EnterData - myCash)
						
					else
						
						--判断是否配置了报名条件
						if self.matchData.SignupTermDesc and string.len(self.matchData.SignupTermDesc)>0 then
							self.isTopLayer = false
							local reward = MatchLayer_widget_detail:create(self.matchData.SignupTermDesc)
							reward:setCid(1)
							reward:bindCloseCB(handler(self,self.frontClosed))
							cc.Director:getInstance():getRunningScene():addChild(reward,5)
						else
							self.isTopLayer = true
							self.clickItem = false
							local ed = MatchCfg.enterTypes[tonumber(self.matchData.EnterType)]
							if ed then
								local storeOpenType = ed.storeOpenType
								FSRegistryManager:currentFSM():trigger("store", 
								{parentNode=display.getRunningScene(), zorder=5, store_openType=storeOpenType, sceneIDKey = "MatchRoom", umengFlg = "InsufficientCost"})
							else
								print("本地未配置当前道具",self.matchData.EnterType)
							end
							
							

						end
					end
					


				end
			else
				--已经报名 退赛
				MatchProxy:quitSign(self.matchid)
			end
		
			
			
		end
	end
	
	
	
end

--顶层关闭的回调
function MatchLayer_Single:frontClosed(force)
	print("MatchLayer_Single frontClosed")
	self.isTopLayer = true
	self.clickItem = false
--[[	self.isTopLayer = true
	self.clickItem = false
	if self.needFresh or force then
		
		MatchProxy:requstMatchList()
		self.contentOffset = self.tableView:getContentOffset()
	end--]]
	
end

function MatchLayer_Single:initLocalText()
	
end

return MatchLayer_Single