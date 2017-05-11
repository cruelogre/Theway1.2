-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2017.1.5
-- Last: 
-- Content:  锦旗结算界面
-- Modify:	
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local GDSettleBaseLayer = class("GDSettleBaseLayer",require("app.views.uibase.PopWindowBase"))

local ChooseRoomProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_CHOORSERM)
local WhippedEggSceneProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().WHIPPEDEGG_SCENE)
local HallCfg = require("hall.mediator.cfg.HallCfg")
local BankruptLayer = require("app.views.customwidget.BankruptLayer")
local WWHeadSprite = require("app.views.customwidget.WWHeadSprite")

function GDSettleBaseLayer:ctor()
	GDSettleBaseLayer.super.ctor(self,false)
	self.canCancel = false --结算界面不响应返回键
	self:setOpacity(200)
end

function GDSettleBaseLayer:onTouchBegin(touch,event)
    if event:getEventCode() == cc.EventCode.BEGAN then
        return true
    elseif event:getEventCode() == cc.EventCode.ENDED then
        --忽略
		--self:close()
    end
end
function GDSettleBaseLayer:onExit()
	self:unscheduleScript()
	self:removeAllChildren()
	GDSettleBaseLayer.super.onExit(self)
end

function GDSettleBaseLayer:unscheduleScript( ... )
	-- body
end
function GDSettleBaseLayer:showBankrupt( butType,leftTime )
	-- body
	wwlog("GDSettleBaseLayer.lua","检测是否破产")
	local enterTime = os.time()
	local layerType = false
	local roomData = ChooseRoomProxy:getRoomData(WhippedEggSceneProxy.gamezoneid)
	local myCash = tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash"))
	if  DataCenter:getUserdataInstance():getValueByKey("bankrupt") and myCash < HallCfg.bankRuptLimit then
		wwlog("GDSettleBaseLayer.lua","有破产标志")
		layerType = 2
	elseif roomData and roomData.FortuneMin > tonumber(myCash) then
		wwlog("GDSettleBaseLayer.lua","金币不足弹出的破产界面 房间的最低金币：%d，我的金币数量：%d",roomData.FortuneMin,tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")))
		layerType = 1
	end
	if not layerType then
		return false
	end
	local para = {}		
	para.layerType = layerType  --界面类型  1金币不足 2 破产
	if roomData then
		para.money = tonumber(roomData.FortuneMin) - tonumber(myCash)
	end
	para.sceneTag = 2 --在哪个场景
	para.upCloseOnClick = false
	para.upCallback = function ()
		--购买金币  打开商城
		self.isTopLayer = false

		local sIDKey 
		if para.layerType == 1 then --金币不足
			sIDKey = "GoldEnough"
		elseif para.layerType == 2 then --破产 then --破产
			sIDKey = "Bankrupt"
		end
		
		FSRegistryManager:currentFSM():trigger("store", 
		{parentNode=display.getRunningScene(), zorder=zorderLayer.BankruptLayer,store_openType=2, sceneIDKey = sIDKey})
			
	end --上面按钮响应
	para.downCloseOnClick = false --下边的按钮点击不自动关闭
    para.downCallback = function ()
		
		if para.layerType==2 then
			HallSceneProxy:requestBankruptAward()
		elseif para.layerType==1 then
			GameManageFactory:getCurGameManage():exitGame()
		end
	end --下面按钮响应
	
	local bankrupt = BankruptLayer:create(para)
	bankrupt:setOpacity(156)
	bankrupt:bindCloseFun(function ()
		self.isTopLayer = false
		if roomData and roomData.FortuneMin <= tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")) then
			local curTime = os.time() 
			if butType == 1 and curTime - enterTime <= leftTime then
				self:close()
				GameManageFactory:getCurGameManage():continueGame()
			else
				self:close()
				GameManageFactory:getCurGameManage():changeDesk()
			end
		else
			self:close()
			GameManageFactory:getCurGameManage():exitGame()
		end
	end)
	bankrupt:show(zorderLayer.BankruptLayer)

	return true
end

function GDSettleBaseLayer:addHead(headNode,Gender, iconid, userid)
	-- body
	local fileName = DataCenter:getUserdataInstance():getHeadIconByGender(Gender)
	if headNode:getChildByName("WWHeadSprite") then
		headNode:removeChildByName("WWHeadSprite")
	end

	local param = {
		headFile=fileName,
		maskFile="",
		headType=2,
		radius=60,
		width = headNode:getContentSize().width,
		height = headNode:getContentSize().height,
		headIconType = iconid,
		userID = userid
	}
	local HeadSprite = WWHeadSprite:create(param)
	local clippingNode = createClippingNode("guandan_head_robot.png",HeadSprite,
		cc.p(headNode:getContentSize().width/2,headNode:getContentSize().height/2))
	clippingNode:setName("WWHeadSprite")
	headNode:addChild(clippingNode,1)
end

return GDSettleBaseLayer