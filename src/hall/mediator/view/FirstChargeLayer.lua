-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  cruelogre
-- Date:    2016.11.22
-- Last: 
-- Content:  房间聊天界面
-- v1.1 添加清空播放数据，经典房结算和私人房结算的时候关闭当前界面
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------
local FirstChargeLayer = class("FirstChargeLayer",require("app.views.uibase.PopWindowBase"))

local StoreProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_StoreProxy)

local FirstChargeLayer_Content = require("csb.hall.firstCharge.FirstChargeLayer_Content")
local Node_firstCharge = require("csb.hall.firstCharge.Node_firstCharge")

local FirstChargeCfg = require("hall.mediator.cfg.FirstChargeCfg")
local HallCfg = require("hall.mediator.cfg.HallCfg")

local Store_TypeSwitch = require("hall.mediator.view.widget.Store_TypeSwitch")
local StoreCfg = require("hall.mediator.cfg.StoreCfg")
local ChargeProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ChargeProxy)

--@key MatchID 比赛ID
--@key GamePlayID 对局ID
--@key InviteRoomID 私人房ID
function FirstChargeLayer:ctor(param)
	FirstChargeLayer.super.ctor(self)	
	
	self.hallHandlers = {}
	local node = FirstChargeLayer_Content:create().root
	FixUIUtils.setRootNodewithFIXED(node)
	
	self:addChild(node)
	
	self.imgId = node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	self:init()

	self._firstChargeData = nil
	
	self:setDisCallback(function ( ... )
		-- body
		FSRegistryManager:currentFSM():trigger("back")
	end)
	
	self:popIn(self.imgId,Pop_Dir.Right)
	
end
function FirstChargeLayer:init()
	self.btnBuy = ccui.Helper:seekWidgetByName(self.imgId,"Button_buy")
	self.btnBuy:addTouchEventListener(handler(self,self.touchEventListener))
	self.btnBuy:setTitleText(string.format(i18n:get('str_firstcharge','btn_buy'),0))
	self.btnBuy:setBright(false)
	self.listView = ccui.Helper:seekWidgetByName(self.imgId,"ListView_award")
	self.listView:setScrollBarEnabled(false)
	self.originSize = self.listView:getContentSize()
end
--刷新界面
function FirstChargeLayer:reloadData(event)
	local firstChargeData = event._userdata
	if not firstChargeData or not next(firstChargeData) or 
		not firstChargeData.MCountTables or not next(firstChargeData.MCountTables) then
		wwlog(self.logTag,"首充数据读取失败")
		return
	end

	self._firstChargeData = firstChargeData

	--刷新物品表
	self.listView:removeAllItems()
	local awardLists = firstChargeData.MCountTables[1].Magics
	local listWidth  = 0
	for _,awardItem in pairs(awardLists) do
		
		local custom_head = Node_firstCharge:create().root
        local Imgbg = custom_head:getChildByName("Image_bg")
        custom_head:setContentSize(Imgbg:getContentSize())
		
		
		local imgIcon = ccui.Helper:seekWidgetByName(Imgbg,"Image_icon")
		local txtAmont = ccui.Helper:seekWidgetByName(Imgbg,"Text_amont")
		if awardItem.MagicFID==10170998 or awardItem.MagicFID==20010993 then --金币和钻石的显示方式
		
			txtAmont:setString(string.format("%s%s",ToolCom.splitNumFix(awardItem.MagicCount),awardItem.MagicName))
		else
			txtAmont:setString(string.format("%sx%d",awardItem.MagicName,awardItem.MagicCount))
		end
		
		local goodsrc = getGoodsSrcByFid(awardItem.MagicFID)
		if goodsrc and cc.FileUtils:getInstance():isFileExist(goodsrc) then
			imgIcon:setVisible(true)
			imgIcon:loadTexture(goodsrc)
		end
		
		
		
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(custom_head:getContentSize())
       -- custom_head:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height/2 ))
        custom_item:addChild(custom_head)
		--Text_signup
		listWidth = listWidth + Imgbg:getContentSize().width +self.listView:getItemsMargin()
        self.listView:pushBackCustomItem(custom_item)
		
		
		
	end
	if self.originSize.width>=listWidth then
		self.listView:setContentSize(cc.size(listWidth,self.originSize.height))
	end
	--刷新价格
	local priceItem = firstChargeData.Items[1]
	self.btnBuy:setTitleText(string.format(i18n:get('str_firstcharge','btn_buy'),priceItem.Money/100))
	self.btnBuy:setBright(true)
	
end

function FirstChargeLayer:onEnter()
	FirstChargeLayer.super.onEnter(self)
	wwlog(self.logTag,"FirstChargeLayer onEnter")
	
	if self:hallEventComponent() then
		local _ = nil
		_,self.hallHandlers[#self.hallHandlers+1] = self:hallEventComponent():addEventListener(
		HallCfg.InnerEvents.HALL_EVENT_FIRSTCHARGE_CONTENT,handler(self,self.reloadData))
	end
	StoreProxy:requestFirstChargeInfo()
	--self:reloadData()
end


function FirstChargeLayer:onExit()
	wwlog(self.logTag,"FirstChargeLayer onExit")
	if self:hallEventComponent() then
		for _,v in pairs(self.hallHandlers) do
			self:hallEventComponent():removeEventListener(v)
		end
	end
	self:removeAllChildren()
	FirstChargeLayer.super.onExit(self)
	
end

function FirstChargeLayer:touchEventListener(ref,eventType)
	if not ref or not ref:isBright() then
		return
	end

	--print("eventType",eventType)
	if eventType==ccui.TouchEventType.ended then
	
		playSoundEffect("sound/effect/anniu")
		
		if ref:getName()=="Button_buy" then
			print("显示支付方式界面")

			wwdump(self._firstChargeData)

			--调用支付流程
			local tCellData = {}
			-- tCellData.magicCount = 1
			tCellData.Name = self._firstChargeData.Items[1].Name
			tCellData.Money = tostring(self._firstChargeData.Items[1].Money)

			local unitInfo = i18n:get("str_common", "yuan")
	
			StoreProxy:setBuycellDatas(tCellData, unitInfo)   --记录购买的数据,顺便记录下支付方式

			local Store_TypeSwitch_node = Store_TypeSwitch:create((self._firstChargeData.Items or {}), 
					StoreCfg.ShopType.STORE_OTHER, 
					handler(self, self.chagrgeSwitchCallBack), 
					true
				)
			self:addChild(Store_TypeSwitch_node, 2)
		end
		
	end
	

end

function FirstChargeLayer:chagrgeSwitchCallBack(nIndex)

	wwlog(self.logTag, "FirstChargeLayer chagrgeSwitchCallBack " .. nIndex )

	--调用购买流程
	
	local sceneID 
	if wwCsvCfg.csvTable.StatisticalReport["FirstCharge"] then
		sceneID = wwCsvCfg.csvTable.StatisticalReport["FirstCharge"].SceneID..'001' --如果取不到SceneID则设置为默认的
	end

	ChargeProxy:requestOrder(self._firstChargeData, nIndex, sceneID or wwConfigData.CHARGE_STATUE_DEFAULT)

	self:close()
end

function FirstChargeLayer:hallEventComponent()
	return HallCfg.innerEventComponent
end
return FirstChargeLayer