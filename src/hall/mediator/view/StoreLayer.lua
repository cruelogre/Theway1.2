local StoreLayer = class("StoreLayer",
	require("app.views.uibase.PopWindowBase"),
	require("packages.mvc.Mediator"))

local StoreProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_StoreProxy)

local StoreCfg = require("hall.mediator.cfg.StoreCfg")

local Store_Shoplist = require("hall.mediator.view.widget.Store_Shoplist")
local Store_Proplist = require("hall.mediator.view.widget.Store_PropList")
local Store_TypeSwitch = require("hall.mediator.view.widget.Store_TypeSwitch")

--store_openType 打开页面的ID 1 2 3 4
function StoreLayer:ctor(param)
	wwdump(param, "StoreLayer:ctor")
	StoreLayer.super.ctor(self)
	self:init()
	self.handles = {}
	-- self.param = param --状态机打开后，传过来的参数
	self.store_openType = param.store_openType --状态机打开后，传过来的参数

	local sceneID

	if param.sceneIDKey then
		sceneID = wwCsvCfg.csvTable.StatisticalReport[param.sceneIDKey].SceneID or wwConfigData.CHARGE_STATUE_DEFAULT --如果取不到SceneID则设置为默认的
	else
		if StoreCfg.SceneID == 0 then
			sceneID = wwConfigData.CHARGE_STATUE_DEFAULT --如果取不到SceneID则设置为默认的
		else
			sceneID = StoreCfg.SceneID --如果是场景状态机存在，则获取状态对象中判断的值
		end
	end

	StoreProxy:setChargeSceneID(sceneID) --状态机打开后，传过来的场景ID，存到Store的委托里面，充值的时候用到

	-- wwlog(self.logTag, "接收到的打开商城状态:%d", self.store_openType)
--[[	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)--]]
end

function StoreLayer:init()
	print("StoreLayer init")
	self.logTag = "StoreLayer.lua"

	self.FirstMenuId = 0  --当前选择的一级菜单ID
	self.InitFirstMenuId = 0  --初始化获取的第一条数据的MenuID
	self.secondMenuId = 0  --默认二级菜单的ID，默认第一个，或选择支付后缓存
	self.tabSwitchTag = StoreCfg.ShopType.STORE_DIAMOND

	self.node = require("csb.hall.store.StoreLayer"):create().root
	
	FixUIUtils.stretchUI(self.node)
	FixUIUtils.setRootNodewithFIXED(self.node)
	self:addChild(self.node)
	
	--testing
	self:setDisCallback(function ( ... )
		-- body
		self:removeListener()
		FSRegistryManager:currentFSM():trigger("back")
	end)
	self.imgId = self.node:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	--FixUIUtils.stretchUI(self.imgId)
	
	self:popIn(self.imgId,Pop_Dir.Right)

	self.Image_choosetag = ccui.Helper:seekWidgetByName(self.imgId,"Image_choosetag")

	self.Panel_Diamond = ccui.Helper:seekWidgetByName(self.imgId,"Panel_Diamond")
	self.Panel_Gold = ccui.Helper:seekWidgetByName(self.imgId,"Panel_Gold")
	self.Panel_VIP = ccui.Helper:seekWidgetByName(self.imgId,"Panel_VIP")
	self.Panel_Prop = ccui.Helper:seekWidgetByName(self.imgId,"Panel_Prop")

	self.Panel_assets = ccui.Helper:seekWidgetByName(self.imgId,"Panel_assets")
	self.Text_gold = ccui.Helper:seekWidgetByName(self.Panel_assets,"Text_gold")
	self.Text_diamond = ccui.Helper:seekWidgetByName(self.Panel_assets,"Text_diamond")
	self.Image_switch = ccui.Helper:seekWidgetByName(self.Panel_assets,"Image_switch")
	self.Image_pay_type = ccui.Helper:seekWidgetByName(self.Image_switch,"Image_pay_type")
	self.Button_switch = ccui.Helper:seekWidgetByName(self.Image_switch,"Button_switch")

	self:addTouchTabMenu()

	--tableview的背景图
	self.tableViewBg = self.imgId:getChildByName("Image_content")
	self:createTableView()
end

