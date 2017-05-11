-------------------------------------------------------------------------
-- Desc:    地方棋牌
-- Author:  diyal
-- Date:    2016.09.10
-- Last: 
-- Content:  选择支付方式
-- Copyright (c) wawagame Entertainment All right reserved.
--------------------------------------------------------------------------

local Store_TypeSwitch = class("Store_TypeSwitch",require("app.views.uibase.PopWindowBase"))

local StoreProxy = ProxyMgr:retrieveProxy(ProxyMgr:getProxyRegistry().HALL_StoreProxy)

local RoomItem = require("csb.hall.store.Node_store_choose")

local StoreCfg = require("hall.mediator.cfg.StoreCfg")

local GOODS_VIEWS = 
{
    {
        n="goodsbg",  
        t="sp", 
        x=ww.px(520), y=ww.py(790),
        od=1, 
        res="#store_pay_style_titlebg.png" 
    },
    {
        n="goodsline",  
        t="sp", 
        x=ww.px(520), y=ww.py(690),
        od=1, 
        -- parent="btn_hall_gold",
        res="#store_seg_line_content.png" 
    },
    {
        n="txt_shoptag", 
        t="txt", 
        x=ww.px(86), y=ww.py(68), 
        arc={0, 0.5}, 
        od=1, 
        align = cc.TEXT_ALIGNMENT_LEFT,
        color=ConvertHex2RGBTab('262f2a'),
        rect={120},
        size=42,
        parent="goodsbg",
        txt="商品:"
    },
    {
        n="txt_amount", 
        t="txt", 
        x=ww.px(184), y=ww.py(68), 
        arc={0, 0.5}, 
        od=1, 
        align = cc.TEXT_ALIGNMENT_LEFT,
        color=ConvertHex2RGBTab('262f2a'),
        rect={300},
        size=42,
        parent="goodsbg",
        txt=""
    },
    {
        n="txt_pricetag", 
        t="txt", 
        x=ww.px(600), y=ww.py(68), 
        arc={0, 0.5}, 
        od=1, 
        align = cc.TEXT_ALIGNMENT_LEFT,
        color=ConvertHex2RGBTab('262f2a'),
        rect={120},
        size=42,
        parent="goodsbg",
        txt="价格:"
    },
    {
        n="txt_price", 
        t="txt", 
        x=ww.px(710), y=ww.py(68), 
        arc={0, 0.5}, 
        od=1, 
        align = cc.TEXT_ALIGNMENT_LEFT,
        color=ConvertHex2RGBTab('262f2a'),
        rect={300},
        size=42,
        parent="goodsbg",
        txt=""
    },
}


function Store_TypeSwitch:ctor(datas, parentTabSwitchTag, callBack, openAsBuy)
	Store_TypeSwitch.super.ctor(self)
	self._chargeData = clone(datas) or {}

	self.tabSwitchTag = parentTabSwitchTag
	self._callBack = callBack

	self._openAsBuy = openAsBuy

	if self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD then
		-- wwdump(self._chargeData)
		self:addDiamondData(self._chargeData)
	end
	
	self:init()
end

function Store_TypeSwitch:init()
	
	self:registerScriptHandler(function (event)
		if event=="enter" then
			self:onEnter()
		elseif event=="exit" then
			self:onExit()
		end
	end)
	
	local Typenode = require("csb.hall.store.StoreLayer_type"):create().root
	FixUIUtils.setRootNodewithFIXED(Typenode)
	self:addChild(Typenode)

	self.imgId = Typenode:getChildByName("Image_bg")
	FixUIUtils.stretchUI(self.imgId)
	
	self.tableViewBg = ccui.Helper:seekWidgetByName(self.imgId,"Image_content")

	local srcCell = StoreProxy:getChooseChargeTypeSrc()
	self.localChargeType = srcCell.cType

	self:popIn(self.imgId,Pop_Dir.Right)

	self:initView()

end 

function Store_TypeSwitch:initView()
	if self._chooseType then
		--支付选择
	else
		--默认支付选择
	end

	local tableViewSize = self.tableViewBg:getContentSize()
	if self._openAsBuy then
		tableViewSize = ww.size(tableViewSize.width, tableViewSize.height * 0.76 / ww.scaleY)

		local budDatas, buyUnit = StoreProxy:getBuycellDatas()
		wwdump(budDatas, "购买数量")

		self.uis = UIFactory:createLayoutNode(GOODS_VIEWS, self.tableViewBg, pathflag)
        self.uis.txt_shoptag:centerY(self.uis.goodsbg):offsetY(5)
        self.uis.txt_pricetag:centerY(self.uis.goodsbg):offsetY(5)
        self.uis.txt_amount:centerY(self.uis.goodsbg):offsetY(5)
        self.uis.txt_price:centerY(self.uis.goodsbg):offsetY(5)

		-- self.uis["goodsbg"]:setPositionX(self.tableViewBg:getContentSize().width * 0.5)
		
		if budDatas.magicCount then
			self.uis["txt_amount"]:setString((ToolCom.splitNumFix(budDatas.magicCount)  or "0")..budDatas.Name)
		else
			self.uis["txt_amount"]:setString(budDatas.Name)
		end

		local priceTxtStr
		if self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD then
			priceTxtStr = tonumber(budDatas.Money) / 10
		else
			priceTxtStr = tonumber(budDatas.Money) / 100
		end
		priceTxtStr = priceTxtStr..i18n:get("str_common", "yuan")
		self.uis["txt_price"]:setString(priceTxtStr)

	end

	local tableView = cc.TableView:create(tableViewSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

	-- tableView:setContentSize(cc.size(self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height * 0.8))
	tableView:setDelegate()
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.tableViewBg:addChild(tableView)
	tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0, 0))
	tableView:setPosition(cc.p(0, 0))
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

