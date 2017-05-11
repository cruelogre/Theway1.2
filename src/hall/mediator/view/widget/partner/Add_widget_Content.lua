-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  添加好友页面控件
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local Add_widget_Content = class("Add_widget_Content",ccui.Layout,require("packages.mvc.Mediator"))

local AddFriendLayout = require("csb.hall.cardpartner.PartnerAddFriendLayout")

local Cardpartner_Face2Face = require("hall.mediator.view.widget.partner.Cardpartner_Face2Face")

local SocialContactProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SOCIALCONTACT)

local CardPartnerCfg = require("hall.mediator.cfg.CardPartnerCfg")

local Toast = require("app.views.common.Toast")

local UserDataCenter = DataCenter:getUserdataInstance()
local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge"):create()

function Add_widget_Content:ctor(size,param)
	self.size = size --显示尺寸
	self:setContentSize(size)
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setTouchEnabled(true)
	self.taskData = {}
	self.taskCount = 0
	self.handlers = {}
	self.logTag = self.__cname..".lua"
	param = param or {}
	self.userOrder = param.userOrder or 4
	self.jumpIndex = param.jumpIndex or 3 --默认有个跳转的索引值
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
end


function Add_widget_Content:initView()
	wwlog(self.logTag,"Add_widget_Content:initView")
	local rootNodeBundle = AddFriendLayout:create()
	if not rootNodeBundle.root then
		return
	end
	self:addChild(rootNodeBundle.root,1)
	FixUIUtils.setRootNodewithFIXED(rootNodeBundle.root)
	self.rootWidget = rootNodeBundle.root:getChildByName("Panel_1")
	FixUIUtils.stretchUI(self.rootWidget)
	self:initEditBox(ccui.Helper:seekWidgetByName(self.rootWidget,"Image_input"))
	
	ccui.Helper:seekWidgetByName(self.rootWidget,"Image_weixin"):addTouchEventListener(handler(self,self.touchEventListener))
	ccui.Helper:seekWidgetByName(self.rootWidget,"Image_addf"):addTouchEventListener(handler(self,self.touchEventListener))
	ccui.Helper:seekWidgetByName(self.rootWidget,"Text_myid"):setString(
		string.format(i18n:get('str_cardpartner','partner_my_id'),tostring(UserDataCenter:getValueByKey("userid"))))
end
function Add_widget_Content:initEditBox(inputWidget)
	
	local bgSize = inputWidget:getContentSize()

	ccui.Helper:seekWidgetByName(inputWidget,"Button_search"):addTouchEventListener(handler(self,self.touchEventListener))
	--TextField_id
	local textField = ccui.Helper:seekWidgetByName(inputWidget,"TextField_id")
	--Button_send
	local fieldSize =cc.size(616,86)
	
	self.sendEditBox= ccui.EditBox:create(fieldSize, "cp_addfriend_edit.png",1)  --输入框尺寸，背景图片
	self.sendEditBox:setPosition(cc.p(textField:getPositionX()+fieldSize.width/2, textField:getPositionY()))
	self.sendEditBox:setAnchorPoint(cc.p(0.5,0.5))
	self.sendEditBox:setFontSize(36)
	self.sendEditBox:setPlaceholderFontSize(36)
	self.sendEditBox:setPlaceholderFontName("Arial")
	self.sendEditBox:setFontColor(cc.c3b(0x4e,0x43,0x27))
	--self.sendEditBox:setMaxLength(RoomChatCfg.characterMaxCount)
	self.sendEditBox:setPlaceHolder(i18n:get('str_cardpartner','partner_search_placeholder'))
	self.sendEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) --输入键盘返回类型，done，send，go等
	self.sendEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC) --输入模型，如整数类型，URL，电话号码等，会检测是否符合\
	self.sendEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_SENTENCE)
	self.sendEditBox:registerScriptEditBoxHandler(handler(self,self.editboxHandle))
	inputWidget:addChild(self.sendEditBox)
	textField:removeFromParent()
end
function Add_widget_Content:editboxHandle(strEventName,sender)
	
	if strEventName=="began" then
		--sender:selectedAll() --光标进入，选中全部内容
	elseif strEventName=="ended" then --当编辑框失去焦点并且键盘消失的时候被调用
		
	elseif strEventName=="return" then -- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		
	elseif strEventName=="changed" then
		
	end
end
function Add_widget_Content:onEnter()
	wwlog(self.logTag,"Add_widget_Content:onEnter")
	self:registerEventListener(
		CardPartnerCfg.InnerEvents.CP_EVENT_SEARCH_OK,handler(self,self.proxyOK))
end


function Add_widget_Content:onExit()
	
	wwlog(self.logTag,"Add_widget_Content:onExit")
	if isLuaNodeValid(self.actWevView) then
		self.actWevView:removeFromParent()
	end


	self:unregisterEventListener(CardPartnerCfg.InnerEvents.CP_EVENT_SEARCH_OK)

end

function Add_widget_Content:active()
	self:initView()
end

function Add_widget_Content:proxyOK(event)
	local name = event._eventName
	local data = unpack(event._userdata or {})
	local userOrder = self.userOrder or 4
	
	if name==CardPartnerCfg.InnerEvents.CP_EVENT_SEARCH_OK then --搜索OK了
		FSRegistryManager:currentFSM():trigger("userinfo",
		{parentNode = display.getRunningScene(), zorder = userOrder,userid = tonumber(data.kReason)})
	end
end

function Add_widget_Content:touchEventListener(ref,eventType)
	
	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_search" then --搜索好友
			wwlog(self.logTag,"搜索好友")
			local searchid = self.sendEditBox:getText()
			if string.len(searchid)>0 then
				print("search user id",searchid)
				SocialContactProxy:searchBuddy(tonumber(searchid))
			else
				Toast:makeToast(i18n:get('str_cardpartner','partner_userid_empty'),0.8):show()
			end
			
		elseif ref:getName() == "Image_weixin" then --微信
			wwlog(self.logTag,"微信分享")
			
			LuaWxShareNativeBridge:callNativeShareByUrl(
			2, --邀请微信好友
			i18n:get("str_cardpartner", "wx_share_title"),
			string.format(i18n:get("str_cardpartner", "wx_share_content"),wwConst.CLIENTNAME,tostring(UserDataCenter:getValueByKey("userid"))),
			wwURLConfig.SHARE_DOWNLOAD_URL, 
			"aa")	
		elseif ref:getName() == "Image_addf" then --添加好友界面
			wwlog(self.logTag,"面对面好友界面")
			
			local face2face = Cardpartner_Face2Face:create() 
			face2face:bindChangeCard(handler(self,self.changeCard))
			cc.Director:getInstance():getRunningScene():addChild(face2face,5)
		end
		
	end
	

end
--绑定切换回调
function Add_widget_Content:bindChangeCard(cbFun)
	self.cbFun = cbFun
end

--搜索好友时间倒计时结束 搜到好友情况
function Add_widget_Content:changeCard()
	if self.cbFun then
		self.cbFun(self.jumpIndex)
	end
end

return Add_widget_Content