function StoreLayer:createTableView()
	if self._tableviewNode then
		self.tableViewBg:removeAllChildren()
		self._tableviewNode = nil
	end
	self._tableviewNode = Store_Shoplist:create(self.tableViewBg, self.tabSwitchTag)
	self.tableViewBg:addChild(self._tableviewNode, 2)
end

function StoreLayer:createPropView()
	if self._tableviewNode then
		self._tableviewNode = nil
	end
	self._tableviewNode = Store_Proplist:create(self.tableViewBg, self.tabSwitchTag)
	self.tableViewBg:addChild(self._tableviewNode, 2)
end

function StoreLayer:onEnter()
	StoreLayer.super.onEnter(self)
	self:initViewData()
	self:registerListener()
	self:initLocalText()

	self:registerEventListener(StoreCfg.InnerEvents.STORE_EVENT_OPENCHARGETYPE, handler(self, self.openChargeSwitch))
end
function StoreLayer:onExit()
	StoreLayer.super.onExit(self)
	self:unregisterScriptHandler()
	self:removeListener()
	self:unregisterEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO)
	self:unregisterEventListener(StoreCfg.InnerEvents.STORE_EVENT_OPENCHARGETYPE)
end
function StoreLayer:removeListener()
	if StoreCfg.innerEventComponent and self.handles then
		for _,handle in pairs(self.handles) do
			StoreCfg.innerEventComponent:removeEventListener(handle)
		end
		
	end
	removeAll(self.handles)
end
function StoreLayer:initViewData()
	StoreProxy:requestDiamond()
	self.srcCell = StoreProxy:getChooseChargeTypeSrc() --读取支付方式缓存

	if self.store_openType == 2 then
		wwlog(self.logTag, "直接打开商城金币购买")
		self:btnClickEvent(self.Panel_Gold)
	elseif self.store_openType == 3 then
		wwlog(self.logTag, "直接打开VIP购买")
		self:btnClickEvent(self.Panel_VIP)
	elseif self.store_openType == 4 then
		wwlog(self.logTag, "直接打开道具购买")
		self:btnClickEvent(self.Panel_Prop)
	else
		wwlog(self.logTag, "直接打开商城默认")
	end
end

function StoreLayer:initLocalText()
	--现在的金币钻石数量
	local gGoldNum, gDiamondNum
	local goldstr = DataCenter:getUserdataInstance():getValueByKey("GameCash") 
	local diamondstr = DataCenter:getUserdataInstance():getValueByKey("Diamond")
	gGoldNum = ToolCom.splitNumFix(tonumber(goldstr))
	gDiamondNum = ToolCom.splitNumFix(tonumber(diamondstr))

	self.Text_gold:setString(gGoldNum)
	self.Text_diamond:setString(gDiamondNum)

	if self.srcCell then
		self.Image_pay_type:loadTexture(StoreCfg.chargeIconPath..self.srcCell.src)
	end
end

function StoreLayer:registerListener()
	local x1,handle1 = StoreCfg.innerEventComponent:addEventListener(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST,handler(self,self.handleProxy))
	local x2,handle2 = StoreCfg.innerEventComponent:addEventListener(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTSECOND,handler(self,self.handleProxy))
	local x3,handle3 = StoreCfg.innerEventComponent:addEventListener(StoreCfg.InnerEvents.STORE_EVENT_PROPLIST,handler(self,self.handleProxy))
	table.insert(self.handles,handle1)
	table.insert(self.handles,handle2)
	table.insert(self.handles,handle3)
	
	--个人信息刷新监听
	self:registerEventListener(COMMON_EVENTS.C_REFLASH_PERSONINFO, handler(self, self.refreshInfo))
end

function StoreLayer:refreshInfo(event)
	local handleType = unpack(event._userdata)
	if handleType == 1 then
		--刷新个人信息区域
		wwlog("刷新商城界面的个人信息")

		local goldstr = ToolCom.splitNumFix(tonumber(DataCenter:getUserdataInstance():getValueByKey("GameCash")))
		local diamondstr = ToolCom.splitNumFix(tonumber(DataCenter:getUserdataInstance():getValueByKey("Diamond")))
		self.Text_gold:setString(goldstr)
		self.Text_diamond:setString(diamondstr)
	elseif handleType == 2 then
		--红点通知
	end
end

