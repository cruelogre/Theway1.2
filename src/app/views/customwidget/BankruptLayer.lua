-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.21
-- Last: 
-- Content:  破产或者金币不足弹出界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

--[[
    local para = {}
    para.layerType = 1  --界面类型
    para.sceneTag = 1 --在哪个场景
	para.upCloseOnClick = false --是不是点击就关闭
    para.upCallback = handler(self, self.upHandler) --上面按钮响应
	para.downCloseOnClick = false --是不是点击就关闭
    para.downCallback = handler(self, self.downHandler) --下面按钮响应
  
   import(".BankruptLayer", "app.views.customwidget."):create( para ):show()

--]]
local BankruptLayer = class("BankruptLayer",require("app.views.uibase.PopWindowBase"))
local csbRuptLayer = require("csb.common.BankruptLayer2")

local layerType = {
	Layer_Gold = 1, --金币不足
	Layer_Bankrupt = 2, --破产
}
local SceneTag = {
	Scene_Hall = 1, --大厅
	Scene_WHIPPEDEGG = 2, --惯蛋游戏界面
}

function BankruptLayer:ctor(param)
	
	BankruptLayer.super.ctor(self,false)
	self:init(param)
	
end

function BankruptLayer:init(para)
	self.param = para
	if self.param.money then
		self.param.money = self.param.money < 0 and 0 or self.param.money
	else
		self.param.money = 0
	end
	
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
	self:setName("BankruptLayer")
	local csbNode = csbRuptLayer:create()
	if not csbNode then
		return
	end
	
	self.rootNode = csbNode.root
	self.rootAnimation = csbNode.animation
	self.rootNode:runAction(self.rootAnimation)
	self.rootAnimation:gotoFrameAndPause(0)
	self:addChild(self.rootNode)
	
	
	FixUIUtils.setRootNodewithFIXED(self.rootNode)
	
	self:setDisCallback(function ( ... )
		-- body
		if self._closeCB then
			self._closeCB()
			self._closeCB = nil
		end
		self:removeFromParent()
	end)
	self.headImg = self.rootNode:getChildByName("Image_head")
	self.bg1Img = self.rootNode:getChildByName("Image_bg1")
	self.bg2Img = self.rootNode:getChildByName("Image_bg2")
	
	self.rootNode:getChildByName("Image_text1"):ignoreContentAdaptWithSize(true)
	ccui.Helper:seekWidgetByName(self.headImg,"Image_text"):ignoreContentAdaptWithSize(true)
	
end

function BankruptLayer:bindCloseFun(closeCB)
	self._closeCB = closeCB