--获取行数
function Store_TypeSwitch:getItemRowNum()
	local rowNum
	if #self._chargeData > 2 then
		rowNum = #self._chargeData / 2 + 1
	else
		rowNum = 1
	end
	return rowNum
end

function Store_TypeSwitch:scrollViewDidScroll(view)
--    print("scrollViewDidScroll")
end

function Store_TypeSwitch:scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function Store_TypeSwitch:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function Store_TypeSwitch:cellSizeForTable(table,idx) 
    return self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height / 4
end

function Store_TypeSwitch:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local item = nil
    -- if nil == cell then
        cell = cc.TableViewCell:new()
        cell:setContentSize(self.tableViewBg:getContentSize().width, self.tableViewBg:getContentSize().height / 4)

        local nowCell = idx + 1
        local nowLefttCell, nowRightCell = (nowCell * 2 -1), (nowCell * 2)
        -- wwdump(self._chargeData, nowLefttCell .. " - " .. nowRightCell .. " - " .. #self._chargeData)

        item = self:createItem(nowLefttCell, false)
        cell:addChild(item)
        item:setPositionX(cell:getContentSize().width * (1/4))
        item:setPositionY(cell:getContentSize().height/2)

        if nowRightCell <= #self._chargeData then
        	wwlog("创建右边", nowCell.. " - " .. nowRightCell)
        	--创建右边Item
        	item = self:createItem(nowRightCell, true)
        	cell:addChild(item)
        	item:setPositionX(cell:getContentSize().width * (3/4))
        	item:setPositionY(cell:getContentSize().height/2)
        end
  --   else
  --       item = cell:getChildByName("Node")
		-- item:getChildByName("Image_bg"):setTag(idx)
  --   end

    return cell
end

function Store_TypeSwitch:createItem(tableIndex, positionRight)
	local item = RoomItem:create().root

	local bg = item:getChildByName("Image_bg")
	bg:setSwallowTouches(false)

	local cellData = self._chargeData[tableIndex]
	wwdump(cellData, tableIndex)
	local chargeInfos = StoreProxy:getChargeTypeByMenuID(cellData.ItemID, self.tabSwitchTag)

	if self.localChargeType == chargeInfos.cType then
		ccui.Helper:seekWidgetByName(bg,"Image_tag"):setVisible(true)
	else
		ccui.Helper:seekWidgetByName(bg,"Image_tag"):setVisible(false)
	end

	--img:setTouchEnabled(false)
	bg:addTouchEventListener(handler(self, self.touchEventListener))
	bg:setTag(tableIndex) --方便点击的时候计算位置

	local Text_content = ccui.Helper:seekWidgetByName(bg,"Text_content")
	local Image_icon = ccui.Helper:seekWidgetByName(bg,"Image_icon")


	local srcInfo

	if self.tabSwitchTag == StoreCfg.ShopType.STORE_OTHER then
		--外部调用的时候
		local srcInfo = StoreProxy:getChargeTypeByCashTpye(cellData.ChargeType)
		wwdump(srcInfo, "srcInfosrcInfosrcInfosrcInfosrcInfo")
		Image_icon:loadTexture(StoreCfg.chargeIconPath..srcInfo.srcType)

		Text_content:setString(srcInfo.Name)

	else
		srcInfo = StoreProxy:getChargeTypeByMenuID(cellData.ItemID, self.tabSwitchTag)
		local filePath = StoreCfg.chargeIconPath..srcInfo.srcType
		local isExist = cc.FileUtils:getInstance():isFileExist(filePath)
		if isExist then
			Image_icon:loadTexture(filePath)
		end
		Text_content:setString(cellData.Name)

	end
	wwdump(srcInfo)


	return item
end

function Store_TypeSwitch:numberOfCellsInTableView(table)
   return math.ceil(#self._chargeData/StoreCfg.maxCountEveryRow)
end

function Store_TypeSwitch:touchEventListener(sender, eventType)
	if not sender or self._tableView:isTouchMoved() then
		return
	end
	
	if eventType==ccui.TouchEventType.ended then
		playSoundEffect("sound/effect/anniu")
		local x = sender:getTag() 
		local cellData = self._chargeData[x]

		UmengManager:eventCount2("ClickSwitchType", cellData.Name)

		if self.tabSwitchTag == StoreCfg.ShopType.STORE_OTHER then
			self._callBack(x) --回调 传参 选中数据index
		else
			self._callBack(cellData.ItemID) --回调
		end
		if isLuaNodeValid(self) then
			self:close()
		end
		self = nil
	end
end

function Store_TypeSwitch:reflashView(chargeData)
	self._chargeData = clone(chargeData)

	if self.tabSwitchTag == StoreCfg.ShopType.STORE_GOLD then
		wwdump(self._chargeData)
		self:addDiamondData(self._chargeData)
	end

	self._tableView:reloadData()
end

function Store_TypeSwitch:addDiamondData()
	local diamondData = {
			["Cash"]        = 0,
			["CashTpye"]    = 0,
			["ChargeCmd"]   = "",
			["ChargeType"]  = 0,
			["Description1"]= "",
			["Description2"]= "",
			["Description3"]= "",
			["DonateCash"]  = 0,
			["Hot"]         = 0,
			["Icon"]        = "",
			["ItemID"]      = 0,
			["MenuData"]    = "",
			["MenuFlag"]    = 0,
			["MenuKey"]     = "",
			["Money"]       = 0,
			["Name"]        = "钻石支付",
			["SP"]          = 0,
			["SPServiceID"] = 0,
			["ToUser"]      = 0,
	}

	table.insert(self._chargeData, diamondData)
end

return Store_TypeSwitch