--[[
--通信交互handle
--]]
function StoreLayer:handleProxy(event)
	local datas = {}

	if event.name == StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTSECOND then --收到二级菜单数据
		self:getDataFromProxy()
	elseif event.name == StoreCfg.InnerEvents.STORE_EVENT_PROPLIST then --收到物品列表
		self:getDataFromProxy()
	elseif event.name == StoreCfg.InnerEvents.STORE_EVENT_GOLDPROPLIST then --收到金币物品列表
		self:getDataFromProxy()
	else
		if event.name == StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST then
			datas = DataCenter:getData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST)
		elseif event.name == StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST_GOLD then
			datas = DataCenter:getData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST_GOLD)
		end

		if  not self.srcCell then
			self.InitFirstMenuId = datas.Items[1].ItemID  --记录收到数据的第一个根菜单ID，主要做默认计费ID
			wwlog("fuck", self.InitFirstMenuId)
		end
	end
end

--显示刷新金币、钻石的tableview
function StoreLayer:getDataFromProxy()

	if (self.tabSwitchTag == StoreCfg.ShopType.STORE_DIAMOND) 
		or (self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD) then

		wwlog(self.logTag, self.srcCell.cType)

		if (self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD) 
			and (self.srcCell.cType == 0) then
			--金币界面，如果支付方式选择的是钻石
			local datas = StoreProxy:getGoldPropinfos()

			wwlog(self.logTag, "钻石购买金币道具数据")

			self._tableviewNode:reflashView(datas, -1)
		else
			local cType, tmpCrcCell = self:getChargeSrc( self.srcCell )
			self.srcCell = tmpCrcCell
			self.Image_pay_type:loadTexture(StoreCfg.chargeIconPath..tmpCrcCell.src)

			local tmpdatas, isThisChargeShow, oneMenuItemID = StoreProxy:getDatasByChargeType(self:getChargeSrc(self.srcCell), self.tabSwitchTag)

			if isThisChargeShow then
				--默认显示第一个根菜单数据，如果缓存有选择的支付方式，则显示该数据
				wwlog(self.logTag, "切换支付，刷新数据的一级菜单 - "..oneMenuItemID)
				self.FirstMenuId = oneMenuItemID  --存一级菜单的Itemid
				self._tableviewNode:reflashView(tmpdatas, oneMenuItemID)
			end
		end
	elseif self.tabSwitchTag == StoreCfg.ShopType.STORE_PROP then

		local datas = StoreProxy:getSecondMenus(self.tabSwitchTag)

		self._tableviewNode:reflashView(datas)
	end

end

--当前支付方式处理
function StoreLayer:getChargeSrc( typeCell )
	local retCellType = typeCell
	if (self.tabSwitchTag == StoreCfg.ShopType.STORE_DIAMOND) then
		--钻石界面 选择的支付缓存不存在则默认取第一个
		if retCellType.cType == 0 then
			retCellType = StoreCfg.ShopTypeSrc[1]
			--保存切换到钻石的默认支付
			self.srcCell = retCellType
			-- wwdump(self.srcCell, "切换到钻石购买，但是钻石购买")
			ww.WWGameData:getInstance():setIntegerForKey(StoreCfg.ChargeKey, retCellType.cType)
			self.Image_pay_type:loadTexture(StoreCfg.chargeIconPath..retCellType.src)
		end
	end

	return retCellType.cType, retCellType
end

function StoreLayer:addTouchTabMenu()
	self.Panel_Diamond:addClickEventListener(handler(self,self.btnClickEvent))
	self.Panel_VIP:addClickEventListener(handler(self,self.btnClickEvent))
	self.Panel_Gold:addClickEventListener(handler(self,self.btnClickEvent))
	self.Panel_Prop:addClickEventListener(handler(self,self.btnClickEvent))

	self.Button_switch:addClickEventListener(handler(self,self.btnClickSwitch))

end

function StoreLayer:btnClickEvent( sender )
	-- self.Image_choosetag:setPositionX(sender:getPositionX())
	playSoundEffect("sound/effect/anniu")
	local localY = self.Image_choosetag:getPositionY()  --解决工具不对齐的情况
	if self.Image_choosetag:getNumberOfRunningActions() == 0 then
		self.Image_choosetag:runAction(cc.Sequence:create(
			cc.MoveTo:create(0.25,cc.p(sender:getPositionX(), localY))))
		self:tabStatusChange(sender)
	end
end