end
function BankruptLayer:onEnter()
	BankruptLayer.super.onEnter(self)
	self.rootNode:getChildByName("Image_text1"):loadTexture(self.param.layerType==layerType.Layer_Gold and
	 "common_bankrupt_title_gold.png" or "common_bankrupt_title_0.png" ,1)
	
	local is = self.param.layerType==layerType.Layer_Bankrupt
	--self.bg2Img:getChildByName("Image_1"):setVisible(is)
	ccui.Helper:seekWidgetByName(self.bg2Img,"Image_2"):setVisible(not is)
	if self.param.layerType == layerType.Layer_Gold then
		ccui.Helper:seekWidgetByName(self.headImg,"Image_text"):loadTexture(self.param.sceneTag == SceneTag.Scene_Hall and
			"common_bankrupt_img_title2.png" or "common_bankrupt_img_title1.png",1)
		ccui.Helper:seekWidgetByName(self.bg1Img,"Text_1"):setString(self.param.sceneTag == SceneTag.Scene_Hall and
			string.format(i18n:get('str_bankrupt','bankrupt_get_gold_1'),ToolCom.splitNumFix(self.param.money)) 
			or string.format(i18n:get('str_bankrupt','bankrupt_get_gold_2'),ToolCom.splitNumFix(self.param.money)))
			
		--Image_2
		ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(i18n:get('str_bankrupt','bankrupt_go_lower'))
		ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTitleText("")
		
	elseif self.param.layerType == layerType.Layer_Bankrupt then
		ccui.Helper:seekWidgetByName(self.headImg,"Image_text"):loadTexture("common_bankrupt_img_title1.png",1)
		ccui.Helper:seekWidgetByName(self.bg1Img,"Text_1"):setString(string.format(i18n:get('str_bankrupt','bankrupt_get_gold_2'),ToolCom.splitNumFix(self.param.money)))
		ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(i18n:get('str_bankrupt','bankrupt_get_charity'))
		--ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setBright(false)
		ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTitleText(i18n:get('str_bankrupt','bankrupt_get_now'))
		
		
		--破产的时候 如果 可以领取 领取次数大于0 并且时间到了
		if DataCenter:getUserdataInstance():getValueByKey("awardCount") > 0
		and os.time() > DataCenter:getUserdataInstance():getValueByKey("nextAwardTime") then
			
		elseif DataCenter:getUserdataInstance():getValueByKey("awardCount") > 0 then
		--领取次数还有  但是没到时间
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setBright(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTouchEnabled(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Image_time"):setVisible(true)
			self:runAction(cc.RepeatForever:create(
				cc.Sequence:create(
					cc.CallFunc:create(handler(self,self.timeTick)),
					cc.DelayTime:create(1.0)
				)))
--[[			local diff = DataCenter:getUserdataInstance():getValueByKey("nextAwardTime") - os.time()
			
			ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(secoundToTimeString(diff))--]]
			
		else
		--领取次数没有了 而且时间也没到
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTouchEnabled(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setVisible(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Image_btn_bg2"):setVisible(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(i18n:get('str_bankrupt','bankrupt_canot_get_count'))
		end
		
	end
	
	ccui.Helper:seekWidgetByName(self.bg1Img,"Button_store"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):addTouchEventListener(handler(self,self.touchListener))
	
end

function BankruptLayer:reLoadView()
		--破产的时候 如果 可以领取 领取次数大于0 并且时间到了
		if DataCenter:getUserdataInstance():getValueByKey("awardCount") > 0
		and os.time() >= DataCenter:getUserdataInstance():getValueByKey("nextAwardTime") then
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setBright(true)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTouchEnabled(true)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Image_time"):setVisible(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(i18n:get('str_bankrupt','bankrupt_get_charity'))
		elseif DataCenter:getUserdataInstance():getValueByKey("awardCount") > 0 then
		--领取次数还有  但是没到时间
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setBright(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTouchEnabled(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Image_time"):setVisible(true)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(i18n:get('str_bankrupt','bankrupt_get_charity'))
--[[			local diff = DataCenter:getUserdataInstance():getValueByKey("nextAwardTime") - os.time()
			
			ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(secoundToTimeString(diff))--]]
			
		else
		--领取次数没有了 而且时间也没到
			ccui.Helper:seekWidgetByName(self.bg2Img,"Image_time"):setVisible(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setTouchEnabled(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Button_go"):setVisible(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Image_btn_bg2"):setVisible(false)
			ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(i18n:get('str_bankrupt','bankrupt_canot_get_count'))
		end
end
function BankruptLayer:timeTick()
	
	local diff = DataCenter:getUserdataInstance():getValueByKey("nextAwardTime") - os.time()
	diff = math.max(diff,0)
	ccui.Helper:seekWidgetByName(self.bg2Img,"Text_2"):setString(secoundToTimeString3(diff))
	if diff==0 then
		self:stopAllActions()
		self:reLoadView()
	end
end

function BankruptLayer:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		if name=="Button_store" then
			if self.param.upCallback then
				if self.param.layerType==layerType.Layer_Bankrupt then
					UmengManager:eventCount("Bankruptcy")
				else
					UmengManager:eventCount("GoldLess")
				end

				self.param.upCallback()
				if self.param.upCloseOnClick then
					self:close()
				end
				
			end
		elseif name=="Button_go" then
			if self.param.downCallback then
				if self.param.layerType==layerType.Layer_Bankrupt then
					UmengManager:eventCount("GetAlms")
				else
					UmengManager:eventCount("GotoLowPlace")
				end
				
				self.param.downCallback()
				if self.param.downCloseOnClick then
					self:close()
				end
				
			end
		end
	end
	
end
function BankruptLayer:show(zorder)
	print("BankruptLayer:show")
	local showOrder = zorder or ww.topOrder
    self:addTo(display.getRunningScene(),showOrder)
	self.rootAnimation:play("animation0",false)
	self.rootAnimation:setAnimationEndCallFunc1("animation0",function ()
		self.rootAnimation:play("animation1",true)
	end)
end

function BankruptLayer:onExit()
	BankruptLayer.super.onExit(self)
	--[[cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_pListener)
	self.m_pListener = nil--]]
end

return BankruptLayer