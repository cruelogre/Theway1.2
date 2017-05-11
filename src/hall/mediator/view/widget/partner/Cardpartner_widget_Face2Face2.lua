-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.13
-- Last: 
-- Content:  比赛界面添加好友控件 搜索好友
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local Cardpartner_widget_Face2Face2 = class("Cardpartner_widget_Face2Face2",ccui.Layout,require("packages.mvc.Mediator"))

local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)
local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

local Node_match_frienditem2 = require("csb.hall.match.Node_match_frienditem2")

local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

local Toast = require("app.views.common.Toast")

local _scheduler = cc.Director:getInstance():getScheduler()

function Cardpartner_widget_Face2Face2:ctor(size,numbers,openType)
	self.size = size


	self.numbers = numbers or CardPartnerCfg.searchSendnumbers
	
	self.timeCount = 0
	--self.leftTime = 0 --还剩余的时间
	self.hasMates = false --是否有好友
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self:setName("Cardpartner_widget_Face2Face2")
	self.cardhandlers = {}
	
	self:init()
	
end

function Cardpartner_widget_Face2Face2:init()
	print("Cardpartner_widget_Face2Face2:init")
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	local searchNode = require("csb.hall.match.MatchLayer_widget_searchFriend"):create()
	self.searchFriend = searchNode.root
	self.radarAnimation = searchNode.animation
	self.radarAnimation:play("animation0",true)
	
	self.searchFriend:runAction(searchNode.animation)
	FixUIUtils.setRootNodewithFIXED(self.searchFriend)
	local panel1 = self.searchFriend:getChildByName("Panel_3")
		
	FixUIUtils.stretchUI(panel1)
	self:addChild(self.searchFriend,1)
	
	self.friendListView = ccui.Helper:seekWidgetByName(panel1,"ListView_friends")
	self.friendListView:setScrollBarEnabled(false)
	self.radarImg = ccui.Helper:seekWidgetByName(panel1,"Image_radar")
	self.orPosY = self.radarImg:getPositionY()
	
	--Text_8
	self.textNumber = ccui.Helper:seekWidgetByName(panel1,"Text_8")
	--剩余时间
	self.clockNumber = ccui.Helper:seekWidgetByName(panel1,"Text_clock")
	--self.buttonAdd = ccui.Helper:seekWidgetByName(panel1,"Button_addeach")
	--self.buttonAdd:addTouchEventListener(handler(self,self.touchListener))
	self.retryBtn = ccui.Helper:seekWidgetByName(panel1,"Button_retry")
	self.retryBtn:addTouchEventListener(handler(self,self.touchListener))
	
	self.orListSize = self.friendListView:getContentSize()

	self.timeCount = os.time() - CardPartnerCfg.matchSendnumberTime
	local numberValidTime = CardPartnerCfg.numberValidTime
	
	print("self.timeCount",self.timeCount)
	self.timeCount = math.max(self.timeCount,0)
	self:freshLeftTime(numberValidTime - self.timeCount)
	--self.clockNumber:setString("0")
	self:freshTextNumber(self.numbers)
	self:freshButton()
end 

function Cardpartner_widget_Face2Face2:freshTextNumber(numbers)
	local showStr = ""
	for _,v in pairs(numbers) do
		showStr = showStr..v
	end
	self.textNumber:setString(showStr)
end
function Cardpartner_widget_Face2Face2:freshButton()
	--self.buttonAdd:setBright(self.hasMates)
	--self.buttonAdd:setTitleColor(self.hasMates and cc.c3b(0x89,0x1E,0x0F) or cc.c3b(0x7F,0x7F,0x7F))
end
--刷新内容
function Cardpartner_widget_Face2Face2:freshContent(event)
	local foundmates = unpack(event._userdata)
	if not foundmates then
		foundmates = event._userdata
	end
	if not foundmates then
		return
	end
	
	--local foundmates = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE)
	
	if not foundmates or not foundmates.friendList or not next(foundmates.friendList) then
		print("Cardpartner_widget_Face2Face2 没找到对象")
		return
	end
	
	self:freshButton()
	--self.friendListView:removeAllItems()
	
	self.radarImg:setPositionY(self.orPosY - 100)
	self.radarImg:setScale(0.8)
	
	print("Cardpartner_widget_Face2Face2:freshContent....")
	
	--有好友啦
	--add custom item
	self:showFriends(foundmates.friendList)
	
