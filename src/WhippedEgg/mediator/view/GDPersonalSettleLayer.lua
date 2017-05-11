-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.5
-- Last: 
-- Content:  锦旗结算界面
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDPersonalSettleLayer = class("GDPersonalSettleLayer",require("WhippedEgg.mediator.view.GDSettleBaseLayer"))
local WWItemSprite = require("app.views.customwidget.WWItemSprite")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local BankruptLayer = require("app.views.customwidget.BankruptLayer")
local HallSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_SCENE)
local ChooseRoomProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_CHOORSERM)
local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge")
local proxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().SiRenRoomProxy)
local request = require("hall.request.SiRenRoomRequest")
local HallCfg = require("hall.mediator.cfg.HallCfg")

function GDPersonalSettleLayer:ctor(param)
	GDPersonalSettleLayer.super.ctor(self)
	self:init(param)
	self:setDisCallback(function ( ... )
		-- body
		
		FSRegistryManager:currentFSM():trigger("back")
	end)
end

function GDPersonalSettleLayer:init(param)
	local personSettleLayer = require("csb.guandan.GDPersonSettleLayer"):create()
	if not personSettleLayer then
		return
	end
	self.personSettleLayerRoot = personSettleLayer["root"]
	self.personSettleLayerAni = personSettleLayer["animation"]
	FixUIUtils.setRootNodewithFIXED(self.personSettleLayerRoot)
	self.personSettleLayerRoot:runAction(self.personSettleLayerAni)
	
  	self:addChild(self.personSettleLayerRoot)
	local Image_listbg = self.personSettleLayerRoot:getChildByName("Image_listbg")
	self.listViewPersonal = Image_listbg:getChildByName("ListView_content")
	self.personalBtnBack = self.personSettleLayerRoot:getChildByName("Button_back")
	self.personalBtnShare = self.personSettleLayerRoot:getChildByName("Button_share")
	self.personalBtnContinue = self.personSettleLayerRoot:getChildByName("Button_continue")
	self.personalBtnBack:addClickEventListener(handler(self,self.btnClick))
  	self.personalBtnShare:addClickEventListener(handler(self,self.btnClick))
	self.personalBtnContinue:addClickEventListener(handler(self,self.btnClick))
	self:personalEnd(param.info)
end


--私人房打完结算
function GDPersonalSettleLayer:personalEnd( info )
	-- body
	self.personSettleLayerRoot:setVisible(true)
	self.personSettleLayerAni:play("animation0",false)
	self.listViewPersonal:removeAllItems()
	local WhippedEggSceneController = ControllerMgr:retrieveController(ControllerMgr:getControllerRegistry().WHIPPEDEGG_SCENE)

	for k,v in pairs(info) do	
		local itemNode = require("csb.guandan.GDPersonListItem"):create()
		local custom_head = itemNode.root
		local Image_master = custom_head:getChildByName("Image_master")--是否房主
		local Text_username = custom_head:getChildByName("Text_username") --名字
		local Image_wintag = custom_head:getChildByName("Image_wintag") --输赢
		local Text_count = custom_head:getChildByName("Text_count") --局数
		local Text_winrate = custom_head:getChildByName("Text_winrate")--胜率
		local Text_fist = custom_head:getChildByName("Text_fist")--头油
		local Text_sixbomb = custom_head:getChildByName("Text_sixbomb")--6炸
		local Text_ths = custom_head:getChildByName("Text_ths")--同花顺
		local Text_score = custom_head:getChildByName("Text_score")--积分

		if WhippedEggSceneController.MasterID == v.UserID then --房主
			Image_master:setVisible(true)
		else
			Image_master:setVisible(false)
		end
		Text_username:setString(subNickName(v.Nickname))
		if v.Score > 0 then
		 	Image_wintag:setVisible(true)
		else
		 	Image_wintag:setVisible(false)
		end
		Text_count:setString(v.Play.."")
		Text_winrate:setString(v.Winp.."%")
		Text_fist:setString(v.Rank1.."")
		Text_sixbomb:setString(v.Boom.."")
		Text_ths:setString(v.StrFlush.."")
		Text_score:setString(v.Score.."")

        custom_head:setContentSize(cc.size(1200,100))
       	local custom_item = ccui.Layout:create()
        custom_item:setContentSize(custom_head:getContentSize())
        custom_head:setPosition(cc.p(0, custom_item:getContentSize().height-60 ))
        custom_item:addChild(custom_head)
		self.listViewPersonal:pushBackCustomItem(custom_item)
	end
end


--按钮响应
function GDPersonalSettleLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref == self.personalBtnBack then --私人返回
		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
	elseif ref == self.personalBtnShare then --私人分享
		self.personalBtnBack:setVisible(false)
		self.personalBtnShare:setVisible(false)
		self.personalBtnContinue:setVisible(false)
		--截屏回调方法  
		 local function afterCaptured(succeed, outputFile)  
		    if succeed then  
		     	wwlog(self.logTag,"截屏分享成功%s",outputFile)
		     	LuaWxShareNativeBridge:create():callNativeShareByPhotos(outputFile,1)
		     	self.personalBtnBack:setVisible(true)
				self.personalBtnShare:setVisible(true)
				self.personalBtnContinue:setVisible(true)
		    else  
		        wwlog(self.logTag,"截屏分享失败")  
		    end  
		 end  
	  
	    local fileName = "SirenCaptureScreenTest.png"  
		fileName = ww.IPhoneTool:getInstance():getExternalFilesDir()..fileName
	    -- 截屏  
	    cc.utils:captureScreen(afterCaptured, fileName)  
	elseif ref == self.personalBtnContinue then --私人继续
    	local SiRenRoomCfg = require("hall.mediator.cfg.SiRenRoomCfg")
		local sirenData = DataCenter:getData(SiRenRoomCfg.InnerEvents.SIREN_ROOM_INFO)
		FSRegistryManager:setJumpState("siren",{ zorder=3,crType = 3 })
		self:close()
		WWFacade:dispatchCustomEvent(HALL_SCENE_EVENTS.MAIN_ENTRY)
		request.createRoom(proxy, sirenData.Playtype, sirenData.PlayData, sirenData.RoomCardCount, sirenData.DWinPoint, sirenData.MultipleData)
	end
end

function GDPersonalSettleLayer:onEnter()
	GDPersonalSettleLayer.super.onEnter(self)
	
end

function GDPersonalSettleLayer:onExit()
	print("GDPersonalSettleLayer onExit")
	--LoadingManager:endLoading()
	self:removeAllChildren()
	GDPersonalSettleLayer.super.onExit(self)
	
end


return GDPersonalSettleLayer