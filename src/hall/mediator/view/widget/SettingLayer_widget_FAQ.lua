-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.08.22
-- Last: 
-- Content:  设置界面中的常见问题
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local SettingLayer_FAQ = class("SettingLayer_FAQ",require("hall.mediator.view.widget.SettingLayer_widget_base"))
local SettingCfg = require("hall.mediator.cfg.SettingCfg")
local SettingProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SETTING)
function SettingLayer_FAQ:ctor(size)
	SettingLayer_FAQ.super.ctor(self,size)
	self:init()
end

function SettingLayer_FAQ:init()
	self.lastSelectItem = -1
	self.canTouch = true
	self._faqTables = {}
	self:initListView()
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)

				
end

function SettingLayer_FAQ:freshListData(faqTables)
	
	self._faqlistview:removeAllItems()
	
	for i,v in pairs(faqTables) do
		self:changeItem0(i-1,i)
	end
	
end
function SettingLayer_FAQ:initListView()
	self._faqlistview = ccui.ListView:create()
	self._faqlistview:setName("listview")
	self._faqlistview:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self._faqlistview:setAnchorPoint(0.5,0.5)
	self._faqlistview:setDirection(ccui.ScrollViewDir.vertical)
	self._faqlistview:setContentSize(cc.size(self.size.width, self.size.height*0.9))
	self._faqlistview:setBounceEnabled(true)
    self._faqlistview:setGravity(ccui.ListViewGravity.centerHorizontal)
    self._faqlistview:setItemsMargin(1.5)
	self._faqlistview:addEventListener(handler(self,self.listItemTouchListener))
	self:addChild(self._faqlistview)
	
end

function SettingLayer_FAQ:listItemTouchListener(ref,eventType)
	if eventType==ccui.ListViewEventType.ONSELECTEDITEM_END then
		if not self.canTouch then
			return
		end
		self.canTouch = false
		playSoundEffect("sound/effect/anniu")
		local curselectedIndex = self._faqlistview:getCurSelectedIndex()
		local selectedItem = self._faqlistview:getItem(curselectedIndex)
		if isLuaNodeValid(selectedItem) then
			
			local removeOld = false
			local tempTag1 = nil
			if self.lastSelectItem>=0 then
				tempTag1 = self._faqlistview:getItem(self.lastSelectItem):getTag()
				removeOld = true
				
			end
			if self.lastSelectItem == curselectedIndex then
				
				self:runAction(cc.CallFunc:create(function ()
					local flag = tonumber(selectedItem:getName())
					flag = flag*-1
					if flag>0 then
						self:changeItem0(self.lastSelectItem,tempTag1)
					else
						self:changeItem1(self.lastSelectItem,tempTag1)
					end
					
				end))
				return
			end
			
			local tempTag2 = selectedItem:getTag()
			--这儿不能直接删除，下一帧删除
			self:runAction(cc.CallFunc:create(function ()
				if removeOld then
					self:changeItem0(self.lastSelectItem,tempTag1)
				end
				
				self:changeItem1(curselectedIndex,tempTag2)
				self.lastSelectItem = tempTag2-1
				
			end))
		end
	end
end
--设置item选项为只有问题
function SettingLayer_FAQ:changeItem0(index,tagid)
	local v = self._faqTables[tagid]
	local innerPos = self._faqlistview:getInnerContainerPosition()
	local innerSize = self._faqlistview:getInnerContainerSize()
	local listContentSize =  self._faqlistview:getContentSize()
	self._faqlistview:removeItem(tonumber(index))
	if v then
		local pLayerout = ccui.Layout:create()
        pLayerout:setPosition(0,0)
        pLayerout:setAnchorPoint(0,1)
		pLayerout:setTouchEnabled(true)
		pLayerout:setTag(tagid)
		pLayerout:setName("1")
        self._faqlistview:insertCustomItem(pLayerout,index)
		local Image_bg = ccui.ImageView:create()
		Image_bg:ignoreContentAdaptWithSize(false)
		Image_bg:loadTexture("setting_playmode_itembg.png",1)
		Image_bg:setTouchEnabled(false)
		Image_bg:setLayoutComponentEnabled(true)
		Image_bg:setName("Image_bg")
		Image_bg:setTag(67)
		Image_bg:setCascadeColorEnabled(true)
		Image_bg:setCascadeOpacityEnabled(true)
		Image_bg:setAnchorPoint(0.5000, 0.0000)
		Image_bg:setPosition(Image_bg:getContentSize().width/2,0)
		pLayerout:setContentSize(Image_bg:getContentSize())
		pLayerout:addChild(Image_bg)
		
		local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 36, glyphs = "CUSTOM" }
		
		local ttf2 = cc.Label:createWithTTF(tmpCfg2,string.ltrim(v[1]), cc.TEXT_ALIGNMENT_LEFT, self.size.width*0.8)
		--contenttable.content, "Helvetica", 30,self.size, cc.TEXT_ALIGNMENT_LEFT
		ttf2:setName("text")
		ttf2:setColor(cc.c3b(38,47,42))
		ttf2:setAnchorPoint(cc.p(0.0,0.5))
		--38.5000
	
		ttf2:setPosition(62.1264, Image_bg:getContentSize().height/2)
		Image_bg:addChild(ttf2)
	end
	self.canTouch = true
	local diffY2 = innerSize.height-listContentSize.height
	if diffY2==0 then
		return
	end
	local percent = (diffY2+innerPos.y)/diffY2*100
	self._faqlistview:jumpToPercentVertical(percent)
	
	
