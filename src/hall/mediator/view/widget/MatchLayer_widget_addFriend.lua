-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.09.13
-- Last: 
-- Content:  比赛界面中的添加好友界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local MatchLayer_widget_addFriend = class("MatchLayer_widget_addFriend",ccui.Layout)

local MatchLayer_Face2Face = require("hall.mediator.view.MatchLayer_Face2Face")

local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge"):create()

function MatchLayer_widget_addFriend:ctor(size)
	self.size = size
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	
	self:init()
	self:initView()
end

function MatchLayer_widget_addFriend:init()
	print("MatchLayer_widget_addFriend:init")
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
	self.addfriend = require("csb.hall.match.MatchLayer_widget_addFriend"):create().root
	FixUIUtils.setRootNodewithFIXED(self.addfriend)
	local panel1 = self.addfriend:getChildByName("Panel_1")
		
	FixUIUtils.stretchUI(panel1)
	self:addChild(self.addfriend,1)
		
	

	ccui.Helper:seekWidgetByName(panel1,"Image_weixin"):addTouchEventListener(handler(self,self.touchListener))
	ccui.Helper:seekWidgetByName(panel1,"Image_addf"):addTouchEventListener(handler(self,self.touchListener))
end 

function MatchLayer_widget_addFriend:initView(...)
	local panel1 = self.addfriend:getChildByName("Panel_1")
	ccui.Helper:seekWidgetByName(panel1,"Text_weixin1"):setString(i18n:get('str_match','match_winxin_title'))
	ccui.Helper:seekWidgetByName(panel1,"Text_weixin2"):setString(i18n:get('str_match','match_winxin_content'))
	ccui.Helper:seekWidgetByName(panel1,"Text_addf1"):setString(i18n:get('str_match','match_face_title'))
	ccui.Helper:seekWidgetByName(panel1,"Text_addf2"):setString(i18n:get('str_match','match_face_content'))
	ccui.Helper:seekWidgetByName(panel1,"Text_how_title"):setString(i18n:get('str_match','match_how_title'))
	ccui.Helper:seekWidgetByName(panel1,"Text_how_content"):setString(i18n:get('str_match','match_how_content'))
	
end

--刷新内容
function MatchLayer_widget_addFriend:freshContent(content)
	
	
end


function MatchLayer_widget_addFriend:eventComponent()
	
end

function MatchLayer_widget_addFriend:onEnter()
	

	
end

function MatchLayer_widget_addFriend:touchListener(ref,eventType)
	if not ref then
		return
	end
	if eventType==ccui.TouchEventType.ended then
		local name = ref:getName()
		playSoundEffect("sound/effect/anniu")
		if name == "Image_weixin" then
		--发送微信分享
			print("微信分享")
			LuaWxShareNativeBridge:callNativeShareByUrl(
				2,
				wwConst.CLIENTNAME,
				i18n:get("str_common", "comm_ShareContent"),
				wwURLConfig.SHARE_DOWNLOAD_URL, 
				"aa")
		elseif name == "Image_addf" then
		--面对面加好友
			print("面对面加好友")
			local face2face = MatchLayer_Face2Face:create()
			face2face:bindChangeCard(handler(self,self.changeCard))
			
			cc.Director:getInstance():getRunningScene():addChild(face2face,5)
		end
	end
	
	
	
end
--打开选项卡
function MatchLayer_widget_addFriend:changeCard()
	if self.cbFun then
		self.cbFun(1)
	end
end
function MatchLayer_widget_addFriend:bindChangeCard(cbFun)
	self.cbFun = cbFun
end

function MatchLayer_widget_addFriend:onExit()
	
	
end
function MatchLayer_widget_addFriend:active()
	print("MatchLayer_widget_addFriend active")
end

return MatchLayer_widget_addFriend