-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal
-- Date:    2016.09.10
-- Last: 
-- Content:  商品列表tableview
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local Store_Shoplist = class("Store_Shoplist", function()
    return display.newNode()
end)

local ChargeProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().ChargeProxy)
local StoreProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_StoreProxy)

local StoreCfg = require("hall.mediator.cfg.StoreCfg")

local RoomItem = require("csb.hall.store.Node_store_diamond")

local LuaChargeNativeBridge = require('app.utilities.LuaChargeNativeBridge'):create();

local SimpleRichText = require("app.views.uibase.SimpleRichText")

--bgNode 父节点  shopType 支付数据类型
function Store_Shoplist:ctor(bgNode ,shopType)
	self.tableViewBg = bgNode
	self._shopType = shopType
	self._firstMenuID = 0   -- == -1情况下是钻石支付
	self._shopdatas = {}

	self:init()
end

function Store_Shoplist:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)

	self:initView()
end 

function Store_Shoplist:initView()
	if self._chooseType then
		--支付选择
	else
		--默认支付选择
	end

	local tableView = cc.TableView:create(self.tableViewBg:getContentSize())
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

	tableView:setContentSize(cc.size(self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height * 0.8))
	tableView:setPosition(cc.p(10, 1))
	tableView:setDelegate()
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.tableViewBg:addChild(tableView)
	--registerScriptHandler functions must be before the reloadData funtion
	tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
	tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
	tableView:registerScriptHandler(handler(self, self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
	tableView:registerScriptHandler(handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(handler(self, self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(handler(self, self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
	tableView:reloadData()

	self._tableView = tableView

end

function Store_Shoplist:scrollViewDidScroll(view)
    -- print("scrollViewDidScroll")
end

function Store_Shoplist:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function Store_Shoplist:tableCellTouched(table,cell)
    -- print("cell touched at index: " .. cell:getIdx())
end

function Store_Shoplist:cellSizeForTable(table,idx) 
    return self.tableViewBg:getContentSize().width, 180
end

function Store_Shoplist:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()

    local cellData 
    if self._firstMenuID == -1 then --后期区分用
		-- wwdump(self._shopdatas)
		cellData = self._shopdatas[idx + 1]
	else
    	cellData = self._shopdatas[idx + 1]
    end

	local item = nil
    if nil == cell then
        cell = cc.TableViewCell:new()

        item = self:createItem(nil, idx, cellData)
        cell:addChild(item)
    else
    	--复用Cell字段内容 TODO
        item = cell:getChildByName("Node")
		item:getChildByName("Image_bg"):setTag(idx)

		self:createItem(item, idx, cellData)
    end

    return cell
end

function Store_Shoplist:createItem(node, idx, cellData)
	-- local item = RoomItem:create().root
	local item
	if node then
		item = node
	else
		item = RoomItem:create().root
	end

	local bg = item:getChildByName("Image_bg")
	bg:setSwallowTouches(false)

	item:setContentSize(bg:getContentSize())

	local isDiamondGold = false
	if self._firstMenuID == -1 then
		isDiamondGold = true
	end

	local Image_icon = ccui.Helper:seekWidgetByName(bg,"Image_icon")
	-- local Image_icon_1 = ccui.Helper:seekWidgetByName(bg,"Image_icon_1")
	local Text_number = ccui.Helper:seekWidgetByName(bg,"Text_number")
	local Text_DonateCash = ccui.Helper:seekWidgetByName(bg,"Text_DonateCash")
	local Cash = isDiamondGold and cellData.magicCount or cellData.Cash

	Text_number:setString(ToolCom.splitNumFix(Cash)  or "")
	local nDonateCash = isDiamondGold and cellData.marketMoney or cellData.DonateCash
	--加赠百分比
	-- Text_DonateCash:setString((nDonateCash == 0) and "" or ToolCom.splitNumFix(nDonateCash))
	-- wwdump(cellData)

	local Image_buy = ccui.Helper:seekWidgetByName(bg,"Image_buy")

	local Text_buy = ccui.Helper:seekWidgetByName(Image_buy,"Text_buy")
	local Image_diamond = ccui.Helper:seekWidgetByName(Image_buy,"Image_diamond")
	local moneyStr
	if isDiamondGold then
		-- moneyStr = cellData.Money.."钻石"
		-- moneyStr = ToolCom.splitNumFix(cellData.Money)

		local richtextStr = string.format(i18n:get("str_store", "showBtnRich1"),
			"common/common_gold_50.png", tonumber(cellData.Money))

		if Image_buy:getChildByTag(100) then
			Image_buy:getChildByTag(100):removeFromParent()
		end

		local btnRichtext = SimpleRichText:create(richtextStr,40,cc.c3b(255,255,255))
		btnRichtext:setAnchorPoint(cc.p(0.5,0.5))
		btnRichtext:setPosition(cc.p(Image_buy:getContentSize().width * 0.5,Image_buy:getContentSize().height * 0.5))
		
		Image_buy:addChild(btnRichtext, 1, 100)

		Text_buy:setVisible(false)
		Image_diamond:setVisible(false)		
	else
		-- moneyStr = cellData.Money/100 .. "元"
		Image_diamond:setVisible(false)
		Text_buy:setAnchorPoint(0.5, 0.5)
		Text_buy:setPositionX(Image_buy:getContentSize().width * 0.5)
		moneyStr = ToolCom.splitNumFix(cellData.Money/100) .. "元"		
	end
	Text_buy:setString(moneyStr)

	local otherGetStr 

	if isDiamondGold then
		--如果是购买金币
		Image_icon:loadTexture("common/common_gold_154.png")
		if nDonateCash == 0 then
			otherGetStr = ""
		else
			-- otherGetStr = i18n:get('str_store', 'store_otherGet')..string.format("%0.2f", (nDonateCash/(Cash - nDonateCash) * 100)) .. '%'
			otherGetStr = i18n:get('str_store', 'store_otherGet')..(nDonateCash/(Cash - nDonateCash) * 100) .. '%'
		end
	else
		if self._shopType == StoreCfg.ShopType.STORE_DIAMOND then
		else
			Image_icon:loadTexture("common/common_gold_154.png")
		end
		if nDonateCash == 0 then
			otherGetStr = ""
		else
			-- otherGetStr = i18n:get('str_store', 'store_otherGet')..string.format("%0.2f", (nDonateCash/Cash * 100)) .. '%'
			otherGetStr = i18n:get('str_store', 'store_otherGet')..(nDonateCash/Cash * 100) .. '%'
		end
	end

	Text_DonateCash:setString(otherGetStr)

	
	item:setPositionX(bg:getContentSize().width/2)
	item:setPositionY(bg:getContentSize().height/2)
	--img:setTouchEnabled(false)
	Image_buy:addTouchEventListener(handler(self, self.touchEventListener))
	Image_buy:setTag(idx) --方便点击的时候计算位置

	if not node then
	   return item
	end
end

function Store_Shoplist:numberOfCellsInTableView(table)
   return #self._shopdatas
end

function Store_Shoplist:touchEventListener(sender, eventType)
	if not sender or self._tableView:isTouchMoved() then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then

		self:calmDown(sender)

		playSoundEffect("sound/effect/anniu")
		local cellIndex = sender:getTag() + 1

		local tCellData = self._shopdatas[cellIndex]

		--调用支付流程
		local unitInfo
		if self._firstMenuID == -1 then
			self:callDiamondByGold(tCellData)
			unitInfo = i18n:get("str_common", "diamond")
		else
			wwdump(tCellData, cellIndex)
			self:callChargeLogic(cellIndex, tCellData)
			unitInfo = i18n:get("str_common", "yuan")
		end
		StoreProxy:setBuycellDatas(tCellData, unitInfo)   --记录购买的数据,顺便记录下支付方式

	end

end

--按钮连续点击屏蔽
--n秒内只允许一次点击
function Store_Shoplist:calmDown(node)
	local stepFunc1 =
	 function()
		node:setTouchEnabled(false)
	end
	local stepFunc2 = function()
		node:setTouchEnabled(true)
		wwlog("retouch")
	end
	node:runAction(cc.Sequence:create(cc.CallFunc:create(stepFunc1),
		cc.DelayTime:create(1.0), 
		cc.CallFunc:create(stepFunc2) 
		))

end

function Store_Shoplist:reflashView(shopdatas, firstMenuID, confirms)


	self._firstMenuID = firstMenuID
    if firstMenuID == -1 then
		if next(shopdatas) then
			self._shopdatas = shopdatas.StoreInfos[1] or {}
			-- wwdump(self._shopdatas)
		end
	else
		self._shopdatas = shopdatas or {}
		-- wwdump(shopdatas, firstMenuID)
    end

    -- wwdump(shopdatas, "商品信息")

	self._tableView:reloadData()
end

--[[
--调用支付流程
--]]
function Store_Shoplist:callChargeLogic( cellIndex, cellData )

	--请求订单信息
	-- wwdump(StoreProxy:getSecondMenus(self._shopType), self._firstMenuID)
	local chargeDatas = StoreProxy:getSecondMenus(self._shopType)[self._firstMenuID]

	-- wwdump(chargeDatas, self._firstMenuID)

	local sceneID = StoreProxy.buySceneID
	if self._shopType == StoreCfg.ShopType.STORE_DIAMOND then
		sceneID = sceneID..wwConfigData.CHARGE_STATUE_DIAMOND_END
	else
		sceneID = sceneID..wwConfigData.CHARGE_STATUE_GOLD_END
	end
	wwlog("商品列表SceneID", sceneID)

	UmengManager:eventCount("ChargeStep1")

	local needConfirm = chargeDatas.Confirms[cellIndex].Confirm

	if needConfirm == 3 then
		local Money = chargeDatas.Money

		local function dialogOk()
			--调用购买流程
			ChargeProxy:requestOrder(chargeDatas, cellIndex, sceneID)
		end

		local function dialogCance()
		end

		local bugWord
		if self._shopType == StoreCfg.ShopType.STORE_DIAMOND then
			bugWord = i18n:get("str_common", "diamond")
		else
			bugWord = i18n:get("str_common", "gold")
		end

		local para = {}
		para.leftBtnlabel = i18n:get("str_common", "comm_cancel")
		para.rightBtnlabel = i18n:get("str_common", "comm_sure")
		para.leftBtnCallback = dialogCance
		para.rightBtnCallback = dialogOk
		para.showclose = false  --是否显示关闭按钮
		para.content = string.format(i18n:get("str_store", "store_charge_confirm2")
			, chargeDatas.Items[cellIndex].Money/100, chargeDatas.Items[cellIndex].Cash..bugWord)

		import(".CommonDialog", "app.views.customwidget."):create( para ):show()
	else
		ChargeProxy:requestOrder(chargeDatas, cellIndex, sceneID)
	end

end

--调用钻石购买金币
function Store_Shoplist:callDiamondByGold(cellData)
	wwlog("点击钻石购买金币", cellIndex)

	local Name = cellData.Name
	local Money = cellData.Money
	local Count = cellData.magicCount

	local function dialogOk()
		--调用购买流程
		StoreProxy:requestBuyProp(cellData, wwConfigData.CHARGE_STORE_GOLD)
	end

	local function dialogCance()
	end

	local para = {}
	para.leftBtnlabel = i18n:get("str_common", "comm_cancel")
	para.rightBtnlabel = i18n:get("str_common", "comm_sure")
	para.leftBtnCallback = dialogCance
	para.rightBtnCallback = dialogOk
	para.showclose = false  --是否显示关闭按钮
	para.content = string.format(i18n:get("str_store", "store_prop_confirm"), 
					Money, Name,Count)

	import(".CommonDialog", "app.views.customwidget."):create( para ):show()

end

return Store_Shoplist