--打开支付选择
function StoreLayer:btnClickSwitch(sender)
	playSoundEffect("sound/effect/anniu")
	-- local datas
	-- if self.tabSwitchTag == StoreCfg.ShopType.STORE_DIAMOND then
	-- 	datas = DataCenter:getData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST)
	-- elseif self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD then
	-- 	datas = DataCenter:getData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST_GOLD)
	-- end

	-- self.Store_TypeSwitch_node = Store_TypeSwitch:create((datas.Items or {}),
	--  self.tabSwitchTag, handler(self, self.chagrgeSwitchCallBack))
	-- self:addChild(self.Store_TypeSwitch_node, 2)
	UmengManager:eventCount("StoreChargeSwitch")

	self:callSwitchOpen()
end

function StoreLayer:callSwitchOpen(isBuyfailureSwitch)
	local datas
	if self.tabSwitchTag == StoreCfg.ShopType.STORE_DIAMOND then
		datas = DataCenter:getData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST)
	elseif self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD then
		datas = DataCenter:getData(StoreCfg.InnerEvents.STORE_EVENT_SHOPLISTFIRST_GOLD)
	end

	if datas then
		self.Store_TypeSwitch_node = Store_TypeSwitch:create((datas.Items or {}),
		 self.tabSwitchTag, handler(self, self.chagrgeSwitchCallBack), isBuyfailureSwitch)
		self:addChild(self.Store_TypeSwitch_node, 2)
	end

end

--外部监听事件
function StoreLayer:openChargeSwitch(event)
	self:callSwitchOpen(true)
end

function StoreLayer:chagrgeSwitchCallBack(menuid)
	--修改支付内容

	local chargeInfos = StoreProxy:getChargeTypeByMenuID(menuid, self.tabSwitchTag)
	wwdump(chargeInfos, "选择支付方式"..chargeInfos.cType)

	ww.WWGameData:getInstance():setIntegerForKey(StoreCfg.ChargeKey, chargeInfos.cType)

	self.Image_pay_type:loadTexture(StoreCfg.chargeIconPath..chargeInfos.src)

	self.srcCell = chargeInfos
	local cType, tmpCrcCell = self:getChargeSrc( self.srcCell )

	--根据选择的支付方式，刷新列表数据
	self:createTableView()
	self:getDataFromProxy()
end

--tab按钮切换
function StoreLayer:tabStatusChange( sender )

	if self.tabSwitchTag == sender:getName() then
		return
	end
	self.tabSwitchTag = sender:getName()  --必须在刷新页面之前修改，数据根据这个值判断

	self.tableViewBg:removeAllChildren()

	self.Image_switch:setVisible(true)
 
	if sender:getName() == StoreCfg.ShopType.STORE_DIAMOND then
		self:createTableView()
		self:getDataFromProxy()

	elseif sender:getName() == StoreCfg.ShopType.STORE_GOLD then
		self:createTableView()

		--请求金币信息 
		StoreProxy:requestGold()
		StoreProxy:requestGoldPropList()
		self:getDataFromProxy()

	elseif sender:getName() == StoreCfg.ShopType.STORE_VIP then
		self:vipViewChoose()
		--隐藏支付方式切换
		self.Image_switch:setVisible(false)
	elseif sender:getName() == StoreCfg.ShopType.STORE_PROP then
		StoreProxy:requestPropList()
		self:createPropView()
		--隐藏支付方式切换
		self.Image_switch:setVisible(false)
	end
end

function StoreLayer:vipViewChoose()
	self.tableViewBg:removeAllChildren()
	self._tableviewNode = nil

	local bgSize = self.tableViewBg:getContentSize()
	
	local vipSprite = cc.Sprite:createWithSpriteFrameName("store_mm.png")
	vipSprite:setPosition(cc.p(bgSize.width * 0.5, bgSize.height * 0.65))
	self.tableViewBg:addChild(vipSprite)

	local vipLabelSprite = cc.Sprite:createWithSpriteFrameName("store_lock_text.png")
	vipLabelSprite:setPosition(cc.p(vipSprite:getPositionX(), 
		vipSprite:getPositionY() - vipSprite:getContentSize().height * 0.5 - vipLabelSprite:getContentSize().height))
	self.tableViewBg:addChild(vipLabelSprite)
end

return StoreLayer