end
function Cardpartner_widget_Face2Face2:showFriends(friendMates)
		for _,mate in pairs(friendMates) do
		self.hasMates = #friendMates > 0
		local custom_head = Node_match_frienditem2:create().root
        
        custom_head:setContentSize(cc.size(205,200))

        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(custom_head:getContentSize())
        custom_head:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height-60 ))
        custom_item:addChild(custom_head)
		--Text_signup
		local nameStr = string.len(mate.Nickname) >0 and mate.Nickname or tostring(mate.UserID)
		
		custom_head:getChildByName("Text_signup"):setString(nameStr)
		local param = {
			headFile=DataCenter:getUserdataInstance():getHeadIconByGender( mate.Gender and tonumber(mate.Gender) or 1),
			maskFile="#match_mate_bg_header2.png",
			frameFile = "common/common_userheader_frame_userinfo.png",
			headType=1,
			radius=60,
	        headIconType =mate.IconID, --DataCenter:getUserdataInstance():getValueByKey("IconID"),
	        userID =mate.UserID, --DataCenter:getUserdataInstance():getValueByKey("userid")
		 }
		--
		local HeadSprite = WWHeadSprite:create(param)
		HeadSprite:setPosition(cc.p(60,60))
		custom_head:getChildByName("Image_head"):removeChildByName("match_mate")
		--match_check
		custom_head:getChildByName("Image_head"):getChildByName("match_check"):setLocalZOrder(2)
		custom_head:getChildByName("Image_head"):addChild(HeadSprite,1)
	
        self.friendListView:pushBackCustomItem(custom_item)
		
	end
	
   
	
	local count = self.friendListView:getChildrenCount()
	local margin = self.friendListView:getItemsMargin()
	local nowWidth = count*205+(count-1)*margin
	if nowWidth < self.orListSize.width then
		self.friendListView:setContentSize(cc.size(nowWidth,200))
	end
end


function Cardpartner_widget_Face2Face2:eventComponent()
	return CardPartnerCfg.innerEventComponent
end

function Cardpartner_widget_Face2Face2:bindTimeOutCB(cb)
	self.timoutCB = cb
end

function Cardpartner_widget_Face2Face2:bindChangeFun(cb)
	self.changeCB = cb
end

function Cardpartner_widget_Face2Face2:onEnter()
--[[	self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.CallFunc:create(function ()
		
		self.hasMates = true
		self:freshButton()
	end)))--]]
	playSoundEffect("sound/effect/leida",true)

	self:registerEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE,handler(self,self.freshContent))
	
	

	self.m_sche = _scheduler:scheduleScriptFunc(handler(self, self.timeClick), 1, false)
	--self.timeCount = 0
	self.retryBtn:setVisible(false)
	self.friendListView:removeAllItems()
	local foundmates = DataCenter:getData(CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE_ALL)
	if foundmates and foundmates.friendList and next(foundmates.friendList) then
		self.radarImg:setPositionY(self.orPosY - 100)
		self.radarImg:setScale(0.8)
		local tempMateList = {}
		copyTable(foundmates.friendList,tempMateList)
		self:showFriends(tempMateList)
		--wwdump(foundmates.mateList)
	else
	--
		print("之前没有扫到什么好友哦")
	end
	
end
--这个方法目前没有调用了，扫好友界面没有添加好友的按钮，扫出来 直接就是好友
function Cardpartner_widget_Face2Face2:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		playSoundEffect("sound/effect/anniu")
		if name == "Button_retry" then --重新搜索
		--互加好友
			if self.changeCB then
				self.changeCB()
			end
			
			
		end
	end
	
	
	
end

function Cardpartner_widget_Face2Face2:timeClick()
	self.timeCount = self.timeCount + 1
	--print("timeClick",self.timeCount)
	self:freshLeftTime(CardPartnerCfg.numberValidTime - self.timeCount)
	if self.timeCount >= CardPartnerCfg.numberValidTime then --时间到了，停止记时 
		stopSoundEffect("sound/effect/leida")
		if self.m_sche then
			_scheduler:unscheduleScriptEntry(self.m_sche)
			self.radarAnimation:stop() --动画也停止掉
			--如果结束的时候没有好友 给个提示
			--跳转界面到上一级
			--self.hasMates
			if not self.hasMates then
				Toast:makeToast(i18n:get('str_match','match_not_find_friend'),1.0):show()
				--没有搜索到好友
				self.retryBtn:setVisible(true)
			else
				--搜索到了好友
				if self.timoutCB then
					self.timoutCB()
				end
			end
			
			
		end
	end
end

function Cardpartner_widget_Face2Face2:freshLeftTime(t)
	t = math.max(t,0)
	self.clockNumber:setString(tostring(t))
end

function Cardpartner_widget_Face2Face2:onExit()
	stopSoundEffect("sound/effect/leida")
	
	if self.m_sche then
		_scheduler:unscheduleScriptEntry(self.m_sche)
		self.m_sche = nil
	end

	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_FOUNDMATES_FACE)
end
function Cardpartner_widget_Face2Face2:active()
	print("Cardpartner_widget_Face2Face2 active")
	self.timeCount = 0
end

return Cardpartner_widget_Face2Face2