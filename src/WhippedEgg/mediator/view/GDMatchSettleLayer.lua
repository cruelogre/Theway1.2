-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.5
-- Last: 
-- Content:  锦旗结算界面
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDMatchSettleLayer = class("GDMatchSettleLayer",require("WhippedEgg.mediator.view.GDSettleBaseLayer"))
local SimpleRichText = require("app.views.uibase.SimpleRichText")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")
local LuaWxShareNativeBridge = require("app.utilities.LuaWxShareNativeBridge")
local WWItemSprite = require("app.views.customwidget.WWItemSprite")
local WWNetSprite = require("app.views.customwidget.WWNetSprite")
local MatchCfg = require("hall.mediator.cfg.MatchCfg")

local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)

function GDMatchSettleLayer:ctor(param)
	GDMatchSettleLayer.super.ctor(self)
	self:init(param)
	self:setDisCallback(function ( ... )
		-- body
		
		FSRegistryManager:currentFSM():trigger("back")
	end)
end

function GDMatchSettleLayer:init(param)
  	--比赛结算
	local matchSettment = require("csb.guandan.MatchSettlement"):create()
	if not matchSettment then
		return
	end
	self.rootMatchSettment = matchSettment["root"]
	self.rootMatchSettmentAni = matchSettment["animation"]
	FixUIUtils.setRootNodewithFIXED(self.rootMatchSettment)
	FixUIUtils.stretchUI(self.rootMatchSettment:getChildByName("Image_15"))
	self:addChild(self.rootMatchSettment)
	self.rootMatchSettment:runAction(self.rootMatchSettmentAni)
	local ImageDi = self.rootMatchSettment:getChildByName("Image")
	self.SettmentTitle = ccui.Helper:seekWidgetByName(ImageDi,"titile")
	self.SettmentRank = ccui.Helper:seekWidgetByName(ImageDi,"rank")
	self.SettmentBack = ccui.Helper:seekWidgetByName(ImageDi,"back")
	self.SettmentShowoff = ccui.Helper:seekWidgetByName(ImageDi,"showoff")
	self.SettmentAward = ccui.Helper:seekWidgetByName(ImageDi,"Panel_award")
	self.SettmentChenghao = ccui.Helper:seekWidgetByName(ImageDi,"Panel_chenghao")
	self.SettmentAward:setVisible(false)
	self.SettmentChenghao:setVisible(false)
	self.SettmentBack:addClickEventListener(handler(self,self.btnClick))
	self.SettmentShowoff:addClickEventListener(handler(self,self.btnClick))
	self:settment(param.info)
end


--结算
function GDMatchSettleLayer:settment( info )
	-- body
	wwlog(self.logTag,"比赛结算")
	playSoundEffect("sound/effect/jiangzhuang")
  	self.rootMatchSettment:setVisible(true)
	self.rootMatchSettmentAni:play("animation0",false)
	self.rootMatchSettmentAni:setFrameEventCallFunc(function (frame)
		if info.awardlist and #info.awardlist > 0 then
	  		self.SettmentAward:setVisible(true)
			self.SettmentChenghao:setVisible(false)
			local Text_1_1 = self.SettmentAward:getChildByName("Text_1_1")
			local Panel_prize = self.SettmentAward:getChildByName("Panel_prize")
			Panel_prize:removeAllChildren()

			for k,v in pairs(info.awardlist) do
				local mRank = info.MRanking
				local matchid = WhippedEggSceneProxy.gamezoneid
				local fileName = false
				if mRank <= 3 then
					--fileName = string.format("hall/match/match_desc_prize%d.png",mRank)
					
				else
					--fileName = "common/common_prize_default.png"
				end
				fileName = "common/common_prize_default.png"
				local prize = WWItemSprite:createItem({
					id = v.FID,
					count = v.MagicCount,
					defaultSrc = fileName,
					remoteSrc = MatchCfg:getMatchImageURL(2,matchid,mRank),
					fontColor = cc.c3b(0x00,0x00,0x00),
				})
				--更新金币钻石
				updataGoods(v.FID,v.MagicCount)

				prize:setPosition(cc.p(prize:getContentSize().width*0.8 + (k-1)*prize:getContentSize().width,Text_1_1:getPositionY()+prize:getContentSize().height))
	  			Panel_prize:addChild(prize)
			end
	  	else
	  		self.SettmentAward:setVisible(false)
			self.SettmentChenghao:setVisible(true)
		end
	end)

	self.SettmentTitle:setString("")
 	self.SettmentTitle:removeAllChildren()
  	self.SettmentTitle:addChild(SimpleRichText:create(string.format(i18n:get('str_guandan','guandan_wait_settment'),
    DataCenter:getUserdataInstance():getValueByKey("nickname"),(info and info.name) or "蛙蛙游戏"),
  			self.SettmentTitle:getFontSize(),self.SettmentTitle:getTextColor()))

  	self.SettmentRank:setString(string.format(i18n:get('str_guandan','guandan_wait_settment_rank'),(info and info.MRanking) or 0))
end

--按钮响应
function GDMatchSettleLayer:btnClick( ref )
	-- body
    playSoundEffect("sound/effect/anniu")

	if ref:getName() == "back" then
		self:close()
		GameManageFactory:getCurGameManage():exitGame()
	elseif ref:getName() == "showoff" then
		self.SettmentBack:setVisible(false)
		self.SettmentShowoff:setVisible(false)

		--截屏回调方法  
		 local function afterCaptured(succeed, outputFile)  
		    if succeed then  
		     	wwlog(self.logTag,"截屏分享成功%s",outputFile)
		     	LuaWxShareNativeBridge:create():callNativeShareByPhotos(outputFile,1)
		     	self.SettmentBack:setVisible(true)
				self.SettmentShowoff:setVisible(true)
				-- GameManageFactory:getCurGameManage():exitGame()
		    else  
		        wwlog(self.logTag,"截屏分享失败")  
		    end  
		 end  
	  
	    local fileName = "CaptureScreenTest.png"  
		fileName = ww.IPhoneTool:getInstance():getExternalFilesDir()..fileName
	    -- 截屏  
	    cc.utils:captureScreen(afterCaptured, fileName)  
	end
end


function GDMatchSettleLayer:onEnter()
	GDMatchSettleLayer.super.onEnter(self)
	
end

function GDMatchSettleLayer:onExit()
	print("GDMatchSettleLayer onExit")
	--LoadingManager:endLoading()
	self:removeAllChildren()
	GDMatchSettleLayer.super.onExit(self)
	
end


return GDMatchSettleLayer