end
--设置item选项为问题和答案
function SettingLayer_FAQ:changeItem1(index,tagid)
	
	local innerPos = self._faqlistview:getInnerContainerPosition()
	local innerSize = self._faqlistview:getInnerContainerSize()
	local listContentSize =  self._faqlistview:getContentSize()
	
	self._faqlistview:removeItem(index)
	--self._faqlistview:removeItem(tonumber(index))
	local v = self._faqTables[tagid]
	local pLayerout = ccui.Layout:create()
    pLayerout:setPosition(0,0)
	pLayerout:setTouchEnabled(true)
    pLayerout:setAnchorPoint(0,0)
	pLayerout:setTag(tagid)
	pLayerout:setName("-1")
	self._faqlistview:insertCustomItem(pLayerout,index)
	local Image_bg = ccui.ImageView:create()
	Image_bg:ignoreContentAdaptWithSize(false)
	Image_bg:loadTexture("setting_playmode_itembg2.png",1)
	Image_bg:setTouchEnabled(false)
	Image_bg:setScale9Enabled(true)
	Image_bg:setCapInsets({x = 316, y = 106, width = 328, height = 88})
	Image_bg:setLayoutComponentEnabled(true)
	Image_bg:setName("Image_bg")
	Image_bg:setTag(67)
	Image_bg:setCascadeColorEnabled(true)
	Image_bg:setCascadeOpacityEnabled(true)
	Image_bg:setAnchorPoint(0.5000, 0.0000)

	pLayerout:addChild(Image_bg)
		
	local tmpCfg2 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 36, glyphs = "CUSTOM" }
	
	local ttf2 = cc.Label:createWithTTF(tmpCfg2,string.ltrim(v[1]), cc.TEXT_ALIGNMENT_LEFT, self.size.width*0.8)
	--contenttable.content, "Helvetica", 30,self.size, cc.TEXT_ALIGNMENT_LEFT
	ttf2:setName("text")
	ttf2:setColor(cc.c3b(38,47,42))
	ttf2:setAnchorPoint(cc.p(0.0,0.5))
	
	
	Image_bg:addChild(ttf2)
	local tmpCfg3 = { fontFilePath = "FZZhengHeiS-B-GB.ttf", fontSize = 36, glyphs = "CUSTOM" }
	local ttf3 = cc.Label:createWithTTF(tmpCfg3,string.ltrim(v[2]), cc.TEXT_ALIGNMENT_LEFT, self.size.width*0.8)
	--contenttable.content, "Helvetica", 30,self.size, cc.TEXT_ALIGNMENT_LEFT
	ttf3:setName("text2")
	ttf3:setColor(cc.c3b(38,47,42))
	ttf3:setAnchorPoint(cc.p(0.0,1.0))
	
	
	local diffY = ttf3:getContentSize().height - ttf2:getContentSize().height
	
	--print("diffY",diffY)
	ttf2:setPosition(62.1264, 200.25+diffY)
	ttf3:setPosition(62.1264, 110.59+diffY)
	local imgoldSize = Image_bg:getContentSize()
	Image_bg:setContentSize(cc.size(imgoldSize.width,imgoldSize.height+diffY))
	Image_bg:setPosition(Image_bg:getContentSize().width/2,0)
	pLayerout:setContentSize(Image_bg:getContentSize())
	
	Image_bg:addChild(ttf3)
	self.canTouch = true
	local diffY2 = innerSize.height-listContentSize.height
	
	if diffY2==0 then
		return
	end
	
	local percent = (diffY2+innerPos.y)/diffY2*100
	
	self._faqlistview:jumpToPercentVertical(percent)
	
end

function SettingLayer_FAQ:eventComponent()
	return SettingCfg.innerEventComponent
end
function SettingLayer_FAQ:onEnter()
	
	local eventName = SettingCfg.getEventByCid(self.cid)
	print("addEventListener",eventName)
	--注册cid响应回调
	self:eventComponent():addEventListener(eventName,handler(self,self.freshFAQ))
	
end

function SettingLayer_FAQ:onExit()
	local eventName = SettingCfg.getEventByCid(self.cid)
	if self:eventComponent() then
		self:eventComponent():removeEventListener(eventName,handler(self,self.freshFAQ))
	end
	--退出的时候取消cid回调绑定
	print("SettingLayer_FAQ onExit",self.cid)
	SettingProxy:cancelProtocol(self.cid)
--[[	self:removeAllChildren()
	self._faqlistview = nil--]]
	
	if self._faqTables and type(self._faqTables)=="table" then
		removeAll(self._faqTables)
	end
end

function SettingLayer_FAQ:freshFAQ(event)
	print("SettingLayer_FAQ:freshFAQ")
	local eventName = SettingCfg.getEventByCid(self.cid)
	local contenttable = DataCenter:getData(eventName)
	
	if not contenttable or not contenttable.content then
		
		return
	end
	
	local faqTables = {}
	local faqvec = string.split(contenttable.content,"$$")
	if faqvec and table.getn(faqvec)>0 then
		for i,v in pairs(faqvec) do
			local group = string.split(v,"$")
			if group and table.getn(group)>=2 then
				local groups = {group[1],group[2]}
				table.insert(faqTables,groups)
				
			end
		end
	end
	--dump(faqTables)
	self._faqTables = faqTables
	self:freshListData(faqTables)
	
end

return SettingLayer_FAQ